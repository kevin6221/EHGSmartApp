//
//  QCCentralManager.m
//  QCBandSDKDemo
//
//  Created by steve on 2023/2/28.
//

#import "QCCentralManager.h"
#import <QCBandSDK/QCSDKManager.h>
#import <QCBandSDK/QCSDKCmdCreator.h>

static NSString *const QCLastConnectedIdentifier = @"QCLastConnectedIdentifier";
static NSInteger const QCBleDefaultTimeout = 15;
static NSInteger const QCBleDefaultConnectTimeout = 6;
@implementation QCBlePeripheral


@end

@interface QCCentralManager()<CBCentralManagerDelegate>

/*中心角色,app*/
@property (strong, nonatomic) CBCentralManager *centerManager;

@property (strong, nonatomic) NSMutableArray<QCBlePeripheral *> *peripherals;

@property (strong, nonatomic) CBPeripheral *connectedPeripheral;

@property (nonatomic,copy) void(^connectCompletedHandle)(BOOL);

@property (nonatomic,strong)NSTimer *reconTimer;

@property (assign,nonatomic)QCDeviceType deviceType;

@property (nonatomic,assign)QCState deviceState;

@property (nonatomic,assign)QCBluetoothState bleState;

@property (nonatomic,assign) NSInteger scanTimeout;

@property (nonatomic,assign) NSInteger connectTimeout;
@end

@implementation QCCentralManager

+ (instancetype)shared {
    static QCCentralManager * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[QCCentralManager alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithBool:YES],CBCentralManagerOptionShowPowerAlertKey,
                                 [NSNumber numberWithBool:YES],CBConnectPeripheralOptionNotifyOnConnectionKey,
                                 nil];
        NSArray *bgModes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UIBackgroundModes"];
        if ([bgModes isKindOfClass:[NSArray class]] && [bgModes containsObject:@"bluetooth-central"]) {
            options[CBCentralManagerOptionRestoreIdentifierKey] = @"QCWXBluetoothRestore";
        }
        
        _centerManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue() options:options];
        _peripherals = [[NSMutableArray alloc] init];
        _scanTimeout = QCBleDefaultTimeout;
        _connectTimeout = QCBleDefaultTimeout;
    }
    return self;
}

#pragma mark - Params
- (void)setScanTimeout:(NSInteger)scanTimeout {
    if(scanTimeout >= 0) {
        _scanTimeout = scanTimeout;
    }
    else {
        _scanTimeout = QCBleDefaultTimeout;
    }
}

- (void)setConnectTimeout:(NSInteger)connectTimeout {
    if(connectTimeout >= 0) {
        _connectTimeout = connectTimeout;
    }
    else {
        _connectTimeout = QCBleDefaultConnectTimeout;
    }
}

- (void)setDeviceState:(QCState)deviceState {
    _deviceState = deviceState;
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(didState:)]) {
        [self.delegate didState:self.deviceState];
    }
}

#pragma mark - Public Fuction
- (void)scan; {
    [self scanWithTimeout:QCBleDefaultTimeout];
}

- (void)scanWithTimeout:(NSInteger)timeout {
    self.scanTimeout = timeout;
    
    [self stopScan];
    [self.peripherals removeAllObjects];
    
    NSArray <CBUUID*>*uuids = @[[CBUUID UUIDWithString:QCBANDSDKSERVERUUID1],[CBUUID UUIDWithString:QCBANDSDKSERVERUUID2]];
    NSArray *connectedP = [self retrieveConnectPeripheral:uuids];
    NSMutableArray * tempAray = [[NSMutableArray alloc] init];
    for (CBPeripheral *per in connectedP) {
        QCBlePeripheral *qcPer = [[QCBlePeripheral alloc] init];
        qcPer.peripheral = per;
        qcPer.mac = @"";//The paired device cannot read the mac from the system information, and can read the mac by sending instructions after the connection is successful
        qcPer.isPaired = YES;
        [tempAray addObject:qcPer];
    }
    
    [self.peripherals addObjectsFromArray:tempAray];
    
    if([connectedP count] > 0) {
        [self.peripherals sortedArrayUsingComparator:^NSComparisonResult(QCBlePeripheral *  _Nonnull obj1, QCBlePeripheral *  _Nonnull obj2) {
            return NSOrderedSame;
        }];
        if(self.delegate && [self.delegate respondsToSelector:@selector(didScanPeripherals:)]) {
            [self.delegate didScanPeripherals:self.peripherals];
        }
    }
    
    NSDictionary *option = @{CBCentralManagerScanOptionAllowDuplicatesKey : [NSNumber numberWithBool:NO]};
    [_centerManager scanForPeripheralsWithServices:nil options:option];
    
    [self stopTimer];
    self.reconTimer = [NSTimer scheduledTimerWithTimeInterval:self.scanTimeout target:self selector:@selector(stopScanFinishTimer:) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop]addTimer:self.reconTimer forMode: NSRunLoopCommonModes];
}

