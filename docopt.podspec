Pod::Spec.new do |s|
  s.name         = "docopt"
  s.version      = "0.6.6"
  s.summary      = "Pythonic command line arguments parser, that will make you smile"
  s.homepage     = "http://docopt.org"
  s.license      = "MIT"
  s.author       = { "Pavel Mazurin" => "kovpas@gmail.com" }

  s.platform     = :osx, '10.9'
  s.module_name  = 'Docopt'
  s.source       = { :git => "https://github.com/docopt/docopt.swift.git", :tag => s.version }
  s.source_files = "Sources/**/*.swift"
  s.requires_arc = true
end
