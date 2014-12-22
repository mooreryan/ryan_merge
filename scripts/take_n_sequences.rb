#!/usr/bin/env ruby

require 'parse_fasta'

Signal.trap("PIPE", "EXIT")

limit = ARGV[0].to_i

n = 1
FastaFile.open(ARGV[1], 'r').each_record do |head, seq|
  puts ">#{head}\n#{seq}" if n <= limit
  n += 1
end
