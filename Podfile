platform :ios, '13.0'

target 'iacademy' do
  use_frameworks!

  pod 'IQKeyboardManager'
  pod 'Alamofire'
  pod 'netfox', '1.19.0'
  pod 'Kingfisher'
  pod 'JGProgressHUD'
  pod 'CRRefresh'
  pod 'FittedSheets', '1.3.0'
  pod 'Firebase/Messaging'
  pod 'VdoFramework'

end

post_install do |installer|
    installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
               end
          end
   end
end
