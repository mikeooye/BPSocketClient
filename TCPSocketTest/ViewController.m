//
//  ViewController.m
//  TCPSocketTest
//
//  Created by LiHaozhen on 15/4/22.
//  Copyright (c) 2015年 LiHaozhen. All rights reserved.
//

#import "ViewController.h"
#import "SocketManager.h"

@interface ViewController ()<UITextViewDelegate, SocketManagerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *ipAddressTf;
@property (weak, nonatomic) IBOutlet UITextField *portTf;
@property (weak, nonatomic) IBOutlet UITextView *historyTextView;
@property (weak, nonatomic) IBOutlet UIButton *connectButton;

- (IBAction)toConnect:(id)sender;

@property (weak, nonatomic) IBOutlet UITextView *textView;

- (void)doSend;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSString *host = [[NSUserDefaults standardUserDefaults] stringForKey:@"host"];
    NSString *port = [[NSUserDefaults standardUserDefaults] stringForKey:@"port"];
    
    self.ipAddressTf.text = host;
    self.portTf.text = port;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)toConnect:(id)sender {
    
    [self.view endEditing:YES];

    AsyncSocket *sock = [SocketManager sharedManager].socket;
    if (sock.isConnected == YES) {
        
        [[SocketManager sharedManager] cutOfSocket];
    }else{
        NSString *addr = _ipAddressTf.text;
        NSString *port = _portTf.text;
        if (addr.length && port.length) {
            
            SocketManager *mgr = [SocketManager sharedManager];
            [mgr socketConnectHost:addr port:[port integerValue] delegate:self];
            _connectButton.enabled = NO;
            _ipAddressTf.enabled = NO;
            _portTf.enabled = NO;
            [[NSUserDefaults standardUserDefaults] setObject:addr forKey:@"host"];
            [[NSUserDefaults standardUserDefaults] setObject:port forKey:@"port"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        
        [self doSend];
        return NO;
    }
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    textView.text = nil;
    return YES;
}

- (void)doSend
{
    [self.view endEditing:YES];
        
    [[SocketManager sharedManager] writeData:[self.textView.text stringByAppendingString:@"\r\n"]];
}

#pragma mark - SocketManager delegate
- (void)socketManager:(SocketManager *)sMgr didUpdateHistory:(NSString *)history
{
    self.historyTextView.text = [history stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (void)socketManager:(SocketManager *)sMgr socketDidConnect:(AsyncSocket *)sock
{
    _ipAddressTf.enabled = NO;
    _portTf.enabled = NO;
    _connectButton.enabled = YES;
    [self.connectButton setTitle:@"断开" forState:UIControlStateNormal];
    [self.connectButton setTintColor:[UIColor redColor]];
}

- (void)socketManager:(SocketManager *)sMgr socketDidDisconnect:(AsyncSocket *)sock
{
    _ipAddressTf.enabled = YES;
    _portTf.enabled = YES;
    _connectButton.enabled = YES;
    
    [self.connectButton setTitle:@"连接" forState:UIControlStateNormal];
    [self.connectButton setTintColor:nil];
}
@end
