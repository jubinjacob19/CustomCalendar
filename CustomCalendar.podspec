Pod::Spec.new do |s|

  s.name         = "CustomCalendar"
  s.version      = "0.0.1"
  s.summary      = "Custom Calendar for iOS"

  s.description  = <<-DESC
                   The custom calendar provides a reusable customisable calendar component for iOS.  
DESC

  s.homepage     = "https://github.com/jubinjacob19/CustomCalendar"
  s.license          = { :type => "MIT", :file => "LICENSE"}
  s.author             = { "jubinjacob19" => "jubinjacob19@gmail.com" }
  s.platform     = :ios
  s.ios.deployment_target = "7.0"
  s.frameworks = "UIKit", "CoreGraphics","Foundation"

  s.source       = { :git => "https://github.com/jubinjacob19/CustomCalendar.git", :tag => "0.0.1", :commit => "636540bfec746244627c64bda0b0ac7391107119" }
  s.source_files  = "SampleCalendar/*.{h,m}"
  s.requires_arc = true

end
