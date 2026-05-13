#!/usr/bin/env ruby

require 'bundler/setup'
require 'micromicro'
require 'json'

def print_usage
  puts 'Usage: test-one <input_file> <base_url>'
end

def process_html(file, baseUrl)
  out = MicroMicro.parse(IO.read(file), baseUrl)
  puts out.to_h.to_json
end

if ARGV[1].nil?
  print_usage
else
  process_html(ARGV[0], ARGV[1])
end