- (void)stopScan {
    
    if (!_centerManager) {
        return;
    }
    [_centerManager stopScan];
}

- (void)connect:(CBPeripheral *)peripheral {    
    [self connect:peripheral deviceType:QCDeviceTypeRing];
}

- (void)connect:(CBPeripheral *)peripheral deviceType:(QCDeviceType)deviceType {
    [self connect:peripheral timeout:QCBleDefaultConnectTimeout deviceType:deviceType];
}

- (void)connect:(CBPeripheral *)peripheral timeout:(NSInteger)timeout {
    [self connect:peripheral timeout:timeout deviceType:QCDeviceTypeRing];
}

- (void)connect:(CBPeripheral *)peripheral timeout:(NSInteger)timeout deviceType:(QCDeviceType)deviceType {
    [self stopScan];
    
    self.connectTimeout = timeout > 0 ? timeout : QCBleDefaultConnectTimeout;
    self.deviceType = deviceType;
    self.connectedPeripheral = peripheral;
    
    [self stopTimer];
    [self connectCurrentPeripheral];
    
    // Schedule one-shot connection timeout timer
    self.reconTimer = [NSTimer scheduledTimerWithTimeInterval:self.connectTimeout target:self selector:@selector(stopConnectFinishTimer:) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:self.reconTimer forMode:NSRunLoopCommonModes];
}

- (void)connectCurrentPeripheral {
    CBPeripheral *lastPer = [self lastPeripheral];
    NSLog(@"connect device: %@", lastPer);
    if (!lastPer) {
        return;
    }
    if (lastPer.state == CBPeripheralStateConnected) {
        NSLog(@"[QCCentralManager] Peripheral already connected in CoreBluetooth, proceeding directly to addPeripheral");
        [self centralManager:_centerManager didConnectPeripheral:lastPer];
        return;
    }
    NSDictionary *options = @{
        CBConnectPeripheralOptionNotifyOnDisconnectionKey: @(YES)
    };
    [_centerManager connectPeripheral:lastPer options:options];
}

- (void)remove {
    [self stopTimer];
    if (self.connectedPeripheral) {
        @try {
            [_centerManager cancelPeripheralConnection:self.connectedPeripheral];
        } @catch (NSException *e) {
            NSLog(@"warn: Exception while cancelling connection to (%@)", self.connectedPeripheral.name);
        }
    }

    [[QCSDKManager shareInstance] removeAllPeripheral];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:QCLastConnectedIdentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];

    // Official QC demo: mark Disconnecting so didDisconnect becomes Unbind
    // instead of triggering auto-reconnect.
    self.deviceState = QCStateDisconnecting;
}


- (void)startToReconnect{
    
    if (self.bleState != QCBluetoothStatePoweredOn) {
        if(self.delegate && [self.delegate respondsToSelector:@selector(didFailConnected:error:)]) {
            [self.delegate didFailConnected:self.connectedPeripheral error:[NSError errorWithDomain:@"Bluetooth powered off" code:-1 userInfo:@{@"message":@"Bluetooth powered off"}]];
        }
        return;
    }
    
    CBPeripheral *lastPer = [self lastPeripheral];
    if(lastPer) {
        [self connect:lastPer];
    }
    else {
        if(self.delegate && [self.delegate respondsToSelector:@selector(didFailConnected:error:)]) {
            [self.delegate didFailConnected:self.connectedPeripheral error:[NSError errorWithDomain:@"CBPeripheral not exist" code:-1 userInfo:@{@"message":@"CBPeripheral not exist"}]];
        }
    }
}

