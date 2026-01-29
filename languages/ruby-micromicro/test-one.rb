#!/usr/bin/env ruby

require 'bundler/setup'
require 'micromicro'
require 'json'

def print_usage
  puts 'Usage: test-one (URL, filepath, or HTML)'
end

def process_html(file)
  baseUrl = 'http://example.com/'
  if file.include?('/microformats-v2-unit/')
    # This is a unit test; these use a different base URL
    baseURL = 'http://example.test'
  end
  out = MicroMicro.parse(IO.read(file), baseUrl)
  puts out.to_h.to_json
end

if ARGV[0].nil?
  print_usage
else
  process_html(ARGV[0])
end
