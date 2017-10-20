#
# Be sure to run `pod lib lint ResearchSuiteResultsProcessor.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ResearchSuiteResultsProcessor'
  s.version          = '0.6.0'
  s.summary          = 'The ResearchSuite Results Processor is an easy and extensible way to process results for ResearchKit.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  Building cross-platform and portable ResearchSuite applications is hard.
    The ResearchSuite Results Processor makes it easier!
                       DESC

   s.homepage         = 'https://github.com/ResearchSuite/ResearchSuiteResultsProcessor-ios'
   # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
   s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
   s.author           = { "James Kizer, Cornell Tech Foundry" => "jdk288 at cornell dot edu" }
   s.source           = { :git => 'https://github.com/ResearchSuite/ResearchSuiteResultsProcessor-ios.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.subspec 'Core' do |core|
    core.source_files = 'ResearchSuiteResultsProcessor/Core/Classes/**/*'
    core.dependency 'ResearchKit', '~> 1.3'
    core.dependency 'Gloss', '~> 1.1'
  end

  s.subspec 'OMHHelper' do |omh|
    omh.source_files = 'ResearchSuiteResultsProcessor/OMHHelper/Classes/**/*'
    omh.dependency 'ResearchSuiteResultsProcessor/Core'
    omh.dependency 'OMHClient'
  end

  s.subspec 'CSVBackend' do |csv|
    csv.source_files = 'ResearchSuiteResultsProcessor/CSVBackend/Classes/**/*'
    csv.dependency 'ResearchSuiteResultsProcessor/Core'
  end

  s.default_subspec = 'Core'
end
