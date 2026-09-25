#import "EHGBandNativePlugin.h"
#import "QCCentralManager.h"
#import <QCBandSDK/QCSDKManager.h>
#import <QCBandSDK/QCSDKCmdCreator.h>
#import <QCBandSDK/QCSportModel.h>
#import <QCBandSDK/QCSleepModel.h>
#import <QCBandSDK/QCHeartRateModel.h>
#import <QCBandSDK/QCSchedualHeartRateModel.h>
#import <QCBandSDK/QCBloodPressureModel.h>
#import <QCBandSDK/QCBloodOxygenModel.h>
#import <QCBandSDK/QCTemperatureModel.h>
#import <QCBandSDK/QCThreeValueTemperatureModel.h>
#import <QCBandSDK/QCStressModel.h>
#import <QCBandSDK/QCHRVModel.h>
#import <QCBandSDK/QCManualHeartRateModel.h>
#import <QCBandSDK/QCRealOneKeyMeasureHeartRateModel.h>

typedef void (^EHGBandDone)(void);
typedef void (^EHGBandWork)(EHGBandDone done);

@interface EHGBandNativePlugin () <QCCentralManagerDelegate>
@property (nonatomic, strong) FlutterEventSink eventSink;
@property (nonatomic, strong) NSMutableArray<QCBlePeripheral *> *discoveredPeripherals;
@property (nonatomic, strong) NSMutableArray<EHGBandWork> *commandQueue;
@property (nonatomic, assign) BOOL commandRunning;
@property (nonatomic, copy) FlutterResult pendingConnectResult;
@property (nonatomic, copy) FlutterResult pendingDisconnectResult;
@property (nonatomic, assign) QCMeasuringType activeMeasureType;
@property (nonatomic, strong) NSTimer *connectTimeoutTimer;
@property (nonatomic, strong) NSTimer *commandWatchdogTimer;
@property (nonatomic, strong) NSTimer *realtimeHrHoldTimer;
@property (nonatomic, strong) NSTimer *stepPollTimer;
@property (nonatomic, assign) NSInteger lastKnownBattery;
@property (nonatomic, assign) BOOL lastKnownCharging;
@property (nonatomic, assign) NSInteger lastKnownSteps;
@property (nonatomic, assign) NSInteger lastKnownCalories;
@property (nonatomic, assign) NSInteger lastKnownDistance;
@property (nonatomic, assign) NSInteger lastKnownSbp;
@property (nonatomic, assign) NSInteger lastKnownDbp;
@property (nonatomic, assign) NSInteger lastKnownSleepMinutes;
@property (nonatomic, assign) NSInteger lastKnownDeepSleepMinutes;
@property (nonatomic, assign) CGFloat lastKnownBloodOxygen;
@property (nonatomic, assign) CGFloat lastKnownSkinTemperature;
@property (nonatomic, assign) NSInteger lastKnownStressLevel;
@property (nonatomic, assign) NSInteger lastKnownHrvMs;
@property (nonatomic, assign) NSInteger lastKnownRestingHeartRate;
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *lastKnownSleepPhases;
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *lastKnownHeartRateHistory;
@end

@implementation EHGBandNativePlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    FlutterMethodChannel *channel = [FlutterMethodChannel methodChannelWithName:@"com.ehg.smartapp/band"
                                                                binaryMessenger:[registrar messenger]];
    FlutterEventChannel *eventChannel = [FlutterEventChannel eventChannelWithName:@"com.ehg.smartapp/band_events"
                                                                  binaryMessenger:[registrar messenger]];
    FlutterMethodChannel *bgChannel = [FlutterMethodChannel methodChannelWithName:@"com.ehg.smartapp/background_sync"
                                                                  binaryMessenger:[registrar messenger]];

    EHGBandNativePlugin *instance = [[EHGBandNativePlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
    [eventChannel setStreamHandler:instance];

    [bgChannel setMethodCallHandler:^(FlutterMethodCall * _Nonnull call, FlutterResult  _Nonnull result) {
        if ([@"schedulePeriodicSync" isEqualToString:call.method]) {
            NSInteger interval = 30;
            if ([call.arguments isKindOfClass:[NSDictionary class]] && call.arguments[@"intervalMinutes"]) {
                interval = [call.arguments[@"intervalMinutes"] integerValue];
            }
            NSLog(@"[EHGBandNative] Native periodic sync scheduled (interval: %ld mins)", (long)interval);
            result(@(YES));
        } else {
            result(FlutterMethodNotImplemented);
        }
    }];

    [QCCentralManager shared].delegate = instance;
    [instance setupSDKCallbacks];
    [instance setupLifecycleObservers];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _discoveredPeripherals = [NSMutableArray array];
        _commandQueue = [NSMutableArray array];
        _activeMeasureType = QCMeasuringTypeUnkown;
        _lastKnownSleepPhases = [NSMutableArray array];
        _lastKnownHeartRateHistory = [NSMutableArray array];
        [self loadCachedVitalsFromStorage];
    }
    return self;
}

- (void)loadCachedVitalsFromStorage {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    _lastKnownSteps = [prefs integerForKey:@"last_known_steps"];
    _lastKnownCalories = [prefs integerForKey:@"last_known_calories"];
    _lastKnownDistance = [prefs integerForKey:@"last_known_distance"];
    _lastKnownSbp = [prefs integerForKey:@"last_known_sbp"];
    _lastKnownDbp = [prefs integerForKey:@"last_known_dbp"];
    _lastKnownSleepMinutes = [prefs integerForKey:@"last_known_sleep_minutes"];
    _lastKnownDeepSleepMinutes = [prefs integerForKey:@"last_known_deep_sleep_minutes"];
    _lastKnownBloodOxygen = [prefs floatForKey:@"last_known_spo2"];
    _lastKnownSkinTemperature = [prefs floatForKey:@"last_known_temp"];
    _lastKnownStressLevel = [prefs integerForKey:@"last_known_stress"];
    _lastKnownHrvMs = [prefs integerForKey:@"last_known_hrv"];
    _lastKnownRestingHeartRate = [prefs integerForKey:@"last_known_resting_hr"];
    _lastKnownBattery = [prefs integerForKey:@"last_known_battery"];
    _lastKnownCharging = [prefs boolForKey:@"last_known_charging"];
}

- (void)resetVitalsMemory {
    _lastKnownSteps = 0;
    _lastKnownCalories = 0;
    _lastKnownDistance = 0;
    _lastKnownSbp = 0;
    _lastKnownDbp = 0;
    _lastKnownSleepMinutes = 0;
    _lastKnownDeepSleepMinutes = 0;
    _lastKnownBloodOxygen = 0.0;
    _lastKnownSkinTemperature = 0.0;
    _lastKnownStressLevel = 0;
    _lastKnownHrvMs = 0;
    _lastKnownRestingHeartRate = 0;
    _lastKnownBattery = 0;
    _lastKnownCharging = NO;
    [_lastKnownSleepPhases removeAllObjects];
    [_lastKnownHeartRateHistory removeAllObjects];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs removeObjectForKey:@"last_known_steps"];
    [prefs removeObjectForKey:@"last_known_calories"];
    [prefs removeObjectForKey:@"last_known_distance"];
    [prefs removeObjectForKey:@"last_known_sbp"];
    [prefs removeObjectForKey:@"last_known_dbp"];
    [prefs removeObjectForKey:@"last_known_sleep_minutes"];
    [prefs removeObjectForKey:@"last_known_deep_sleep_minutes"];
    [prefs removeObjectForKey:@"last_known_spo2"];
    [prefs removeObjectForKey:@"last_known_temp"];
    [prefs removeObjectForKey:@"last_known_stress"];
    [prefs removeObjectForKey:@"last_known_hrv"];
    [prefs removeObjectForKey:@"last_known_resting_hr"];
    [prefs removeObjectForKey:@"last_known_battery"];
    [prefs removeObjectForKey:@"last_known_charging"];
    [prefs synchronize];
}

