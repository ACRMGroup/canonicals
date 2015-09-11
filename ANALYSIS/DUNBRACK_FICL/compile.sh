if [ $# -lt 1 ]
then
   echo
   echo "Usage: sh $0 <Name of C program> <Name of executable (Optional)>"
   echo
   exit 0
fi

inputCfile=$1
prefix=`basename $inputCfile .c`

if [ "$2" != "" ]
then
   executable=$2
else
   executable=$prefix.o
fi

gcc -g -ansi -Wall -pedantic $inputCfile  -o $executable -L ~/lib/ -labs -I ~/include/ -L ~martin/lib/ -lbiop -lgen -I ~martin/include -lm
