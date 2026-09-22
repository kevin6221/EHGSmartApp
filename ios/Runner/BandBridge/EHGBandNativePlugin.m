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
@end

@implementation EHGBandNativePlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    FlutterMethodChannel *channel = [FlutterMethodChannel methodChannelWithName:@"com.ehg.smartapp/band"
                                                                binaryMessenger:[registrar messenger]];
    FlutterEventChannel *eventChannel = [FlutterEventChannel eventChannelWithName:@"com.ehg.smartapp/band_events"
                                                                  binaryMessenger:[registrar messenger]];

    EHGBandNativePlugin *instance = [[EHGBandNativePlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
    [eventChannel setStreamHandler:instance];

    [QCCentralManager shared].delegate = instance;
    [instance setupSDKCallbacks];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _discoveredPeripherals = [NSMutableArray array];
        _commandQueue = [NSMutableArray array];
        _activeMeasureType = QCMeasuringTypeUnkown;
    }
    return self;
}

- (void)setupSDKCallbacks {
    __weak typeof(self) weakSelf = self;

    [QCSDKManager shareInstance].realTimeHeartRate = ^(NSInteger hr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf sendEvent:@{@"type": @"live_heart_rate", @"bpm": @(hr)}];
        });
    };

    [QCSDKManager shareInstance].currentBatteryInfo = ^(NSInteger battery, BOOL charging) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf sendEvent:@{
                @"type": @"battery_update",
                @"battery": @(battery),
                @"charging": @(charging)
            }];
        });
    };

    [QCSDKManager shareInstance].currentStepInfo = ^(NSInteger step, NSInteger calorie, NSInteger distance) {
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
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.commandWatchdogTimer invalidate];
            weakSelf.commandWatchdogTimer = nil;
            weakSelf.commandRunning = NO;
            [weakSelf dequeueIfNeeded];
        });
    });
}

#pragma mark - FlutterStreamHandler

- (FlutterError * _Nullable)onListenWithArguments:(id _Nullable)arguments eventSink:(FlutterEventSink)events {
    self.eventSink = events;
    return nil;
}

- (FlutterError * _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    self.eventSink = nil;
    return nil;
}

