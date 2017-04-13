
Pod::Spec.new do |s|

  s.name         = "WYShareSDK"
  s.author       = { "wangyansnow" => "13146597377@163.com" }
  s.version      = "0.1.0"
  s.summary      = "三大平台登录和分享"
  s.description  = <<-DESC
    qq, 微信， 微博分享以及除了微博的登录
  DESC
  s.homepage     = "https://github.com/wangyansnow/WYShareSDK"
  s.source       = { :git => "https://github.com/wangyansnow/WYShareSDK.git", :tag => "#{s.version}" ,submodules: true}
  s.platform     = :ios, '7.0'
  s.requires_arc = true
  s.license      = 'MIT'
  s.source_files = 'ShareSDK/Core/*.{h,m}'
  s.frameworks   = 'ImageIO', 'SystemConfiguration', 'CoreText', 'QuartzCore', 'Security', 'UIKit', 'Foundation', 'CoreGraphics','CoreTelephony'
  s.libraries = 'sqlite3', 'z', 'c++', 'iconv', 'stdc++', 'sqlite3.0'

  s.subspec 'QQSDK' do |ss|
    ss.source_files = 'ShareSDK/QQModel/*.{h,m}'
    ss.resource = 'ShareSDK/QQSDK/TencentOpenApi_IOS_Bundle.bundle'
    ss.vendored_frameworks = 'ShareSDK/QQSDK/TencentOpenAPI.framework'
    ss.dependency 'WYShareSDK/Core'
  end

  s.subspec 'WXSDK' do |ss|
    ss.source_files = 'ShareSDK/WXSDK/*.{h,m}', 'ShareSDK/WXModel/*.{h,m}'
    ss.vendored_libraries = 'ShareSDK/WXSDK/libWeChatSDK.a'
    ss.dependency 'WYShareSDK/Core'
  end

  s.subspec 'WeiboSDK' do |ss|
    ss.source_files = 'ShareSDK/libWeiboSDK/*.{h,m}', 'ShareSDK/WeiboModel/*.{h,m}'
    ss.resource = 'ShareSDK/libWeiboSDK/WeiboSDK.bundle'
    ss.vendored_libraries = 'ShareSDK/libWeiboSDK/libWeiboSDK.a'
    ss.dependency 'WYShareSDK/Core'
  end

  s.subspec 'Core' do |ss|
    ss.source_files = 'ShareSDK/Core/*.{h,m}'
  end

end
