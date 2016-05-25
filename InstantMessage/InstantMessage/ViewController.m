//
//  ViewController.m
//  InstantMessage
//
//  Created by 吴会生 on 16/5/24.
//  Copyright © 2016年 吴会生. All rights reserved.
//

#import "ViewController.h"
#import <AsyncSocket.h>
#import <GCDAsyncSocket.h>
@interface ViewController ()<AsyncSocketDelegate>
@property (weak, nonatomic) IBOutlet UILabel *hostName;
@property (weak, nonatomic) IBOutlet UILabel *portName;
@property (weak, nonatomic) IBOutlet UITextField *host;
@property (weak, nonatomic) IBOutlet UITextField *port;
- (IBAction)sendClick:(UIButton *)sender;
- (IBAction)disconnect:(id)sender;

- (IBAction)connect:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *historytext;

@property (weak, nonatomic) IBOutlet UITextView *massageText;
@property(nonatomic,strong) AsyncSocket * socket;
@end

@implementation ViewController
-(AsyncSocket *)socket{

    if (!_socket) {
        _socket=[[AsyncSocket alloc]initWithDelegate:self];
    }
    return _socket;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.historytext.editable=NO;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendClick:(UIButton *)sender {
    
    //发给服务器
    NSString * msg = self.massageText.text;
    NSDictionary * dic =@{@"user":@"客户端1",@"massage":msg};
    [self.socket writeData:[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil] withTimeout:3 tag:1];
    NSLog(@"已经发送，请等待发送结果");
    [self.socket readDataWithTimeout:-1 tag:0];
  
}

- (IBAction)disconnect:(id)sender {
    //断开连接
    [self.socket disconnect];
}

- (IBAction)connect:(id)sender {
    //连接
//    [self.socket disconnect];
    NSError * error=nil;
    NSLog(@"%@====%@",self.host.text,self.port.text);
   BOOL result= [self.socket connectToHost:self.host.text onPort:[self.port.text integerValue] error:&error];
    NSLog(@"%d连接结果%@",result,error);
}
- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port{
    NSLog(@"连接成功");
    [self.socket readDataWithTimeout:-1 tag:0];
}

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
    NSLog(@"即将失去连接%@",err);
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
//    NSString *msg = @"Sorry this connect is failure";
    NSLog(@"失去连接");
}

-(void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{   [self.socket readDataWithTimeout:-1 tag:0];
    NSLog(@"发送数据");
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    
    UIApplicationState  state = [UIApplication sharedApplication].applicationState;
    if (state==UIApplicationStateBackground) {
        NSInteger number = [UIApplication sharedApplication].applicationIconBadgeNumber;
        NSLog(@"设置程序标示后台情况下%ld",number);
        number++;
        NSLog(@"%ld",number);
        NSLog(@"%@",[NSThread currentThread]);
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:number];
       
    }
    

    NSString* aStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"Hava received datas is :%@",aStr);
    NSDate * date = [NSDate date];
    NSDateFormatter * format =[[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString * datestring = [format stringFromDate:date];
    NSString * massege =[datestring stringByAppendingString:[NSString stringWithFormat:@":%@",aStr]];
    NSLog(@"%@",massege);
    NSString * text = self.historytext.text;
    text=[text stringByAppendingString:[NSString stringWithFormat:@"\n%@",massege]];
    NSLog(@"====%@",text);
    self.historytext.text=text;
    [self.socket readDataWithTimeout:-1 tag:0];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];

}



@end
