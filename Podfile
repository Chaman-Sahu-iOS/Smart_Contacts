# Define a global platform to avoid outdated deployment target issues on new Xcode SDKs
platform :ios, '12.0'

target 'SmartContacts' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for SmartContacts
  pod 'GoogleSignIn'
  pod 'MBProgressHUD'

end

# Ensure all Pods use a minimum iOS deployment target compatible with Xcode 15/16 toolchains
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      # Align pods' deployment target to avoid missing 'libarclite' errors
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
    end
  end
end
