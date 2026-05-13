#!/usr/bin/env ruby

require 'bundler/setup'
require 'microformats'
require 'json'

def print_usage
  puts 'Usage: test-one <input_file> <base_url>'
end

def process_html(file, baseUrl)
  collection = Microformats.parse(file, base: baseUrl)
  puts JSON.pretty_generate(JSON[collection.to_json.to_s])
end

if ARGV[1].nil?
  print_usage
else
  process_html(ARGV[0], ARGV[1])
end