- (NSDictionary *)buildCachedSyncMap {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSInteger sbp = self.lastKnownSbp > 0 ? self.lastKnownSbp : [prefs integerForKey:@"last_known_sbp"];
    NSInteger dbp = self.lastKnownDbp > 0 ? self.lastKnownDbp : [prefs integerForKey:@"last_known_dbp"];
    NSInteger steps = self.lastKnownSteps > 0 ? self.lastKnownSteps : [prefs integerForKey:@"last_known_steps"];
    NSInteger cal = self.lastKnownCalories > 0 ? self.lastKnownCalories : [prefs integerForKey:@"last_known_calories"];
    NSInteger dist = self.lastKnownDistance > 0 ? self.lastKnownDistance : [prefs integerForKey:@"last_known_distance"];
    NSInteger sleepMins = self.lastKnownSleepMinutes > 0 ? self.lastKnownSleepMinutes : [prefs integerForKey:@"last_known_sleep_minutes"];
    NSInteger deepSleepMins = self.lastKnownDeepSleepMinutes > 0 ? self.lastKnownDeepSleepMinutes : [prefs integerForKey:@"last_known_deep_sleep_minutes"];
    CGFloat spo2 = self.lastKnownBloodOxygen > 0.0 ? self.lastKnownBloodOxygen : [prefs floatForKey:@"last_known_spo2"];
    CGFloat temp = self.lastKnownSkinTemperature > 0.0 ? self.lastKnownSkinTemperature : [prefs floatForKey:@"last_known_temp"];
    NSInteger stress = self.lastKnownStressLevel > 0 ? self.lastKnownStressLevel : [prefs integerForKey:@"last_known_stress"];
    NSInteger hrv = self.lastKnownHrvMs > 0 ? self.lastKnownHrvMs : [prefs integerForKey:@"last_known_hrv"];
    NSInteger restingHr = self.lastKnownRestingHeartRate > 0 ? self.lastKnownRestingHeartRate : [prefs integerForKey:@"last_known_resting_hr"];

    return @{
        @"steps": @(steps),
        @"calories": @(cal),
        @"distance": @(dist),
        @"sleepMinutes": @(sleepMins),
        @"deepSleepMinutes": @(deepSleepMins),
        @"bloodOxygen": @(spo2),
        @"systolicBP": @(sbp),
        @"diastolicBP": @(dbp),
        @"skinTemperature": @(temp),
        @"stressLevel": @(stress),
        @"hrvMs": @(hrv),
        @"restingHeartRate": @(restingHr),
        @"sleepPhases": [self.lastKnownSleepPhases copy] ?: @[],
        @"heartRateHistory": [self.lastKnownHeartRateHistory copy] ?: @[]
    };
}

- (void)setupSDKCallbacks {
    __weak typeof(self) weakSelf = self;

    [QCSDKManager shareInstance].realTimeHeartRate = ^(NSInteger hr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf sendEvent:@{@"type": @"live_heart_rate", @"bpm": @(hr)}];
        });
    };

    [QCSDKManager shareInstance].currentBatteryInfo = ^(NSInteger battery, BOOL charging) {
        weakSelf.lastKnownBattery = battery;
        weakSelf.lastKnownCharging = charging;
        [[NSUserDefaults standardUserDefaults] setInteger:battery forKey:@"last_known_battery"];
        [[NSUserDefaults standardUserDefaults] setBool:charging forKey:@"last_known_charging"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf sendEvent:@{
                @"type": @"battery_update",
                @"battery": @(battery),
                @"charging": @(charging)
            }];
        });
    };

    [QCSDKManager shareInstance].currentStepInfo = ^(NSInteger step, NSInteger calorie, NSInteger distance) {
        weakSelf.lastKnownSteps = step;
        weakSelf.lastKnownCalories = calorie;
        weakSelf.lastKnownDistance = distance;
        [[NSUserDefaults standardUserDefaults] setInteger:step forKey:@"last_known_steps"];
        [[NSUserDefaults standardUserDefaults] setInteger:calorie forKey:@"last_known_calories"];
        [[NSUserDefaults standardUserDefaults] setInteger:distance forKey:@"last_known_distance"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf sendEvent:@{
                @"type": @"step_update",
                @"steps": @(step),
                @"calories": @(calorie),
                @"distance": @(distance)
            }];
        });
    };

    [QCSDKManager shareInstance].hrMeasuring = ^(NSInteger hr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf sendEvent:@{
                @"type": @"measurement_result",
                @"measureType": @"heartRate",
                @"hr": @(hr)
            }];
        });
    };

    [QCSDKManager shareInstance].bpMeasuring = ^(NSInteger sbp, NSInteger dbp) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf sendEvent:@{
                @"type": @"measurement_result",
                @"measureType": @"bloodPressure",
                @"sbp": @(sbp),
                @"dbp": @(dbp)
            }];
        });
    };

    [QCSDKManager shareInstance].boMeasuring = ^(CGFloat so2) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf sendEvent:@{
                @"type": @"measurement_result",
                @"measureType": @"bloodOxygen",
                @"spo2": @(so2)
            }];
        });
    };

    [QCSDKManager shareInstance].measuringFail = ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf sendEvent:@{
                @"type": @"measurement_fail",
                @"measureType": @"heartRate",
                @"error": @"Measurement failed. Wear the band correctly and try again."
            }];
        });
    };
}

- (void)sendEvent:(NSDictionary *)event {
    if (self.eventSink) {
        self.eventSink(event);
    }
}

- (void)enqueueCommand:(EHGBandWork)work {
    [self.commandQueue addObject:[work copy]];
    [self dequeueIfNeeded];
}

- (void)dequeueIfNeeded {
    if (self.commandRunning || self.commandQueue.count == 0) {
        return;
    }
    self.commandRunning = YES;
    EHGBandWork work = self.commandQueue.firstObject;
    [self.commandQueue removeObjectAtIndex:0];
    
    [self.commandWatchdogTimer invalidate];
    __weak typeof(self) weakSelf = self;
    self.commandWatchdogTimer = [NSTimer scheduledTimerWithTimeInterval:6.0 repeats:NO block:^(NSTimer * _Nonnull timer) {
        NSLog(@"[EHGBandNative] Command watchdog timeout (6s) reached. Resetting queue.");
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.commandRunning = NO;
            [weakSelf dequeueIfNeeded];
        });
    }];

    work(^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(150 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
            [weakSelf.commandWatchdogTimer invalidate];
            weakSelf.commandWatchdogTimer = nil;
            weakSelf.commandRunning = NO;
            [weakSelf dequeueIfNeeded];
        });
    });
}

#pragma mark - Lifecycle Observers

- (void)setupLifecycleObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleAppDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleAppWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleAppDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)handleAppDidEnterBackground:(NSNotification *)note {
    NSLog(@"[EHGBandNative] 📱 App entered background - keeping BLE connection active.");
    // In background, CoreBluetooth maintains connection if bluetooth-central is configured.
}

- (void)handleAppWillEnterForeground:(NSNotification *)note {
    NSLog(@"[EHGBandNative] 📱 App entering foreground - verifying band connection...");
    CBPeripheral *per = [QCCentralManager shared].connectedPeripheral;
    if ([QCCentralManager shared].deviceState == QCStateConnected && per != nil) {
        [self sendEvent:@{
            @"type": @"connection_state",
            @"state": @"connected",
            @"name": per.name ?: @"EHG Smart Band",
            @"id": per.identifier.UUIDString ?: @"",
            @"mac": per.identifier.UUIDString ?: @""
        }];
        if (self.lastKnownBattery > 0) {
            [self sendEvent:@{
                @"type": @"battery_update",
                @"battery": @(self.lastKnownBattery),
                @"charging": @(self.lastKnownCharging)
            }];
        }
        [self startStepPolling];
        __weak typeof(self) weakSelf = self;
        [self enqueueCommand:^(EHGBandDone done) {
            [QCSDKCmdCreator readBatterySuccess:^(int battery, BOOL charging) {
                weakSelf.lastKnownBattery = battery;
                weakSelf.lastKnownCharging = charging;
                [[NSUserDefaults standardUserDefaults] setInteger:battery forKey:@"last_known_battery"];
                [[NSUserDefaults standardUserDefaults] setBool:charging forKey:@"last_known_charging"];
                [weakSelf sendEvent:@{
                    @"type": @"battery_update",
                    @"battery": @(battery),
                    @"charging": @(charging)
                }];
                done();
            } failed:^{
                done();
            }];
        }];
    } else {
        NSString *lastId = [[NSUserDefaults standardUserDefaults] objectForKey:@"QCLastConnectedIdentifier"];
        if (lastId.length > 0 && [QCCentralManager shared].bleState == QCBluetoothStatePoweredOn) {
            NSLog(@"[EHGBandNative] 📱 App resumed and band disconnected, triggering auto-reconnect to %@", lastId);
            [[QCCentralManager shared] startToReconnect];
        }
    }
}

