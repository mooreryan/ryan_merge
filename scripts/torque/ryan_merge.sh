#!/bin/bash

scripts=/home/moorer/git_repos/merge_assemblies/scripts
prefix=$1
outdir=/home/aoh/cow/viral_metagenomes/$prefix/assembly/ryan_merged_fast
combined=$outdir/$prefix.unique.fa
short=$outdir/$prefix.unique.short.fa
long=$outdir/$prefix.unique.long.fa
rayContigs=/home/aoh/cow/viral_metagenomes/$prefix/assembly/RayOutput.*/Contigs.fasta
celeraContigs=/home/aoh/cow/viral_metagenomes/$prefix/assembly_celera/celera.ctg.fasta

time ruby $scripts/dereplicate_fast_2.rb -p $prefix -o $outdir $rayContigs $celeraContigs \
    && \
    time ruby $scripts/bin_seqs.rb $short $long $combined \
    && \
    time ruby $scripts/celera.rb -f $short --make-fq -p $prefix.short -o $outdir/celera_assembly \
    && \
    time ruby $scripts/minimus2.rb --celera $outdir/celera_assembly/assembly_celera/9-terminator/$prefix.short.ctg.fasta --long $long -o $outdir \
    && \
    time ruby $scripts/make_minimus_headers.rb $outdir/two_assemblies.fa > $outdir/tmp && mv $outdir/tmp $outdir/two_assemblies.fa \
    && \
    time /usr/local/AMOS/bin/toAmos -s $outdir/two_assemblies.fa -o $outdir/two_assemblies.fa.afg \
    && \
    time /home/moorer/bin/minimus2 $outdir/two_assemblies.fa -D REFCOUNT=21108 -D OVERLAP=80 -D CONSERR=0.06 -D MINID=98 \
    && \
    time cat $outdir/two_assemblies.fa.fasta $outdir/two_assemblies.fa.singletons.seq > $outdir/two_assemblies.ryan_merged.fa \
    && \
    ruby $scripts/dereplicate_sequences.rb $outdir/two_assemblies.ryan_merged.fa > $outdir/tmp && mv $outdir/tmp $outdir/two_assemblies.ryan_merged.unique.fa

# the minimus2 script breaks if headers are not unique


