package com.ehgsmartwellness.app

import android.annotation.SuppressLint
import android.app.Activity
import android.app.Application
import android.Manifest
import android.bluetooth.*
import android.bluetooth.le.*
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.location.LocationManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.ParcelUuid
import android.os.Vibrator
import android.os.VibratorManager
import android.os.VibrationEffect
import android.util.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.*

@SuppressLint("MissingPermission")
class EHGBandAndroidPlugin(private val activity: Activity, messenger: BinaryMessenger) :
    MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    private val context: Context get() = activity.applicationContext
    private val methodChannel = MethodChannel(messenger, "com.ehg.smartapp/band")
    private val eventChannel = EventChannel(messenger, "com.ehg.smartapp/band_events")
    private val backgroundChannel = MethodChannel(messenger, "com.ehg.smartapp/background_sync")

    private var eventSink: EventChannel.EventSink? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    private val bluetoothManager by lazy {
        activity.getSystemService(Context.BLUETOOTH_SERVICE) as? BluetoothManager
    }
    private val bluetoothAdapter: BluetoothAdapter? get() = bluetoothManager?.adapter
    private var bluetoothLeScanner: BluetoothLeScanner? = null

    private var connectedGatt: BluetoothGatt? = null
    private var connectedDevice: BluetoothDevice? = null
    private var isScanning = false
    private val discoveredDevices = mutableMapOf<String, Map<String, Any>>()

    private var currentBatteryPercentage: Int? = null
    private var batteryCharacteristic: BluetoothGattCharacteristic? = null
    private var heartRateCharacteristic: BluetoothGattCharacteristic? = null
    private var qcTxCharacteristic: BluetoothGattCharacteristic? = null
    private var qcRxCharacteristic: BluetoothGattCharacteristic? = null
    private var qcTx2Characteristic: BluetoothGattCharacteristic? = null
    private var qcRx2Characteristic: BluetoothGattCharacteristic? = null
    private var hasSentConnectionVibration = false
    private var pendingBatteryResult: MethodChannel.Result? = null
    private var pendingConnectResult: MethodChannel.Result? = null
    private val prefs by lazy { activity.getSharedPreferences("ehg_band_prefs", Context.MODE_PRIVATE) }

    // Real-time heart rate & PPG LED activation state
    private var isLiveHeartRateActive = false
    private var realtimeHrHoldRunnable: Runnable? = null
    private var stepPollRunnable: Runnable? = null
    private var activeMeasuringType: String? = null
    private var measuringTimeoutRunnable: Runnable? = null

    // Cached vitals from GATT packets
    private var lastKnownSteps: Int = 0
    private var lastKnownCalories: Int = 0
    private var lastKnownDistance: Int = 0
    private var lastKnownSbp: Int = 0
    private var lastKnownDbp: Int = 0
    private var lastKnownSleepMinutes: Int = 0
    private var lastKnownDeepSleepMinutes: Int = 0
    private var lastKnownBloodOxygen: Double = 0.0
    private var lastKnownSkinTemperature: Double = 0.0
    private var lastKnownStressLevel: Int = 0
    private var lastKnownHrvMs: Int = 0
    private var lastKnownRestingHeartRate: Int = 0
    private val lastKnownSleepPhases = Collections.synchronizedList(mutableListOf<Map<String, Any>>())
    private val lastKnownHeartRateHistory = Collections.synchronizedList(mutableListOf<Map<String, Any>>())

    // ─── Health Data Synchronization Coordination (Sequential State Machine) ───
    private data class SyncStep(val id: String, val cmdHex: String, val responseCmds: Set<Int>, val timeoutMs: Long = 1500L)

    private fun getActiveSyncSteps(): List<SyncStep> {
        val cal = Calendar.getInstance()
        val year = cal.get(Calendar.YEAR) % 100
        val month = cal.get(Calendar.MONTH) + 1
        val day = cal.get(Calendar.DAY_OF_MONTH)

        // Today midnight unix timestamp in LOCAL seconds since epoch (matches iOS OdmBandGetSchedualHeartRateData):
        // [midnightDate timeIntervalSince1970] + [NSTimeZone systemTimeZone].secondsFromGMT;
        // Hardware band RTC operates in local time and expects a 4-byte LITTLE-ENDIAN hex string.
        val midnightCal = Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }
        val tzOffsetSec = TimeZone.getDefault().getOffset(System.currentTimeMillis()) / 1000
        val localMidnightSec = (midnightCal.timeInMillis / 1000) + tzOffsetSec

        val b0 = (localMidnightSec and 0xFF).toInt()
        val b1 = ((localMidnightSec shr 8) and 0xFF).toInt()
        val b2 = ((localMidnightSec shr 16) and 0xFF).toInt()
        val b3 = ((localMidnightSec shr 24) and 0xFF).toInt()
        val hrCmdHex = "15%02X%02X%02X%02X".format(b0, b1, b2, b3)
        val sleepCmdHex = "44%02X%02X%02X00".format(year, month, day)

        // Manual BP command with timestamp 0 to fetch recent manual BP records (matches iOS OdmBandGetManualBloodPressureHistoryData)
        // iOS SDK: 14%@00%02X -> [0x14, 4-byte little-endian timestamp (00000000), 0x00, count (0x32 = 50)]
        val bpManualCmdHex = "14000000000032"

        // DFU SpO2 query with today midnight timestamp (matches iOS QCBloodOxygenList / QCDFU_Utils)
        // BC 2A 01 00 CRC16(BF40) dayIndex(00)
        val dfuSpo2Cmd = "BC2A0100BF4000"

        // 1. "48"  -> OdmBandGetCurrentSportInfo (summary steps, calories, distance)
        // 2. "03"  -> OdmBandReadBattery (battery percentage, charging state)
        // 3. "15"  -> OdmBandGetSchedualHeartRateData (24h continuous 5-min HR samples & resting HR)
        // 4. "14.."-> OdmBandGetManualBloodPressureHistoryData (latest manual/calibrated BP reading)
        // 5. "0D00"-> OdmBandGetBPHistoryData Stage 0 (systolic BP)
        // 6. "0E00"-> OdmBandGetBPHistoryData Stage 1 (diastolic BP)
        // 7. "BC2A"-> QCDFU_Utils / QCBloodOxygenList DFU query (SpO2 long packet - primary)
        // 8. "2A00"-> QCBloodOxygenList / OdmBandSchedualBloodOxgyenInfo (SpO2 standard fallback)
        // 9. "3700"-> QCGetScheualStressData (stress 1..100)
        // 10."3900"-> QCGetScheualHRVDataCmd (HRV in ms)
        // 11."44"  -> OdmBandGetSleepDetailInfo (total sleep, deep sleep, sleep phases)
        // 12."2500"-> QCSchedualTemperatureList (skin temperature - NOT 08 which is shutdown!)
        return listOf(
            SyncStep("sport", "48", setOf(0x48, 0xC8, 0x02, 0x82)),
            SyncStep("battery", "03", setOf(0x03, 0x83)),
            SyncStep("heartRate", hrCmdHex, setOf(0x15, 0x95, 0x05, 0x85), timeoutMs = 3000L),
            SyncStep("bpManual", bpManualCmdHex, setOf(0x14, 0x94), timeoutMs = 2500L),
            SyncStep("bpSystolic", "0D00", setOf(0x0D, 0x8D), timeoutMs = 3000L),
            SyncStep("bpDiastolic", "0E00", setOf(0x0E, 0x8E), timeoutMs = 3000L),
            SyncStep("oxygenDfu", dfuSpo2Cmd, setOf(0xBC), timeoutMs = 3500L),
            SyncStep("oxygen", "2A00", setOf(0x2A, 0xAA, 0x2C, 0xAC, 0x06, 0x86), timeoutMs = 2500L),
            SyncStep("stress", "3700", setOf(0x37, 0xB7)),
            SyncStep("hrv", "3900", setOf(0x39, 0xB9), timeoutMs = 3000L),
            SyncStep("sleep", sleepCmdHex, setOf(0x44, 0xC4, 0x04, 0x84), timeoutMs = 2500L),
            SyncStep("temperature", "2500", setOf(0x25, 0xA5))
        )
    }

    private var activeSyncSteps: List<SyncStep> = emptyList()

    private var isSyncInProgress = false
    private var currentSyncStepIndex = 0
    private var syncStepTimeoutRunnable: Runnable? = null
    private var syncMasterTimeoutRunnable: Runnable? = null
    private val pendingSyncResults = Collections.synchronizedList(mutableListOf<MethodChannel.Result>())
    private var syncAdvanceDebounceRunnable: Runnable? = null
    private var syncAdvanceRunnable: Runnable? = null
    private var hasEmittedConnected = false

    private fun triggerMinorVibration() {
        try {
            // 1. Phone minor haptic vibration on connect (matching iOS haptic experience)
            val vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                val vibratorManager = activity.getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as? VibratorManager
                vibratorManager?.defaultVibrator
            } else {
                @Suppress("DEPRECATION")
                activity.getSystemService(Context.VIBRATOR_SERVICE) as? Vibrator
            }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                vibrator?.vibrate(VibrationEffect.createOneShot(80L, VibrationEffect.DEFAULT_AMPLITUDE))
            } else {
                @Suppress("DEPRECATION")
                vibrator?.vibrate(80L)
            }
            Log.i(TAG, "Triggered phone minor haptic vibration on connect")
        } catch (e: Exception) {
            Log.w(TAG, "Could not trigger phone vibration: ${e.message}")
        }

        // 2. Also ensure band confirms connection with single minor vibration (QC alertBindingSuccess 0x10)
        try {
            if (!hasSentConnectionVibration && qcTxCharacteristic != null) {
                val packet = buildQcPacket("10")
                writeQcPacketDirect(packet)
                hasSentConnectionVibration = true
                Log.i(TAG, "Triggered band connection vibration (0x10)")
            }
        } catch (e: Exception) {
            Log.w(TAG, "Could not trigger band vibration: ${e.message}")
        }
    }

    private fun notifyConnectedState() {
        if (hasEmittedConnected) return
        hasEmittedConnected = true
        val devName = connectedDevice?.name ?: "EHG Smart Band"
        val devId = connectedDevice?.address ?: ""
        Log.i(TAG, "Notifying Flutter: Band successfully connected and ready: $devName ($devId)")

        triggerMinorVibration()

        sendEvent(mapOf(
            "type" to "connection_state",
            "state" to "connected",
            "name" to devName,
            "id" to devId,
            "mac" to devId
        ))
        pendingConnectResult?.success(true)
        pendingConnectResult = null
        startStepPolling()
    }

    private fun buildCachedSyncMap(): Map<String, Any> {
        val sbp = if (lastKnownSbp > 0) lastKnownSbp else prefs.getInt("last_known_sbp", 0)
        val dbp = if (lastKnownDbp > 0) lastKnownDbp else prefs.getInt("last_known_dbp", 0)
        val steps = if (lastKnownSteps > 0) lastKnownSteps else prefs.getInt("last_known_steps", 0)
        val calories = if (lastKnownCalories > 0) lastKnownCalories else prefs.getInt("last_known_calories", 0)
        val distance = if (lastKnownDistance > 0) lastKnownDistance else prefs.getInt("last_known_distance", 0)
        val sleepMins = if (lastKnownSleepMinutes > 0) lastKnownSleepMinutes else prefs.getInt("last_known_sleep_minutes", 0)
        val deepSleepMins = if (lastKnownDeepSleepMinutes > 0) lastKnownDeepSleepMinutes else prefs.getInt("last_known_deep_sleep_minutes", 0)
        val spo2 = if (lastKnownBloodOxygen > 0.0) lastKnownBloodOxygen else prefs.getFloat("last_known_spo2", 0f).toDouble()
        val temp = if (lastKnownSkinTemperature > 0.0) lastKnownSkinTemperature else prefs.getFloat("last_known_temp", 0f).toDouble()
        val stress = if (lastKnownStressLevel > 0) lastKnownStressLevel else prefs.getInt("last_known_stress", 0)
        val hrv = if (lastKnownHrvMs > 0) lastKnownHrvMs else prefs.getInt("last_known_hrv", 0)
        val restingHr = if (lastKnownRestingHeartRate > 0) lastKnownRestingHeartRate else prefs.getInt("last_known_resting_hr", 0)

        return mutableMapOf(
            "steps" to steps,
            "calories" to calories,
            "distance" to distance,
            "sleepMinutes" to sleepMins,
            "deepSleepMinutes" to deepSleepMins,
            "bloodOxygen" to spo2,
            "systolicBP" to sbp,
            "diastolicBP" to dbp,
            "skinTemperature" to temp,
            "stressLevel" to stress,
            "hrvMs" to hrv,
            "restingHeartRate" to restingHr,
            "sleepPhases" to ArrayList(lastKnownSleepPhases),
            "heartRateHistory" to ArrayList(lastKnownHeartRateHistory)
        )
    }

    private var syncDrainRetries = 0

    private fun scheduleSyncAdvanceDebounce(cmd: Int, delayMs: Long = 350L) {
        syncAdvanceDebounceRunnable?.let { mainHandler.removeCallbacks(it) }
        val r = Runnable {
            syncAdvanceDebounceRunnable = null
            onSyncPacketReceived(cmd)
        }
        syncAdvanceDebounceRunnable = r
        mainHandler.postDelayed(r, delayMs)
    }

    private fun startSequentialHealthSync(result: MethodChannel.Result) {
        if (connectedGatt == null || !isDeviceConnected) {
            Log.w(TAG, "startSequentialHealthSync: Band not connected. Returning cached health metrics immediately.")
            result.success(buildCachedSyncMap())
            return
        }

        pendingSyncResults.add(result)

        if (isSyncInProgress) {
            Log.i(TAG, "startSequentialHealthSync: Sync already in progress, registered caller to receive full fresh payload.")
            return
        }

        // Safety guard: if the GATT queue still has pending init pipeline operations,
        // wait for them to drain before starting the sync. This prevents interleaving
        // sync commands with init commands.
        if (gattBusy || gattQueue.isNotEmpty()) {
            if (syncDrainRetries < 10) {
                syncDrainRetries++
                Log.i(TAG, "startSequentialHealthSync: GATT queue still busy (queueSize=${gattQueue.size}, busy=$gattBusy). " +
                        "Waiting 500ms for init pipeline to drain (retry $syncDrainRetries/10)...")
                mainHandler.postDelayed({
                    if (isDeviceConnected && !isSyncInProgress) {
                        startSequentialHealthSyncInternal()
                    }
                }, 500L)
                return
            } else {
                Log.w(TAG, "startSequentialHealthSync: GATT queue drain retries exhausted. Proceeding with sync anyway.")
            }
        }
        syncDrainRetries = 0
        startSequentialHealthSyncInternal()
    }

    private fun startSequentialHealthSyncInternal() {
        if (isSyncInProgress || connectedGatt == null || !isDeviceConnected) return
        activeSyncSteps = getActiveSyncSteps()
        isSyncInProgress = true
        currentSyncStepIndex = 0

        // 30-second master watchdog: if band communication drops completely, return best-effort cached data
        // Increased from 20s to 30s to accommodate longer per-step timeouts for multi-packet BP/SpO2/HRV queries
        syncMasterTimeoutRunnable?.let { mainHandler.removeCallbacks(it) }
        val masterTimeout = Runnable {
            Log.w(TAG, "Sequential sync: Master 30s watchdog expired. Finishing with accumulated metrics.")
            finishSequentialSync()
        }
        syncMasterTimeoutRunnable = masterTimeout
        mainHandler.postDelayed(masterTimeout, 30_000L)

        Log.i(TAG, "startSequentialHealthSync: Starting sequential health data sync (${activeSyncSteps.size} steps)...")
        executeCurrentSyncStep()
    }

    private fun executeCurrentSyncStep() {
        if (!isSyncInProgress || connectedGatt == null) {
            finishSequentialSync()
            return
        }

        if (currentSyncStepIndex >= activeSyncSteps.size) {
            Log.i(TAG, "Sequential sync: All ${activeSyncSteps.size} sync steps completed successfully!")
            finishSequentialSync()
            return
        }

        val step = activeSyncSteps[currentSyncStepIndex]
        Log.d(TAG, "Sequential sync: Starting step ${currentSyncStepIndex + 1}/${activeSyncSteps.size} [${step.id}] (cmd=${step.cmdHex}, timeout=${step.timeoutMs}ms)")

        // Per-step timeout: multi-packet steps (BP, SpO2 DFU, HRV) get longer timeouts
        // because the band sends header → data → EOF packets over multiple GATT notifications
        syncStepTimeoutRunnable?.let { mainHandler.removeCallbacks(it) }
        val timeoutRunnable = Runnable {
            Log.w(TAG, "Sequential sync: Step [${step.id}] timed out after ${step.timeoutMs}ms. Advancing safely to next step.")
            advanceSyncStep()
        }
        syncStepTimeoutRunnable = timeoutRunnable
        mainHandler.postDelayed(timeoutRunnable, step.timeoutMs)

        // Enqueue only the single query for this specific step
        enqueueGattOp(OpType.CHAR_WRITE, "sync-${step.id}") {
            writeQcPacketDirect(buildQcPacket(step.cmdHex))
        }
    }

    private fun onSyncPacketReceived(cmd: Int) {
        if (!isSyncInProgress) return
        syncAdvanceDebounceRunnable?.let {
            mainHandler.removeCallbacks(it)
            syncAdvanceDebounceRunnable = null
        }
        val currentStep = if (currentSyncStepIndex < activeSyncSteps.size) activeSyncSteps[currentSyncStepIndex] else null
        if (currentStep != null && (currentStep.responseCmds.contains(cmd) || (cmd and 0x7F) == (currentStep.responseCmds.first() and 0x7F))) {
            Log.d(TAG, "Sequential sync: Matched response 0x%02X for step [${currentStep.id}]. Advancing after 150ms delay...".format(cmd))
            syncStepTimeoutRunnable?.let {
                mainHandler.removeCallbacks(it)
                syncStepTimeoutRunnable = null
            }
            // Cancel any previously scheduled advance runnable to prevent multiple advances
            // from accumulating when a step receives multiple response packets (e.g. stress)
            syncAdvanceRunnable?.let { mainHandler.removeCallbacks(it) }
            val r = Runnable {
                syncAdvanceRunnable = null
                advanceSyncStep()
            }
            syncAdvanceRunnable = r
            mainHandler.postDelayed(r, 150L)
        }
    }

    private fun advanceSyncStep() {
        syncStepTimeoutRunnable?.let {
            mainHandler.removeCallbacks(it)
            syncStepTimeoutRunnable = null
        }
        syncAdvanceDebounceRunnable?.let {
            mainHandler.removeCallbacks(it)
            syncAdvanceDebounceRunnable = null
        }
        syncAdvanceRunnable?.let {
            mainHandler.removeCallbacks(it)
            syncAdvanceRunnable = null
        }
        currentSyncStepIndex++
        executeCurrentSyncStep()
    }

    private fun finishSequentialSync() {
        mainHandler.post {
            isSyncInProgress = false
            syncStepTimeoutRunnable?.let {
                mainHandler.removeCallbacks(it)
                syncStepTimeoutRunnable = null
            }
            syncAdvanceDebounceRunnable?.let {
                mainHandler.removeCallbacks(it)
                syncAdvanceDebounceRunnable = null
            }
            syncAdvanceRunnable?.let {
                mainHandler.removeCallbacks(it)
                syncAdvanceRunnable = null
            }
            syncMasterTimeoutRunnable?.let {
                mainHandler.removeCallbacks(it)
                syncMasterTimeoutRunnable = null
            }
            val waitingList = synchronized(pendingSyncResults) {
                val list = ArrayList(pendingSyncResults)
                pendingSyncResults.clear()
                list
            }
            val syncMap = buildCachedSyncMap()
            Log.i(TAG, "finishSequentialSync: Returning fresh health data sync payload to ${waitingList.size} Flutter caller(s): steps=${syncMap["steps"]}, cal=${syncMap["calories"]}, bp=${syncMap["systolicBP"]}/${syncMap["diastolicBP"]}, spo2=${syncMap["bloodOxygen"]}%, hrv=${syncMap["hrvMs"]}ms")
            for (res in waitingList) {
                try {
                    res.success(syncMap)
                } catch (e: Exception) {
                    Log.e(TAG, "finishSequentialSync: Failed to send success result: ${e.message}")
                }
            }
        }
    }

    private fun resetVitalsMemory(clearAll: Boolean = false) {
        lastKnownSteps = 0
        lastKnownCalories = 0
        lastKnownDistance = 0
        lastKnownSbp = if (clearAll) 0 else prefs.getInt("last_known_sbp", 0)
        lastKnownDbp = if (clearAll) 0 else prefs.getInt("last_known_dbp", 0)
        lastKnownSleepMinutes = 0
        lastKnownDeepSleepMinutes = 0
        lastKnownBloodOxygen = if (clearAll) 0.0 else prefs.getFloat("last_known_spo2", 0f).toDouble()
        lastKnownSkinTemperature = 0.0
        lastKnownStressLevel = if (clearAll) 0 else prefs.getInt("last_known_stress", 0)
        lastKnownHrvMs = if (clearAll) 0 else prefs.getInt("last_known_hrv", 0)
        lastKnownRestingHeartRate = if (clearAll) 0 else prefs.getInt("last_known_resting_hr", 0)
        if (clearAll) {
            currentBatteryPercentage = null
        }
        lastKnownSleepPhases.clear()
        lastKnownHeartRateHistory.clear()
    }

    // ─── GATT Serial Command Queue ───────────────────────────────────────────────
    // Android BLE allows only ONE outstanding GATT write/read at a time.
    // Concurrent writes return GATT_WRITE_REQUEST_BUSY (201) and crash the stack.
    // This queue serializes ALL descriptor writes, characteristic writes, and reads.
    private data class GattOp(
        val type: OpType,
        val action: () -> Boolean,   // returns true if the operation was successfully initiated
        val label: String            // for logging
    )
    private enum class OpType { DESCRIPTOR_WRITE, CHAR_WRITE, CHAR_READ }
    private val gattQueue = ArrayDeque<GattOp>()
    private var gattBusy = false
    private var gattWatchdogRunnable: Runnable? = null

    /** Enqueue a GATT operation and drain if idle. */
    private fun enqueueGattOp(type: OpType, label: String, action: () -> Boolean) {
        gattQueue.addLast(GattOp(type, action, label))
        drainGattQueue()
    }

    /** Execute the next queued operation if the stack is free. */
    private fun drainGattQueue() {
        if (gattBusy) return
        val op = if (gattQueue.isEmpty()) null else gattQueue.removeFirst()
        if (op == null) return
        gattBusy = true
        Log.d(TAG, "GattQueue: executing '${op.label}' (remaining=${gattQueue.size})")

        // 2.5s watchdog timer prevents queue from permanently hanging if callback is dropped
        gattWatchdogRunnable?.let { mainHandler.removeCallbacks(it) }
        val watchdog = Runnable {
            Log.w(TAG, "GattQueue: watchdog timeout (2.5s) reached for '${op.label}'. Releasing queue.")
            gattBusy = false
            drainGattQueue()
        }
        gattWatchdogRunnable = watchdog
        mainHandler.postDelayed(watchdog, 2500L)

        val started = try { op.action() } catch (e: Exception) {
            Log.e(TAG, "GattQueue: '${op.label}' threw: ${e.message}")
            false
        }
        if (!started) {
            // Operation could not start (e.g. GATT closed); skip and continue
            Log.w(TAG, "GattQueue: '${op.label}' failed to start, skipping")
            gattWatchdogRunnable?.let { mainHandler.removeCallbacks(it) }
            gattWatchdogRunnable = null
            gattBusy = false
            drainGattQueue()
        }
        // Otherwise, wait for the callback (onDescriptorWrite / onCharacteristicWrite / onCharacteristicRead)
    }

    /** Called from GATT callbacks to signal the current operation completed. */
    private fun onGattOpComplete(label: String) {
        Log.d(TAG, "GattQueue: '$label' complete, draining next")
        gattWatchdogRunnable?.let { mainHandler.removeCallbacks(it) }
        gattWatchdogRunnable = null
        mainHandler.postDelayed({
            gattBusy = false
            drainGattQueue()
        }, 150L)
    }

    /** Clear the queue (e.g. on disconnect). */
    private fun clearGattQueue() {
        gattWatchdogRunnable?.let { mainHandler.removeCallbacks(it) }
        gattWatchdogRunnable = null
        gattQueue.clear()
        gattBusy = false
    }

    companion object {
        private const val TAG = "EHGBandAndroidPlugin"
        val QC_SERVICE_UUID_1: UUID = UUID.fromString("6e40fff0-b5a3-f393-e0a9-e50e24dcca9e")
        val QC_SERVICE_UUID_2: UUID = UUID.fromString("de5bf728-d711-4e47-af26-65e3012a5dc7")
        val QC_CHAR_RX: UUID = UUID.fromString("6e400003-b5a3-f393-e0a9-e50e24dcca9e")
        val QC_CHAR_TX: UUID = UUID.fromString("6e400002-b5a3-f393-e0a9-e50e24dcca9e")
        val QC_CHAR_RX_2: UUID = UUID.fromString("de5bf729-d711-4e47-af26-65e3012a5dc7")
        val QC_CHAR_TX_2: UUID = UUID.fromString("de5bf72a-d711-4e47-af26-65e3012a5dc7")
        val CCCD_UUID: UUID = UUID.fromString("00002902-0000-1000-8000-00805f9b34fb")
        val BATTERY_SERVICE_UUID: UUID = UUID.fromString("0000180f-0000-1000-8000-00805f9b34fb")
        val BATTERY_CHAR_UUID: UUID = UUID.fromString("00002a19-0000-1000-8000-00805f9b34fb")
        val HEART_RATE_SERVICE_UUID: UUID = UUID.fromString("0000180d-0000-1000-8000-00805f9b34fb")
        val HEART_RATE_CHAR_UUID: UUID = UUID.fromString("00002a37-0000-1000-8000-00805f9b34fb")
    }

    private val isDeviceConnected: Boolean
        get() {
            val dev = connectedDevice ?: return false
            val gatt = connectedGatt ?: return false
            val manager = activity.getSystemService(Context.BLUETOOTH_SERVICE) as? BluetoothManager
            return manager?.getConnectionState(gatt.device, BluetoothProfile.GATT) == BluetoothProfile.STATE_CONNECTED
        }

    private val bluetoothStateReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            if (intent?.action == BluetoothAdapter.ACTION_STATE_CHANGED) {
                val state = intent.getIntExtra(BluetoothAdapter.EXTRA_STATE, BluetoothAdapter.ERROR)
                when (state) {
                    BluetoothAdapter.STATE_ON -> {
                        bluetoothLeScanner = bluetoothAdapter?.bluetoothLeScanner
                        sendEvent(mapOf("type" to "bluetooth_state", "state" to "poweredOn"))
                        val lastMac = prefs.getString("last_connected_mac", null)
                        if (!lastMac.isNullOrEmpty() && !isDeviceConnected) {
                            Log.d(TAG, "Bluetooth turned on, auto-reconnecting to $lastMac")
                            connectToDevice(lastMac, null)
                        }
                    }
                    BluetoothAdapter.STATE_OFF, BluetoothAdapter.STATE_TURNING_OFF -> {
                        Log.d(TAG, "Bluetooth turned off, gracefully resetting connection")
                        sendEvent(mapOf("type" to "bluetooth_state", "state" to "poweredOff"))
                        stopBleScan()
                        disconnectDevice()
                    }
                }
            }
        }
    }

    init {
        methodChannel.setMethodCallHandler(this)
        eventChannel.setStreamHandler(this)
        backgroundChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "schedulePeriodicSync" -> {
                    val interval = call.argument<Int>("intervalMinutes") ?: 30
                    Log.i(TAG, "Native WorkManager periodic sync scheduled (interval: $interval mins)")
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
        bluetoothLeScanner = bluetoothAdapter?.bluetoothLeScanner
        try {
            val filter = IntentFilter(BluetoothAdapter.ACTION_STATE_CHANGED)
            activity.registerReceiver(bluetoothStateReceiver, filter)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to register bluetoothStateReceiver", e)
        }

        // Register application lifecycle callbacks to mirror iOS handleAppWillEnterForeground
        try {
            activity.application.registerActivityLifecycleCallbacks(object : Application.ActivityLifecycleCallbacks {
                override fun onActivityResumed(act: Activity) {
                    if (act == activity) {
                        Log.d(TAG, "📱 App resumed in foreground - checking band connection...")
                        if (isDeviceConnected && connectedDevice != null) {
                            val dev = connectedDevice!!
                            sendEvent(mapOf(
                                "type" to "connection_state",
                                "state" to "connected",
                                "name" to (dev.name ?: "EHG Smart Band"),
                                "id" to dev.address,
                                "mac" to dev.address
                            ))
                            if (currentBatteryPercentage != null) {
                                sendEvent(mapOf(
                                    "type" to "battery_update",
                                    "battery" to currentBatteryPercentage,
                                    "charging" to false
                                ))
                            }
                            sendReadBattery()
                        } else {
                            val lastMac = prefs.getString("last_connected_mac", null)
                            if (!lastMac.isNullOrEmpty() && bluetoothAdapter?.isEnabled == true) {
                                Log.d(TAG, "📱 App resumed and band disconnected, triggering auto-reconnect to $lastMac")
                                connectToDevice(lastMac, null)
                            }
                        }
                    }
                }
                override fun onActivityPaused(act: Activity) {}
                override fun onActivityStarted(act: Activity) {}
                override fun onActivityStopped(act: Activity) {}
                override fun onActivitySaveInstanceState(act: Activity, outState: android.os.Bundle) {}
                override fun onActivityCreated(act: Activity, savedInstanceState: android.os.Bundle?) {}
                override fun onActivityDestroyed(act: Activity) {}
            })
        } catch (e: Exception) {
            Log.w(TAG, "Could not register ActivityLifecycleCallbacks: ${e.message}")
        }
    }

    private fun sendEvent(event: Map<String, Any?>) {
        mainHandler.post {
            eventSink?.success(event)
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        this.eventSink = events

        // Immediately re-emit current Bluetooth state
        val btState = if (bluetoothAdapter?.isEnabled == true) "poweredOn" else "poweredOff"
        events?.success(mapOf("type" to "bluetooth_state", "state" to btState))

        // If band is already connected (e.g. across Hot Restart or stream re-listen), emit connected immediately
        val dev = connectedDevice
        if (connectedGatt != null && dev != null) {
            val manager = activity.getSystemService(Context.BLUETOOTH_SERVICE) as? BluetoothManager
            val state = manager?.getConnectionState(connectedGatt?.device, BluetoothProfile.GATT)
            if (state == BluetoothProfile.STATE_CONNECTED) {
                Log.d(TAG, "🔌 Re-emitting connected state to Flutter on hot restart: ${dev.name} (${dev.address})")
                events?.success(mapOf(
                    "type" to "connection_state",
                    "state" to "connected",
                    "name" to (dev.name ?: "EHG Smart Band"),
                    "id" to dev.address,
                    "mac" to dev.address
                ))
                if (currentBatteryPercentage != null) {
                    events?.success(mapOf(
                        "type" to "battery_update",
                        "battery" to currentBatteryPercentage,
                        "charging" to false
                    ))
                }
                sendReadBattery()
            }
        }
    }

    override fun onCancel(arguments: Any?) {
        this.eventSink = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "isConnected" -> {
                result.success(isDeviceConnected)
            }
            "requestEnableBluetooth" -> {
                requestEnableBluetooth()
                result.success(true)
            }
            "openAppSettings" -> {
                openAppSettings()
                result.success(true)
            }
            "openBluetoothSettings" -> {
                openBluetoothSettings()
                result.success(true)
            }
            "openLocationSettings" -> {
                openLocationSettings()
                result.success(true)
            }
            "startScan" -> {
                val timeoutSeconds = call.argument<Int>("timeout") ?: 30
                startBleScan(timeoutSeconds)
                result.success(true)
            }
            "stopScan" -> {
                stopBleScan()
                result.success(true)
            }
            "connect" -> {
                val deviceId = call.argument<String>("deviceId")
                if (deviceId.isNullOrEmpty()) {
                    result.error("INVALID_ARGS", "deviceId cannot be null or empty", null)
                    return
                }
                connectToDevice(deviceId, result)
            }
            "disconnect", "unbind" -> {
                val unpair = (call.method == "unbind") || (call.argument<Boolean>("unpair") ?: false)
                if (unpair) {
                    val lastMac = prefs.getString("last_connected_mac", null)
                    try {
                        val dev = connectedDevice ?: if (!lastMac.isNullOrEmpty()) {
                            try { bluetoothAdapter?.getRemoteDevice(lastMac) } catch (_: Exception) { null }
                        } else null
                        if (dev != null && dev.bondState == BluetoothDevice.BOND_BONDED) {
                            val method = dev.javaClass.getMethod("removeBond")
                            method.invoke(dev)
                            Log.i(TAG, "Unpair/Unbind: Device ${dev.address} unbonded from Android OS Bluetooth")
                        }
                    } catch (e: Exception) {
                        Log.w(TAG, "Failed to removeBond on unbind: ${e.message}")
                    }
                    prefs.edit().clear().apply()
                    resetVitalsMemory(clearAll = true)
                }
                disconnectDevice()
                result.success(true)
            }
            "reconnect" -> {
                if (isDeviceConnected && connectedGatt != null) {
                    Log.d(TAG, "Reconnect: Band is already actively connected natively.")
                    result.success(true)
                } else {
                    val lastMac = prefs.getString("last_connected_mac", null)
                    if (!lastMac.isNullOrEmpty()) {
                        connectToDevice(lastMac, result)
                    } else {
                        result.success(false)
                    }
                }
            }
            "getBattery" -> {
                readBattery(result)
            }
            "getDeviceInfo" -> {
                val mac = connectedDevice?.address ?: prefs.getString("last_connected_mac", "") ?: ""
                val name = connectedDevice?.name ?: prefs.getString("last_connected_name", "EHG Smart Band") ?: "EHG Smart Band"
                val soft = prefs.getString("band_soft_version", "1.0.4") ?: "1.0.4"
                val hard = prefs.getString("band_hard_version", "1.0.0") ?: "1.0.0"
                result.success(
                    mapOf(
                        "name" to name,
                        "id" to mac,
                        "macAddress" to mac,
                        "softVersion" to soft,
                        "hardVersion" to hard
                    )
                )
            }
            "setTime" -> {
                val ok = sendSetTime()
                result.success(ok)
            }
            "findBand" -> {
                val ok = sendLookupDeviceVibration()
                result.success(ok)
            }
            "startRealtimeHeartRate" -> {
                val ok = startRealtimeHeartRateQc()
                result.success(ok)
            }
            "stopRealtimeHeartRate" -> {
                val ok = stopRealtimeHeartRateQc()
                result.success(ok)
            }
            "syncHistoricalVitals", "syncFullHealthData" -> {
                syncFullHealthData(result)
            }
            "startMeasuring" -> {
                val type = call.argument<String>("type") ?: "heartRate"
                val ok = startMeasuringQc(type)
                result.success(ok)
            }
            "stopMeasuring" -> {
                val type = call.argument<String>("type") ?: "heartRate"
                val ok = stopMeasuringQc(type)
                result.success(ok)
            }
            else -> result.notImplemented()
        }
    }

    private fun startBleScan(timeoutSeconds: Int) {
        val adapter = bluetoothAdapter
        if (adapter == null) {
            sendEvent(mapOf("type" to "bluetooth_state", "state" to "unsupported"))
            sendEvent(mapOf("type" to "connection_failed", "error" to "Bluetooth is not available on this device"))
            sendEvent(mapOf("type" to "scan_finished"))
            return
        }

        if (!adapter.isEnabled) {
            sendEvent(mapOf("type" to "bluetooth_state", "state" to "poweredOff"))
            sendEvent(mapOf("type" to "connection_failed", "error" to "Please turn ON Bluetooth to connect to your band."))
            try {
                val enableBtIntent = Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE)
                activity.startActivity(enableBtIntent)
            } catch (_: Exception) {}
            sendEvent(mapOf("type" to "scan_finished"))
            return
        }

        val locationManager = activity.getSystemService(Context.LOCATION_SERVICE) as? LocationManager
        val isLocationEnabled = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            locationManager?.isLocationEnabled == true
        } else {
            locationManager?.isProviderEnabled(LocationManager.GPS_PROVIDER) == true ||
            locationManager?.isProviderEnabled(LocationManager.NETWORK_PROVIDER) == true
        }
        if (!isLocationEnabled) {
            Log.w(TAG, "Location (GPS) is turned OFF!")
            sendEvent(mapOf(
                "type" to "connection_failed",
                "error" to "Please turn ON Location (GPS) in phone settings so Bluetooth can discover nearby bands."
            ))
        }

        discoveredDevices.clear()
        bluetoothLeScanner = adapter.bluetoothLeScanner
        if (bluetoothLeScanner == null) {
            sendEvent(mapOf("type" to "bluetooth_state", "state" to "poweredOff"))
            sendEvent(mapOf("type" to "scan_finished"))
            return
        }

        isScanning = true
        sendEvent(mapOf("type" to "connection_state", "state" to "scanning"))

        val settings = ScanSettings.Builder()
            .setScanMode(ScanSettings.SCAN_MODE_LOW_LATENCY)
            .build()

        try {
            bluetoothLeScanner?.startScan(null, settings, scanCallback)
        } catch (e: Exception) {
            Log.e(TAG, "BLE scan start failed", e)
            sendEvent(mapOf("type" to "connection_failed", "error" to "Failed to start BLE scan: ${e.localizedMessage}"))
            sendEvent(mapOf("type" to "scan_finished"))
        }

        mainHandler.postDelayed({
            stopBleScan()
        }, timeoutSeconds * 1000L)
    }

    private fun stopBleScan() {
        if (isScanning) {
            isScanning = false
            try {
                bluetoothLeScanner?.stopScan(scanCallback)
            } catch (_: Exception) {}
            sendEvent(mapOf("type" to "scan_finished"))
        }
    }

    private val scanCallback = object : ScanCallback() {
        override fun onScanResult(callbackType: Int, result: ScanResult?) {
            result?.let {
                val dev = it.device
                val address = dev.address ?: return
                val advertisedName = it.scanRecord?.deviceName?.trim()
                val cachedName = dev.name?.trim()
                val rawName = if (!advertisedName.isNullOrEmpty()) advertisedName else if (!cachedName.isNullOrEmpty()) cachedName else ""
                val nameLower = rawName.lowercase()

                // Exclude earbuds, headphones, speakers, TVs, laptops, phones
                val excludedKeywords = listOf(
                    "buds", "airpod", "earphone", "headphone", "headset",
                    "speaker", "audio", "sound", "tv", "macbook", "phone",
                    "ipad", "laptop", "car", "echo", "beats", "sony", "jbl",
                    "freebuds", "linkbuds", "pixel", "galaxy"
                )
                if (nameLower.isNotEmpty() && excludedKeywords.any { kw -> nameLower.contains(kw) }) {
                    return
                }

                // 1. Check for QC Wireless Service UUIDs (6E40FFF0 / DE5BF728 / 0xFFF0)
                val serviceUuids = it.scanRecord?.serviceUuids?.map { u -> u.uuid.toString().lowercase() } ?: emptyList()
                val hasQcService = serviceUuids.any { u ->
                    u.contains("6e40") || u.contains("de5b") || u.contains("fff0")
                }

                // 2. Check for verified QC manufacturer data signature matching device address
                val mfgData = it.scanRecord?.manufacturerSpecificData
                var hasQcMfgSignature = false
                if (mfgData != null && mfgData.size() > 0) {
                    val cleanAddress = address.replace(":", "").uppercase()
                    for (i in 0 until mfgData.size()) {
                        val bytes = mfgData.valueAt(i) ?: continue
                        val extractedMac = extractMacFromMfg(bytes)?.replace(":", "")?.uppercase()
                        if (extractedMac != null && (extractedMac == cleanAddress ||
                                    extractedMac == cleanAddress.chunked(2).reversed().joinToString(""))) {
                            hasQcMfgSignature = true
                            break
                        }
                    }
                }

                // 3. Strict EHG / QC / QRing device naming (aligned with QWatch Pro / QC SDK)
                val isEhgOrQcDevice = nameLower.startsWith("ehg") ||
                        nameLower.startsWith("o_") ||
                        nameLower.startsWith("q_") ||
                        nameLower.startsWith("qc") ||
                        nameLower.startsWith("qwatch") ||
                        nameLower.startsWith("qring") ||
                        nameLower.startsWith("r0") ||
                        nameLower.startsWith("r_") ||
                        nameLower.startsWith("ring") ||
                        nameLower.contains("ehg") ||
                        nameLower.contains("smart") ||
                        nameLower.contains("band") ||
                        nameLower.contains("ring") ||
                        nameLower.contains("watch")

                // Must be verified QC service, verified QC manufacturer signature, or official EHG/QC device name
                if (!hasQcService && !hasQcMfgSignature && !isEhgOrQcDevice) {
                    Log.v(TAG, "Filtered non-EHG device: '$rawName' ($address)")
                    return
                }

                // Never display unnamed devices unless they explicitly broadcast verified QC service or MAC signature
                if (rawName.isBlank() && !hasQcService && !hasQcMfgSignature) {
                    return
                }

                val finalName = if (rawName.isNotBlank()) rawName else "EHG Smart Band"
                val rssi = it.rssi

                Log.i(TAG, "EHG Band found: '$finalName' ($address), rssi=$rssi, qcService=$hasQcService, qcMfg=$hasQcMfgSignature")

                val devMap = mapOf(
                    "id" to address,
                    "name" to finalName,
                    "mac" to address,
                    "rssi" to rssi
                )
                discoveredDevices[address] = devMap

                sendEvent(
                    mapOf(
                        "type" to "scan_results",
                        "devices" to discoveredDevices.values.toList()
                    )
                )
            }
        }

        override fun onBatchScanResults(results: MutableList<ScanResult>?) {
            results?.forEach { onScanResult(ScanSettings.CALLBACK_TYPE_ALL_MATCHES, it) }
        }

        override fun onScanFailed(errorCode: Int) {
            Log.e(TAG, "BLE Scan Failed: errorCode=$errorCode")
            sendEvent(mapOf("type" to "scan_finished"))
        }
    }

    private fun extractMacFromMfg(data: ByteArray): String? {
        return when {
            data.size >= 10 -> {
                String.format(
                    "%02X:%02X:%02X:%02X:%02X:%02X",
                    data[4], data[5], data[6], data[7], data[8], data[9]
                )
            }
            data.size == 8 -> {
                String.format(
                    "%02X:%02X:%02X:%02X:%02X:%02X",
                    data[2], data[3], data[4], data[5], data[6], data[7]
                )
            }
            data.size == 6 -> {
                String.format(
                    "%02X:%02X:%02X:%02X:%02X:%02X",
                    data[0], data[1], data[2], data[3], data[4], data[5]
                )
            }
            else -> null
        }
    }

    private fun connectToDevice(deviceId: String, result: MethodChannel.Result? = null) {
        if (connectedGatt != null && connectedDevice?.address == deviceId) {
            val manager = activity.getSystemService(Context.BLUETOOTH_SERVICE) as? BluetoothManager
            val state = manager?.getConnectionState(connectedGatt?.device, BluetoothProfile.GATT)
            if (state == BluetoothProfile.STATE_CONNECTED) {
                Log.d(TAG, "Device $deviceId is ALREADY connected in Android GATT. Returning success.")
                val devName = connectedDevice?.name ?: "EHG Smart Band"
                sendEvent(mapOf(
                    "type" to "connection_state",
                    "state" to "connected",
                    "name" to devName,
                    "id" to deviceId,
                    "mac" to deviceId
                ))
                if (currentBatteryPercentage != null) {
                    sendEvent(mapOf(
                        "type" to "battery_update",
                        "battery" to currentBatteryPercentage,
                        "charging" to false
                    ))
                }
                sendReadBattery()
                startStepPolling()
                result?.success(true)
                return
            }
        }

        // 1. Immediately stop scanning
        stopBleScan()
        sendEvent(mapOf("type" to "connection_state", "state" to "connecting"))

        // Senior Android BLE pattern:
        // Wait 250ms after stopping scan before initiating connectGatt so the BLE hardware
        // radio chip finishes stopping the scanner, preventing status 133 radio collisions.
        mainHandler.postDelayed({
            executeConnectGatt(deviceId, result)
        }, 250L)
    }

    private fun executeConnectGatt(deviceId: String, result: MethodChannel.Result? = null) {
        val adapter = bluetoothAdapter
        val device = try {
            adapter?.getRemoteDevice(deviceId)
        } catch (_: IllegalArgumentException) {
            null
        }

        if (device == null) {
            sendEvent(mapOf("type" to "connection_failed", "error" to "Device $deviceId not found"))
            result?.error("DEVICE_NOT_FOUND", "Bluetooth device $deviceId not found", null)
            return
        }

        // Clean up previous GATT instance if present
        clearGattQueue()
        try {
            connectedGatt?.disconnect()
            connectedGatt?.close()
        } catch (_: Exception) {}
        connectedGatt = null

        connectedDevice = device
        pendingConnectResult = result
        hasSentConnectionVibration = false
        qcTxCharacteristic = null
        qcRxCharacteristic = null

        // Connect with TRANSPORT_LE
        connectedGatt = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            device.connectGatt(activity, false, gattCallback, BluetoothDevice.TRANSPORT_LE)
        } else {
            device.connectGatt(activity, false, gattCallback)
        }

        // 20-second connection timeout guard
        mainHandler.postDelayed({
            val callback = pendingConnectResult ?: return@postDelayed
            pendingConnectResult = null
            sendEvent(mapOf(
                "type" to "connection_failed",
                "error" to "Connection timed out. Ensure band is nearby, charged, and unlinked from other apps (like QwatchPro)."
            ))
            callback.error("CONNECT_TIMEOUT", "Timed out while connecting to the band", null)
            disconnectDevice()
        }, 20_000L)
    }

    private fun disconnectDevice() {
        stopStepPolling()
        stopRealtimeHeartRateQc()
        stopMeasuringQc("all")
        clearGattQueue()
        hasSentConnectionVibration = false
        qcTxCharacteristic = null
        qcRxCharacteristic = null
        try {
            connectedGatt?.disconnect()
            connectedGatt?.close()
        } catch (_: Exception) {}
        connectedGatt = null
        connectedDevice = null
        sendEvent(mapOf("type" to "connection_state", "state" to "disconnected"))
    }

    private val gattCallback = object : BluetoothGattCallback() {
        override fun onConnectionStateChange(gatt: BluetoothGatt?, status: Int, newState: Int) {
            Log.d(TAG, "onConnectionStateChange status=$status, newState=$newState")
            if (status == BluetoothGatt.GATT_SUCCESS && newState == BluetoothProfile.STATE_CONNECTED) {
                Log.d(TAG, "Connected to GATT server. Scheduling service discovery and priority boost...")
                // Senior Android BLE pattern:
                // Android BLE stack requires running discoverServices after a short delay (250ms)
                // on the main looper to avoid native stack deadlock on Qualcomm/MediaTek/Xiaomi chipsets.
                mainHandler.postDelayed({
                    if (connectedGatt != null && connectedGatt == gatt) {
                        gatt?.requestConnectionPriority(BluetoothGatt.CONNECTION_PRIORITY_HIGH)
                        val success = gatt?.discoverServices() ?: false
                        Log.d(TAG, "discoverServices initiated: $success")
                    }
                }, 250L)
            } else if (newState == BluetoothProfile.STATE_DISCONNECTED || status != BluetoothGatt.GATT_SUCCESS) {
                Log.d(TAG, "Disconnected or connect failure (status=$status, newState=$newState)")
                stopStepPolling()
                clearGattQueue()
                isLiveHeartRateActive = false
                hasEmittedConnected = false
                realtimeHrHoldRunnable?.let {
                    mainHandler.removeCallbacks(it)
                    realtimeHrHoldRunnable = null
                }
                measuringTimeoutRunnable?.let {
                    mainHandler.removeCallbacks(it)
                    measuringTimeoutRunnable = null
                }
                hasSentConnectionVibration = false
                if (isSyncInProgress) {
                    Log.w(TAG, "Band disconnected during active sequential sync. Completing with cached metrics.")
                    finishSequentialSync()
                }
                sendEvent(mapOf("type" to "connection_state", "state" to "disconnected"))
                if (pendingConnectResult != null) {
                    val msg = if (status != BluetoothGatt.GATT_SUCCESS) {
                        "Connection failed (status $status). If previously paired in phone Bluetooth settings, please unpair it first and retry."
                    } else {
                        "The band disconnected while connecting"
                    }
                    sendEvent(mapOf("type" to "connection_failed", "error" to msg))
                    pendingConnectResult?.error("CONNECT_FAILED", msg, null)
                    pendingConnectResult = null
                }
                try {
                    gatt?.close()
                } catch (_: Exception) {}
                if (connectedGatt == gatt) {
                    connectedGatt = null
                }
            }
        }

        override fun onServicesDiscovered(gatt: BluetoothGatt?, status: Int) {
            if (status == BluetoothGatt.GATT_SUCCESS && gatt != null) {
                Log.i(TAG, "GATT services discovered successfully (${gatt.services.size} services found)")

                // Check Standard Battery & Heart Rate
                batteryCharacteristic = gatt.getService(BATTERY_SERVICE_UUID)
                    ?.getCharacteristic(BATTERY_CHAR_UUID)

                val hrService = gatt.getService(HEART_RATE_SERVICE_UUID)
                heartRateCharacteristic = hrService?.getCharacteristic(HEART_RATE_CHAR_UUID)

                // Locate QC Wireless Proprietary TX and RX characteristics
                resolveQcCharacteristics(gatt)

                val devName = connectedDevice?.name ?: "EHG Smart Band"
                val devId = connectedDevice?.address ?: ""

                // Persist device MAC for persistent auto-reconnect
                prefs.edit()
                    .putString("last_connected_mac", devId)
                    .putString("last_connected_name", devName)
                    .apply()

                // Reset flags for this connection session
                hasSentConnectionVibration = false
                hasEmittedConnected = false

                // Safety fallback (8s): If the entire init pipeline + sentinel somehow never
                // fires, this guarantees Flutter still gets notified. Under normal conditions
                // the sentinel op at the end of the pipeline fires notifyConnectedState
                // well before this timeout.
                mainHandler.postDelayed({
                    if (connectedGatt != null && !hasEmittedConnected) {
                        Log.w(TAG, "Safety fallback timer (8s) fired: notifying connected state to Flutter")
                        notifyConnectedState()
                    }
                }, 8000L)

                // ── Serial initialization pipeline via GATT queue (identical to iOS) ──
                // Brief 150ms delay gives the Android BLE service cache time to stabilize
                // before writing descriptors/characteristics.
                mainHandler.postDelayed({
                    if (connectedGatt == null || connectedGatt != gatt) return@postDelayed

                    // Step 1: Enable CCCD notifications on QC RX characteristic and standard Heart Rate characteristic
                    val rxChar = qcRxCharacteristic
                    if (rxChar != null) {
                        Log.i(TAG, "QC Band proprietary RX located (${rxChar.uuid}), queueing CCCD enable...")
                        enqueueGattOp(OpType.DESCRIPTOR_WRITE, "CCCD-enable-qcRx") {
                            if (!gatt.setCharacteristicNotification(rxChar, true)) return@enqueueGattOp false
                            val cccd = rxChar.getDescriptor(CCCD_UUID) ?: return@enqueueGattOp false
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                                gatt.writeDescriptor(cccd, BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE) == android.bluetooth.BluetoothStatusCodes.SUCCESS
                            } else {
                                @Suppress("DEPRECATION")
                                cccd.value = BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE
                                @Suppress("DEPRECATION")
                                gatt.writeDescriptor(cccd)
                            }
                        }
                    }

                    val rx2Char = qcRx2Characteristic
                    if (rx2Char != null) {
                        Log.i(TAG, "QC Band DFU RX located (${rx2Char.uuid}), queueing CCCD enable...")
                        enqueueGattOp(OpType.DESCRIPTOR_WRITE, "CCCD-enable-qcRx2") {
                            if (!gatt.setCharacteristicNotification(rx2Char, true)) return@enqueueGattOp false
                            val cccd = rx2Char.getDescriptor(CCCD_UUID) ?: return@enqueueGattOp false
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                                gatt.writeDescriptor(cccd, BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE) == android.bluetooth.BluetoothStatusCodes.SUCCESS
                            } else {
                                @Suppress("DEPRECATION")
                                cccd.value = BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE
                                @Suppress("DEPRECATION")
                                gatt.writeDescriptor(cccd)
                            }
                        }
                    }

                    val hrChar = heartRateCharacteristic
                    if (hrChar != null) {
                        Log.i(TAG, "Standard Heart Rate characteristic located (${hrChar.uuid}), queueing CCCD enable...")
                        enqueueGattOp(OpType.DESCRIPTOR_WRITE, "CCCD-enable-heartRate") {
                            if (!gatt.setCharacteristicNotification(hrChar, true)) return@enqueueGattOp false
                            val cccd = hrChar.getDescriptor(CCCD_UUID) ?: return@enqueueGattOp false
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                                gatt.writeDescriptor(cccd, BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE) == android.bluetooth.BluetoothStatusCodes.SUCCESS
                            } else {
                                @Suppress("DEPRECATION")
                                cccd.value = BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE
                                @Suppress("DEPRECATION")
                                gatt.writeDescriptor(cccd)
                            }
                        }
                    } else if (batteryCharacteristic != null && rxChar == null) {
                        val batChar = batteryCharacteristic!!
                        enqueueGattOp(OpType.DESCRIPTOR_WRITE, "CCCD-enable-battery") {
                            if (!gatt.setCharacteristicNotification(batChar, true)) return@enqueueGattOp false
                            val cccd = batChar.getDescriptor(CCCD_UUID) ?: return@enqueueGattOp false
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                                gatt.writeDescriptor(cccd, BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE) == android.bluetooth.BluetoothStatusCodes.SUCCESS
                            } else {
                                @Suppress("DEPRECATION")
                                cccd.value = BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE
                                @Suppress("DEPRECATION")
                                gatt.writeDescriptor(cccd)
                            }
                        }
                    }

                    // Step 2: One-time connection vibration (matching iOS alertBindingSuccess)
                    // In iOS QC SDK, [QCSDKCmdCreator alertBindingSuccess] sends packet '10' (CMD 0x10, "绑定震动").
                    // The band vibrates once upon receiving 0x10 to signal successful connection/binding.
                    enqueueGattOp(OpType.CHAR_WRITE, "connection-vibration") {
                        if (hasSentConnectionVibration) {
                            return@enqueueGattOp false
                        }
                        val packet = buildQcPacket("10")
                        val ok = writeQcPacketDirect(packet)
                        Log.i(TAG, "sendConnectionVibration (alertBindingSuccess 0x10) packet='10', success=$ok")
                        if (ok) hasSentConnectionVibration = true
                        ok
                    }

                    // Step 3: Sync band clock (identical to iOS setTime)
                    enqueueGattOp(OpType.CHAR_WRITE, "set-time") {
                        val calendar = Calendar.getInstance()
                        val year = calendar.get(Calendar.YEAR) % 100
                        val month = calendar.get(Calendar.MONTH) + 1
                        val day = calendar.get(Calendar.DAY_OF_MONTH)
                        val hour = calendar.get(Calendar.HOUR_OF_DAY)
                        val minute = calendar.get(Calendar.MINUTE)
                        val second = calendar.get(Calendar.SECOND)
                        val timeHex = String.format("01%02d%02d%02d%02d%02d%02d", year, month, day, hour, minute, second)
                        val packet = buildQcPacket(timeHex)
                        val ok = writeQcPacketDirect(packet)
                        Log.i(TAG, "sendSetTime (queued) timeHex='$timeHex', success=$ok")
                        ok
                    }

                    // Step 4: Read battery via QC proprietary command (identical to iOS readBatterySuccess)
                    enqueueGattOp(OpType.CHAR_WRITE, "read-battery") {
                        val packet = buildQcPacket("03")
                        val ok = writeQcPacketDirect(packet)
                        Log.i(TAG, "sendReadBattery (queued) packet='03', success=$ok")
                        ok
                    }

                    // Step 5: Enable scheduled continuous heart rate monitoring (5-minute interval)
                    // In Oudmon QC protocol, CMD 0x16 with payload [0x01, 0x05] sets continuous heart rate monitoring.
                    // This turns ON the band's periodic PPG optical sensor engine.
                    enqueueGattOp(OpType.CHAR_WRITE, "enable-scheduled-hr") {
                        val packet = buildQcPacket("160105")
                        val ok = writeQcPacketDirect(packet)
                        Log.i(TAG, "enableScheduledHeartRate (queued) packet='160105', success=$ok")
                        ok
                    }

                    // Step 6: Query today's steps/sport data (CMD 0x48 / OdmBandGetCurrentSportInfo)
                    enqueueGattOp(OpType.CHAR_WRITE, "query-today-sport") {
                        val packet = buildQcPacket("48")
                        val ok = writeQcPacketDirect(packet)
                        Log.i(TAG, "queryTodaySport (queued) packet='48', success=$ok")
                        ok
                    }

                    // Step 7: Read standard battery characteristic (if available)
                    if (batteryCharacteristic != null) {
                        enqueueGattOp(OpType.CHAR_READ, "read-battery-std") {
                            val ok = gatt.readCharacteristic(batteryCharacteristic)
                            Log.d(TAG, "readBatteryCharacteristic (queued), success=$ok")
                            ok
                        }
                    }

                    // Step 8: SENTINEL — Notify Flutter "connected" only AFTER the entire
                    // init pipeline has finished. This prevents Flutter from triggering
                    // syncFullHealthData() while init commands are still draining through
                    // the serial GATT queue, which would interleave sync commands with
                    // init commands and overwhelm the band firmware.
                    enqueueGattOp(OpType.CHAR_WRITE, "init-pipeline-sentinel") {
                        Log.i(TAG, "Init pipeline sentinel reached — all init ops complete. Notifying Flutter.")
                        mainHandler.post {
                            notifyConnectedState()
                        }
                        // Return false so no actual GATT write is attempted
                        // (this is a virtual sentinel, not a real BLE write)
                        false
                    }
                }, 150L)
            } else {
                Log.e(TAG, "Service discovery failed with status $status")
                sendEvent(mapOf("type" to "connection_failed", "error" to "Could not discover services on the band (status $status)"))
                pendingConnectResult?.error(
                    "SERVICE_DISCOVERY_FAILED",
                    "Could not discover services on the band (status $status)",
                    null
                )
                pendingConnectResult = null
            }
        }

        override fun onDescriptorWrite(
            gatt: BluetoothGatt?,
            descriptor: BluetoothGattDescriptor?,
            status: Int
        ) {
            Log.d(TAG, "onDescriptorWrite status=$status, descUuid=${descriptor?.uuid}")
            // NOTE: We intentionally do NOT call notifyConnectedState() here.
            // The init-pipeline-sentinel at the end of the GATT queue handles it.
            // Emitting 'connected' early causes Flutter to start syncFullHealthData()
            // while the init pipeline is still draining, interleaving commands and
            // corrupting the QC protocol state (all zeros + disconnect).
            mainHandler.post { onGattOpComplete("descriptor-write") }
        }

        override fun onCharacteristicWrite(
            gatt: BluetoothGatt?,
            characteristic: BluetoothGattCharacteristic?,
            status: Int
        ) {
            Log.d(TAG, "onCharacteristicWrite uuid=${characteristic?.uuid}, status=$status")
            mainHandler.post { onGattOpComplete("char-write") }
        }

        @Deprecated("Deprecated in Java")
        override fun onCharacteristicRead(
            gatt: BluetoothGatt,
            characteristic: BluetoothGattCharacteristic,
            status: Int
        ) {
            // Signal the GATT queue that a read completed
            mainHandler.post { onGattOpComplete("char-read") }
            if (characteristic.uuid != BATTERY_CHAR_UUID) return
            val callback = pendingBatteryResult
            pendingBatteryResult = null
            if (status != BluetoothGatt.GATT_SUCCESS) {
                callback?.error("BATTERY_READ_FAILED", "The band did not return its battery level", null)
                return
            }
            publishBattery(characteristic, callback)
        }

        override fun onCharacteristicRead(
            gatt: BluetoothGatt,
            characteristic: BluetoothGattCharacteristic,
            value: ByteArray,
            status: Int
        ) {
            if (characteristic.uuid != BATTERY_CHAR_UUID) return
            val callback = pendingBatteryResult
            pendingBatteryResult = null
            if (status != BluetoothGatt.GATT_SUCCESS) {
                callback?.error("BATTERY_READ_FAILED", "The band did not return its battery level", null)
                return
            }
            if (value.isNotEmpty()) {
                val battery = value[0].toInt() and 0xFF
                if (battery in 0..100) {
                    currentBatteryPercentage = battery
                    val data = mapOf("battery" to battery, "charging" to false)
                    callback?.success(data)
                    sendEvent(mapOf("type" to "battery_update") + data)
                    return
                }
            }
            publishBattery(characteristic, callback)
        }

        @Deprecated("Deprecated in Java")
        override fun onCharacteristicChanged(
            gatt: BluetoothGatt,
            characteristic: BluetoothGattCharacteristic
        ) {
            @Suppress("DEPRECATION")
            val value = characteristic.value ?: ByteArray(0)
            handleCharacteristicUpdate(characteristic, value)
        }

        override fun onCharacteristicChanged(
            gatt: BluetoothGatt,
            characteristic: BluetoothGattCharacteristic,
            value: ByteArray
        ) {
            handleCharacteristicUpdate(characteristic, value)
        }

        private fun handleCharacteristicUpdate(
            characteristic: BluetoothGattCharacteristic,
            value: ByteArray
        ) {
            val uuid = characteristic.uuid
            if (uuid == HEART_RATE_CHAR_UUID) {
                if (value.isNotEmpty()) {
                    val flags = value[0].toInt() and 0xFF
                    val is16Bit = (flags and 0x01) != 0
                    val bpm = if (is16Bit && value.size >= 3) {
                        (value[1].toInt() and 0xFF) or ((value[2].toInt() and 0xFF) shl 8)
                    } else if (value.size >= 2) {
                        value[1].toInt() and 0xFF
                    } else null
                    if (bpm != null && bpm > 0) {
                        sendEvent(mapOf("type" to "live_heart_rate", "bpm" to bpm))
                    }
                }
            } else if (uuid == BATTERY_CHAR_UUID) {
                publishBattery(characteristic)
            } else if (uuid == QC_CHAR_RX || uuid == QC_CHAR_RX_2 || uuid == qcRxCharacteristic?.uuid || uuid == qcRx2Characteristic?.uuid) {
                if (value.isEmpty()) return
                val cmd = value[0].toInt() and 0xFF
                Log.d(TAG, "QC RX packet: cmd=0x%02X, len=%d, hex=%s".format(cmd, value.size, value.joinToString("") { "%02X".format(it) }))

                when (cmd) {
                    0x1E, 0x9E -> {
                        // RealTimeHeartRate response / live continuous PPG packet
                        // Byte layout in Oudmon SDK: [0x1E, hr, ...] or [0x1E, status, hr, ...]
                        val b1 = if (value.size > 1) (value[1].toInt() and 0xFF) else 0
                        val b2 = if (value.size > 2) (value[2].toInt() and 0xFF) else 0
                        val finalHr = when {
                            b1 in 30..240 -> b1
                            b2 in 30..240 -> b2
                            else -> null
                        }

                        if (finalHr != null && finalHr > 0) {
                            Log.i(TAG, "Received Live Heart Rate from band (CMD 0x%02X): $finalHr bpm".format(cmd))
                            sendEvent(mapOf(
                                "type" to "live_heart_rate",
                                "bpm" to finalHr
                            ))
                            if (activeMeasuringType == "heartRate" || activeMeasuringType == "oneKey") {
                                sendEvent(mapOf(
                                    "type" to "measurement_result",
                                    "measureType" to "heartRate",
                                    "hr" to finalHr
                                ))
                            }
                        }
                    }
                    0x69, 0xE9 -> {
                        // Active measurement response (StartHeartRateRsp)
                        // Layout: [0x69, measureType, errCode/status, value, (sbp), (dbp)...]
                        val mType = if (value.size > 1) (value[1].toInt() and 0xFF) else 0
                        val byte2 = if (value.size > 2) (value[2].toInt() and 0xFF) else -1
                        val rawVal = if (value.size > 3) (value[3].toInt() and 0xFF) else 0

                        val hrCandidate = when {
                            rawVal in 30..240 -> rawVal
                            byte2 in 30..240 -> byte2
                            else -> 0
                        }

                        if (byte2 == 0 || hrCandidate > 0) {
                            measuringTimeoutRunnable?.let {
                                mainHandler.removeCallbacks(it)
                                measuringTimeoutRunnable = null
                            }
                            when (mType) {
                                1 -> { // Heart Rate
                                    val hrToUse = if (hrCandidate > 0) hrCandidate else rawVal
                                    if (hrToUse in 30..240) {
                                        if (lastKnownRestingHeartRate == 0 || hrToUse < lastKnownRestingHeartRate) {
                                            lastKnownRestingHeartRate = hrToUse
                                            prefs.edit().putInt("last_known_resting_hr", hrToUse).apply()
                                        }
                                        sendEvent(mapOf(
                                            "type" to "measurement_result",
                                            "measureType" to "heartRate",
                                            "hr" to hrToUse
                                        ))
                                        sendEvent(mapOf(
                                            "type" to "live_heart_rate",
                                            "bpm" to hrToUse
                                        ))
                                    }
                                }
                                2 -> { // Blood Pressure
                                    val sbp = if (value.size > 4) (value[4].toInt() and 0xFF) else rawVal
                                    val dbp = if (value.size > 5) (value[5].toInt() and 0xFF) else 0
                                    if (sbp > 0) lastKnownSbp = sbp
                                    if (dbp > 0) lastKnownDbp = dbp
                                    prefs.edit().putInt("last_known_sbp", lastKnownSbp).putInt("last_known_dbp", lastKnownDbp).apply()
                                    sendEvent(mapOf(
                                        "type" to "measurement_result",
                                        "measureType" to "bloodPressure",
                                        "sbp" to lastKnownSbp,
                                        "dbp" to lastKnownDbp
                                    ))
                                }
                                3 -> { // Blood Oxygen
                                    if (rawVal in 70..100) {
                                        lastKnownBloodOxygen = rawVal.toDouble()
                                        prefs.edit().putFloat("last_known_spo2", rawVal.toFloat()).apply()
                                    }
                                    sendEvent(mapOf(
                                        "type" to "measurement_result",
                                        "measureType" to "bloodOxygen",
                                        "spo2" to rawVal
                                    ))
                                }
                                4 -> { // Temperature
                                    val tempVal = if (rawVal > 100) rawVal / 10.0 else rawVal.toDouble()
                                    if (tempVal > 30.0) {
                                        lastKnownSkinTemperature = tempVal
                                        prefs.edit().putFloat("last_known_temp", tempVal.toFloat()).apply()
                                    }
                                    sendEvent(mapOf(
                                        "type" to "measurement_result",
                                        "measureType" to "temperature",
                                        "temperature" to rawVal
                                    ))
                                }
                                5 -> { // Stress
                                    if (rawVal in 1..100) {
                                        lastKnownStressLevel = rawVal
                                        prefs.edit().putInt("last_known_stress", rawVal).apply()
                                    }
                                    sendEvent(mapOf(
                                        "type" to "measurement_result",
                                        "measureType" to "stress",
                                        "stress" to rawVal
                                    ))
                                }
                                6 -> { // HRV
                                    if (rawVal in 10..250) {
                                        lastKnownHrvMs = rawVal
                                        prefs.edit().putInt("last_known_hrv", rawVal).apply()
                                    }
                                    sendEvent(mapOf(
                                        "type" to "measurement_result",
                                        "measureType" to "hrv",
                                        "hrv" to rawVal
                                    ))
                                }
                            }
                        } else if (byte2 > 0) {
                            sendEvent(mapOf(
                                "type" to "measurement_fail",
                                "measureType" to (activeMeasuringType ?: "heartRate"),
                                "error" to "Band reported measurement error code $byte2. Please wear band snugly."
                            ))
                        }
                    }
                    0x6A, 0xEA -> {
                        Log.i(TAG, "QC Band confirmed stop measurement response (0x6A ACK)")
                    }
                    0x07, 0x87 -> {
                        // Realtime Sport / Workout Activity packet
                        // Byte layout in Oudmon protocol: [0x07, sportType, state, hr, step(3), cal(3), dist(3)...]
                        try {
                            if (value.size >= 4) {
                                val sportHr = value[3].toInt() and 0xFF
                                if (sportHr in 30..240) {
                                    sendEvent(mapOf(
                                        "type" to "live_heart_rate",
                                        "bpm" to sportHr
                                    ))
                                }
                            }
                        } catch (e: Exception) {
                            Log.w(TAG, "Error parsing sport packet 0x07: ${e.message}")
                        }
                    }
                    0x48, 0xC8 -> {
                        // Current day sport summary (steps, calories, distance) - Matches iOS OdmBandGetCurrentSportInfo
                        try {
                            if (value.size >= 13) {
                                val steps = ((value[1].toInt() and 0xFF) shl 16) or ((value[2].toInt() and 0xFF) shl 8) or (value[3].toInt() and 0xFF)
                                val runSteps = ((value[4].toInt() and 0xFF) shl 16) or ((value[5].toInt() and 0xFF) shl 8) or (value[6].toInt() and 0xFF)
                                val calories = ((value[7].toInt() and 0xFF) shl 16) or ((value[8].toInt() and 0xFF) shl 8) or (value[9].toInt() and 0xFF)
                                val distance = ((value[10].toInt() and 0xFF) shl 16) or ((value[11].toInt() and 0xFF) shl 8) or (value[12].toInt() and 0xFF)
                                if (steps > 0 || calories > 0 || distance > 0 || lastKnownSteps == 0) {
                                    lastKnownSteps = steps
                                    lastKnownCalories = calories
                                    lastKnownDistance = distance
                                    prefs.edit()
                                        .putInt("last_known_steps", steps)
                                        .putInt("last_known_calories", calories)
                                        .putInt("last_known_distance", distance)
                                        .apply()
                                    sendEvent(mapOf(
                                        "type" to "step_update",
                                        "steps" to steps,
                                        "calories" to calories,
                                        "distance" to distance
                                    ))
                                    Log.i(TAG, "QC Sport summary parsed (CMD 0x48, 13B): $steps steps, run=$runSteps, $calories kcal, $distance m")
                                }
                            } else if (value.size >= 10) {
                                val steps = ((value[1].toInt() and 0xFF) shl 16) or ((value[2].toInt() and 0xFF) shl 8) or (value[3].toInt() and 0xFF)
                                val calories = ((value[4].toInt() and 0xFF) shl 16) or ((value[5].toInt() and 0xFF) shl 8) or (value[6].toInt() and 0xFF)
                                val distance = ((value[7].toInt() and 0xFF) shl 16) or ((value[8].toInt() and 0xFF) shl 8) or (value[9].toInt() and 0xFF)
                                if (steps > 0 || calories > 0 || distance > 0 || lastKnownSteps == 0) {
                                    lastKnownSteps = steps
                                    lastKnownCalories = calories
                                    lastKnownDistance = distance
                                    prefs.edit()
                                        .putInt("last_known_steps", steps)
                                        .putInt("last_known_calories", calories)
                                        .putInt("last_known_distance", distance)
                                        .apply()
                                    sendEvent(mapOf(
                                        "type" to "step_update",
                                        "steps" to steps,
                                        "calories" to calories,
                                        "distance" to distance
                                    ))
                                    Log.i(TAG, "QC Sport summary parsed (CMD 0x48, 10B): $steps steps, $calories kcal, $distance m")
                                }
                            }
                        } finally {
                            onSyncPacketReceived(cmd)
                        }
                    }
                    0x02, 0x82 -> {
                        // Today sport data packet fallback
                        try {
                            if (value.size >= 13) {
                                val steps = ((value[1].toInt() and 0xFF) shl 16) or ((value[2].toInt() and 0xFF) shl 8) or (value[3].toInt() and 0xFF)
                                val runSteps = ((value[4].toInt() and 0xFF) shl 16) or ((value[5].toInt() and 0xFF) shl 8) or (value[6].toInt() and 0xFF)
                                val calories = ((value[7].toInt() and 0xFF) shl 16) or ((value[8].toInt() and 0xFF) shl 8) or (value[9].toInt() and 0xFF)
                                val distance = ((value[10].toInt() and 0xFF) shl 16) or ((value[11].toInt() and 0xFF) shl 8) or (value[12].toInt() and 0xFF)
                                if (steps > 0 || calories > 0 || distance > 0 || lastKnownSteps == 0) {
                                    lastKnownSteps = steps
                                    lastKnownCalories = calories
                                    lastKnownDistance = distance
                                    prefs.edit()
                                        .putInt("last_known_steps", steps)
                                        .putInt("last_known_calories", calories)
                                        .putInt("last_known_distance", distance)
                                        .apply()
                                    sendEvent(mapOf(
                                        "type" to "step_update",
                                        "steps" to steps,
                                        "calories" to calories,
                                        "distance" to distance
                                    ))
                                    Log.i(TAG, "QC Sport fallback parsed (CMD 0x02, 13B): $steps steps, run=$runSteps, $calories kcal, $distance m")
                                }
                            } else if (value.size >= 10) {
                                val steps = ((value[1].toInt() and 0xFF) shl 16) or ((value[2].toInt() and 0xFF) shl 8) or (value[3].toInt() and 0xFF)
                                val calories = ((value[4].toInt() and 0xFF) shl 16) or ((value[5].toInt() and 0xFF) shl 8) or (value[6].toInt() and 0xFF)
                                val distance = ((value[7].toInt() and 0xFF) shl 16) or ((value[8].toInt() and 0xFF) shl 8) or (value[9].toInt() and 0xFF)
                                if (steps > 0 || calories > 0 || distance > 0 || lastKnownSteps == 0) {
                                    lastKnownSteps = steps
                                    lastKnownCalories = calories
                                    lastKnownDistance = distance
                                    prefs.edit()
                                        .putInt("last_known_steps", steps)
                                        .putInt("last_known_calories", calories)
                                        .putInt("last_known_distance", distance)
                                        .apply()
                                    sendEvent(mapOf(
                                        "type" to "step_update",
                                        "steps" to steps,
                                        "calories" to calories,
                                        "distance" to distance
                                    ))
                                    Log.i(TAG, "QC Sport fallback parsed (CMD 0x02, 10B): $steps steps, $calories kcal, $distance m")
                                }
                            }
                        } finally {
                            onSyncPacketReceived(cmd)
                        }
                    }
                    0x03, 0x83 -> {
                        // Battery packet
                        try {
                            if (value.size >= 3) {
                                val battery = value[1].toInt() and 0xFF
                                val charging = value[2].toInt() != 0
                                if (battery in 0..100) {
                                    currentBatteryPercentage = battery
                                    val data = mapOf("battery" to battery, "charging" to charging)
                                    val pending = pendingBatteryResult
                                    pendingBatteryResult = null
                                    pending?.success(data)
                                    sendEvent(mapOf("type" to "battery_update") + data)
                                }
                            }
                        } finally {
                            onSyncPacketReceived(cmd)
                        }
                    }
                    0x15, 0x95, 0x05, 0x85 -> {
                        // QC Scheduled 24h Heart Rate History (matches iOS OdmBandGetSchedualHeartRateData)
                        var isFinished = false
                        try {
                            if (value.size >= 3) {
                                val packetIdx = value[1].toInt() and 0xFF
                                if (packetIdx != 0xEE) {
                                    if (packetIdx == 0) {
                                        // Header packet: value[2] = total packets, value[3] = interval in minutes
                                        lastKnownHeartRateHistory.clear()
                                        Log.d(TAG, "QC HeartRateHistory header: totalPackets=${value[2].toInt() and 0xFF}, interval=${value[3].toInt() and 0xFF}")
                                    } else if (packetIdx != 0xFF) {
                                        // Data packet: value[2..14] are heart rate readings (13 samples per packet)
                                        var minNonZero = lastKnownRestingHeartRate
                                        for (i in 2 until value.size - 1) {
                                            val bpm = value[i].toInt() and 0xFF
                                            if (bpm in 35..220) {
                                                if (minNonZero == 0 || bpm < minNonZero) {
                                                    minNonZero = bpm
                                                }
                                                lastKnownHeartRateHistory.add(mapOf(
                                                    "bpm" to bpm,
                                                    "timestamp" to "sample#${lastKnownHeartRateHistory.size + 1}"
                                                ))
                                            }
                                        }
                                        if (minNonZero > 0) {
                                            lastKnownRestingHeartRate = minNonZero
                                            prefs.edit().putInt("last_known_resting_hr", minNonZero).apply()
                                        }
                                        Log.i(TAG, "QC HeartRateHistory packet $packetIdx: accumulated ${lastKnownHeartRateHistory.size} samples, resting=$minNonZero bpm")
                                    } else {
                                        // packetIdx == 0xFF: End of HR history transmission
                                        isFinished = true
                                        Log.i(TAG, "QC HeartRateHistory complete (CMD 0x%02X): ${lastKnownHeartRateHistory.size} total samples, resting=$lastKnownRestingHeartRate bpm".format(cmd))
                                    }
                                } else {
                                    isFinished = true
                                    Log.d(TAG, "QC HeartRateHistory: No historical HR data recorded for today (code 0xEE)")
                                }
                            }
                        } catch (e: Exception) {
                            Log.w(TAG, "Error parsing QC HR history packet: ${e.message}")
                            isFinished = true
                        } finally {
                            if (isFinished) {
                                onSyncPacketReceived(cmd)
                            }
                        }
                    }
                    0x0D, 0x8D -> {
                        // QC Scheduled Blood Pressure - Systolic (matches iOS OdmBandGetBPHistoryData Stage 0)
                        // Multi-packet: header(idx=0) → data(idx=1..N) → EOF(0xFF/0xEE)
                        // Use debounce for data packets; immediate advance for EOF/no-data
                        // Guard: if current sync step is bpDiastolic, ignore residual systolic packets
                        val currentStepId = if (isSyncInProgress && currentSyncStepIndex < activeSyncSteps.size) activeSyncSteps[currentSyncStepIndex].id else ""
                        if (currentStepId == "bpDiastolic") {
                            Log.d(TAG, "QC Systolic BP: Ignoring residual 0x0D packet during bpDiastolic step")
                        } else {
                            var isFinished = false
                            try {
                                if (value.size >= 3) {
                                    val packetIdx = value[1].toInt() and 0xFF
                                    if (packetIdx == 0xFF || packetIdx == 0xEE) {
                                        isFinished = true
                                        Log.d(TAG, "QC Systolic BP: End of packets (0x%02X)".format(packetIdx))
                                    } else if (packetIdx == 0) {
                                        // Header packet: reset per-step timeout to wait for data packets
                                        Log.d(TAG, "QC Systolic BP: Header packet received (resetting timeout for data packets)")
                                        syncStepTimeoutRunnable?.let { mainHandler.removeCallbacks(it) }
                                        val step = if (currentSyncStepIndex < activeSyncSteps.size) activeSyncSteps[currentSyncStepIndex] else null
                                        val stepTimeout = step?.timeoutMs ?: 3000L
                                        val timeoutRunnable = Runnable {
                                            Log.w(TAG, "QC Systolic BP: Data timeout after header. Advancing.")
                                            advanceSyncStep()
                                        }
                                        syncStepTimeoutRunnable = timeoutRunnable
                                        mainHandler.postDelayed(timeoutRunnable, stepTimeout)
                                    } else {
                                        var count = 0
                                        for (i in 2 until value.size - 1) {
                                            val sbp = value[i].toInt() and 0xFF
                                            if (sbp in 60..240) {
                                                lastKnownSbp = sbp
                                                prefs.edit().putInt("last_known_sbp", sbp).apply()
                                                count++
                                            }
                                        }
                                        Log.i(TAG, "QC Systolic BP parsed (CMD 0x0D, packet $packetIdx): sbp=$lastKnownSbp mmHg (read $count samples)")
                                        scheduleSyncAdvanceDebounce(cmd, 500L)
                                    }
                                }
                            } finally {
                                if (isFinished) {
                                    onSyncPacketReceived(cmd)
                                }
                            }
                        }
                    }
                    0x0E, 0x8E -> {
                        // QC Scheduled Blood Pressure - Diastolic (matches iOS OdmBandGetBPHistoryData Stage 1)
                        // Multi-packet: header(idx=0) → data(idx=1..N) → EOF(0xFF/0xEE)
                        var isFinished = false
                        try {
                            if (value.size >= 3) {
                                val packetIdx = value[1].toInt() and 0xFF
                                if (packetIdx == 0xFF || packetIdx == 0xEE) {
                                    isFinished = true
                                    Log.d(TAG, "QC Diastolic BP: End of packets (0x%02X)".format(packetIdx))
                                } else if (packetIdx == 0) {
                                    // Header packet: reset per-step timeout to wait for data packets
                                    Log.d(TAG, "QC Diastolic BP: Header packet received (resetting timeout for data packets)")
                                    syncStepTimeoutRunnable?.let { mainHandler.removeCallbacks(it) }
                                    val step = if (currentSyncStepIndex < activeSyncSteps.size) activeSyncSteps[currentSyncStepIndex] else null
                                    val stepTimeout = step?.timeoutMs ?: 3000L
                                    val timeoutRunnable = Runnable {
                                        Log.w(TAG, "QC Diastolic BP: Data timeout after header. Advancing.")
                                        advanceSyncStep()
                                    }
                                    syncStepTimeoutRunnable = timeoutRunnable
                                    mainHandler.postDelayed(timeoutRunnable, stepTimeout)
                                } else {
                                    var count = 0
                                    for (i in 2 until value.size - 1) {
                                        val dbp = value[i].toInt() and 0xFF
                                        if (dbp in 40..160) {
                                            lastKnownDbp = dbp
                                            prefs.edit().putInt("last_known_dbp", dbp).apply()
                                            count++
                                        }
                                    }
                                    Log.i(TAG, "QC Diastolic BP parsed (CMD 0x0E, packet $packetIdx): dbp=$lastKnownDbp mmHg (read $count samples)")
                                    scheduleSyncAdvanceDebounce(cmd, 500L)
                                }
                            }
                        } finally {
                            if (isFinished) {
                                onSyncPacketReceived(cmd)
                            }
                        }
                    }
                    0x14, 0x94 -> {
                        // QC Manual Blood Pressure History (matches iOS OdmBandGetManualBloodPressureHistoryData)
                        // Layout: [0x14, ts0, ts1, ts2, ts3, dbp, sbp, ...]
                        var isFinished = false
                        try {
                            if (value.size >= 7) {
                                val b1 = value[1].toInt() and 0xFF
                                val b2 = value[2].toInt() and 0xFF
                                if (b1 == 0xFF && b2 == 0xFF) {
                                    isFinished = true
                                    Log.d(TAG, "QC Manual Blood Pressure: End of records (0xFFFF)")
                                } else {
                                    val dbp = value[5].toInt() and 0xFF
                                    val sbp = value[6].toInt() and 0xFF
                                    if (sbp in 60..240 && dbp in 40..160) {
                                        lastKnownSbp = sbp
                                        lastKnownDbp = dbp
                                        prefs.edit().putInt("last_known_sbp", sbp).putInt("last_known_dbp", dbp).apply()
                                        Log.i(TAG, "QC Manual Blood Pressure parsed (CMD 0x14): $sbp/$dbp mmHg")
                                    }
                                    scheduleSyncAdvanceDebounce(cmd, 400L)
                                }
                            }
                        } finally {
                            if (isFinished) {
                                onSyncPacketReceived(cmd)
                            }
                        }
                    }
                    0x2A, 0xAA, 0x2C, 0xAC, 0x06, 0x86 -> {
                        // QC Blood Oxygen (SpO2) standard query (matches iOS QCBloodOxygenList / OdmBandSchedualBloodOxgyenInfo)
                        try {
                            if (value.size >= 2) {
                                val statusByte = value[1].toInt() and 0xFF
                                if (statusByte != 0xEE && statusByte != 0xFF) {
                                    var foundSpo2 = 0
                                    for (i in 1 until value.size) {
                                        val spo2 = value[i].toInt() and 0xFF
                                        if (spo2 in 70..100) {
                                            foundSpo2 = spo2
                                        }
                                    }
                                    if (foundSpo2 > 0) {
                                        lastKnownBloodOxygen = foundSpo2.toDouble()
                                        prefs.edit().putFloat("last_known_spo2", foundSpo2.toFloat()).apply()
                                        Log.i(TAG, "QC SpO2 parsed (CMD 0x%02X): ${lastKnownBloodOxygen}%%".format(cmd))
                                    }
                                } else {
                                    Log.d(TAG, "QC SpO2 standard query: No data (status=0x%02X)".format(statusByte))
                                }
                            }
                        } finally {
                            onSyncPacketReceived(cmd)
                        }
                    }
                    0xBC -> {
                        // QC Long Packet / DFU Protocol (matches iOS QCDFU_Utils / QCBloodOxygenList)
                        // Layout: [0xBC, type, lenLow, lenHigh, crcLow, crcHigh, payload...]
                        try {
                            if (value.size >= 6) {
                                val type = value[1].toInt() and 0xFF
                                val len = (value[2].toInt() and 0xFF) or ((value[3].toInt() and 0xFF) shl 8)
                                Log.d(TAG, "QC DFU/LongPacket received: type=0x%02X, len=$len, totalBytes=${value.size}".format(type))
                                when (type) {
                                    0x2A, 0x49, 0x5F -> {
                                        // Blood oxygen list (0x2A), manual blood oxygen (0x49), interval blood oxygen (0x5F)
                                        var foundSpo2 = 0
                                        for (i in 6 until value.size) {
                                            val spo2 = value[i].toInt() and 0xFF
                                            if (spo2 in 70..100) {
                                                foundSpo2 = spo2
                                            }
                                        }
                                        if (foundSpo2 > 0) {
                                            lastKnownBloodOxygen = foundSpo2.toDouble()
                                            prefs.edit().putFloat("last_known_spo2", foundSpo2.toFloat()).apply()
                                            Log.i(TAG, "QC SpO2 parsed from DFU packet (type 0x%02X): ${lastKnownBloodOxygen}%%".format(type))
                                        } else {
                                            Log.d(TAG, "QC DFU SpO2: No valid SpO2 values in payload (type 0x%02X)".format(type))
                                        }
                                    }
                                    else -> {
                                        Log.d(TAG, "QC DFU: Unhandled type 0x%02X (len=$len)".format(type))
                                    }
                                }
                            } else if (value.size >= 2) {
                                // Short DFU response — likely an error/no-data indicator
                                val type = value[1].toInt() and 0xFF
                                Log.d(TAG, "QC DFU: Short response (${value.size} bytes), type=0x%02X — no data available".format(type))
                            }
                        } finally {
                            onSyncPacketReceived(cmd)
                        }
                    }
                    0x37, 0xB7 -> {
                        // QC Stress Level (matches iOS QCGetScheualStressData)
                        // Multi-packet: band sends 5+ packets. Use debounce to collect all data
                        // before advancing, preventing race conditions with subsequent steps.
                        try {
                            if (value.size >= 3) {
                                val statusByte = value[1].toInt() and 0xFF
                                if (statusByte == 0xEE || statusByte == 0xFF) {
                                    Log.d(TAG, "QC Stress: No data (status=0x%02X)".format(statusByte))
                                    onSyncPacketReceived(cmd)
                                } else {
                                    for (i in 2 until value.size - 1) {
                                        val stress = value[i].toInt() and 0xFF
                                        if (stress in 1..100) {
                                            lastKnownStressLevel = stress
                                            prefs.edit().putInt("last_known_stress", stress).apply()
                                        }
                                    }
                                    Log.i(TAG, "QC Stress Level parsed (CMD 0x37): $lastKnownStressLevel")
                                    // Use debounce: more stress packets may follow
                                    scheduleSyncAdvanceDebounce(cmd, 500L)
                                }
                            }
                        } catch (e: Exception) {
                            Log.w(TAG, "Error parsing stress packet: ${e.message}")
                            onSyncPacketReceived(cmd)
                        }
                    }
                    0x39, 0xB9, 0x2D, 0xAD -> {
                        // QC HRV (matches iOS QCGetScheualHRVDataCmd)
                        // Multi-packet: header(idx=0) → data(idx=1..N) → EOF(0xFF/0xEE)
                        // Header packet may contain HRV data starting at byte 3.
                        // Data packets contain HRV values starting at byte 2.
                        // Use debounce to wait for all packets before advancing.
                        var isFinished = false
                        try {
                            if (value.size >= 3) {
                                val packetIdx = value[1].toInt() and 0xFF
                                if (packetIdx == 0xFF || packetIdx == 0xEE) {
                                    isFinished = true
                                    Log.d(TAG, "QC HRV: End of packets (0x%02X), final HRV=${lastKnownHrvMs}ms".format(packetIdx))
                                } else if (packetIdx == 0) {
                                    // Header packet: byte[2]=totalPackets, bytes[3..]=first HRV values
                                    val totalPackets = value[2].toInt() and 0xFF
                                    Log.d(TAG, "QC HRV: Header packet received (totalPackets=$totalPackets)")
                                    if (totalPackets == 0) {
                                        isFinished = true
                                    } else {
                                        // Parse any HRV data embedded in the header packet (bytes 3+)
                                        for (i in 3 until value.size) {
                                            val hrv = value[i].toInt() and 0xFF
                                            if (hrv in 10..250) {
                                                lastKnownHrvMs = hrv
                                                prefs.edit().putInt("last_known_hrv", hrv).apply()
                                            }
                                        }
                                        Log.d(TAG, "QC HRV: Header parsed, current HRV=${lastKnownHrvMs}ms (waiting for data packets)")
                                        // Reset step timeout to wait for subsequent data packets
                                        syncStepTimeoutRunnable?.let { mainHandler.removeCallbacks(it) }
                                        val step = if (currentSyncStepIndex < activeSyncSteps.size) activeSyncSteps[currentSyncStepIndex] else null
                                        val stepTimeout = step?.timeoutMs ?: 3000L
                                        val timeoutRunnable = Runnable {
                                            Log.w(TAG, "QC HRV: Data timeout after header. Advancing with HRV=${lastKnownHrvMs}ms")
                                            advanceSyncStep()
                                        }
                                        syncStepTimeoutRunnable = timeoutRunnable
                                        mainHandler.postDelayed(timeoutRunnable, stepTimeout)
                                    }
                                } else {
                                    // Data packet: bytes[2..] are HRV readings
                                    for (i in 2 until value.size) {
                                        val hrv = value[i].toInt() and 0xFF
                                        if (hrv in 10..250) {
                                            lastKnownHrvMs = hrv
                                            prefs.edit().putInt("last_known_hrv", hrv).apply()
                                        }
                                    }
                                    Log.i(TAG, "QC HRV parsed (CMD 0x39, packet $packetIdx): ${lastKnownHrvMs}ms")
                                    // Use debounce: more data packets may follow
                                    scheduleSyncAdvanceDebounce(cmd, 500L)
                                }
                            }
                        } finally {
                            if (isFinished) {
                                onSyncPacketReceived(cmd)
                            }
                        }
                    }
                    0x44, 0xC4, 0x04, 0x84 -> {
                        // QC Sleep packet (total sleep, deep sleep, sleep phases) - Matches iOS OdmBandGetSleepDetailInfo
                        try {
                            if (value.size >= 3) {
                                val errByte = value[1].toInt() and 0xFF
                                if (errByte != 0xEE && errByte != 0xFF && value.size >= 4) {
                                    val totalMinutes = ((value[1].toInt() and 0xFF) shl 8) or (value[2].toInt() and 0xFF)
                                    val deepMinutes = if (value.size >= 6) {
                                        ((value[3].toInt() and 0xFF) shl 8) or (value[4].toInt() and 0xFF)
                                    } else {
                                        (totalMinutes * 0.25).toInt()
                                    }
                                    if (totalMinutes in 10..1200) {
                                        lastKnownSleepMinutes = totalMinutes
                                        lastKnownDeepSleepMinutes = deepMinutes
                                        prefs.edit()
                                            .putInt("last_known_sleep_minutes", lastKnownSleepMinutes)
                                            .putInt("last_known_deep_sleep_minutes", lastKnownDeepSleepMinutes)
                                            .apply()
                                        Log.i(TAG, "QC Sleep parsed: total=$totalMinutes min, deep=$deepMinutes min")
                                    }
                                    if (value.size >= 8) {
                                        val phaseType = value[3].toInt() and 0xFF
                                        val duration = value[4].toInt() and 0xFF
                                        if (duration > 0) {
                                            val phaseMap = mapOf<String, Any>(
                                                "type" to phaseType,
                                                "startTime" to "",
                                                "endTime" to "",
                                                "durationMinutes" to duration
                                            )
                                            lastKnownSleepPhases.add(phaseMap)
                                        }
                                    }
                                } else {
                                    Log.d(TAG, "QC Sleep: No historical sleep data recorded for today")
                                }
                            }
                        } catch (e: Exception) {
                            Log.w(TAG, "Error parsing QC sleep packet: ${e.message}")
                        } finally {
                            onSyncPacketReceived(cmd)
                        }
                    }
                    0x25, 0xA5 -> {
                        // QC Skin Temperature (matches iOS QCSchedualTemperatureList - NOT 08 which is shutdown!)
                        try {
                            if (value.size >= 3) {
                                val statusByte = value[1].toInt() and 0xFF
                                if (statusByte != 0xEE && statusByte != 0xFF) {
                                    val rawTemp = if (value.size >= 4) {
                                        ((value[2].toInt() and 0xFF) shl 8) or (value[3].toInt() and 0xFF)
                                    } else {
                                        value[2].toInt() and 0xFF
                                    }
                                    val temp = if (rawTemp in 300..450) rawTemp / 10.0 else if (rawTemp in 30..45) rawTemp.toDouble() else 0.0
                                    if (temp > 0.0) {
                                        lastKnownSkinTemperature = temp
                                        prefs.edit().putFloat("last_known_temp", temp.toFloat()).apply()
                                        Log.i(TAG, "QC Skin Temperature parsed: $temp°C")
                                    }
                                }
                            }
                        } finally {
                            onSyncPacketReceived(cmd)
                        }
                    }
                    0x10 -> {
                        Log.i(TAG, "QC Band confirmed binding vibration response (0x10 ACK)")
                    }
                    0x16 -> {
                        Log.i(TAG, "QC Band confirmed scheduled heart rate setting (0x16 ACK)")
                    }
                }
            }
        }
    }

    private fun resolveQcCharacteristics(gatt: BluetoothGatt) {
        qcTxCharacteristic = null
        qcRxCharacteristic = null
        qcTx2Characteristic = null
        qcRx2Characteristic = null

        // 1. Check primary QC Service 1
        val s1 = gatt.getService(QC_SERVICE_UUID_1)
        if (s1 != null) {
            qcTxCharacteristic = s1.getCharacteristic(QC_CHAR_TX)
            qcRxCharacteristic = s1.getCharacteristic(QC_CHAR_RX)
        }

        // 2. Check primary QC Service 2 (DFU / Long packet service)
        val s2 = gatt.getService(QC_SERVICE_UUID_2)
        if (s2 != null) {
            qcTx2Characteristic = s2.getCharacteristic(QC_CHAR_TX_2)
            qcRx2Characteristic = s2.getCharacteristic(QC_CHAR_RX_2)
            if (qcTxCharacteristic == null) qcTxCharacteristic = qcTx2Characteristic
            if (qcRxCharacteristic == null) qcRxCharacteristic = qcRx2Characteristic
        }

        // 3. Fallback: Search all discovered services
        if (qcTxCharacteristic == null || qcRxCharacteristic == null || qcTx2Characteristic == null || qcRx2Characteristic == null) {
            for (service in gatt.services) {
                val sUuid = service.uuid.toString().lowercase()
                for (charac in service.characteristics) {
                    val cUuid = charac.uuid.toString().lowercase()
                    if (qcTxCharacteristic == null && (
                        cUuid.startsWith("6e400002") || 
                        ((charac.properties and (BluetoothGattCharacteristic.PROPERTY_WRITE or BluetoothGattCharacteristic.PROPERTY_WRITE_NO_RESPONSE)) != 0 && sUuid.contains("fff0"))
                    )) {
                        qcTxCharacteristic = charac
                        Log.i(TAG, "Located QC TX characteristic via fallback: ${charac.uuid}")
                    }
                    if (qcRxCharacteristic == null && (
                        cUuid.startsWith("6e400003") || 
                        ((charac.properties and BluetoothGattCharacteristic.PROPERTY_NOTIFY) != 0 && sUuid.contains("fff0"))
                    )) {
                        qcRxCharacteristic = charac
                        Log.i(TAG, "Located QC RX characteristic via fallback: ${charac.uuid}")
                    }
                    if (qcTx2Characteristic == null && cUuid.startsWith("de5bf72a")) {
                        qcTx2Characteristic = charac
                        Log.i(TAG, "Located QC TX2 (DFU) characteristic via fallback: ${charac.uuid}")
                    }
                    if (qcRx2Characteristic == null && cUuid.startsWith("de5bf729")) {
                        qcRx2Characteristic = charac
                        Log.i(TAG, "Located QC RX2 (DFU) characteristic via fallback: ${charac.uuid}")
                    }
                }
            }
        }
        Log.i(TAG, "Resolved QC Characteristics: TX=${qcTxCharacteristic?.uuid}, RX=${qcRxCharacteristic?.uuid}, TX2=${qcTx2Characteristic?.uuid}, RX2=${qcRx2Characteristic?.uuid}")
    }

    private fun buildQcPacket(hexString: String): ByteArray {
        val cleanHex = hexString.replace(" ", "").uppercase()
        val byteCount = cleanHex.length / 2
        // DFU Long packet (matches iOS QCDFU_Utils)
        if (cleanHex.startsWith("BC")) {
            val packet = ByteArray(byteCount)
            for (i in 0 until byteCount) {
                packet[i] = cleanHex.substring(i * 2, i * 2 + 2).toInt(16).toByte()
            }
            return packet
        }
        val packet = ByteArray(16)
        var sum = 0
        for (i in 0 until byteCount) {
            val byteVal = cleanHex.substring(i * 2, i * 2 + 2).toInt(16)
            packet[i] = byteVal.toByte()
            sum += byteVal
        }
        packet[15] = (sum and 0xFF).toByte()
        return packet
    }

    /**
     * Direct write — bypasses the queue. Used ONLY inside queued lambdas.
     * Returns true if the BLE stack accepted the write.
     */
    private fun writeQcPacketDirect(packet: ByteArray): Boolean {
        val gatt = connectedGatt ?: return false
        val isDfuPacket = packet.isNotEmpty() && (packet[0].toInt() and 0xFF) == 0xBC
        val txChar = if (isDfuPacket && qcTx2Characteristic != null) qcTx2Characteristic!! else (qcTxCharacteristic ?: return false)

        // Oudmon SDK WriteRequest.execute always uses WRITE_TYPE_DEFAULT (type=2, write with response).
        val writeType = if ((txChar.properties and BluetoothGattCharacteristic.PROPERTY_WRITE) != 0) {
            BluetoothGattCharacteristic.WRITE_TYPE_DEFAULT
        } else if ((txChar.properties and BluetoothGattCharacteristic.PROPERTY_WRITE_NO_RESPONSE) != 0) {
            BluetoothGattCharacteristic.WRITE_TYPE_NO_RESPONSE
        } else {
            BluetoothGattCharacteristic.WRITE_TYPE_DEFAULT
        }

        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                val res = gatt.writeCharacteristic(txChar, packet, writeType)
                Log.d(TAG, "writeQcPacketDirect (API33+) char=${txChar.uuid}, writeType=$writeType, result=$res, packet=${packet.joinToString("") { "%02X".format(it) }}")
                val ok = res == android.bluetooth.BluetoothStatusCodes.SUCCESS
                if (ok && writeType == BluetoothGattCharacteristic.WRITE_TYPE_NO_RESPONSE) {
                    mainHandler.postDelayed({ onGattOpComplete("char-write-no-resp") }, 50L)
                }
                ok
            } else {
                @Suppress("DEPRECATION")
                txChar.value = packet
                @Suppress("DEPRECATION")
                txChar.writeType = writeType
                @Suppress("DEPRECATION")
                val ok = gatt.writeCharacteristic(txChar)
                Log.d(TAG, "writeQcPacketDirect (legacy) char=${txChar.uuid}, writeType=$writeType, result=$ok, packet=${packet.joinToString("") { "%02X".format(it) }}")
                if (ok && writeType == BluetoothGattCharacteristic.WRITE_TYPE_NO_RESPONSE) {
                    mainHandler.postDelayed({ onGattOpComplete("char-write-no-resp") }, 50L)
                }
                ok
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error writing QC packet: ${e.message}")
            false
        }
    }

    /**
     * Public write — enqueues through the serial GATT queue.
     * Used by on-demand operations (findBand, manual battery reads, etc.).
     */
    private fun writeQcPacket(packet: ByteArray): Boolean {
        enqueueGattOp(OpType.CHAR_WRITE, "writeQcPacket") {
            writeQcPacketDirect(packet)
        }
        return true // enqueued successfully
    }

    private fun sendLookupDeviceVibration(): Boolean {
        // Oudmon FindDeviceReq: key=0x50, subData=[0x55, 0xAA]
        enqueueGattOp(OpType.CHAR_WRITE, "find-device-vibration") {
            val packet = buildQcPacket("5055AA")
            val ok = writeQcPacketDirect(packet)
            Log.i(TAG, "sendLookupDeviceVibration sent packet='5055AA' (FindDeviceReq), success=$ok")
            ok
        }
        return true
    }

    private fun sendSetTime(): Boolean {
        enqueueGattOp(OpType.CHAR_WRITE, "set-time-manual") {
            val calendar = Calendar.getInstance()
            val year = calendar.get(Calendar.YEAR) % 100
            val month = calendar.get(Calendar.MONTH) + 1
            val day = calendar.get(Calendar.DAY_OF_MONTH)
            val hour = calendar.get(Calendar.HOUR_OF_DAY)
            val minute = calendar.get(Calendar.MINUTE)
            val second = calendar.get(Calendar.SECOND)
            val timeHex = String.format("01%02d%02d%02d%02d%02d%02d", year, month, day, hour, minute, second)
            val packet = buildQcPacket(timeHex)
            val ok = writeQcPacketDirect(packet)
            Log.i(TAG, "sendSetTime sent timeHex='$timeHex', success=$ok")
            ok
        }
        return true
    }

    private fun sendReadBattery(): Boolean {
        enqueueGattOp(OpType.CHAR_WRITE, "read-battery-qc") {
            val packet = buildQcPacket("03")
            val ok = writeQcPacketDirect(packet)
            Log.i(TAG, "sendReadBattery sent packet='03', success=$ok")
            ok
        }
        return true
    }

    private fun readBattery(result: MethodChannel.Result) {
        val gatt = connectedGatt
        val standardChar = batteryCharacteristic
        if (gatt != null && standardChar != null) {
            if (pendingBatteryResult != null) {
                result.error("BATTERY_READ_IN_PROGRESS", "A battery read is already in progress", null)
                return
            }
            pendingBatteryResult = result
            if (!gatt.readCharacteristic(standardChar)) {
                pendingBatteryResult = null
                sendReadBattery()
                result.success(mapOf("battery" to (currentBatteryPercentage ?: 0), "charging" to false))
            }
        } else if (qcTxCharacteristic != null) {
            if (pendingBatteryResult != null) {
                result.error("BATTERY_READ_IN_PROGRESS", "A battery read is already in progress", null)
                return
            }
            pendingBatteryResult = result
            sendReadBattery()
            mainHandler.postDelayed({
                val cb = pendingBatteryResult ?: return@postDelayed
                pendingBatteryResult = null
                cb.success(mapOf("battery" to (currentBatteryPercentage ?: 0), "charging" to false))
            }, 2000L)
        } else {
            result.error("BATTERY_UNAVAILABLE", "The connected band does not expose battery characteristics", null)
        }
    }

    private fun startRealtimeHeartRateQc(): Boolean {
        val gatt = connectedGatt ?: return false
        if (qcTxCharacteristic == null && heartRateCharacteristic == null) return false
        isLiveHeartRateActive = true

        // Ensure notifications on RX are enabled
        val rxChar = qcRxCharacteristic
        if (rxChar != null) {
            gatt.setCharacteristicNotification(rxChar, true)
        }
        val hrChar = heartRateCharacteristic
        if (hrChar != null) {
            enableNotifications(gatt, hrChar)
        }

        if (qcTxCharacteristic != null) {
            // Step 1: Send RealTimeHeartRate START (CMD 0x1E, subCmd 0x01)
            enqueueGattOp(OpType.CHAR_WRITE, "qc-realtime-hr-start") {
                val packet = buildQcPacket("1E01")
                val ok = writeQcPacketDirect(packet)
                Log.i(TAG, "startRealtimeHeartRateQc packet='1E01' enqueued, success=$ok")
                ok
            }

            // Step 2: Trigger optical PPG green LEDs on the band (CMD 0x69, type 0x01, sub 0x00)
            // On QC Wireless / Oudmon firmware, CMD 0x690100 explicitly commands the sensor MCU
            // to turn on the green optical PPG LEDs and begin active sampling.
            enqueueGattOp(OpType.CHAR_WRITE, "qc-realtime-hr-sensor-on") {
                val packet = buildQcPacket("690100")
                val ok = writeQcPacketDirect(packet)
                Log.i(TAG, "startRealtimeHeartRateQc packet='690100' (PPG Green LEDs ON), success=$ok")
                ok
            }

            // Repeating keep-alive timer (every 10s) sending CMD 0x1E03 (Hold)
            // QC Wireless band turns off the optical PPG LEDs after ~20s unless refreshed.
            realtimeHrHoldRunnable?.let { mainHandler.removeCallbacks(it) }
            val holdTask = object : Runnable {
                override fun run() {
                    if (!isLiveHeartRateActive || connectedGatt == null || qcTxCharacteristic == null) return
                    enqueueGattOp(OpType.CHAR_WRITE, "qc-realtime-hr-hold") {
                        val packet = buildQcPacket("1E03")
                        val ok = writeQcPacketDirect(packet)
                        Log.d(TAG, "sendRealtimeHeartRateHold packet='1E03' (PPG Keep-Alive), success=$ok")
                        ok
                    }
                    mainHandler.postDelayed(this, 10_000L)
                }
            }
            realtimeHrHoldRunnable = holdTask
            mainHandler.postDelayed(holdTask, 10_000L)
        }
        return true
    }

    private fun stopRealtimeHeartRateQc(): Boolean {
        isLiveHeartRateActive = false
        realtimeHrHoldRunnable?.let {
            mainHandler.removeCallbacks(it)
            realtimeHrHoldRunnable = null
        }
        if (connectedGatt != null && qcTxCharacteristic != null) {
            enqueueGattOp(OpType.CHAR_WRITE, "qc-realtime-hr-end") {
                val packet = buildQcPacket("1E02")
                val ok = writeQcPacketDirect(packet)
                Log.i(TAG, "stopRealtimeHeartRateQc packet='1E02' (Continuous HR End), success=$ok")
                ok
            }
            enqueueGattOp(OpType.CHAR_WRITE, "qc-realtime-hr-sensor-off") {
                val packet = buildQcPacket("6A0100")
                val ok = writeQcPacketDirect(packet)
                Log.i(TAG, "stopRealtimeHeartRateQc packet='6A0100' (PPG Green LEDs OFF), success=$ok")
                ok
            }
        }
        return true
    }

    private fun startStepPolling() {
        stopStepPolling()
        val pollTask = object : Runnable {
            override fun run() {
                val gatt = connectedGatt
                if (gatt != null && qcTxCharacteristic != null) {
                    if (gattQueue.isEmpty() && !gattBusy && !isSyncInProgress && activeMeasuringType == null && !isLiveHeartRateActive) {
                        enqueueGattOp(OpType.CHAR_WRITE, "poll-sport-48") {
                            val packet = buildQcPacket("48")
                            writeQcPacketDirect(packet)
                        }
                    }
                    mainHandler.postDelayed(this, 15_000L)
                } else {
                    stopStepPolling()
                }
            }
        }
        stepPollRunnable = pollTask
        mainHandler.postDelayed(pollTask, 15_000L)
    }

    private fun stopStepPolling() {
        stepPollRunnable?.let { mainHandler.removeCallbacks(it) }
        stepPollRunnable = null
    }

    private fun startMeasuringQc(type: String): Boolean {
        if (connectedGatt == null || qcTxCharacteristic == null) return false
        activeMeasuringType = type
        measuringTimeoutRunnable?.let { mainHandler.removeCallbacks(it) }
        val timeout = Runnable {
            if (activeMeasuringType != null) {
                sendEvent(mapOf(
                    "type" to "measurement_fail",
                    "measureType" to activeMeasuringType,
                    "error" to "Measurement timed out. Ensure the band is worn snugly."
                ))
                activeMeasuringType = null
            }
        }
        measuringTimeoutRunnable = timeout
        mainHandler.postDelayed(timeout, 90_000L)

        when (type) {
            "bloodOxygen" -> {
                enqueueGattOp(OpType.CHAR_WRITE, "start-measuring-spo2") {
                    val packet = buildQcPacket("690300")
                    writeQcPacketDirect(packet)
                }
            }
            "bloodPressure" -> {
                enqueueGattOp(OpType.CHAR_WRITE, "start-measuring-bp") {
                    val packet = buildQcPacket("690200")
                    writeQcPacketDirect(packet)
                }
            }
            "temperature" -> {
                enqueueGattOp(OpType.CHAR_WRITE, "start-measuring-temp") {
                    val packet = buildQcPacket("690400")
                    writeQcPacketDirect(packet)
                }
            }
            "stress" -> {
                enqueueGattOp(OpType.CHAR_WRITE, "start-measuring-stress") {
                    val packet = buildQcPacket("690500")
                    writeQcPacketDirect(packet)
                }
            }
            "hrv" -> {
                enqueueGattOp(OpType.CHAR_WRITE, "start-measuring-hrv") {
                    val packet = buildQcPacket("690600")
                    writeQcPacketDirect(packet)
                }
            }
            else -> {
                // Heart rate / oneKey: activate optical PPG LEDs via 1E01 & 690100
                enqueueGattOp(OpType.CHAR_WRITE, "start-measuring-hr-ppg") {
                    val packet = buildQcPacket("1E01")
                    writeQcPacketDirect(packet)
                }
                enqueueGattOp(OpType.CHAR_WRITE, "start-measuring-cmd-69") {
                    val packet = buildQcPacket("690100")
                    writeQcPacketDirect(packet)
                }
            }
        }
        return true
    }

    private fun stopMeasuringQc(type: String): Boolean {
        measuringTimeoutRunnable?.let {
            mainHandler.removeCallbacks(it)
            measuringTimeoutRunnable = null
        }
        activeMeasuringType = null
        when (type) {
            "bloodOxygen" -> {
                enqueueGattOp(OpType.CHAR_WRITE, "stop-measuring-spo2") {
                    val packet = buildQcPacket("6A0300")
                    writeQcPacketDirect(packet)
                }
            }
            "bloodPressure" -> {
                enqueueGattOp(OpType.CHAR_WRITE, "stop-measuring-bp") {
                    val packet = buildQcPacket("6A0200")
                    writeQcPacketDirect(packet)
                }
            }
            "temperature" -> {
                enqueueGattOp(OpType.CHAR_WRITE, "stop-measuring-temp") {
                    val packet = buildQcPacket("6A0400")
                    writeQcPacketDirect(packet)
                }
            }
            "stress" -> {
                enqueueGattOp(OpType.CHAR_WRITE, "stop-measuring-stress") {
                    val packet = buildQcPacket("6A0500")
                    writeQcPacketDirect(packet)
                }
            }
            "hrv" -> {
                enqueueGattOp(OpType.CHAR_WRITE, "stop-measuring-hrv") {
                    val packet = buildQcPacket("6A0600")
                    writeQcPacketDirect(packet)
                }
            }
            else -> {
                enqueueGattOp(OpType.CHAR_WRITE, "stop-measuring-hr") {
                    val packet = buildQcPacket("1E02")
                    writeQcPacketDirect(packet)
                }
                enqueueGattOp(OpType.CHAR_WRITE, "stop-measuring-cmd-6a") {
                    val packet = buildQcPacket("6A0100")
                    writeQcPacketDirect(packet)
                }
            }
        }
        return true
    }

    private fun syncFullHealthData(result: MethodChannel.Result) {
        startSequentialHealthSync(result)
    }

    private fun enableNotifications(gatt: BluetoothGatt, characteristic: BluetoothGattCharacteristic): Boolean {
        // Queue-based: used only for on-demand notification enables outside the init pipeline
        enqueueGattOp(OpType.DESCRIPTOR_WRITE, "enable-notifications-${characteristic.uuid}") {
            if (!gatt.setCharacteristicNotification(characteristic, true)) return@enqueueGattOp false
            val cccd = characteristic.getDescriptor(CCCD_UUID) ?: return@enqueueGattOp false
            cccd.value = BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE
            gatt.writeDescriptor(cccd)
        }
        return true
    }

    private fun publishBattery(
        characteristic: BluetoothGattCharacteristic,
        callback: MethodChannel.Result? = null
    ) {
        val battery = characteristic.getIntValue(BluetoothGattCharacteristic.FORMAT_UINT8, 0)
        if (battery == null || battery !in 0..100) {
            callback?.error("BATTERY_INVALID", "The band returned an invalid battery level", null)
            return
        }
        currentBatteryPercentage = battery
        val data = mapOf("battery" to battery, "charging" to false)
        callback?.success(data)
        sendEvent(mapOf("type" to "battery_update") + data)
    }

    private fun openLocationSettings() {
        try {
            val intent = Intent(android.provider.Settings.ACTION_LOCATION_SOURCE_SETTINGS).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            activity.startActivity(intent)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to open location settings", e)
        }
    }

    private fun requestEnableBluetooth() {
        try {
            val btSettingsIntent = Intent(android.provider.Settings.ACTION_BLUETOOTH_SETTINGS).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            activity.startActivity(btSettingsIntent)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to open bluetooth settings, trying ACTION_REQUEST_ENABLE", e)
            try {
                val enableBtIntent = Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                activity.startActivity(enableBtIntent)
            } catch (e2: Exception) {
                Log.e(TAG, "Failed to request enable bluetooth, fallback to app settings", e2)
                openAppSettings()
            }
        }
    }

    private fun openBluetoothSettings() {
        try {
            val intent = Intent(android.provider.Settings.ACTION_BLUETOOTH_SETTINGS).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            activity.startActivity(intent)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to open bluetooth settings, fallback to app settings", e)
            openAppSettings()
        }
    }

    private fun openAppSettings() {
        try {
            val intent = Intent(android.provider.Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = android.net.Uri.fromParts("package", activity.packageName, null)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            activity.startActivity(intent)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to open app settings", e)
        }
    }
}
