Pod::Spec.new do |s|
    s.name = "UserDefaultsStore"
    s.version = "0.4"
    s.summary = "Why not use UserDefaults to store Codable objects 😉"
    s.description = <<-DESC
    You love Swift"s Codable protocol and use it everywhere, here is an easy and very light way to store - reasonable amount 😅 - of Codable objects, in a couple lines of code.
    DESC

    s.homepage = "https://github.com/omaralbeik/UserDefaultsStore"
    s.license = { :type => "MIT", :file => "LICENSE" }
    s.social_media_url = "http://twitter.com/omaralbeik"

    s.authors = { "Omar Albeik" => "https://twitter.com/omaralbeik" }

    s.module_name  = "UserDefaultsStore"
    s.source = { :git => "https://github.com/omaralbeik/UserDefaultsStore.git", :tag => s.version }
    s.source_files = "Sources/**/*.swift"
    s.swift_version = "4.1"
    s.requires_arc = true
    
    s.ios.deployment_target = "8.0"
    s.osx.deployment_target = "10.10"
    s.tvos.deployment_target = "9.0"
    s.watchos.deployment_target = "2.0"
end