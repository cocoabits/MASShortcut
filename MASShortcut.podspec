Pod::Spec.new do |s|
  s.name	      = 'MASShortcut'
  s.version       = '2.0.0'
  s.summary       = 'Modern framework for managing global keyboard shortcuts compatible with Mac App Store'
  s.homepage      = 'https://github.com/sonoramac/MASShortcut'
  s.authors       = { 'Vadim Shpakovski' => 'vadim@shpakovski.com' }
  s.license       = 'BSD 2-clause'

  s.source        = { :git => 'git@github.com:shpakovski/MASShortcut.git', :tag => '2.0.0' }
  s.source_files  = 'Framework/*.{h,m}'
  s.exclude_files = 'Framework/*Tests.m'
  s.framework     = 'Carbon'
  s.requires_arc  = true
end
