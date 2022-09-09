#
#  Be sure to run `pod spec lint AlphaWalletFoundation.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|
  spec.name         = "AlphaWalletSDK"
  spec.version      = "1.0.0"
  spec.summary      = "AlphaWallet functionality"
  spec.description      = "Core wallet functionality"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author             = { "Vladyslav Shepitko" => "vladyslav.shepitko@gmail.com" }
  spec.homepage     = "https://github.com/AlphaWallet/AlphaWalletSDK"
  spec.ios.deployment_target = '13.0'
  spec.swift_version    = '4.2'
  spec.platform         = :ios, "13.0"
  spec.source           = { :git => 'git@github.com:AlphaWallet/alpha-wallet-ios.git', :tag => "#{spec.version}" }
  spec.source_files     = 'AlphaWalletSDK/**/*.{h,m,swift}'
  spec.pod_target_xcconfig = { 'SWIFT_OPTIMIZATION_LEVEL' => '-Owholemodule' }
  spec.resource_bundles = {'AlphaWalletSDK' => ['AlphaWalletSDK/**/*.{graphql,json}'] }

  spec.source_files        = 'AlphaWalletSDK/**/*.{h,m,swift}'
  spec.dependency 'AlphaWalletFoundation'
  spec.dependency 'AlphaWalletCore'
  spec.dependency 'AlphaWalletAddress'
  spec.dependency 'AlphaWalletGoBack'
  spec.dependency 'AlphaWalletOpenSea'
  spec.dependency 'AlphaWalletENS'

end
