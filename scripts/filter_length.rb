#!/usr/bin/env ruby

require 'parse_fasta'

Signal.trap("PIPE", "EXIT")

cutoff = ARGV[0].to_i

FastaFile.open(ARGV[1], 'r').each_record do |head, seq|
  puts ">#{head}\n#{seq}" if seq.length >= cutoff
end
