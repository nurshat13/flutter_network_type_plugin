Pod::Spec.new do |s|
  s.name             = 'flutter_network_type_plugin'
  s.version          = '0.2.0'
  s.summary          = 'A Flutter plugin to determine network type and speed.'
  s.description      = <<-DESC
                       This plugin provides functionality to determine the network type (e.g., 4G, 5G, WiFi) and speed.
                       DESC
  s.homepage         = 'https://github.com/your-repo/flutter_network_type_plugin'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Nurshat' => 'nurshat170@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform         = :ios, '9.0'
  s.swift_version    = '5.0'
end
