$LOAD_PATH << File.dirname(File.expand_path(__FILE__)) + "/.."
ENV["RACK_ENV"] ||= "development"

require "rubygems"
require "bundler"
Bundler.require(:default, ENV["RACK_ENV"])
