Pod::Spec.new do |s|
  s.name         = "KRImageViewer"
  s.version      = "1.0.0"
  s.platform     = :ios, '5.0'
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.summary      = "A instantgramish image viewer for iOS"
  s.screenshots  = "https://dl.dropboxusercontent.com/u/83663874/GitHubs/KRImageViewer-2.png"
  s.homepage     = "https://www.github.com/Kalvar/ios-KRImageViewer"
  s.author       = { "Kalvar" => "ilovekalvar@gmail.com" }
  s.source       = { :git => "https://github.com/Kalvar/ios-KRImageViewer.git", :tag => "v#{s.version}" }
  s.source_files = "KRImagaeViewerDemo/KRImageViewer/**/*.{h,m}"
  s.requires_arc = true
  s.framework    = 'QuartzCore'
end
