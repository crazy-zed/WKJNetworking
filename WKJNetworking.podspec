
Pod::Spec.new do |s|
##项目名称
s.name         = "WKJNetworking"
##版本号
s.version      = "1.0.2"
##开源证书
s.license      = { :type => "MIT", :file => "LICENSE" }
##项目简介
s.summary      = "一个流畅的链式请求框架（基于AFNetworking实现）"
##项目主页
s.homepage     = "https://github.com/Jerry-Zed/WKJNetworking"
##仓库地址
s.source       = { :git => "https://github.com/Jerry-Zed/WKJNetworking.git",
                   :tag => "#{s.version}" }
##项目源的位置
s.source_files = "WKJNetworking/*.{h,m}"
##是否启用ARC
s.requires_arc = true
##平台及支持的最低版本
s.platform     = :ios, "8.0"
##支持的框架
s.frameworks   = "UIKit", "Foundation"
##依赖库
s.dependency 'AFNetworking','~>3.2'
##个人信息
s.author             = { "WKJ" => "843377736@qq.com" }
#s.social_media_url   = "https://www.wkjstudio.com"
end
