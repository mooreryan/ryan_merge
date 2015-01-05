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
  opt(:prefix, 'Prefix for combined output', type: :string,
      default: 'combined')
  opt(:outdir, 'Output directory', type: :string)
  opt(:usearch, 'usearch binary', type: :string,
      default: '/usr/local/bin/usearch')
  opt(:min_len, 'Min length contig to consider', type: :int,
      default: 200)
  opt(:cluster, 'Flag to do 100% id clustering as well as dereplication',
      type: :boolean, default: false)
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

abort("Don't forget to specify files") if ARGV.empty?

# combine the files into one uber fasta
# ARGV will contain fastq files to process
combined_fname = File.join(opts[:outdir], "#{opts[:prefix]}.fa")
File.open(combined_fname, 'w') do |f|
  ARGV.each do |fname|
    FastaFile.open(fname, 'r').each_record do |header, sequence|
      f.puts ">#{header}\n#{sequence}" if sequence.length > opts[:min_len]
    end
  end
end

# dereplicate
uniques_fname = File.join(opts[:outdir], "#{opts[:prefix]}.unique.fa")
derep_uc_fname = File.join(opts[:outdir], "#{opts[:prefix]}.dereplication.uc")
cmd =
  "time #{opts[:usearch]} " +
  "-derep_fulllength #{combined_fname} " +
  "-uc #{derep_uc_fname} " +
  "-output #{uniques_fname} " +
  "-sizeout " +
  "-strand both"
run_it(cmd)
FileUtils.rm(combined_fname)

if opts[:cluster]
  # sort
  sorted_fname = File.join(opts[:outdir], "#{opts[:prefix]}.unique.sorted.fa")
  cmd =
    "time #{opts[:usearch]} " +
    "-sortbylength #{uniques_fname} " +
    "-output #{sorted_fname}"
  run_it(cmd)
  FileUtils.rm(uniques_fname)
  
  # cluster at 100 percent identity
  uc_fname = File.join(opts[:outdir], "#{opts[:prefix]}.uc")
  centroids_fname = File.join(opts[:outdir],
                              "#{opts[:prefix]}.unique.sorted.centroids_100.fa")
  cmd =
    "time #{opts[:usearch]} " +
    "-cluster_fast #{sorted_fname} " +
    "id 1.0 " +
    "-centroids #{centroids_fname} " +
    "-uc #{uc_fname}"
  run_it(cmd)
  FileUtils.rm(sorted_fname)
end

puts
