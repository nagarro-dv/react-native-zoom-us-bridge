require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "RNZoomUsBridge"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.description  = <<-DESC
                  React Native Zoom.us bridge for iOS
                  DESC
  s.homepage     = "https://github.com/nagarro-dv/react-native-zoom-us-bridge"
  # brief license entry:
  s.license      = "MIT"
  # optional - use expanded license entry instead:
  s.authors      = { "Nagarro" => "jim.ji@nagarro.com" }
  s.platforms    = { :ios => "10.0" }
  s.source       = { :git => "https://github.com/nagarro-dv/react-native-zoom-us-bridge.git", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,m,swift}"
  s.requires_arc = true

  s.dependency "React"

  s.pod_target_xcconfig = { 'FRAMEWORK_SEARCH_PATHS' => ['"${PROJECT_DIR}/../ZoomSDK/**"'] }
end
