lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'date'

require_relative 'lib/sensu-plugins-citoengine'

Gem::Specification.new do |s|
  s.authors                = ['Evelyn Lee']

  s.date                   = Date.today.to_s
  s.description            = 'Sensu plugins for interfacing with Citoengine'
  s.executables            = Dir.glob('bin/**/*.rb').map { |file| File.basename(file) }
  s.files                  = Dir.glob('{bin,lib}/**/*')
  s.homepage               = 'http://rubygems.org/gems/sensu-plugins-citoengine'
  s.license                = 'MIT'
  s.name                   = 'sensu-plugins-citoengine'
  s.post_install_message   = 'You can use the embedded Ruby by setting EMBEDDED_RUBY=true in /etc/default/sensu'
  s.require_paths          = ['lib']
  s.required_ruby_version  = '>= 2.0.0'
  s.summary                = 'Sensu plugins for interfacing with Citoengine'
  s.version                = SensuPluginsCitoengine::Version::VER_STRING

  s.add_runtime_dependency 'erubis',         '2.7.0'
  s.add_runtime_dependency 'sensu-plugin',   '~> 1.2'
end