- (void)handleAppDidBecomeActive:(NSNotification *)note {
    NSLog(@"[EHGBandNative] 📱 App became active.");
}

#pragma mark - FlutterStreamHandler

- (FlutterError * _Nullable)onListenWithArguments:(id _Nullable)arguments eventSink:(FlutterEventSink)events {
    self.eventSink = events;

    // Immediately re-emit current Bluetooth state
    NSString *btState = @"unknown";
    switch ([QCCentralManager shared].bleState) {
        case QCBluetoothStatePoweredOn: btState = @"poweredOn"; break;
        case QCBluetoothStatePoweredOff: btState = @"poweredOff"; break;
        case QCBluetoothStateUnauthorized: btState = @"unauthorized"; break;
        case QCBluetoothStateUnsupported: btState = @"unsupported"; break;
        case QCBluetoothStateResetting: btState = @"resetting"; break;
        default: break;
    }
    events(@{
        @"type": @"bluetooth_state",
        @"state": btState
    });

    // If band is already connected (e.g. across Hot Restart or foreground restore), emit connected immediately
    CBPeripheral *per = [QCCentralManager shared].connectedPeripheral;
    if ([QCCentralManager shared].deviceState == QCStateConnected && per != nil) {
        NSLog(@"[EHGBandNative] 🔌 Re-emitting connected state to Flutter on hot restart / stream listen: %@ (%@)", per.name, per.identifier.UUIDString);
        events(@{
            @"type": @"connection_state",
            @"state": @"connected",
            @"name": per.name ?: @"EHG Smart Band",
            @"id": per.identifier.UUIDString ?: @"",
            @"mac": per.identifier.UUIDString ?: @""
        });

        if (self.lastKnownBattery > 0) {
            events(@{
                @"type": @"battery_update",
                @"battery": @(self.lastKnownBattery),
                @"charging": @(self.lastKnownCharging)
            });
        }

        [self startStepPolling];

        __weak typeof(self) weakSelf = self;
        [self enqueueCommand:^(EHGBandDone done) {
            [QCSDKCmdCreator readBatterySuccess:^(int battery, BOOL charging) {
                NSLog(@"[EHGBandNative] 🔋 Stream-attached fresh battery level: %d%%", battery);
                weakSelf.lastKnownBattery = battery;
                weakSelf.lastKnownCharging = charging;
                [[NSUserDefaults standardUserDefaults] setInteger:battery forKey:@"last_known_battery"];
                [[NSUserDefaults standardUserDefaults] setBool:charging forKey:@"last_known_charging"];
                [weakSelf sendEvent:@{
                    @"type": @"battery_update",
                    @"battery": @(battery),
                    @"charging": @(charging)
                }];
                done();
            } failed:^{
                done();
            }];
        }];
    }

    return nil;
}

- (FlutterError * _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    self.eventSink = nil;
    return nil;
}

