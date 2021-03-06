#!/bin/sh

METHOD=1
EPSILON=0.1
MACHFILE=${1}

if [ -z "${MACHFILE}" ]; then
  echo machinefile not specified 
  exit
fi
if [ ! -e "${MACHFILE}" ]; then
  echo machinefile not found
  exit
fi

PROCS="1 2 4 6 8 10 12 16"
HEIGHT="32 64 128 256 512 1024" # 1024 2048" # 4096 8192" # min has to be at least max num procs!! (need to fix this)
WIDTH="32 64 128 256 512 1024" # 1024 2048 4096 8192"
REPEAT=`seq 1 `                     #"1 2 3"

echo "Method $METHOD Epsilon $EPSILON"
echo "Widths $WIDTH"
echo "Heights $HEIGHT"
echo "Procs $PROCS"
echo
    echo "... W     H       W*H	 P     H/P          W/P       Time(s)         Spd Up          %Eff"
for w in ${WIDTH}; do
  for h in ${HEIGHT}; do
    serial=0
    if [ "$w" == "$h" ]; then 
      for p in ${PROCS}; do
        for interation in ${REPEAT}; do
          out=`mpirun -np ${p} -machinefile ${MACHFILE} ../src/mpi-2dheat.x -t -w ${w} -h ${h} -m ${METHOD} -e ${EPSILON}`
          # capture serial time
          if [ 1 -eq ${p} ]; then
            serial=$out
          fi
          # calculate H*W
          a=`perl -e "print ($w * $h)"`
          # calculate speed up
          s=`perl -e "print ($serial / $out)"`
          # calculate efficiency
          e=`perl -e "print ($s / $p)"`
          # rows per cpu
          r=`perl -e "print ($h / $p)"`
          # w / h
          c=`perl -e "print ($w / $p)"`
         	printf "%5d %5d %10d %3d %10.5f %10.5f %15.9f %15.9f %15.9f\n" $w $h $a $p $r $c $out $s $e
        done
      done
    fi
  done
done
