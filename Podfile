# Uncomment this line to define a global platform for your project
platform :ios, '8.0'

pod 'MBProgressHUD', '~> 0.9.1'
pod 'GPUImage'
pod 'VWWPermissionKit', '~> 1.3.0'

post_install do | installer |
  require 'fileutils'
  FileUtils.cp_r('Pods/Target Support Files/Pods/Pods-acknowledgements.plist', 'ZHTimeLapse/Settings.bundle/Pods-acknowledgements.plist', :remove_destination => true)

end



