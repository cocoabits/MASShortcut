Pod::Spec.new do |s|
  s.name	       = 'MASShortcut'
  s.version      = '1.2.3'
  s.summary      = 'Modern framework for managing global keyboard shortcuts compatible with Mac App Store'
  s.homepage     = 'https://github.com/sonoramac/MASShortcut'
  s.authors      = { 'Vadim Shpakovski' => 'vadim@shpakovski.com' }
  s.license      = 'BSD 2-clause'

  s.source       = { :git => 'git@github.com:shpakovski/MASShortcut.git', :tag => '1.2.3' }
  s.source_files = '*.{h,m}'
  s.framework    = 'Carbon'
  s.requires_arc = true
end
