Pod::Spec.new do |s|
  s.name = 'AI'
  s.version = '0.0.6'
  s.license = 'MIT'
  s.summary = 'The API.AI iOS SDK makes it easy to integrate speech recognition with API.AI natural language processing API on iOS devices.'
  s.homepage = 'https://api.ai/'
  s.social_media_url = ''
  s.authors = {
    'Dmitriy Kuragin' => 'kuragin@speaktoit.com'
  }
  s.source = {
    :git => 'https://github.com/api-ai/api-ai-cocoa-swift.git',
    :tag => 'v' + s.version.to_s,
    :submodules => true
  }

  s.requires_arc = true

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'

  s.source_files = 'AI/src/**/*.swift'
end
