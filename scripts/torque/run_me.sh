#!/bin/bash

#PBS -N ryan_merge_fast
#PBS -l walltime=200:00:00,nodes=biohen36:ppn=24,cput=4800:00:00
#PBS -d /home/moorer/runt
#PBS -e /home/moorer/runt/oe
#PBS -o /home/moorer/runt/oe

hostname
date

scripts=/home/moorer/git_repos/merge_assemblies/scripts
prefix=Sample_100
outdir=/home/aoh/cow/viral_metagenomes/Sample_100/qc/digi_dir/assembly/ryan_merged_fast
combined=$outdir/$prefix.unique.fa
short=$outdir/$prefix.unique.short.fa
long=$outdir/$prefix.unique.long.fa

time ruby $scripts/dereplicate_fast_2.rb -p $prefix -o $outdir /home/aoh/cow/viral_metagenomes/Sample_100/qc/digi_dir/assembly/RayOutput.*/Contigs.fasta /home/moorer/sandbox/Sample_100.celera.ctg.fasta \
    && \
    time ruby $scripts/bin_seqs.rb $short $long $combined \
    && \
    time ruby $scripts/celera.rb -f $short --make-fq -p Sample_100.short -o $outdir/celera_assembly \
    && \
    time ruby $scripts/minimus2.rb --celera $outdir/celera_assembly/assembly_celera/9-terminator/Sample_100.short.ctg.fasta --long $long -o $outdir

# the minimus2 script breaks if headers are not unique

echo "all done!"
date

