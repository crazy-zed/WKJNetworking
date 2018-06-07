# WKJNetworking
一个书写流畅的链式请求框架（基于AFNetworking实现），您可以跟调用属性那样简单方便的发起请求。在本框架中实现了简单Cache功能，您可以轻松设置是否需要缓存响应数据，并提供缓存相关操作方法。

## Cocoapods导入
在Podfile中添加

	pod 'WKJNetworking', '~> 1.0.1'

## 使用方法
1. 注册基础URL

	注册基础请求地址（前缀），在AppDelegate（保证在所有请求开始之前调用即可）添加以下方法：
	
		//如“https://api.xxx.com”
		[WKJNetworking registBaseURL:@"Your BaseURL"];
		
2. 注册自定请求响应回调
	
	可以根据公司的业务逻辑及接口的数据结构自定义响应回调的调用时机以及返回值，在AppDelegate（保证在所有请求开始之前调用即可）添加以下方法：
	
		/* 某接口返回数据格式如下：
		 *	{
		 *	 "resultcode":"200",
		 *	 "reason":"SUCCESSED!", 
		 *	 "result":xxxxxxx
		 *	}
		 */
		 [WKJNetworking registResponseBlock:^(id respones, RequestSuccess rs, RequestFail rf) {
		 
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
	
3. 开始请求

	注册过baseURL后则可以再项目中使用 **global(@"subURL")** 构建请求，方法如下：
	
		//该请求完整URL为：http://web.juhe.cn:8080/finance/exchange/rmbquot
    	NSDictionary *params = @{@"key":@"31e52c8179a83852a0f9b8846fd86b11"};
    	
    	WKJNetworking
    	//使用全局构建对象，传入子URL即可
    	.global(@"rmbquot")
    	
    	//设置请求头
    	.header(@{@"testKey":@"is test header"})
    	
    	//设置超时时间
    	.timeout(10)
    	
    	//设置是否缓存（如果为YES，success回调会调用两次）
    	.cache(YES)
    	
    	//开始请求
    	 .request()
    	 
    	//使用GET方法，传入请求参数（更多方法请查看WKJNetworking.h文件）
    	.get(params)
    	
    	//成功回调，该block不会发生循环引用
    	.success(^(id respones) {
        	self.responseView.text = [respones description];
    	})
    	
    	//失败回调，该block不会发生循环引用
   		.fail(^(NSError *error) {
        	self.responseView.text = error.domain;
    	});
    	
    也可以用默认配置进行快速请求：
    
    	WKJNetworking.global(@"rmbquot").request()
    	.get(params)
    	.success(^(id respones) {
        	self.responseView.text = [respones description];
    	})
   		.fail(^(NSError *error) {
        	self.responseView.text = error.domain;
    	});