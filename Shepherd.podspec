Pod::Spec.new do |spec|
  spec.name         = "Shepherd"
  spec.version      = "0.1.0"
  spec.summary      = "A collection of classes and extensions to aid with `NSUserActivity`s"
  spec.description  = "A collection of classes and extensions to aid with the handling and creation of `NSUserActivity`s"
  spec.homepage     = "https://github.com/JosephDuffy/Shepherd"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = "Joseph Duffy"
  spec.source       = {
    :git => "https://github.com/JosephDuffy/Shepherd.git",
    :tag => "v#{spec.version}"
  }
  spec.source_files = "Sources/Shepherd/*.swift"
  spec.ios.deployment_target = "8.0"
  spec.swift_versions = "5.0"
end