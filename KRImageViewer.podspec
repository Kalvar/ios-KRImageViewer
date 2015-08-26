Pod::Spec.new do |s|
  s.name         = "KRImageViewer"
  s.version      = "1.0.3"
  s.summary      = "Quickly reviewing photos from URLs or Storage."
  s.screenshots  = "https://dl.dropboxusercontent.com/u/83663874/GitHubs/KRImageViewer-2.png"
  s.description  = <<-DESC
                   KRImageViewer could let you easy browse photos from the URLs, storage or folders. You can scroll to change page, pinching zooming, dragging and swiping to close, this viewer supports automatic rotation.
                   DESC
  s.homepage     = "https://github.com/Kalvar/ios-KRImageViewer"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "Kalvar Lin" => "ilovekalvar@gmail.com" }
  s.social_media_url = "https://twitter.com/ilovekalvar"
  s.source       = { :git => "https://github.com/Kalvar/ios-KRImageViewer.git", :tag => "v#{s.version}" }
  s.platform     = :ios, '7.0'
  s.requires_arc = true
  s.public_header_files = 'KRImageViewer/*.h'
  s.source_files = 'KRImageViewer/*.{h,m}'
  s.frameworks   = 'QuartzCore'
end 