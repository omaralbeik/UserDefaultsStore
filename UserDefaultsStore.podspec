Pod::Spec.new do |s|
    s.name = "UserDefaultsStore"
    s.version = "2.0.0"
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
    s.swift_versions = ['5.1', '5.2']
    s.requires_arc = true

    s.ios.deployment_target = "13.0"
    s.osx.deployment_target = "10.15"
    s.tvos.deployment_target = "13.0"
    s.watchos.deployment_target = "6.0"
end
