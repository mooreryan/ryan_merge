#!/bin/bash

#PBS -N ryan_merge_fast
#PBS -l walltime=200:00:00,nodes=1:ppn=24,cput=4800:00:00
#PBS -d /home/abod/runt
#PBS -e /home/abod/runt/oe
#PBS -o /home/abod/runt/oe

hostname
date

time bash /home/moorer/git_repos/merge_assemblies/scripts/torque/ryan_merge.sh Sample_144-B2

echo "this script is all done!"
date