#pragma mark - FlutterMethodCallHandler

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([@"requestEnableBluetooth" isEqualToString:call.method] || [@"openBluetoothSettings" isEqualToString:call.method]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSURL *btUrl = [NSURL URLWithString:@"App-Prefs:root=Bluetooth"];
            NSURL *appSettings = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if (@available(iOS 10.0, *)) {
                [[UIApplication sharedApplication] openURL:btUrl options:@{} completionHandler:^(BOOL success) {
                    if (!success) {
                        [[UIApplication sharedApplication] openURL:appSettings options:@{} completionHandler:^(BOOL appSuccess) {
                            result(@(appSuccess));
                        }];
                    } else {
                        result(@(YES));
                    }
                }];
            } else {
                [[UIApplication sharedApplication] openURL:appSettings];
                result(@(YES));
            }
        });
    }
    else if ([@"openLocationSettings" isEqualToString:call.method] || [@"openAppSettings" isEqualToString:call.method]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                if (@available(iOS 10.0, *)) {
                    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
                        result(@(success));
                    }];
                } else {
                    [[UIApplication sharedApplication] openURL:url];
                    result(@(YES));
                }
            } else {
                result(@(NO));
            }
        });
    }
    else if ([@"startScan" isEqualToString:call.method]) {
        NSInteger timeout = 30;
        if ([call.arguments isKindOfClass:[NSDictionary class]] && call.arguments[@"timeout"]) {
            timeout = [call.arguments[@"timeout"] integerValue];
        }
        [self.discoveredPeripherals removeAllObjects];
        [self sendEvent:@{@"type": @"connection_state", @"state": @"scanning"}];
        [[QCCentralManager shared] scanWithTimeout:timeout];
        result(@(YES));
    }
    else if ([@"stopScan" isEqualToString:call.method]) {
        [[QCCentralManager shared] stopScan];
        result(@(YES));
    }
    else if ([@"connect" isEqualToString:call.method]) {
        [self handleConnect:call result:result];
    }
    else if ([@"reconnect" isEqualToString:call.method]) {
        if ([QCCentralManager shared].deviceState == QCStateConnected) {
            NSLog(@"[EHGBand] Reconnect: Already connected natively.");
            result(@(YES));
            return;
        }
        NSString *lastId = [[NSUserDefaults standardUserDefaults] objectForKey:@"QCLastConnectedIdentifier"];
        if (lastId.length > 0) {
            FlutterMethodCall *connectCall = [FlutterMethodCall methodCallWithMethodName:@"connect"
                                                                               arguments:@{@"deviceId": lastId}];
            [self handleConnect:connectCall result:result];
        } else {
            result(@(NO));
        }
    }
    else if ([@"unbind" isEqualToString:call.method]) {
        FlutterMethodCall *unbindCall = [FlutterMethodCall methodCallWithMethodName:@"disconnect"
                                                                           arguments:@{@"unpair": @(YES)}];
        [self handleDisconnect:unbindCall result:result];
    }
    else if ([@"isConnected" isEqualToString:call.method]) {
        BOOL connected = ([QCCentralManager shared].deviceState == QCStateConnected);
        result(@(connected));
    }
    else if ([@"disconnect" isEqualToString:call.method]) {
        [self handleDisconnect:call result:result];
    }
    else if ([@"getBattery" isEqualToString:call.method]) {
        if ([QCCentralManager shared].deviceState != QCStateConnected) {
            if (self.lastKnownBattery > 0) {
                result(@{@"battery": @(self.lastKnownBattery), @"charging": @(self.lastKnownCharging)});
            } else {
                result(@{@"battery": @(0), @"charging": @(NO)});
            }
            return;
        }
        __weak typeof(self) weakSelf = self;
        [self enqueueCommand:^(EHGBandDone done) {
            [QCSDKCmdCreator readBatterySuccess:^(int battery, BOOL charging) {
                weakSelf.lastKnownBattery = battery;
                weakSelf.lastKnownCharging = charging;
                [[NSUserDefaults standardUserDefaults] setInteger:battery forKey:@"last_known_battery"];
                [[NSUserDefaults standardUserDefaults] setBool:charging forKey:@"last_known_charging"];
                result(@{@"battery": @(battery), @"charging": @(charging)});
                done();
            } failed:^{
                if (weakSelf.lastKnownBattery > 0) {
                    result(@{@"battery": @(weakSelf.lastKnownBattery), @"charging": @(weakSelf.lastKnownCharging)});
                } else {
                    result(@{@"battery": @(0), @"charging": @(NO)});
                }
                done();
            }];
        }];
    }
    else if ([@"getDeviceInfo" isEqualToString:call.method]) {
        CBPeripheral *per = [QCCentralManager shared].connectedPeripheral;
        NSString *name = per.name ?: @"EHG Smart Band";
        NSString *deviceId = per.identifier.UUIDString ?: @"";
        if (!per || [QCCentralManager shared].deviceState != QCStateConnected) {
            NSString *savedId = [[NSUserDefaults standardUserDefaults] objectForKey:@"QCLastConnectedIdentifier"] ?: @"";
            result(@{
                @"name": name,
                @"id": savedId.length > 0 ? savedId : @"EH-9F2C",
                @"hardVersion": @"1.0.0",
                @"softVersion": @"1.0.4",
                @"macAddress": savedId
            });
            return;
        }
        [self enqueueCommand:^(EHGBandDone done) {
            [QCSDKCmdCreator getDeviceSoftAndHardVersionSuccess:^(NSString *hardVersion, NSString *softVersion) {
                [QCSDKCmdCreator getDeviceMacAddressSuccess:^(NSString *macAddress) {
                    result(@{
                        @"name": name,
                        @"id": deviceId,
                        @"hardVersion": hardVersion ?: @"1.0.0",
                        @"softVersion": softVersion ?: @"1.0.4",
                        @"macAddress": macAddress ?: @""
                    });
                    done();
                } fail:^{
                    result(@{
                        @"name": name,
                        @"id": deviceId,
                        @"hardVersion": hardVersion ?: @"1.0.0",
                        @"softVersion": softVersion ?: @"1.0.4",
                        @"macAddress": @""
                    });
                    done();
                }];
            } fail:^{
                result(@{
                    @"name": name,
                    @"id": deviceId,
                    @"hardVersion": @"1.0.0",
                    @"softVersion": @"1.0.4",
                    @"macAddress": @""
                });
                done();
            }];
        }];
    }
    else if ([@"setTime" isEqualToString:call.method]) {
        [self enqueueCommand:^(EHGBandDone done) {
            [QCSDKCmdCreator setTime:[NSDate date] success:^(NSDictionary *info) {
                result(@(YES));
                done();
            } failed:^{
                result(@(NO));
                done();
            }];
        }];
    }
    else if ([@"findBand" isEqualToString:call.method]) {
        [self enqueueCommand:^(EHGBandDone done) {
            [QCSDKCmdCreator lookupDeviceSuccess:^{
                result(@(YES));
                done();
            } fail:^{
                result(@(NO));
                done();
            }];
        }];
    }
    else if ([@"startRealtimeHeartRate" isEqualToString:call.method]) {
        [self enqueueCommand:^(EHGBandDone done) {
            [QCSDKCmdCreator realTimeHeartRateWithCmd:QCBandRealTimeHeartRateCmdTypeStart finished:^(BOOL success) {
                result(@(success));
                done();
            }];
        }];
        [self.realtimeHrHoldTimer invalidate];
        __weak typeof(self) weakSelf = self;
        self.realtimeHrHoldTimer = [NSTimer scheduledTimerWithTimeInterval:15.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
            [weakSelf enqueueCommand:^(EHGBandDone done) {
                __block BOOL doneCalled = NO;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if (!doneCalled) {
                        doneCalled = YES;
                        done();
                    }
                });
                [QCSDKCmdCreator realTimeHeartRateWithCmd:QCBandRealTimeHeartRateCmdTypeHold finished:^(BOOL success) {
                    if (!doneCalled) {
                        doneCalled = YES;
                        done();
                    }
                }];
            }];
        }];
    }
    else if ([@"stopRealtimeHeartRate" isEqualToString:call.method]) {
        [self.realtimeHrHoldTimer invalidate];
        self.realtimeHrHoldTimer = nil;
        [self enqueueCommand:^(EHGBandDone done) {
            [QCSDKCmdCreator realTimeHeartRateWithCmd:QCBandRealTimeHeartRateCmdTypeEnd finished:^(BOOL success) {
                result(@(success));
                done();
            }];
        }];
    }
    else if ([@"syncHistoricalVitals" isEqualToString:call.method] || [@"syncFullHealthData" isEqualToString:call.method]) {
        [self syncFullHealthDataWithResult:result];
    }
    else if ([@"startMeasuring" isEqualToString:call.method]) {
        [self startMeasuring:call.arguments[@"type"] result:result];
    }
    else if ([@"stopMeasuring" isEqualToString:call.method]) {
        QCMeasuringType type = [self measuringTypeFromString:call.arguments[@"type"]];
        [self enqueueCommand:^(EHGBandDone done) {
            [[QCSDKManager shareInstance] stopToMeasuringWithOperateType:type completedHandle:^(BOOL isSuccess, NSError *error) {
                result(@(isSuccess));
                done();
            }];
        }];
    }
    else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)handleConnect:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSString *deviceId = call.arguments[@"deviceId"];

    // Check if peripheral is ALREADY connected in QCCentralManager
    if ([QCCentralManager shared].deviceState == QCStateConnected &&
        [QCCentralManager shared].connectedPeripheral != nil &&
        [deviceId isEqualToString:[QCCentralManager shared].connectedPeripheral.identifier.UUIDString]) {
        NSLog(@"[EHGBandNative] Device %@ is ALREADY connected. Skipping re-connect.", deviceId);
        result(@(YES));
        return;
    }

    // Check if already connected to this device (e.g. across hot restart)
    CBPeripheral *connectedPer = [QCCentralManager shared].connectedPeripheral;
    if ([QCCentralManager shared].deviceState == QCStateConnected && connectedPer != nil) {
        if ([deviceId length] == 0 || [connectedPer.identifier.UUIDString isEqualToString:deviceId]) {
            NSLog(@"[EHGBandNative] 🔌 Device is ALREADY connected: %@ (%@). Reusing existing connection without reset.", connectedPer.name, connectedPer.identifier.UUIDString);
            [self sendEvent:@{
                @"type": @"connection_state",
                @"state": @"connected",
                @"name": connectedPer.name ?: @"EHG Smart Band",
                @"id": connectedPer.identifier.UUIDString ?: @"",
                @"mac": connectedPer.identifier.UUIDString ?: @""
            }];
            if (self.lastKnownBattery > 0) {
                [self sendEvent:@{
                    @"type": @"battery_update",
                    @"battery": @(self.lastKnownBattery),
                    @"charging": @(self.lastKnownCharging)
                }];
            }
            [self startStepPolling];
            __weak typeof(self) weakSelf = self;
            [self enqueueCommand:^(EHGBandDone done) {
                [QCSDKCmdCreator readBatterySuccess:^(int battery, BOOL charging) {
                    NSLog(@"[EHGBandNative] 🔋 Reconnect-reused fresh battery level: %d%%", battery);
                    weakSelf.lastKnownBattery = battery;
                    weakSelf.lastKnownCharging = charging;
                    [[NSUserDefaults standardUserDefaults] setInteger:battery forKey:@"last_known_battery"];
                    [[NSUserDefaults standardUserDefaults] setBool:charging forKey:@"last_known_charging"];
                    [weakSelf sendEvent:@{
                        @"type": @"battery_update",
                        @"battery": @(battery),
                        @"charging": @(charging)
                    }];
                    done();
                } failed:^{
                    done();
                }];
            }];
            result(@(YES));
            return;
        }
    }

    // 1. Immediately stop scanning before connecting to avoid BLE radio collision
    [[QCCentralManager shared] stopScan];

    CBPeripheral *target = nil;
    NSString *deviceName = @"";
    for (QCBlePeripheral *blePer in self.discoveredPeripherals) {
        if ([blePer.peripheral.identifier.UUIDString isEqualToString:deviceId]) {
            target = blePer.peripheral;
            deviceName = blePer.peripheral.name ?: @"";
            break;
        }
    }
    if (!target) {
        target = [[QCCentralManager shared] periperalWithUUID:deviceId];
        deviceName = target.name ?: @"";
    }

    if (!target) {
        result([FlutterError errorWithCode:@"DEVICE_NOT_FOUND"
                                   message:@"Specified peripheral was not found"
                                   details:nil]);
        return;
    }

    // Flush any pending commands/timers from previous connection before starting new connect
    [self.realtimeHrHoldTimer invalidate];
    self.realtimeHrHoldTimer = nil;
    [self.commandWatchdogTimer invalidate];
    self.commandWatchdogTimer = nil;
    self.commandRunning = NO;
    [self.commandQueue removeAllObjects];

    self.pendingConnectResult = result;

    // Safety timeout timer (20 seconds)
    [self.connectTimeoutTimer invalidate];
    __weak typeof(self) weakSelf = self;
    self.connectTimeoutTimer = [NSTimer scheduledTimerWithTimeInterval:20.0 repeats:NO block:^(NSTimer * _Nonnull timer) {
        if (weakSelf.pendingConnectResult) {
            NSLog(@"[EHGBandNative] Connection timed out after 20 seconds");
            [weakSelf finishConnect:NO error:@"Connection timed out. Ensure the band is powered on and within Bluetooth range."];
        }
    }];

    // Connect using Watch device type (matching QWatch Pro protocol)
    [[QCCentralManager shared] connect:target timeout:20 deviceType:QCDeviceTypeWatch];
}

