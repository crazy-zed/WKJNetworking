//
//  ViewController.m
//  WKJNetworkingDemo
//
//  Created by 王恺靖 on 2018/6/6.
//  Copyright © 2018年 wkj. All rights reserved.
//

#import "ViewController.h"
#import "WKJNetworking.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextView *requestView;

@property (weak, nonatomic) IBOutlet UITextView *responseView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)startRequest:(id)sender
{
    // 使用global构建请求
    [self globalRequest];
    
    // 使用builder构建请求
//    [self builderRequest];
}

- (void)globalRequest
{
    // 该请求完整URL为：http://web.juhe.cn:8080/finance/exchange/rmbquot
    NSDictionary *params = @{@"key":@"31e52c8179a83852a0f9b8846fd86b11"};
    NSDictionary *header = WKJNetworking
    // 使用全局构建对象，传入子URL即可
    .global(@"/rmbquot")
    // 开始请求
    .request()
    // 使用GET方法，传入请求参数（更多方法请查看WKJNetworking.h文件）
    .get(params)
    // 成功回调，该block不会发生循环引用
    .success(^(id respones) {
        self.responseView.text = [respones description];
    })
    // 失败回调，该block不会发生循环引用
    .fail(^(NSError *error) {
        self.responseView.text = error.domain;
    })
    // 获取请求头信息
    .header;
    
    NSString *paramsStr = [NSString stringWithFormat:@"请求参数：\n%@", [params description]];
    NSString *headerStr = [NSString stringWithFormat:@"请求头信息：\n%@", [header description]];
    self.requestView.text = [NSString stringWithFormat:@"%@\n\n%@", paramsStr, headerStr];
}

- (void)builderRequest
{
    // 该请求完整URL为：http://web.juhe.cn:8080/finance/exchange/rmbquot
    NSDictionary *params = @{@"key":@"31e52c8179a83852a0f9b8846fd86b11"};
    NSDictionary *header = WKJNetworking
    // 构建请求，传入完整URL
    .builder(@"http://web.juhe.cn:8080/finance/exchange/rmbquot")
    // 设置请求头
    .header(@{@"Test-Key":@"123"})
    // 设置超时时间
    .timeout(10)
    // 设置是否缓存（如果为YES，success回调会调用两次）
    .cache(NO)
    // 开始请求
    .request()
    // 使用GET方法，传入请求参数（更多方法请查看WKJNetworking.h文件）
    .get(params)
    // 成功回调，该block不会发生循环引用
    .success(^(id respones) {
        self.responseView.text = [respones description];
    })
    // 失败回调，该block不会发生循环引用
    .fail(^(NSError *error) {
        self.responseView.text = error.domain;
    })
    // 获取请求头信息
    .header;
    
    NSString *paramsStr = [NSString stringWithFormat:@"请求参数：\n%@", [params description]];
    NSString *headerStr = [NSString stringWithFormat:@"请求头信息：\n%@", [header description]];
    self.requestView.text = [NSString stringWithFormat:@"%@\n\n%@", paramsStr, headerStr];
}

@end