- (CBPeripheral*)lastPeripheral {
    
    if(self.connectedPeripheral) {
        return self.connectedPeripheral;
    }
    
    NSString *uuidStr = [[NSUserDefaults standardUserDefaults] objectForKey:QCLastConnectedIdentifier];
    
    if(uuidStr && uuidStr.length > 0) {
        return [self periperalWithUUID:uuidStr];
    }
    
    return nil;
}

- (BOOL)isBindDevice {
    NSString *uuidStr = [[NSUserDefaults standardUserDefaults] objectForKey:QCLastConnectedIdentifier];
    if(uuidStr && uuidStr.length > 0) {
        return YES;
    }
    return NO;
}

# pragma mark - CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    NSLog(@"centralManagerDidUpdateState:%ld",[central state]);
    QCBluetoothState bleState = QCBluetoothStateUnkown;
    
    switch([central state]) {
        case CBManagerStateUnknown:
            bleState = QCBluetoothStateUnkown;
            break;
        case CBManagerStateResetting:
            bleState = QCBluetoothStateResetting;
            break;
        case CBManagerStateUnsupported:
            bleState = QCBluetoothStateUnsupported;
            break;
        case CBManagerStateUnauthorized:
            bleState = QCBluetoothStateUnauthorized;
            break;
        case CBManagerStatePoweredOff:
            bleState = QCBluetoothStatePoweredOff;
            break;
        case CBManagerStatePoweredOn:
            bleState = QCBluetoothStatePoweredOn;
            break;
        default:break;
    }
    
    self.bleState = bleState;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didBluetoothState:)]) {
        [self.delegate didBluetoothState:bleState];
    }
    
    if([self isBindDevice]) {
        self.deviceState = QCStateConnecting;
    }
    else {
        self.deviceState = QCStateUnbind;
    }
    
    if (bleState == QCBluetoothStatePoweredOn && self.deviceState == QCStateConnecting) {
        [self startToReconnect];
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    if (peripheral.name.length == 0) return;
    
    NSString *nameLower = peripheral.name.lowercaseString;
    // 1. Filter out audio accessories, TVs, computers, phones, beacons
    NSArray *excludedKeywords = @[
        @"buds", @"airpod", @"earphone", @"headphone", @"headset",
        @"speaker", @"audio", @"sound", @"tv", @"macbook", @"iphone",
        @"ipad", @"laptop", @"car", @"echo", @"beats", @"sony", @"jbl",
        @"freebuds", @"linkbuds", @"pixel", @"galaxy"
    ];
    for (NSString *keyword in excludedKeywords) {
        if ([nameLower containsString:keyword]) {
            return;
        }
    }
    
    // 2. Check for QC Band characteristics
    NSString *mac = [self macFromAdvertisementData:advertisementData];
    
    NSArray *services = advertisementData[CBAdvertisementDataServiceUUIDsKey];
    BOOL hasQcService = NO;
    if ([services isKindOfClass:[NSArray class]]) {
        for (CBUUID *uuid in services) {
            NSString *uStr = uuid.UUIDString.lowercaseString;
            if ([uStr containsString:@"6e40"] || [uStr containsString:@"de5b"] || [uStr containsString:@"fff0"]) {
                hasQcService = YES;
                break;
            }
        }
    }
    
    BOOL hasBandPrefix = [nameLower hasPrefix:@"o_"] ||
                         [nameLower hasPrefix:@"q_"] ||
                         [nameLower hasPrefix:@"qc"] ||
                         [nameLower hasPrefix:@"ehg"] ||
                         [nameLower containsString:@"band"] ||
                         [nameLower containsString:@"ring"] ||
                         [nameLower containsString:@"watch"];
                         
    // Require genuine QC band attributes
    if (mac.length == 0 && !hasQcService && !hasBandPrefix) {
        return;
    }

    NSLog(@"Band device found:%@,mac:%@,id:%@",peripheral.name,mac,peripheral.identifier.UUIDString);
    BOOL isExist = false;
    for (QCBlePeripheral *per in self.peripherals) {
        if([per.peripheral.identifier.UUIDString isEqual:peripheral.identifier.UUIDString]) {
            per.peripheral = peripheral;
            per.mac = mac;
            per.advertisementData = advertisementData;
            per.RSSI = RSSI;
            isExist = true;
            return;
        }
    }
    
    if(!isExist) {
        QCBlePeripheral *per = [[QCBlePeripheral alloc] init];
        per.peripheral = peripheral;
        per.mac = mac;
        per.advertisementData = advertisementData;
        per.RSSI = RSSI;
        [self.peripherals addObject:per];
    }
    
    //Signal strength sorting
    [self.peripherals sortUsingComparator:^NSComparisonResult(QCBlePeripheral *obj1, QCBlePeripheral *obj2) {
        NSNumber *rssi1 = obj1.RSSI ?: @(-100);
        NSNumber *rssi2 = obj2.RSSI ?: @(-100);
        return [rssi2 compare:rssi1]; // 从大到小
    }];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(didScanPeripherals:)]) {
        [self.delegate didScanPeripherals:self.peripherals];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"Connection to device (%@) succeeded", peripheral.name);
    [self stopTimer];
    
    [[QCSDKManager shareInstance] removePeripheral:peripheral];
    [[QCSDKManager shareInstance] addPeripheral:peripheral finished:^(BOOL success) {
        if (success) {
            NSLog(@"Add peripherals successfully");
            [[NSUserDefaults standardUserDefaults] setValue:peripheral.identifier.UUIDString forKey:QCLastConnectedIdentifier];
            [[NSUserDefaults standardUserDefaults] synchronize];

            self.deviceState = QCStateConnected;
        }
        else {
            NSLog(@"Failed to add peripheral");
            if(self.delegate && [self.delegate respondsToSelector:@selector(didFailConnected:error:)]) {
                [self.delegate didFailConnected:peripheral error:[NSError errorWithDomain:@"Connect fail" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"Device handshake failed. Ensure band is unlinked from other apps."}]];
            }
        }
    }];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    NSLog(@"Device(%@) didFailToConnectPeripheral, err: %@", peripheral.name, error);
    [self stopTimer];
    self.deviceState = QCStateDisconnected;
    if (self.delegate && [self.delegate respondsToSelector:@selector(didFailConnected:error:)]) {
        [self.delegate didFailConnected:peripheral error:error ?: [NSError errorWithDomain:@"ConnectFail" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Failed to connect to peripheral"}]];
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    NSLog(@"Device(%@)didDisconnect, err: %@", peripheral.name, error);
    [self stopTimer];
    
    if (error && (error.code == 14 || [error.domain isEqualToString:CBErrorDomain])) {
        if (error.code == 14 || [error.localizedDescription.lowercaseString containsString:@"pairing"]) {
            NSLog(@"[QCCentralManager] Peer removed pairing information detected.");
            if (self.delegate && [self.delegate respondsToSelector:@selector(didFailConnected:error:)]) {
                NSError *pairErr = [NSError errorWithDomain:CBErrorDomain
                                                       code:14
                                                   userInfo:@{NSLocalizedDescriptionKey: @"Pairing info mismatch: Please go to iPhone Settings > Bluetooth, tap (i) next to this device, tap 'Forget This Device', then connect again."}];
                [self.delegate didFailConnected:peripheral error:pairErr];
            }
        }
    }
    
    if (self.deviceState == QCStateDisconnecting) {
        self.deviceState = QCStateUnbind;
        self.connectedPeripheral = nil;
    } else {
        [[QCSDKManager shareInstance] removeAllPeripheral];
        self.deviceState = QCStateDisconnected;
    }
}

- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary *)dict {
    NSArray *peripherals = dict[CBCentralManagerRestoredStatePeripheralsKey];
    if (peripherals.count > 0) {
        //恢复重连上一次连接的设备
        NSString *uuidStr = [[NSUserDefaults standardUserDefaults] objectForKey:QCLastConnectedIdentifier];
        if (uuidStr.length > 0) {
            for (CBPeripheral* pr in peripherals) {
                if ([uuidStr isEqualToString:pr.identifier.UUIDString]) {
                    self.connectedPeripheral = pr;
                }
            }
        }
    }
}

#pragma mark - Helpers
- (NSArray *)retrieveConnectPeripheral:(NSArray<CBUUID *> *)uuidArray
{
    NSArray *connectedDevice = [_centerManager retrieveConnectedPeripheralsWithServices:uuidArray];
    NSMutableArray *connectedPeripheral = [NSMutableArray arrayWithCapacity:connectedDevice.count];
    [connectedDevice enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj isKindOfClass:[CBPeripheral class]]) {
            return;
        }
        [connectedPeripheral addObject:obj];
    }];
    
    return [connectedPeripheral copy];
}

