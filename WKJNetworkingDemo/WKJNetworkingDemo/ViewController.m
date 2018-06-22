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
    
    /**
     * 注册公共请求地址，可以在APPDelegate中使用；
     */
    [WKJNetworking registBaseURL:@"http://web.juhe.cn:8080/finance/exchange"];
    
    /**
     * 这里可以根据公司接口的数据格式做自定义回调配置，可以在APPDelegate中使用；
     * 之后只要使用global构建的请求都会使用一下配置的回调（注：该方法仅支持global构建的请求）
     *
     * 如该网站数据格式统一为：{"resultcode":"200",
     *                      "reason":"SUCCESSED!",
     *                      "result":xxxxxxx}
     * 则可以将回调内容更改如下：
     */
    [WKJNetworking registResponseBlock:^(id respones, NSError *error, RequestSuccess rs, RequestFail rf) {
        // 处理网络错误回调
        if (error.code == -1009) {
            NSError *error = [NSError errorWithDomain:@"无网络连接" code:-1009 userInfo:nil];
            rf(error);
            return;
        }
        // 处理业务逻辑回调
        if ([respones[@"resultcode"] intValue] == 200) {
            rs(respones[@"result"]);
        }
        else {
            NSError *error = [NSError errorWithDomain:respones[@"reason"]
                                                 code:[respones[@"resultcode"] intValue]
                                             userInfo:nil];
            rf(error);
        }
    }];
}

- (IBAction)startRequest:(id)sender
{
    // 该请求完整URL为：http://web.juhe.cn:8080/finance/exchange/rmbquot
    NSDictionary *params = @{@"key":@"31e52c8179a83852a0f9b8846fd86b11"};
    NSDictionary *header = WKJNetworking
    // 使用全局构建对象，传入子URL即可
    .global(@"rmbquot")
    // 设置请求头
    .header(@{@"testKey":@"is test header"})
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
