#!/usr/bin/env gnuplot
unset key
#set key top left
set xlabel font "Helvetica, 14"
set ylabel font "Helvetica, 14"
set tics font "Helvetica, 20"
set xrange[0:10]
set term gif animate optimize
set output 'heat_eq.gif'
itrmax = 20000
do for[i = 100 : itrmax : 100]{
   file = sprintf("Phi_%05d.d", i)
   filetitle = sprintf("step : %05d / %05d", i, itrmax)
   set title filetitle font "Helvetica, 14"
   plot file w l lw 3; pause 0.05
}
