//
//  SocketManager.m
//  TCPSocketTest
//
//  Created by LiHaozhen on 15/4/22.
//  Copyright (c) 2015年 LiHaozhen. All rights reserved.
//

#import "SocketManager.h"

@interface SocketManager ()

@property (strong, nonatomic) NSMutableArray *socketHistory;

@property (copy, nonatomic) NSString *willSenddata;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@end

@implementation SocketManager

+ (instancetype)sharedManager
{
    static SocketManager *mgr = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        mgr = [[super allocWithZone:NULL] init];
    });
    return mgr;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    return [self sharedManager];
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setDateFormat:@"HH:mm:ss"];
        
//        self.socketHistory = [NSMutableArray array];
    }
    return self;
}

- (void)socketConnectHost:(NSString *)host
                     port:(UInt16)port
                 delegate:(id<SocketManagerDelegate>)delegate
{
    if (self.socket == nil) {
        self.socket = [[AsyncSocket alloc] initWithDelegate:self];
    }
    
    NSError *error = nil;
    
    self.socketHost = host;
    self.socketPort = port;
//    self.socketHost = @"10.211.55.6";
//    self.socketPort = 60000;
    self.delegate = delegate;
    NSLog(@"will connect : %@:%d", self.socketHost, self.socketPort);
    [[NSString stringWithFormat:@"will connect : %@:%d", self.socketHost, self.socketPort] toast];
    BOOL connected = [self.socket connectToHost:self.socketHost
                        onPort:self.socketPort
                         error:&error];
    
    if (!connected) {
        NSLog(@"error: %@", error);
        abort();
    }else{
        [self.socket setRunLoopModes:@[NSRunLoopCommonModes]];
    }
}

- (void)cutOfSocket
{
    if ([self.socket isConnected]) {
        [self.socket disconnect];
    }
}

- (void)writeData:(NSString *)data
{
    if (self.socket.isConnected == YES) {
        self.willSenddata = data;
        NSData *_data = [data dataUsingEncoding:NSUTF8StringEncoding];
        [self.socket writeData:_data withTimeout:-1 tag:0];
    }
}

- (NSString *)dateFormatText:(NSString *)text send:(BOOL)send
{
    NSString *fmt = @"%@ %@:%@";
    NSString *fmtText = [NSString stringWithFormat:fmt,
                         [self.dateFormatter stringFromDate:[NSDate date]],
                         send?@"发送数据":@"收到数据",
                         text];
    return fmtText;
}

- (NSString *)historyLog
{
    return [self.socketHistory componentsJoinedByString:@"\n"];
}

- (void)addToHistory:(NSString *)text send:(BOOL)send
{
    NSString *fmtText = [self dateFormatText:text send:send];
    if (self.socketHistory == nil) {
        self.socketHistory = [NSMutableArray array];
    }
    [self.socketHistory addObject:fmtText];
    if ([self.delegate respondsToSelector:@selector(socketManager:didUpdateHistory:)]) {
        [self.delegate socketManager:self didUpdateHistory:self.historyLog];
    }
}

#pragma mark - Socket delegate
- (BOOL)onSocketWillConnect:(AsyncSocket *)sock
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    return YES;
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    [@"socket 已连接" toast];
    [sock readDataWithTimeout:-1 tag:0];
    
    if ([self.delegate respondsToSelector:@selector(socketManager:socketDidConnect:)]) {
        [self.delegate socketManager:self socketDidConnect:sock];
    }
}

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
    NSLog(@"%s: %@", __PRETTY_FUNCTION__, err);
    
    if ([self.delegate respondsToSelector:@selector(socketManager:socketDidDisconnect:)]) {
        [self.delegate socketManager:self socketDidDisconnect:sock];
    }
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
    [@"socket 已断开连接" toast];
    
    if ([self.delegate respondsToSelector:@selector(socketManager:socketDidDisconnect:)]) {
        [self.delegate socketManager:self socketDidDisconnect:sock];
    }
}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    [@"socket 发送数据" toast];
    [self addToHistory:self.willSenddata send:YES];
    [sock readDataWithTimeout:-1 tag:0];
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    [self addToHistory:response send:NO];
    [[NSString stringWithFormat:@"socket 收到数据: %@", response] toast];
    [sock readDataWithTimeout:-1 tag:0];
}

@end
