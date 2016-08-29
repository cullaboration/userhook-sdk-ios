#
# Be sure to run `pod lib lint UserHook.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'UserHook'
  s.version          = '1.1.3'
  s.summary          = 'iOS SDK for the User Hook service'

  s.homepage         = 'https://userhook.com'
  s.license          = { :type => 'BSD', :file => 'LICENSE' }
  s.author           = { 'User Hook' => 'info@cullaboration.com' }
  s.source           = { :git => 'https://github.com/cullaboration/userhook-sdk-ios.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.source_files = 'UserHook/**/**'
  s.frameworks = 'UIKit'
  s.dependency 'JSONModel'
end