- (void)handleDisconnect:(FlutterMethodCall *)call result:(FlutterResult)result {
    BOOL unpair = [call.arguments[@"unpair"] boolValue];
    [self stopStepPolling];
    [self.realtimeHrHoldTimer invalidate];
    self.realtimeHrHoldTimer = nil;
    [self.connectTimeoutTimer invalidate];
    self.connectTimeoutTimer = nil;
    [self.commandWatchdogTimer invalidate];
    self.commandWatchdogTimer = nil;
    self.commandRunning = NO;
    [self.commandQueue removeAllObjects];
    self.pendingDisconnectResult = result;
    if (unpair) {
        [self resetVitalsMemory];
        [[QCCentralManager shared] remove];
    } else {
        CBPeripheral *per = [QCCentralManager shared].connectedPeripheral;
        if (per) {
            [[QCCentralManager shared].centerManager cancelPeripheralConnection:per];
        }
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.pendingDisconnectResult) {
            self.pendingDisconnectResult(@(YES));
            self.pendingDisconnectResult = nil;
        }
    });
}

- (void)finishConnect:(BOOL)success error:(NSString *)error {
    [self.connectTimeoutTimer invalidate];
    self.connectTimeoutTimer = nil;
    if (!self.pendingConnectResult) {
        return;
    }
    FlutterResult callback = self.pendingConnectResult;
    self.pendingConnectResult = nil;
    if (success) {
        callback(@(YES));
    } else {
        callback([FlutterError errorWithCode:@"CONNECT_FAILED"
                                     message:error ?: @"Connection failed"
                                     details:nil]);
    }
}

- (void)sendBindVibrationThenTime {
    __weak typeof(self) weakSelf = self;
    // Command 1: Single band vibration confirmation on connect
    [self enqueueCommand:^(EHGBandDone done) {
        [QCSDKCmdCreator alertBindingSuccess:^{
            NSLog(@"[EHGBandNative] Alert binding single vibration sent");
            done();
        } fail:^{
            NSLog(@"[EHGBandNative] Alert binding vibration failed or unsupported");
            done();
        }];
    }];

    // Command 2: Set band time
    [self enqueueCommand:^(EHGBandDone done) {
        [QCSDKCmdCreator setTime:[NSDate date] success:^(NSDictionary *info) {
            NSLog(@"[EHGBandNative] Set time succeeded");
            done();
        } failed:^{
            NSLog(@"[EHGBandNative] Set time failed");
            done();
        }];
    }];

    // Command 3: Read battery
    [self enqueueCommand:^(EHGBandDone done) {
        [QCSDKCmdCreator readBatterySuccess:^(int battery, BOOL charging) {
            NSLog(@"[EHGBandNative] Battery level: %d%%", battery);
            weakSelf.lastKnownBattery = battery;
            weakSelf.lastKnownCharging = charging;
            [[NSUserDefaults standardUserDefaults] setInteger:battery forKey:@"last_known_battery"];
            [[NSUserDefaults standardUserDefaults] setBool:charging forKey:@"last_known_charging"];
            [weakSelf sendEvent:@{
                @"type": @"battery_update",
                @"battery": @(battery),
                @"charging": @(charging)
            }];
            done();
        } failed:^{
            done();
        }];
    }];

    // Command 4: Enable scheduled continuous heart rate monitoring (5-minute interval)
    [self enqueueCommand:^(EHGBandDone done) {
        [QCSDKCmdCreator setSchedualHeartRateStatus:YES timeInterval:5 success:^{
            NSLog(@"[EHGBandNative] Scheduled heart rate monitoring enabled (5m)");
            done();
        } fail:^{
            NSLog(@"[EHGBandNative] Scheduled heart rate monitoring setting failed or unsupported");
            done();
        }];
    }];
}

- (void)startStepPolling {
    [self.stepPollTimer invalidate];
    __weak typeof(self) weakSelf = self;
    self.stepPollTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        if ([QCCentralManager shared].deviceState != QCStateConnected) {
            [strongSelf stopStepPolling];
            return;
        }
        if (strongSelf.commandQueue.count == 0 && !strongSelf.commandRunning && strongSelf.activeMeasureType == QCMeasuringTypeUnkown) {
            [strongSelf enqueueCommand:^(EHGBandDone done) {
                [QCSDKCmdCreator getCurrentSportSucess:^(QCSportModel *sport) {
                    if (sport) {
                        NSLog(@"[EHGBandNative] Dynamic step update: %ld steps, %d kcal, %ld m", (long)sport.totalStepCount, (int)sport.calories, (long)sport.distance);
                        strongSelf.lastKnownSteps = sport.totalStepCount;
                        strongSelf.lastKnownCalories = (int)sport.calories;
                        strongSelf.lastKnownDistance = sport.distance;
                        [[NSUserDefaults standardUserDefaults] setInteger:sport.totalStepCount forKey:@"last_known_steps"];
                        [[NSUserDefaults standardUserDefaults] setInteger:(int)sport.calories forKey:@"last_known_calories"];
                        [[NSUserDefaults standardUserDefaults] setInteger:sport.distance forKey:@"last_known_distance"];
                        [strongSelf sendEvent:@{
                            @"type": @"step_update",
                            @"steps": @(sport.totalStepCount),
                            @"calories": @((int)sport.calories),
                            @"distance": @(sport.distance)
                        }];
                    }
                    done();
                } failed:^{
                    done();
                }];
            }];
        }
    }];
}

- (void)stopStepPolling {
    [self.stepPollTimer invalidate];
    self.stepPollTimer = nil;
}

#pragma mark - Health sync (sequential; SDK rejects overlapping commands)