- (CBPeripheral *)periperalWithUUID:(NSString *)uuid {
    
    if (!uuid) {
        return nil;
    }
    
    NSArray *periperals = nil;
    NSUUID *UUID = [[NSUUID alloc] initWithUUIDString:uuid];
    if(!UUID){
        NSLog(@"NSUUID(%@)合法，但无法创建UUID，原因不明", uuid);
        return nil;
    }
    periperals = [_centerManager retrievePeripheralsWithIdentifiers:@[UUID]];
    if (periperals.count > 0) {
        return [periperals objectAtIndex:0];
    } else {
        return nil;
    }
}

- (NSString *)macFromAdvertisementData:(NSDictionary *)advertisementData {
    NSString *mac = @"";
    NSData *manufacturerData = [advertisementData objectForKey:@"kCBAdvDataManufacturerData"];
    mac = [self macFromData:manufacturerData];
    
    if (mac.length == 0) {
        NSDictionary *serviceData = [advertisementData objectForKey:@"kCBAdvDataServiceData"];
        if ([serviceData isKindOfClass:[NSDictionary class]]) {
            NSArray *allValues = [serviceData allValues];
            if (allValues.count > 0) {
                for (NSData *dataValue in allValues) {
                    if ([dataValue isKindOfClass:[NSData class]]) {
                        mac = [self macFromData:dataValue];
                    }
                }
            }
        }
    }
    return mac;
}

