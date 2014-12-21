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
  opt(:uclust, 'Uclust binary', type: :string,
      default: '/usr/local/bin/uclust')
end


# if opts[:right].nil?
#   Trollop.die :right, "You must enter a file name"
# elsif !File.exist? opts[:right]
#   Trollop.die :right, "The file must exist"
# end

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

# combine the files into one uber fasta
# ARGV will contain fastq files to process
combined_fname = File.join(opts[:outdir], "#{opts[:prefix]}.fa")
File.open(combined_fname, 'w') do |f|
  ARGV.each do |fname|
    File.open(fname, 'r').each_line do |line|
      f.puts line
    end
  end
end

# cluster at 100 percent identity
uc_fname = File.join(opts[:outdir], "#{opts[:prefix]}.uc")
cmd =
  "#{opts[:uclust]} --usersort " +
  "--maxlen 1000000 " +
  "--minlien 200 " +
  "--nucleo " +
  "--id 1 " +
  "--rev " +
  "--uc #{uc_fname} " +
  "--input #{combined_fname}"
run_it(cmd)

# convert to fasta keep only seeds
derep_fname = File.join(opts[:outdir], "#{opts[:prefix]}.cluster_100.fa")
cmd =
  "#{opts[:uclust]} --uc2fasta #{uc_fname} " +
  "--input #{combined_fname} " +
  "--output #{derep_fname} " +
  "--types S"
run_it(cmd)

# clean up
FileUtils.rm([uc_fname, combined_fname])

puts
