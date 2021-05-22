Pod::Spec.new do |s|
  s.name             = 'XTILoger'
  s.version          = '1.0'
  s.summary          = 'XTILoger'

  s.description      = <<-DESC
  TODO: 打印日志的组件
                       DESC

  s.homepage         = 'https://github.com/xt-input/XTILoger'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'xt-input' => 'input@tcoding.cn' }
  s.source           = { :git => 'https://github.com/xt-input/XTILoger.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'

  s.source_files = 'Source/**/*.swift'

  s.swift_version = '5'
  s.requires_arc  = true
end