#pragma mark - FlutterMethodCallHandler

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([@"requestEnableBluetooth" isEqualToString:call.method] || [@"openLocationSettings" isEqualToString:call.method]) {
        result(@(YES));
    }
    else if ([@"startScan" isEqualToString:call.method]) {
        NSInteger timeout = 30;
        if ([call.arguments isKindOfClass:[NSDictionary class]] && call.arguments[@"timeout"]) {
            timeout = [call.arguments[@"timeout"] integerValue];
        }
        [self.discoveredPeripherals removeAllObjects];
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
    else if ([@"disconnect" isEqualToString:call.method]) {
        [self handleDisconnect:result];
    }
    else if ([@"getBattery" isEqualToString:call.method]) {
        [self enqueueCommand:^(EHGBandDone done) {
            [QCSDKCmdCreator readBatterySuccess:^(int battery, BOOL charging) {
                result(@{@"battery": @(battery), @"charging": @(charging)});
                done();
            } failed:^{
                result([FlutterError errorWithCode:@"BATTERY_FAILED" message:@"Failed to read battery" details:nil]);
                done();
            }];
        }];
    }
    else if ([@"getDeviceInfo" isEqualToString:call.method]) {
        [self enqueueCommand:^(EHGBandDone done) {
            CBPeripheral *per = [QCCentralManager shared].connectedPeripheral;
            NSString *name = per.name ?: @"EHG Smart Band";
            NSString *deviceId = per.identifier.UUIDString ?: @"";
            [QCSDKCmdCreator getDeviceSoftAndHardVersionSuccess:^(NSString *hardVersion, NSString *softVersion) {
                [QCSDKCmdCreator getDeviceMacAddressSuccess:^(NSString *macAddress) {
                    result(@{
                        @"name": name,
                        @"id": deviceId,
                        @"hardVersion": hardVersion ?: @"",
                        @"softVersion": softVersion ?: @"",
                        @"macAddress": macAddress ?: @""
                    });
                    done();
                } fail:^{
                    result(@{
                        @"name": name,
                        @"id": deviceId,
                        @"hardVersion": hardVersion ?: @"",
                        @"softVersion": softVersion ?: @"",
                        @"macAddress": @""
                    });
                    done();
                }];
            } fail:^{
                result([FlutterError errorWithCode:@"VERSION_FAILED" message:@"Failed to read device version" details:nil]);
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
                [QCSDKCmdCreator realTimeHeartRateWithCmd:QCBandRealTimeHeartRateCmdTypeHold finished:^(BOOL success) {
                    done();
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

    self.pendingConnectResult = result;

    // Safety timeout timer (20 seconds)
    [self.connectTimeoutTimer invalidate];
    __weak typeof(self) weakSelf = self;
    self.connectTimeoutTimer = [NSTimer scheduledTimerWithTimeInterval:20.0 repeats:NO block:^(NSTimer * _Nonnull timer) {
        if (weakSelf.pendingConnectResult) {
            NSLog(@"[EHGBandNative] Connection timed out after 20 seconds");
            [weakSelf finishConnect:NO error:@"Connection timed out. If the band is linked to QwatchPro or paired in phone Bluetooth Settings, please unpair it there first."];
        }
    }];

    // Connect using Ring device type (no ANCS requirement)
    [[QCCentralManager shared] connect:target timeout:20 deviceType:QCDeviceTypeRing];
}

- (void)handleDisconnect:(FlutterResult)result {
    [self.realtimeHrHoldTimer invalidate];
    self.realtimeHrHoldTimer = nil;
    [self.connectTimeoutTimer invalidate];
    self.connectTimeoutTimer = nil;
    self.pendingDisconnectResult = result;
    [[QCCentralManager shared] remove];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
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

#pragma mark - Health sync (sequential; SDK rejects overlapping commands)

- (void)syncFullHealthDataWithResult:(FlutterResult)result {
    [self enqueueCommand:^(EHGBandDone done) {
        NSMutableDictionary *syncData = [NSMutableDictionary dictionary];
        syncData[@"steps"] = @0;
        syncData[@"calories"] = @0;
        syncData[@"distance"] = @0;
        syncData[@"sleepMinutes"] = @0;
        syncData[@"deepSleepMinutes"] = @0;
        syncData[@"bloodOxygen"] = @0;
        syncData[@"systolicBP"] = @0;
        syncData[@"diastolicBP"] = @0;
        syncData[@"skinTemperature"] = @0;
        syncData[@"stressLevel"] = @0;
        syncData[@"hrvMs"] = @0;
        syncData[@"restingHeartRate"] = @0;
        syncData[@"sleepPhases"] = @[];
        syncData[@"heartRateHistory"] = @[];

        [QCSDKCmdCreator getCurrentSportSucess:^(QCSportModel *sport) {
            syncData[@"steps"] = @(sport.totalStepCount);
            syncData[@"calories"] = @((int)sport.calories);
            syncData[@"distance"] = @(sport.distance);
            [self syncSleepInto:syncData finish:^{
                [self syncHeartRateInto:syncData finish:^{
                    [self syncOxygenInto:syncData finish:^{
                        [self syncBloodPressureInto:syncData finish:^{
                            [self syncTemperatureInto:syncData finish:^{
                                [self syncStressInto:syncData finish:^{
                                    [self syncHrvInto:syncData finish:^{
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
            result(syncData);
            done();
        }];
    }];
}

- (void)syncSleepInto:(NSMutableDictionary *)syncData finish:(void (^)(void))finish {
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
        finish();
    } fail:^{
        finish();
    }];
}

- (void)syncHeartRateInto:(NSMutableDictionary *)syncData finish:(void (^)(void))finish {
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
        }
        syncData[@"heartRateHistory"] = history;
        finish();
    } fail:^{
        finish();
    }];
}

- (void)syncOxygenInto:(NSMutableDictionary *)syncData finish:(void (^)(void))finish {
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
        }
        finish();
    }];
}

- (void)syncBloodPressureInto:(NSMutableDictionary *)syncData finish:(void (^)(void))finish {
    [QCSDKCmdCreator getSchedualBPHistoryDataWithSuccess:^(NSArray<QCBloodPressureModel *> *data) {
        QCBloodPressureModel *last = data.lastObject;
        if (last.systolicPressure > 0 && last.diastolicPressure > 0) {
            syncData[@"systolicBP"] = @(last.systolicPressure);
            syncData[@"diastolicBP"] = @(last.diastolicPressure);
        }
        finish();
    } fail:^{
        finish();
    }];
}

- (void)syncTemperatureInto:(NSMutableDictionary *)syncData finish:(void (^)(void))finish {
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
        }
        finish();
    }];
}

- (void)syncStressInto:(NSMutableDictionary *)syncData finish:(void (^)(void))finish {
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
        }
        finish();
    }];
}

- (void)syncHrvInto:(NSMutableDictionary *)syncData finish:(void (^)(void))finish {
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
        } else if (type == QCMeasuringTypeStress) {
            event[@"stress"] = resultObj;
        } else if (type == QCMeasuringTypeHRV) {
            event[@"hrv"] = resultObj;
        } else {
            event[@"hr"] = resultObj;
        }
    } else if ([resultObj isKindOfClass:[QCHeartRateModel class]]) {
        event[@"hr"] = @(((QCHeartRateModel *)resultObj).heartrate);
    } else if ([resultObj isKindOfClass:[QCBloodPressureModel class]]) {
        QCBloodPressureModel *model = (QCBloodPressureModel *)resultObj;
        event[@"sbp"] = @(model.systolicPressure);
        event[@"dbp"] = @(model.diastolicPressure);
    } else if ([resultObj isKindOfClass:[QCBloodOxygenModel class]]) {
        event[@"spo2"] = @(((QCBloodOxygenModel *)resultObj).soa2);
    } else if ([resultObj isKindOfClass:[QCTemperatureModel class]]) {
        event[@"temperature"] = @(((QCTemperatureModel *)resultObj).temperature);
    } else if ([resultObj isKindOfClass:[QCThreeValueTemperatureModel class]]) {
        event[@"temperature"] = @(((QCThreeValueTemperatureModel *)resultObj).temperature1);
    } else if ([resultObj isKindOfClass:[QCRealOneKeyMeasureHeartRateModel class]]) {
                event[@"hr"] = @(((QCRealOneKeyMeasureHeartRateModel *)resultObj).heartRateValue);
        event[@"hrv"] = @(((QCRealOneKeyMeasureHeartRateModel *)resultObj).heartRateHRV);
        event[@"stress"] = @(((QCRealOneKeyMeasureHeartRateModel *)resultObj).stress);
        event[@"sbp"] = @(((QCRealOneKeyMeasureHeartRateModel *)resultObj).bloodPressureSbp);
        event[@"dbp"] = @(((QCRealOneKeyMeasureHeartRateModel *)resultObj).bloodPressureDbp);
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
            break;
        }
        case QCStateConnecting:
            stateStr = @"connecting";
            break;
        case QCStateDisconnected:
        case QCStateUnbind:
            stateStr = @"disconnected";
            if (self.pendingConnectResult) {
                [self finishConnect:NO error:@"Band disconnected during connection. If previously paired, forget device in Settings > Bluetooth."];
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
