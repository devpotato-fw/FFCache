Pod::Spec.new do |s|
  s.name         = "FFCache"
  s.version      = "1.0.0"
  s.swift_version = '4.2'
  s.summary      = "Fast Caching for Swift (Works with iOS)."
  s.description  = "FFCache is a simple, thread-safe key value cache store for iOS."
  s.homepage     = "https://github.com/onefboy/FFCache"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { 'onefboy' => 'onefboy@gmail.com' }
  s.source       = { :git => "https://github.com/onefboy/FFCache.git", :tag => s.version.to_s }
  s.requires_arc = true
  s.source_files = "FFCache/FFCache/*.{swift}"
  s.ios.deployment_target  = "9.0"
end