- (NSString*)macFromData:(NSData*)macData {
    NSString *mac = @"";
    if ([macData isKindOfClass:[NSData class]] && macData.length > 0) {
        NSData *data = macData;
        if (data.length >= 10) {
            data = [data subdataWithRange:NSMakeRange(4, 6)];
            Byte *bytes = (Byte *)data.bytes;
            mac = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x",
                        bytes[0], bytes[1], bytes[2], bytes[3], bytes[4], bytes[5]];
        } else if (data.length == 8) {
            data = [data subdataWithRange:NSMakeRange(2, 6)];
            Byte *bytes = (Byte *)data.bytes;
            mac = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x",
                        bytes[0], bytes[1], bytes[2], bytes[3], bytes[4], bytes[5]];
        } else if (data.length == 6) {
           data = [data subdataWithRange:NSMakeRange(0, 6)];
           Byte *bytes = (Byte *)data.bytes;
           mac = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x",
                       bytes[0], bytes[1], bytes[2], bytes[3], bytes[4], bytes[5]];
       }
    }
    
    return mac;
}

- (void)stopTimer
{
    if ([self.reconTimer isValid]) {
        [self.reconTimer invalidate];
        self.reconTimer = nil;
    }
}

- (void)stopConnectFinishTimer:(NSTimer *)timer {
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(didFailConnected:error:)]) {
        [self.delegate didFailConnected:self.connectedPeripheral error:[NSError errorWithDomain:@"timeout" code:-1 userInfo:@{@"message":@"connect timeout"}]];
    }
}

- (void)stopScanFinishTimer:(NSTimer *)timer
{
    [self stopScan];
    if (self.delegate && [self.delegate respondsToSelector:@selector(scanPeripheralFinish)]) {
        [self.delegate scanPeripheralFinish];
    }
}
@end
