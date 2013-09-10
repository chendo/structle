$:.unshift(File.join(File.dirname(__FILE__), 'lib'))

spec = Gem::Specification.new do |s|
  s.name        = 'structle'
  s.version     = '0.1'
  s.summary     = 'A multi-language little-endian struct protocol generator.'
  s.description = 'A multi-language little-endian struct protocol generator.'
  s.authors     = ['Shane Hanna']
  s.email       = ['shane.hanna@gmail.com']
  s.licenses    = ['MIT']
  s.homepage    = 'https://github.com/shanna/structle'

  s.required_ruby_version = '>= 1.9.2'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- test/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']
end