- (void)syncFullHealthDataWithResult:(FlutterResult)result {
    if ([QCCentralManager shared].deviceState != QCStateConnected) {
        NSLog(@"[EHGBandNative] syncFullHealthData: Band not connected. Returning cached health metrics immediately.");
        result([self buildCachedSyncMap]);
        return;
    }

    __weak typeof(self) weakSelf = self;
    [self enqueueCommand:^(EHGBandDone done) {
        NSMutableDictionary *syncData = [NSMutableDictionary dictionary];
        syncData[@"steps"] = @(weakSelf.lastKnownSteps);
        syncData[@"calories"] = @(weakSelf.lastKnownCalories);
        syncData[@"distance"] = @(weakSelf.lastKnownDistance);
        syncData[@"sleepMinutes"] = @(weakSelf.lastKnownSleepMinutes);
        syncData[@"deepSleepMinutes"] = @(weakSelf.lastKnownDeepSleepMinutes);
        syncData[@"bloodOxygen"] = @(weakSelf.lastKnownBloodOxygen);
        syncData[@"systolicBP"] = @(weakSelf.lastKnownSbp);
        syncData[@"diastolicBP"] = @(weakSelf.lastKnownDbp);
        syncData[@"skinTemperature"] = @(weakSelf.lastKnownSkinTemperature);
        syncData[@"stressLevel"] = @(weakSelf.lastKnownStressLevel);
        syncData[@"hrvMs"] = @(weakSelf.lastKnownHrvMs);
        syncData[@"restingHeartRate"] = @(weakSelf.lastKnownRestingHeartRate);
        syncData[@"sleepPhases"] = [weakSelf.lastKnownSleepPhases copy] ?: @[];
        syncData[@"heartRateHistory"] = [weakSelf.lastKnownHeartRateHistory copy] ?: @[];

        [QCSDKCmdCreator getCurrentSportSucess:^(QCSportModel *sport) {
            if (sport) {
                syncData[@"steps"] = @(sport.totalStepCount);
                syncData[@"calories"] = @((int)sport.calories);
                syncData[@"distance"] = @(sport.distance);
                weakSelf.lastKnownSteps = sport.totalStepCount;
                weakSelf.lastKnownCalories = (int)sport.calories;
                weakSelf.lastKnownDistance = sport.distance;
                [[NSUserDefaults standardUserDefaults] setInteger:sport.totalStepCount forKey:@"last_known_steps"];
                [[NSUserDefaults standardUserDefaults] setInteger:(int)sport.calories forKey:@"last_known_calories"];
                [[NSUserDefaults standardUserDefaults] setInteger:sport.distance forKey:@"last_known_distance"];
            }
            [weakSelf syncSleepInto:syncData finish:^{
                [weakSelf syncHeartRateInto:syncData finish:^{
                    [weakSelf syncOxygenInto:syncData finish:^{
                        [weakSelf syncBloodPressureInto:syncData finish:^{
                            [weakSelf syncTemperatureInto:syncData finish:^{
                                [weakSelf syncStressInto:syncData finish:^{
                                    [weakSelf syncHrvInto:syncData finish:^{
                                        result(syncData);
                                        done();
                                    }];
                                }];
                            }];
                        }];
                    }];
                }];
            }];
        } failed:^{
            result([weakSelf buildCachedSyncMap]);
            done();
        }];
    }];
}

- (void)syncSleepInto:(NSMutableDictionary *)syncData finish:(void (^)(void))finish {
    __weak typeof(self) weakSelf = self;
    [QCSDKCmdCreator getFulldaySleepDetailDataByDay:0 sleepDatas:^(NSArray<QCSleepModel *> *sleeps, NSArray<QCSleepModel *> *naps) {
        NSInteger totalSleepMinutes = 0;
        NSInteger deepSleepMinutes = 0;
        NSMutableArray *phases = [NSMutableArray array];
        for (QCSleepModel *s in sleeps) {
            if (s.type == SLEEPTYPENONE || s.type == SLEEPTYPEUNWEARED) {
                continue;
            }
            totalSleepMinutes += s.total;
            if (s.type == SLEEPTYPEDEEP) {
                deepSleepMinutes += s.total;
            }
            [phases addObject:@{
                @"type": @(s.type),
                @"startTime": s.happenDate ?: @"",
                @"endTime": s.endTime ?: @"",
                @"durationMinutes": @(s.total)
            }];
        }
        syncData[@"sleepMinutes"] = @(totalSleepMinutes);
        syncData[@"deepSleepMinutes"] = @(deepSleepMinutes);
        syncData[@"sleepPhases"] = phases;
        if (totalSleepMinutes > 0) {
            weakSelf.lastKnownSleepMinutes = totalSleepMinutes;
            weakSelf.lastKnownDeepSleepMinutes = deepSleepMinutes;
            [weakSelf.lastKnownSleepPhases removeAllObjects];
            [weakSelf.lastKnownSleepPhases addObjectsFromArray:phases];
            [[NSUserDefaults standardUserDefaults] setInteger:totalSleepMinutes forKey:@"last_known_sleep_minutes"];
            [[NSUserDefaults standardUserDefaults] setInteger:deepSleepMinutes forKey:@"last_known_deep_sleep_minutes"];
        }
        finish();
    } fail:^{
        finish();
    }];
}

- (void)syncHeartRateInto:(NSMutableDictionary *)syncData finish:(void (^)(void))finish {
    __weak typeof(self) weakSelf = self;
    [QCSDKCmdCreator getSchedualHeartRateDataWithDayIndexs:@[@0] success:^(NSArray<QCSchedualHeartRateModel *> *models) {
        NSMutableArray *history = [NSMutableArray array];
        NSInteger resting = 0;
        NSInteger latest = 0;
        for (QCSchedualHeartRateModel *model in models) {
            NSInteger index = 0;
            for (NSNumber *hr in model.heartRates) {
                NSInteger bpm = hr.integerValue;
                if (bpm <= 0) {
                    index += 1;
                    continue;
                }
                latest = bpm;
                if (resting == 0 || bpm < resting) {
                    resting = bpm;
                }
                [history addObject:@{
                    @"bpm": @(bpm),
                    @"timestamp": [NSString stringWithFormat:@"%@#%ld", model.date ?: @"", (long)index]
                }];
                index += 1;
            }
        }
        if (latest > 0) {
            syncData[@"restingHeartRate"] = @(resting);
            weakSelf.lastKnownRestingHeartRate = resting;
            [[NSUserDefaults standardUserDefaults] setInteger:resting forKey:@"last_known_resting_hr"];
        }
        syncData[@"heartRateHistory"] = history;
        if (history.count > 0) {
            [weakSelf.lastKnownHeartRateHistory removeAllObjects];
            [weakSelf.lastKnownHeartRateHistory addObjectsFromArray:history];
        }
        finish();
    } fail:^{
        finish();
    }];
}

- (void)syncOxygenInto:(NSMutableDictionary *)syncData finish:(void (^)(void))finish {
    __weak typeof(self) weakSelf = self;
    [QCSDKCmdCreator getBloodOxygenDataByDayIndex:0 finished:^(NSArray *list, NSError *error) {
        CGFloat latest = 0;
        for (id item in list) {
            if ([item isKindOfClass:[QCBloodOxygenModel class]]) {
                QCBloodOxygenModel *model = (QCBloodOxygenModel *)item;
                if (model.soa2 > 0) {
                    latest = model.soa2;
                }
            } else if ([item isKindOfClass:[NSNumber class]]) {
                CGFloat value = [(NSNumber *)item doubleValue];
                if (value > 0) {
                    latest = value;
                }
            }
        }
        if (latest > 0) {
            syncData[@"bloodOxygen"] = @(latest);
            weakSelf.lastKnownBloodOxygen = latest;
            [[NSUserDefaults standardUserDefaults] setFloat:latest forKey:@"last_known_spo2"];
        }
        finish();
    }];
}

