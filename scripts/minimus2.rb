#!/usr/bin/env ruby

begin
  require 'trollop'
  require 'shell/executer.rb'
  require 'parse_fasta'
  require 'fileutils'
rescue LoadError => e
  bad_file = e.message.sub(/^cannot load such file -- /, '')
  abort("ERROR: #{e.message}\nTry running: gem install #{bad_file}")
end

require_relative '../lib/functions'

Signal.trap("PIPE", "EXIT")

opts = Trollop.options do
  banner <<-EOS

  Steps:

  Options:
  EOS

  opt(:celera, 'Fasta with celera contigs (from the small contig assembly)',
      type: :string)
  opt(:long, 'Fasta with long non-celera assembled contigs',
      type: :string)

  opt(:outdir, 'Output directory', type: :string)
end

if opts[:outdir].nil?
  Trollop.die :outdir, "You must enter an output directory"
elsif !File.exist? opts[:outdir]
  begin
    FileUtils.mkdir(opts[:outdir])
  rescue EACCES => e
    abort("ERROR: #{e.message}\n\n" +
          "It appears you don't have the proper permissions")
  end
end

# count long contigs
num = 0
FastaFile.open(opts[:long], 'r').each_record do |head, seq|
  num += 1
end

# combine
combined_fname = File.join(opts[:outdir], 'two_assemblies.fa')
cmd =
  "cat #{opts[:long]} #{opts[:celera]} > #{combined_fname}"
run_it(cmd)

# to amos format
amos = '/usr/local/AMOS/bin/toAmos'
cmd =
  "#{amos} -s #{combined_fname} -o #{combined_fname}.afg"
run_it(cmd)

# minimus2
minimus = '/usr/local/AMOS/bin/minimus2'
cmd =
  "#{minimus} #{combined_fname} " +
  "-D REFCOUNT=#{num} " +
  "-D OVERLAP=80 " +
  "-D CONSERR=0.06 " +
  "-D MINID=98"
run_it(cmd)
  
