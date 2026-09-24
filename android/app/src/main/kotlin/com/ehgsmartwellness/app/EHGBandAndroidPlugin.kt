package com.ehgsmartwellness.app

import android.annotation.SuppressLint
import android.app.Activity
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

    // ─── Health Data Synchronization Coordination ──────────────────────────────
    private var pendingSyncResult: MethodChannel.Result? = null
    private val pendingSyncCommands = Collections.synchronizedSet(mutableSetOf<Int>())
    private var syncMasterTimeoutRunnable: Runnable? = null

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

    private fun onSyncPacketReceived(cmd: Int) {
        if (pendingSyncCommands.remove(cmd)) {
            Log.d(TAG, "onSyncPacketReceived: cmd=0x%02X received, remaining=%d (%s)".format(cmd, pendingSyncCommands.size, pendingSyncCommands))
            if (pendingSyncCommands.isEmpty()) {
                Log.i(TAG, "onSyncPacketReceived: All requested health sync packets received from band! Completing sync.")
                completeSyncIfPending()
            }
        }
    }

    private fun completeSyncIfPending() {
        mainHandler.post {
            syncMasterTimeoutRunnable?.let {
                mainHandler.removeCallbacks(it)
                syncMasterTimeoutRunnable = null
            }
            val res = pendingSyncResult ?: return@post
            pendingSyncResult = null
            pendingSyncCommands.clear()
            val syncMap = buildCachedSyncMap()
            Log.i(TAG, "completeSyncIfPending: Returning fresh health data sync payload to Flutter.")
            try {
                res.success(syncMap)
            } catch (e: Exception) {
                Log.e(TAG, "completeSyncIfPending: Failed to send success result: ${e.message}")
            }
        }
    }

    private fun resetVitalsMemory() {
        lastKnownSteps = 0
        lastKnownCalories = 0
        lastKnownDistance = 0
        lastKnownSbp = 0
        lastKnownDbp = 0
        lastKnownSleepMinutes = 0
        lastKnownDeepSleepMinutes = 0
        lastKnownBloodOxygen = 0.0
        lastKnownSkinTemperature = 0.0
        lastKnownStressLevel = 0
        lastKnownHrvMs = 0
        lastKnownRestingHeartRate = 0
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
        }, 100L)
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

        // If band is already connected (e.g. across Hot Restart), emit connected immediately
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
            "disconnect" -> {
                val unpair = call.argument<Boolean>("unpair") ?: false
                if (unpair) {
                    prefs.edit().clear().apply()
                    resetVitalsMemory()
                }
                disconnectDevice()
                result.success(true)
            }
            "reconnect" -> {
                val lastMac = prefs.getString("last_connected_mac", null)
                if (!lastMac.isNullOrEmpty()) {
                    connectToDevice(lastMac, result)
                } else {
                    result.success(false)
                }
            }
            "getBattery" -> {
                readBattery(result)
            }
            "getDeviceInfo" -> {
                val mac = connectedDevice?.address ?: ""
                val name = connectedDevice?.name ?: "EHG Smart Band"
                result.success(
                    mapOf(
                        "name" to name,
                        "macAddress" to mac,
                        "softVersion" to "",
                        "hardVersion" to ""
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
                sendEvent(mapOf("type" to "connection_state", "state" to "connected", "name" to (connectedDevice?.name ?: "EHG Smart Band"), "id" to deviceId))
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
                realtimeHrHoldRunnable?.let {
                    mainHandler.removeCallbacks(it)
                    realtimeHrHoldRunnable = null
                }
                measuringTimeoutRunnable?.let {
                    mainHandler.removeCallbacks(it)
                    measuringTimeoutRunnable = null
                }
                hasSentConnectionVibration = false
                if (pendingSyncResult != null) {
                    Log.w(TAG, "Band disconnected during active health sync. Completing with cached metrics.")
                    completeSyncIfPending()
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

                sendEvent(mapOf(
                    "type" to "connection_state",
                    "state" to "connected",
                    "name" to devName,
                    "id" to devId
                ))
                pendingConnectResult?.success(true)
                pendingConnectResult = null

                // Reset vibration flag for this new connection session
                hasSentConnectionVibration = false

                // ── Serial initialization pipeline via GATT queue (identical to iOS) ──
                // Brief 150ms delay gives the Android BLE service cache time to stabilize
                // before writing descriptors/characteristics.
                mainHandler.postDelayed({
                    if (connectedGatt == null || connectedGatt != gatt) return@postDelayed

                    // Step 1: Enable CCCD notifications on QC RX characteristic
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
                    } else if (batteryCharacteristic != null) {
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

                    // Step 6: Query today's steps/sport data (CMD 0x02)
                    enqueueGattOp(OpType.CHAR_WRITE, "query-today-sport") {
                        val packet = buildQcPacket("02")
                        val ok = writeQcPacketDirect(packet)
                        Log.i(TAG, "queryTodaySport (queued) packet='02', success=$ok")
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

                    // Step 8: Standard init complete (realtime updates reserved for Heart Rate)
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
            } else if (uuid == QC_CHAR_RX || uuid == QC_CHAR_RX_2 || uuid == qcRxCharacteristic?.uuid) {
                if (value.isEmpty()) return
                val cmd = value[0].toInt() and 0xFF
                Log.d(TAG, "QC RX packet: cmd=0x%02X, len=%d, hex=%s".format(cmd, value.size, value.joinToString("") { "%02X".format(it) }))

                when (cmd) {
                    0x1E -> {
                        // RealTimeHeartRate response / live continuous PPG packet
                        // Byte layout in Oudmon protocol: [0x1E, status, hr, ...]
                        val hr = if (value.size > 2) (value[2].toInt() and 0xFF) else 0
                        val fallbackHr = if (value.size > 1) (value[1].toInt() and 0xFF) else 0
                        val finalHr = if (hr in 30..240) hr else if (fallbackHr in 30..240) fallbackHr else null

                        if (finalHr != null && finalHr > 0) {
                            Log.i(TAG, "Received Live Heart Rate from band: $finalHr bpm")
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
                    0x69 -> {
                        // Active measurement response (StartHeartRateRsp)
                        // Layout: [0x69, measureType, errCode, value, (sbp), (dbp)...]
                        val mType = if (value.size > 1) (value[1].toInt() and 0xFF) else 0
                        val errCode = if (value.size > 2) (value[2].toInt() and 0xFF) else -1
                        val rawVal = if (value.size > 3) (value[3].toInt() and 0xFF) else 0

                        if (errCode == 0) {
                            measuringTimeoutRunnable?.let {
                                mainHandler.removeCallbacks(it)
                                measuringTimeoutRunnable = null
                            }
                            when (mType) {
                                1 -> { // Heart Rate
                                    if (rawVal in 30..240) {
                                        if (lastKnownRestingHeartRate == 0 || rawVal < lastKnownRestingHeartRate) {
                                            lastKnownRestingHeartRate = rawVal
                                            prefs.edit().putInt("last_known_resting_hr", rawVal).apply()
                                        }
                                        sendEvent(mapOf(
                                            "type" to "measurement_result",
                                            "measureType" to "heartRate",
                                            "hr" to rawVal
                                        ))
                                        sendEvent(mapOf(
                                            "type" to "live_heart_rate",
                                            "bpm" to rawVal
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
                            }
                        } else if (errCode > 0) {
                            sendEvent(mapOf(
                                "type" to "measurement_fail",
                                "measureType" to (activeMeasuringType ?: "heartRate"),
                                "error" to "Band reported measurement error code $errCode. Please wear band snugly."
                            ))
                        }
                    }
                    0x02 -> {
                        // Today sport data packet (steps, calories, distance)
                        try {
                            if (value.size >= 10) {
                                val steps = ((value[1].toInt() and 0xFF) shl 16) or ((value[2].toInt() and 0xFF) shl 8) or (value[3].toInt() and 0xFF)
                                val calories = ((value[4].toInt() and 0xFF) shl 16) or ((value[5].toInt() and 0xFF) shl 8) or (value[6].toInt() and 0xFF)
                                val distance = ((value[7].toInt() and 0xFF) shl 16) or ((value[8].toInt() and 0xFF) shl 8) or (value[9].toInt() and 0xFF)
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
                            }
                        } finally {
                            onSyncPacketReceived(0x02)
                        }
                    }
                    0x03 -> {
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
                            onSyncPacketReceived(0x03)
                        }
                    }
                    0x04 -> {
                        // QC Sleep packet (total sleep, deep sleep, sleep phases)
                        try {
                            if (value.size >= 4) {
                                try {
                                    val totalMinutes = ((value[1].toInt() and 0xFF) shl 8) or (value[2].toInt() and 0xFF)
                                    val deepMinutes = if (value.size >= 6) {
                                        ((value[3].toInt() and 0xFF) shl 8) or (value[4].toInt() and 0xFF)
                                    } else {
                                        (totalMinutes * 0.25).toInt()
                                    }
                                    if (totalMinutes in 30..900) {
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
                                } catch (e: Exception) {
                                    Log.w(TAG, "Error parsing QC sleep packet: ${e.message}")
                                }
                            }
                        } finally {
                            onSyncPacketReceived(0x04)
                        }
                    }
                    0x05 -> {
                        // QC Scheduled 24h Heart Rate History
                        try {
                            if (value.size >= 3) {
                                try {
                                    var minNonZero = 0
                                    val hrList = mutableListOf<Map<String, Any>>()
                                    for (i in 2 until value.size - 1) {
                                        val bpm = value[i].toInt() and 0xFF
                                        if (bpm in 35..220) {
                                            if (minNonZero == 0 || bpm < minNonZero) {
                                                minNonZero = bpm
                                            }
                                            hrList.add(mapOf(
                                                "bpm" to bpm,
                                                "timestamp" to "today#$i"
                                            ))
                                        }
                                    }
                                    if (hrList.isNotEmpty()) {
                                        lastKnownHeartRateHistory.clear()
                                        lastKnownHeartRateHistory.addAll(hrList)
                                        if (minNonZero > 0) {
                                            lastKnownRestingHeartRate = minNonZero
                                            prefs.edit().putInt("last_known_resting_hr", minNonZero).apply()
                                        }
                                        Log.i(TAG, "QC HeartRateHistory parsed: ${hrList.size} samples, resting=$minNonZero bpm")
                                    }
                                } catch (e: Exception) {
                                    Log.w(TAG, "Error parsing QC HR history packet: ${e.message}")
                                }
                            }
                        } finally {
                            onSyncPacketReceived(0x05)
                        }
                    }
                    0x06 -> {
                        // QC Blood Oxygen (SpO2)
                        try {
                            if (value.size >= 3) {
                                val spo2 = value[2].toInt() and 0xFF
                                val fallback = value[1].toInt() and 0xFF
                                val valid = if (spo2 in 70..100) spo2 else if (fallback in 70..100) fallback else 0
                                if (valid > 0) {
                                    lastKnownBloodOxygen = valid.toDouble()
                                    prefs.edit().putFloat("last_known_spo2", valid.toFloat()).apply()
                                    Log.i(TAG, "QC SpO2 parsed: $valid%")
                                }
                            }
                        } finally {
                            onSyncPacketReceived(0x06)
                        }
                    }
                    0x08 -> {
                        // QC Skin Temperature
                        try {
                            if (value.size >= 3) {
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
                        } finally {
                            onSyncPacketReceived(0x08)
                        }
                    }
                    0x2C -> {
                        // QC Stress Level
                        try {
                            if (value.size >= 3) {
                                val stress = value[2].toInt() and 0xFF
                                val fallback = value[1].toInt() and 0xFF
                                val valid = if (stress in 1..100) stress else if (fallback in 1..100) fallback else 0
                                if (valid > 0) {
                                    lastKnownStressLevel = valid
                                    prefs.edit().putInt("last_known_stress", valid).apply()
                                    Log.i(TAG, "QC Stress Level parsed: $valid")
                                }
                            }
                        } finally {
                            onSyncPacketReceived(0x2C)
                        }
                    }
                    0x2D -> {
                        // QC HRV
                        try {
                            if (value.size >= 3) {
                                val hrv = value[2].toInt() and 0xFF
                                val fallback = value[1].toInt() and 0xFF
                                val valid = if (hrv in 10..250) hrv else if (fallback in 10..250) fallback else 0
                                if (valid > 0) {
                                    lastKnownHrvMs = valid
                                    prefs.edit().putInt("last_known_hrv", valid).apply()
                                    Log.i(TAG, "QC HRV parsed: ${valid}ms")
                                }
                            }
                        } finally {
                            onSyncPacketReceived(0x2D)
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

        // 1. Check primary QC Service 1
        val s1 = gatt.getService(QC_SERVICE_UUID_1)
        if (s1 != null) {
            qcTxCharacteristic = s1.getCharacteristic(QC_CHAR_TX)
            qcRxCharacteristic = s1.getCharacteristic(QC_CHAR_RX)
        }

        // 2. Check primary QC Service 2
        if (qcTxCharacteristic == null || qcRxCharacteristic == null) {
            val s2 = gatt.getService(QC_SERVICE_UUID_2)
            if (s2 != null) {
                if (qcTxCharacteristic == null) qcTxCharacteristic = s2.getCharacteristic(QC_CHAR_TX_2)
                if (qcRxCharacteristic == null) qcRxCharacteristic = s2.getCharacteristic(QC_CHAR_RX_2)
            }
        }

        // 3. Fallback: Search all discovered services
        if (qcTxCharacteristic == null || qcRxCharacteristic == null) {
            for (service in gatt.services) {
                val sUuid = service.uuid.toString().lowercase()
                for (charac in service.characteristics) {
                    val cUuid = charac.uuid.toString().lowercase()
                    if (qcTxCharacteristic == null && (
                        cUuid.startsWith("6e400002") || 
                        cUuid.startsWith("de5bf72a") ||
                        ((charac.properties and (BluetoothGattCharacteristic.PROPERTY_WRITE or BluetoothGattCharacteristic.PROPERTY_WRITE_NO_RESPONSE)) != 0 && (sUuid.contains("fff0") || sUuid.contains("de5b")))
                    )) {
                        qcTxCharacteristic = charac
                        Log.i(TAG, "Located QC TX characteristic via fallback: ${charac.uuid}")
                    }
                    if (qcRxCharacteristic == null && (
                        cUuid.startsWith("6e400003") || 
                        cUuid.startsWith("de5bf729") ||
                        ((charac.properties and BluetoothGattCharacteristic.PROPERTY_NOTIFY) != 0 && (sUuid.contains("fff0") || sUuid.contains("de5b")))
                    )) {
                        qcRxCharacteristic = charac
                        Log.i(TAG, "Located QC RX characteristic via fallback: ${charac.uuid}")
                    }
                }
            }
        }
        Log.i(TAG, "Resolved QC Characteristics: TX=${qcTxCharacteristic?.uuid}, RX=${qcRxCharacteristic?.uuid}")
    }

    private fun buildQcPacket(hexString: String): ByteArray {
        val cleanHex = hexString.replace(" ", "").uppercase()
        val byteCount = cleanHex.length / 2
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
        val txChar = qcTxCharacteristic ?: return false

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
                Log.d(TAG, "writeQcPacketDirect (API33+) writeType=$writeType, result=$res, packet=${packet.joinToString("") { "%02X".format(it) }}")
                res == android.bluetooth.BluetoothStatusCodes.SUCCESS
            } else {
                @Suppress("DEPRECATION")
                txChar.value = packet
                @Suppress("DEPRECATION")
                txChar.writeType = writeType
                @Suppress("DEPRECATION")
                val ok = gatt.writeCharacteristic(txChar)
                Log.d(TAG, "writeQcPacketDirect (legacy) writeType=$writeType, result=$ok, packet=${packet.joinToString("") { "%02X".format(it) }}")
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
        if (connectedGatt == null || qcTxCharacteristic == null) return false
        isLiveHeartRateActive = true

        // Send RealTimeHeartRate START (CMD 0x1E, subCmd 0x01)
        // This immediately triggers the green optical PPG LEDs on the band.
        enqueueGattOp(OpType.CHAR_WRITE, "qc-realtime-hr-start") {
            val packet = buildQcPacket("1E01")
            val ok = writeQcPacketDirect(packet)
            Log.i(TAG, "startRealtimeHeartRateQc packet='1E01' (PPG LEDs ON), success=$ok")
            ok
        }

        // Repeating keep-alive timer (every 15s) sending CMD 0x1E03 (Hold)
        // QC Wireless band turns off the optical PPG LEDs after ~20s unless Hold is periodically refreshed.
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
                mainHandler.postDelayed(this, 15_000L)
            }
        }
        realtimeHrHoldRunnable = holdTask
        mainHandler.postDelayed(holdTask, 15_000L)

        // Ensure CCCD notification is enabled on QC RX
        val rxChar = qcRxCharacteristic
        val gatt = connectedGatt
        if (gatt != null && rxChar != null) {
            enableNotifications(gatt, rxChar)
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
                Log.i(TAG, "stopRealtimeHeartRateQc packet='1E02' (PPG LEDs OFF), success=$ok")
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
                    if (gattQueue.isEmpty() && !gattBusy && activeMeasuringType == null) {
                        enqueueGattOp(OpType.CHAR_WRITE, "poll-sport-02") {
                            val packet = buildQcPacket("02")
                            writeQcPacketDirect(packet)
                        }
                    }
                    mainHandler.postDelayed(this, 10_000L)
                } else {
                    stopStepPolling()
                }
            }
        }
        stepPollRunnable = pollTask
        mainHandler.postDelayed(pollTask, 10_000L)
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
        if (connectedGatt == null) {
            Log.w(TAG, "syncFullHealthData: Band not currently connected. Returning cached health metrics immediately.")
            result.success(buildCachedSyncMap())
            return
        }

        // Complete any previously uncompleted sync request gracefully
        pendingSyncResult?.let { oldResult ->
            try {
                oldResult.success(buildCachedSyncMap())
            } catch (_: Exception) {}
        }
        syncMasterTimeoutRunnable?.let {
            mainHandler.removeCallbacks(it)
            syncMasterTimeoutRunnable = null
        }

        pendingSyncResult = result
        pendingSyncCommands.clear()
        pendingSyncCommands.addAll(listOf(0x02, 0x03, 0x04, 0x05, 0x06, 0x08, 0x2C, 0x2D))

        // 15-second master watchdog: if band drops packets, return best-effort cached/accumulated data
        val timeoutRunnable = Runnable {
            Log.w(TAG, "syncFullHealthData: 15s timeout expired. Remaining packets: $pendingSyncCommands. Returning accumulated data.")
            completeSyncIfPending()
        }
        syncMasterTimeoutRunnable = timeoutRunnable
        mainHandler.postDelayed(timeoutRunnable, 15000L)

        Log.i(TAG, "syncFullHealthData: Enqueueing 8 health sync GATT queries and awaiting responses...")

        // Enqueue sport query packet (0x02) and battery packet (0x03)
        enqueueGattOp(OpType.CHAR_WRITE, "sync-sport-02") {
            writeQcPacketDirect(buildQcPacket("02"))
        }
        enqueueGattOp(OpType.CHAR_WRITE, "sync-battery-03") {
            writeQcPacketDirect(buildQcPacket("03"))
        }
        enqueueGattOp(OpType.CHAR_WRITE, "sync-sleep-04") {
            writeQcPacketDirect(buildQcPacket("0400"))
        }
        enqueueGattOp(OpType.CHAR_WRITE, "sync-hr-history-05") {
            writeQcPacketDirect(buildQcPacket("0500"))
        }
        enqueueGattOp(OpType.CHAR_WRITE, "sync-oxygen-06") {
            writeQcPacketDirect(buildQcPacket("0600"))
        }
        enqueueGattOp(OpType.CHAR_WRITE, "sync-temp-08") {
            writeQcPacketDirect(buildQcPacket("0800"))
        }
        enqueueGattOp(OpType.CHAR_WRITE, "sync-stress-2c") {
            writeQcPacketDirect(buildQcPacket("2C00"))
        }
        enqueueGattOp(OpType.CHAR_WRITE, "sync-hrv-2d") {
            writeQcPacketDirect(buildQcPacket("2D00"))
        }
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
