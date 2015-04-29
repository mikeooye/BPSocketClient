//
//  SocketManager.h
//  TCPSocketTest
//
//  Created by LiHaozhen on 15/4/22.
//  Copyright (c) 2015年 LiHaozhen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncSocket.h"
#import "BPToast.h"

@protocol SocketManagerDelegate;
@interface SocketManager : NSObject<AsyncSocketDelegate>

+ (instancetype)sharedManager;

@property (strong, nonatomic)   AsyncSocket *socket;
@property (copy, nonatomic)     NSString    *socketHost;
@property (assign, nonatomic)   UInt16   socketPort;
@property (weak, nonatomic) id<SocketManagerDelegate> delegate;

/**
 *  socket连接服务器
 */
- (void)socketConnectHost:(NSString *)host
                     port:(UInt16)port
                 delegate:(id<SocketManagerDelegate>)delegate;

/**
 *  socket断开连接
 */
- (void)cutOfSocket;

- (void)writeData:(NSString *)data;

@property (readonly, nonatomic) NSString *historyLog;
@end


@protocol SocketManagerDelegate <NSObject>

- (void)socketManager:(SocketManager *)sMgr didUpdateHistory:(NSString *)history;

- (void)socketManager:(SocketManager *)sMgr socketDidConnect:(AsyncSocket *)sock;
- (void)socketManager:(SocketManager *)sMgr socketDidDisconnect:(AsyncSocket *)sock;
@end