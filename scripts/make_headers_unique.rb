#!/usr/bin/env ruby

require 'parse_fasta'

Signal.trap("PIPE", "EXIT")

num = 1
FastaFile.open(ARGV.first, 'r').each_record do |header, sequence|
  puts ">#{header.gsub(/ +/, '_')}_#{num}\n#{sequence}"
  num += 1
end
