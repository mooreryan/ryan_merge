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
  opt(:fasta, 'Fasta file with contigs', type: :string,
      default: 'test_files/test_output/combined.cluster_100.fa')

  opt(:make_fq, 'Flag to make fake fq from fa (takes only <2000 seqs)',
      type: :boolean, default: false)
  
  opt(:settings, 'Celera settings file', type: :string,
      default: '/home/moorer/scripts/celera/ca_settings.txt')
  opt(:bin, 'Celera bin', type: :string,
      default: '/home/dnasko/software/wgs-8.1/Linux-amd64/bin/')
  
  opt(:prefix, 'Prefix for combined output', type: :string,
      default: 'combined')
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

p opts

if opts[:make_fq]
  # make fake fastq
  fq_fname = File.join(opts[:outdir], parse_fname(opts[:fasta])[:base] + '.fq')
  File.open(fq_fname, 'w') do |f|
    FastaFile.open(opts[:fasta], 'r').each_record do |header, sequence|
      if sequence.length < 2000
        f.puts "@#{header}\n#{sequence}\n+\n#{'I'*sequence.length}"
      end
    end
  end
end    

fastqToCA = File.join(opts[:bin], 'fastqToCA')
frg = File.join(opts[:outdir], "#{opts[:prefix]}.frg")
cmd =
  "time #{fastqToCA} " +
  "-libraryname #{opts[:prefix]} " +
  "-technology illumina-long " +
  "-type sanger " +
  "-reads #{fq_fname} " +
  "> #{frg}"
run_it(cmd) 

runCA = File.join(opts[:bin], 'runCA')
cmd =
  "time #{runCA} " +
  "-p #{opts[:prefix]} " +
  "-d #{opts[:outdir]}/assembly_celera " +
  "-s #{opts[:settings]} " +
  "useGrid=0 scriptOnGrid=0 doOBT=0 unitigger=bogart " +
  "#{frg}"
run_it(cmd)
