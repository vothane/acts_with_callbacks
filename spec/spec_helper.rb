ENV['RAILS_ENV'] = 'test'
$:.unshift(File.join(File.dirname(__FILE__), "..", "lib"))
require 'acts_with_callbacks'
