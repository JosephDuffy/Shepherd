Pod::Spec.new do |spec|
  spec.name         = "Shepherd"
  spec.version      = "0.1.4"
  spec.summary      = <<-SUMM
                   A collection of protocol and extensions to aid with `NSUserActivity`s
                   SUMM
  spec.description  = <<-DESC
                   A collection of protocol and extensions to aid with the handling and creation of `NSUserActivity`s
                   DESC
  spec.homepage     = "https://github.com/JosephDuffy/Shepherd"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = "Joseph Duffy"
  spec.source       = {
    :git => "https://github.com/JosephDuffy/Shepherd.git",
    :tag => "v#{spec.version}"
  }
  spec.source_files = "Sources/**/*.swift"
  spec.osx.deployment_target = "10.10"
  spec.ios.deployment_target = "8.0"
  spec.tvos.deployment_target = "9.0"
  spec.watchos.deployment_target = "2.0"
  spec.swift_version = "5.0"
end
