#! /bin/sh
#$ -cwd
#$ -V -S /bin/bash
#$ -pe smp 4
#$ -N ensyu1-2
mpirun -np 4 ./ensyu1-2.out