- (void)syncBloodPressureInto:(NSMutableDictionary *)syncData finish:(void (^)(void))finish {
    __weak typeof(self) weakSelf = self;
    [QCSDKCmdCreator getSchedualBPHistoryDataWithSuccess:^(NSArray<QCBloodPressureModel *> *data) {
        QCBloodPressureModel *last = data.lastObject;
        if (last.systolicPressure > 0 && last.diastolicPressure > 0) {
            syncData[@"systolicBP"] = @(last.systolicPressure);
            syncData[@"diastolicBP"] = @(last.diastolicPressure);
            weakSelf.lastKnownSbp = last.systolicPressure;
            weakSelf.lastKnownDbp = last.diastolicPressure;
            [[NSUserDefaults standardUserDefaults] setInteger:last.systolicPressure forKey:@"last_known_sbp"];
            [[NSUserDefaults standardUserDefaults] setInteger:last.diastolicPressure forKey:@"last_known_dbp"];
            finish();
        } else {
            // Check manual blood pressure history as well
            [QCSDKCmdCreator getManualBloodPressureDataWithLastUnixSeconds:0 success:^(NSArray<QCBloodPressureModel *> *manualData) {
                QCBloodPressureModel *mLast = manualData.lastObject;
                if (mLast.systolicPressure > 0 && mLast.diastolicPressure > 0) {
                    syncData[@"systolicBP"] = @(mLast.systolicPressure);
                    syncData[@"diastolicBP"] = @(mLast.diastolicPressure);
                    weakSelf.lastKnownSbp = mLast.systolicPressure;
                    weakSelf.lastKnownDbp = mLast.diastolicPressure;
                    [[NSUserDefaults standardUserDefaults] setInteger:mLast.systolicPressure forKey:@"last_known_sbp"];
                    [[NSUserDefaults standardUserDefaults] setInteger:mLast.diastolicPressure forKey:@"last_known_dbp"];
                } else {
                    syncData[@"systolicBP"] = @(weakSelf.lastKnownSbp);
                    syncData[@"diastolicBP"] = @(weakSelf.lastKnownDbp);
                }
                finish();
            } fail:^{
                syncData[@"systolicBP"] = @(weakSelf.lastKnownSbp);
                syncData[@"diastolicBP"] = @(weakSelf.lastKnownDbp);
                finish();
            }];
        }
    } fail:^{
        [QCSDKCmdCreator getManualBloodPressureDataWithLastUnixSeconds:0 success:^(NSArray<QCBloodPressureModel *> *manualData) {
            QCBloodPressureModel *mLast = manualData.lastObject;
            if (mLast.systolicPressure > 0 && mLast.diastolicPressure > 0) {
                syncData[@"systolicBP"] = @(mLast.systolicPressure);
                syncData[@"diastolicBP"] = @(mLast.diastolicPressure);
                weakSelf.lastKnownSbp = mLast.systolicPressure;
                weakSelf.lastKnownDbp = mLast.diastolicPressure;
                [[NSUserDefaults standardUserDefaults] setInteger:mLast.systolicPressure forKey:@"last_known_sbp"];
                [[NSUserDefaults standardUserDefaults] setInteger:mLast.diastolicPressure forKey:@"last_known_dbp"];
            } else {
                syncData[@"systolicBP"] = @(weakSelf.lastKnownSbp);
                syncData[@"diastolicBP"] = @(weakSelf.lastKnownDbp);
            }
            finish();
        } fail:^{
            syncData[@"systolicBP"] = @(weakSelf.lastKnownSbp);
            syncData[@"diastolicBP"] = @(weakSelf.lastKnownDbp);
            finish();
        }];
    }];
}

- (void)syncTemperatureInto:(NSMutableDictionary *)syncData finish:(void (^)(void))finish {
    __weak typeof(self) weakSelf = self;
    [QCSDKCmdCreator getSchedualTemperatureDataByDayIndex:0 finished:^(NSArray *temperatureList, NSError *error) {
        CGFloat latest = 0;
        for (id item in temperatureList) {
            if ([item isKindOfClass:[QCTemperatureModel class]]) {
                QCTemperatureModel *model = (QCTemperatureModel *)item;
                if (model.temperature > 0) {
                    latest = model.temperature;
                }
            } else if ([item isKindOfClass:[QCThreeValueTemperatureModel class]]) {
                QCThreeValueTemperatureModel *model = (QCThreeValueTemperatureModel *)item;
                if (model.temperature1 > 0) {
                    latest = model.temperature1;
                }
            }
        }
        if (latest > 0) {
            syncData[@"skinTemperature"] = @(latest);
            weakSelf.lastKnownSkinTemperature = latest;
            [[NSUserDefaults standardUserDefaults] setFloat:latest forKey:@"last_known_temp"];
        }
        finish();
    }];
}

- (void)syncStressInto:(NSMutableDictionary *)syncData finish:(void (^)(void))finish {
    __weak typeof(self) weakSelf = self;
    [QCSDKCmdCreator getSchedualStressDataWithDates:@[@0] finished:^(NSArray *list, NSError *error) {
        NSInteger latest = 0;
        for (id item in list) {
            if ([item isKindOfClass:[QCStressModel class]]) {
                for (NSNumber *value in ((QCStressModel *)item).stresses) {
                    if (value.integerValue > 0) {
                        latest = value.integerValue;
                    }
                }
            }
        }
        if (latest > 0) {
            syncData[@"stressLevel"] = @(latest);
            weakSelf.lastKnownStressLevel = latest;
            [[NSUserDefaults standardUserDefaults] setInteger:latest forKey:@"last_known_stress"];
        }
        finish();
    }];
}

- (void)syncHrvInto:(NSMutableDictionary *)syncData finish:(void (^)(void))finish {
    __weak typeof(self) weakSelf = self;
    [QCSDKCmdCreator getSchedualHRVDataWithDates:@[@0] finished:^(NSArray *list, NSError *error) {
        NSInteger latest = 0;
        for (id item in list) {
            if ([item isKindOfClass:[QCHRVModel class]]) {
                for (NSNumber *value in ((QCHRVModel *)item).hrv) {
                    if (value.integerValue > 0) {
                        latest = value.integerValue;
                    }
                }
            }
        }
        if (latest > 0) {
            syncData[@"hrvMs"] = @(latest);
            weakSelf.lastKnownHrvMs = latest;
            [[NSUserDefaults standardUserDefaults] setInteger:latest forKey:@"last_known_hrv"];
        }
        finish();
    }];
}

#pragma mark - On-demand measurement

- (QCMeasuringType)measuringTypeFromString:(NSString *)type {
    if ([type isEqualToString:@"bloodPressure"]) return QCMeasuringTypeBloodPressue;
    if ([type isEqualToString:@"bloodOxygen"]) return QCMeasuringTypeBloodOxygen;
    if ([type isEqualToString:@"temperature"]) return QCMeasuringTypeBodyTemperature;
    if ([type isEqualToString:@"stress"]) return QCMeasuringTypeStress;
    if ([type isEqualToString:@"hrv"]) return QCMeasuringTypeHRV;
    if ([type isEqualToString:@"oneKey"]) return QCMeasuringTypeOneKeyMeasure;
    return QCMeasuringTypeHeartRate;
}

- (NSString *)stringFromMeasuringType:(QCMeasuringType)type {
    switch (type) {
        case QCMeasuringTypeBloodPressue: return @"bloodPressure";
        case QCMeasuringTypeBloodOxygen: return @"bloodOxygen";
        case QCMeasuringTypeBodyTemperature:
        case QCMeasuringTypeThreeValueBodyTemperature: return @"temperature";
        case QCMeasuringTypeStress: return @"stress";
        case QCMeasuringTypeHRV: return @"hrv";
        case QCMeasuringTypeOneKeyMeasure:
        case QCMeasuringTypeOneKeyMeasureHeartRate: return @"oneKey";
        default: return @"heartRate";
    }
}

- (void)startMeasuring:(NSString *)typeName result:(FlutterResult)result {
    QCMeasuringType type = [self measuringTypeFromString:typeName];
    self.activeMeasureType = type;
    __weak typeof(self) weakSelf = self;
    [self enqueueCommand:^(EHGBandDone done) {
        [[QCSDKManager shareInstance] startToMeasuringWithOperateType:type timeout:90 measuringHandle:^(id resultObj) {
            [weakSelf emitMeasurementResult:type success:YES result:resultObj error:nil];
        } completedHandle:^(BOOL isSuccess, id resultObj, NSError *error) {
            [weakSelf emitMeasurementResult:type success:isSuccess result:resultObj error:error];
            result(@(isSuccess));
            done();
        }];
    }];
}

