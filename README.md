# WKJNetworking
一个书写流畅的链式请求框架（基于AFNetworking实现），您可以跟调用属性那样简单方便的发起请求。在本框架中实现了简单Cache功能，您可以轻松设置是否需要缓存响应数据，并提供缓存相关操作方法。

## Cocoapods导入
在Podfile中添加

	pod 'WKJNetworking', '~> 1.0.3'

## 使用方法
### 1. 注册基础URL

注册基础请求地址（前缀），在AppDelegate（保证在所有请求开始之前调用即可）添加以下方法：
	
	[WKJNetworking registBaseURL:@"Your BaseURL"];
		
### 2. 注册自定请求响应回调

可以根据公司的业务逻辑及接口的数据结构自定义响应回调的调用时机以及返回值，在AppDelegate（保证在所有请求开始之前调用即可）添加以下方法：
		
	/* 某接口返回数据格式如下：
	 * {
	 * 	"code":"200",
	 *	"msg":"SUCCESSED!", 
	 *	"data":xxxxxxx
	 * }
	 */
	[WKJNetworking registResponseBlock:^(id respones, NSError *error, RequestSuccess rs, RequestFail rf) {
		// 处理网络错误回调
   		if (error.code == -1009) {
   			NSError *error = [NSError errorWithDomain:@"无网络连接" code:-1009 userInfo:nil];
 			rf(error);
   			return;
  		}
 		// 处理业务逻辑回调
   		if ([respones[@"code"] intValue] == 200) {
   			rs(respones[@"data"]);
   		}
  		else {
   			NSError *error = [NSError errorWithDomain:respones[@"msg"] code:[respones[@"code"] intValue] userInfo:nil];
			rf(error);
  		}
   	}];
	
### 3. 开始请求

1.通过 **global** 构建请求，该方式可以在注册过BaseURL或提前设置好Header，Timeout等参数后直接开始请求，该方式只要设置一次全局使用。

	WKJNetworking.global(@"rmbquot").request()
    .get(params)
    .success(^(id respones) {
        // your code
    })
   	.fail(^(NSError *error) {
        // your code
    });

2.通过 **builder** 构建请求，该方式针对单独的网络请求，如其他三方的API等等可以使用该方法构建（注：cache()方法只针对摸个请求，与global和builder无关，默认为NO）。
	
	WKJNetworking
    // 构建请求，传入完整URL
    .builder(@"http://api.xxxxxxx.com")
    
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
        // your code
    })
    
    // 失败回调，该block不会发生循环引用
    .fail(^(NSError *error) {
        // your code
    });