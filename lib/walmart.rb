# frozen_string_literal: true
require 'pathname'

module Walmart
  PROJECT_ROOT = File.expand_path(Pathname.new(__FILE__).join('../..'))
  DEBUG = ENV['WALMART_DEBUG'] && !ENV['WALMART_DEBUG'].empty? ? ENV['WALMART_DEBUG'].to_i : false
  VERSION = '0.0.1'
  NAME = 'walmart'
end

require 'letters' if Walmart::DEBUG && Walmart::DEBUG == 0
require 'byebug' if Walmart::DEBUG && Walmart::DEBUG == 0
