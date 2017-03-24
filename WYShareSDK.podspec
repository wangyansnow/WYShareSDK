
Pod::Spec.new do |s|

  s.name         = "WYShareSDK"
  s.author       = { "wangyansnow" => "13146597377@163.com" }
  s.version      = "0.1.0"
  s.summary      = "三大平台登录和分享"
  s.description  = <<-DESC
    qq, 微信， 微博分享以及除了微博的登录
  DESC
  s.homepage     = "https://github.com/wangyansnow/WYShareSDK"
  s.source       = { :git => "https://github.com/wangyansnow/WYShareSDK.git", :tag => "#{s.version}" }
  s.platform     = :ios, '7.0'
  s.requires_arc = true
  s.license      = 'MIT'
  s.source_files = 'ShareSDK/**/*.{h,m}'
#s.exclude_files = "ShareSDK/*.{h,m}"
  s.resource     = 'ShareSDK/libWeiboSDK/WeiboSDK.bundle', 'ShareSDK/QQSDK/TencentOpenApi_IOS_Bundle.bundle'
  s.vendored_libraries  = 'ShareSDK/libWeiboSDK/libWeiboSDK.a', 'ShareSDK/WXSDK/libWeChatSDK.a'
  s.vendored_frameworks = 'ShareSDK/QQSDK/TencentOpenAPI.framework'
  s.frameworks   = 'ImageIO', 'SystemConfiguration', 'CoreText', 'QuartzCore', 'Security', 'UIKit', 'Foundation', 'CoreGraphics','CoreTelephony'
  s.libraries = 'sqlite3', 'z', 'c++', 'iconv', 'stdc++', 'sqlite3.0'

end
