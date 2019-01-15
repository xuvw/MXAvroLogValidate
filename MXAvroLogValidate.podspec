#
# Be sure to run `pod lib lint MXAvroLogValidate.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MXAvroLogValidate'
  s.version          = '0.1.0'
  s.summary          = 'OC版Avro log格式校验工具'

  s.description      = <<-DESC
                        OC版Avro log格式校验工具，目前支持所有Avro数据类型json格式校验
                       DESC

  s.homepage         = 'https://github.com/xuvw/MXAvroLogValidate'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '何可' => '1052110478@qq.com' }
  s.source           = { :git => 'https://github.com/xuvw/MXAvroLogValidate.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'MXAvroLogValidate/Classes/**/*'

end
