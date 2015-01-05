#!/usr/bin/env ruby

require 'parse_fasta'
require 'set'

Signal.trap("PIPE", "EXIT")

seqs = Set.new
FastaFile.open(ARGV.first, 'r').each_record do |head, seq|
  rev_comp = seq.reverse.tr('ACTG', 'TGAC')
  unless seqs.include?(seq) || seqs.include?(rev_comp)
    seqs << seq << rev_comp
    puts ">#{head}\n#{seq}"
  end
end
