#
# Be sure to run `pod lib lint REBottomSheetController.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'REBottomSheetController'
  s.version          = '0.2.0'
  s.summary          = 'REBottomSheetController is bottomSheet like map app, stock app.'
  s.homepage         = 'https://github.com/roceun/REBottomSheetController'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'roceun' => 'roceun@gmail.com' }
  s.source           = { :git => 'https://github.com/roceun/REBottomSheetController.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.source_files = 'REBottomSheetController/Classes/**/*'
  
  # s.resource_bundles = {
  #   'REBottomSheetController' => ['REBottomSheetController/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
