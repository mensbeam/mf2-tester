#!/usr/bin/env ruby

require 'bundler/setup'
require 'microformats'
require 'json'

def print_usage
  puts 'Usage: microformats (URL, filepath, or HTML)'
end

def process_html(file)
  baseUrl = 'http://example.com/'
  if file.include?('/microformats-v2-unit/')
    # This is a unit test; these use a different base URL
    baseURL = 'http://example.test'
  end
  collection = Microformats.parse(file, base: baseUrl)
  puts JSON.pretty_generate(JSON[collection.to_json.to_s])
end

if ARGV[0].nil?
  print_usage
else
  process_html(ARGV[0])
end
