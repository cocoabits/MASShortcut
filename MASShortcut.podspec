Pod::Spec.new do |s|
  s.platform       = :osx
  s.name	       = 'MASShortcut'
  s.version        = '1.3.1'
  s.summary        = 'Modern framework for managing global keyboard shortcuts compatible with Mac App Store'
  s.homepage       = 'https://github.com/shpakovski/MASShortcut'
  s.authors        = { 'Vadim Shpakovski' => 'vadim@shpakovski.com' }
  s.license        = 'BSD 2-clause'
  s.source         = { :git => 'https://github.com/shpakovski/MASShortcut.git', :tag => '1.3.1' }
  s.source_files   = '*.{h,m}'
  s.osx.frameworks = 'Carbon', 'AppKit'
  s.requires_arc   = true
end
