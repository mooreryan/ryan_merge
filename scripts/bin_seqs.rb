#!/usr/bin/env ruby

require 'parse_fasta'

Signal.trap("PIPE", "EXIT")

if ARGV.length < 3
  abort("USAGE: ruby bin_seqs.rb short_output.fa long_output.fa input.fa")
end

short = File.open(ARGV[0], 'w')
long = File.open(ARGV[1], 'w')

FastaFile.open(ARGV[2], 'r').each_record do |head, seq|
  if seq.length < 2000
    short.puts ">#{head}\n#{seq}"
  else
    long.puts ">#{head}\n#{seq}"
  end
end