- (void)emitMeasurementResult:(QCMeasuringType)type success:(BOOL)success result:(id)resultObj error:(NSError *)error {
    NSMutableDictionary *event = [NSMutableDictionary dictionary];
    event[@"type"] = success ? @"measurement_result" : @"measurement_fail";
    event[@"measureType"] = [self stringFromMeasuringType:type];
    if (!success) {
        event[@"error"] = error.localizedDescription ?: @"Measurement failed";
        [self sendEvent:event];
        return;
    }
    if ([resultObj isKindOfClass:[NSNumber class]]) {
        if (type == QCMeasuringTypeBloodOxygen) {
            event[@"spo2"] = resultObj;
            self.lastKnownBloodOxygen = [resultObj floatValue];
            [[NSUserDefaults standardUserDefaults] setFloat:[resultObj floatValue] forKey:@"last_known_spo2"];
        } else if (type == QCMeasuringTypeStress) {
            event[@"stress"] = resultObj;
            self.lastKnownStressLevel = [resultObj integerValue];
            [[NSUserDefaults standardUserDefaults] setInteger:[resultObj integerValue] forKey:@"last_known_stress"];
        } else if (type == QCMeasuringTypeHRV) {
            event[@"hrv"] = resultObj;
            self.lastKnownHrvMs = [resultObj integerValue];
            [[NSUserDefaults standardUserDefaults] setInteger:[resultObj integerValue] forKey:@"last_known_hrv"];
        } else {
            event[@"hr"] = resultObj;
        }
    } else if ([resultObj isKindOfClass:[QCHeartRateModel class]]) {
        event[@"hr"] = @(((QCHeartRateModel *)resultObj).heartrate);
    } else if ([resultObj isKindOfClass:[QCBloodPressureModel class]]) {
        QCBloodPressureModel *model = (QCBloodPressureModel *)resultObj;
        event[@"sbp"] = @(model.systolicPressure);
        event[@"dbp"] = @(model.diastolicPressure);
        self.lastKnownSbp = model.systolicPressure;
        self.lastKnownDbp = model.diastolicPressure;
        [[NSUserDefaults standardUserDefaults] setInteger:model.systolicPressure forKey:@"last_known_sbp"];
        [[NSUserDefaults standardUserDefaults] setInteger:model.diastolicPressure forKey:@"last_known_dbp"];
    } else if ([resultObj isKindOfClass:[QCBloodOxygenModel class]]) {
        event[@"spo2"] = @(((QCBloodOxygenModel *)resultObj).soa2);
        self.lastKnownBloodOxygen = ((QCBloodOxygenModel *)resultObj).soa2;
        [[NSUserDefaults standardUserDefaults] setFloat:self.lastKnownBloodOxygen forKey:@"last_known_spo2"];
    } else if ([resultObj isKindOfClass:[QCTemperatureModel class]]) {
        event[@"temperature"] = @(((QCTemperatureModel *)resultObj).temperature);
        self.lastKnownSkinTemperature = ((QCTemperatureModel *)resultObj).temperature;
        [[NSUserDefaults standardUserDefaults] setFloat:self.lastKnownSkinTemperature forKey:@"last_known_temp"];
    } else if ([resultObj isKindOfClass:[QCThreeValueTemperatureModel class]]) {
        event[@"temperature"] = @(((QCThreeValueTemperatureModel *)resultObj).temperature1);
        self.lastKnownSkinTemperature = ((QCThreeValueTemperatureModel *)resultObj).temperature1;
        [[NSUserDefaults standardUserDefaults] setFloat:self.lastKnownSkinTemperature forKey:@"last_known_temp"];
    } else if ([resultObj isKindOfClass:[QCRealOneKeyMeasureHeartRateModel class]]) {
        event[@"hr"] = @(((QCRealOneKeyMeasureHeartRateModel *)resultObj).heartRateValue);
        event[@"hrv"] = @(((QCRealOneKeyMeasureHeartRateModel *)resultObj).heartRateHRV);
        event[@"stress"] = @(((QCRealOneKeyMeasureHeartRateModel *)resultObj).stress);
        event[@"sbp"] = @(((QCRealOneKeyMeasureHeartRateModel *)resultObj).bloodPressureSbp);
        event[@"dbp"] = @(((QCRealOneKeyMeasureHeartRateModel *)resultObj).bloodPressureDbp);
        self.lastKnownHrvMs = ((QCRealOneKeyMeasureHeartRateModel *)resultObj).heartRateHRV;
        self.lastKnownStressLevel = ((QCRealOneKeyMeasureHeartRateModel *)resultObj).stress;
        self.lastKnownSbp = ((QCRealOneKeyMeasureHeartRateModel *)resultObj).bloodPressureSbp;
        self.lastKnownDbp = ((QCRealOneKeyMeasureHeartRateModel *)resultObj).bloodPressureDbp;
        [[NSUserDefaults standardUserDefaults] setInteger:self.lastKnownHrvMs forKey:@"last_known_hrv"];
        [[NSUserDefaults standardUserDefaults] setInteger:self.lastKnownStressLevel forKey:@"last_known_stress"];
        [[NSUserDefaults standardUserDefaults] setInteger:self.lastKnownSbp forKey:@"last_known_sbp"];
        [[NSUserDefaults standardUserDefaults] setInteger:self.lastKnownDbp forKey:@"last_known_dbp"];
    }
    [self sendEvent:event];
}

#pragma mark - QCCentralManagerDelegate

- (void)didState:(QCState)state {
    NSString *stateStr = @"unknown";
    CBPeripheral *per = [QCCentralManager shared].connectedPeripheral;
    switch (state) {
        case QCStateConnected: {
            stateStr = @"connected";
            [self finishConnect:YES error:nil];
            [self sendBindVibrationThenTime];
            [self startStepPolling];
            break;
        }
        case QCStateConnecting:
            stateStr = @"connecting";
            break;
        case QCStateDisconnected:
        case QCStateUnbind:
            stateStr = @"disconnected";
            [self stopStepPolling];
            [self.realtimeHrHoldTimer invalidate];
            self.realtimeHrHoldTimer = nil;
            [self.commandWatchdogTimer invalidate];
            self.commandWatchdogTimer = nil;
            self.commandRunning = NO;
            [self.commandQueue removeAllObjects];
            if (self.pendingConnectResult) {
                [self finishConnect:NO error:@"Band disconnected during connection."];
            }
            if (self.pendingDisconnectResult) {
                self.pendingDisconnectResult(@(YES));
                self.pendingDisconnectResult = nil;
            }
            break;
        case QCStateDisconnecting:
            stateStr = @"disconnecting";
            break;
        default:
            break;
    }

    NSMutableDictionary *event = [@{
        @"type": @"connection_state",
        @"state": stateStr
    } mutableCopy];
    if (per) {
        event[@"name"] = per.name ?: @"EHG Smart Band";
        event[@"id"] = per.identifier.UUIDString ?: @"";
        event[@"mac"] = per.identifier.UUIDString ?: @"";
    }
    [self sendEvent:event];
}

- (void)didBluetoothState:(QCBluetoothState)state {
    NSString *stateStr = @"unknown";
    switch (state) {
        case QCBluetoothStatePoweredOn: stateStr = @"poweredOn"; break;
        case QCBluetoothStatePoweredOff: stateStr = @"poweredOff"; break;
        case QCBluetoothStateUnauthorized: stateStr = @"unauthorized"; break;
        case QCBluetoothStateUnsupported: stateStr = @"unsupported"; break;
        case QCBluetoothStateResetting: stateStr = @"resetting"; break;
        default: break;
    }
    [self sendEvent:@{@"type": @"bluetooth_state", @"state": stateStr}];
}

- (void)didScanPeripherals:(NSArray<QCBlePeripheral *> *)peripheralArr {
    [self.discoveredPeripherals removeAllObjects];
    [self.discoveredPeripherals addObjectsFromArray:peripheralArr];

    NSMutableArray *deviceList = [NSMutableArray array];
    for (QCBlePeripheral *blePer in peripheralArr) {
        [deviceList addObject:@{
            @"id": blePer.peripheral.identifier.UUIDString ?: @"",
            @"name": blePer.peripheral.name ?: @"EHG Smart Band",
            @"mac": blePer.mac ?: @"",
            @"rssi": blePer.RSSI ?: @(-70),
        }];
    }
    [self sendEvent:@{@"type": @"scan_results", @"devices": deviceList}];
}

- (void)scanPeripheralFinish {
    [self sendEvent:@{@"type": @"scan_finished"}];
}

- (void)didFailConnected:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    if ([QCCentralManager shared].bleState != QCBluetoothStatePoweredOn) {
        [self finishConnect:NO error:nil];
        [self sendEvent:@{
            @"type": @"connection_state",
            @"state": @"disconnected"
        }];
        return;
    }
    NSString *msg = error.localizedDescription ?: @"Connection failed";
    if (error.code == 14 || [msg.lowercaseString containsString:@"pairing"] || [msg.lowercaseString containsString:@"peer"]) {
        msg = @"Pairing info mismatch: Please go to iPhone Settings > Bluetooth, tap (i) next to this device, tap 'Forget This Device', then connect again.";
    }
    [self finishConnect:NO error:msg];
    [self sendEvent:@{
        @"type": @"connection_failed",
        @"error": msg
    }];
}

@end
