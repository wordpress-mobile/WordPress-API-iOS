Pod::Spec.new do |s|
  s.name         = "WordPressApi"
  s.version      = "0.3.6"
  s.summary      = "A simple Objective-C client to publish posts on the WordPress platform"
  s.homepage     = "https://github.com/wordpress-mobile/WordPressApi"
  s.license      = { :type => 'MIT', :file => 'LICENSE.md' }
  s.author       = "WordPress"
  s.source       = { :git => "https://github.com/wordpress-mobile/WordPressApi.git", :tag => s.version.to_s }
  s.source_files = 'Pod'
  s.requires_arc = true
  s.dependency 'AFNetworking', '~> 2.6.0'
  s.dependency 'wpxmlrpc', '~> 0.7'

  s.platform = :ios, '8.0'
  s.ios.deployment_target = '8.0'
  s.public_header_files = "Pod/**/*.h"
  s.frameworks = 'Foundation', 'UIKit', 'Security'
end
