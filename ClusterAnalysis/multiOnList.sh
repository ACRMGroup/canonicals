#!/bin/sh

for file in *.pdb
do pdbgetzone L24 L34 $file "$file"_L1.pdb
done

read -p 'Number of clusters: ' clusterNumber
currentNumber=1

while [ $currentNumber -le $clusterNumber ]
do
profit <<EOF
multi $currentNumber
atoms ca
fit
mwrite $currentNumber
EOF

cat *.$currentNumber > $currentNumber.pdb
rm *.$currentNumber
pdbchain $currentNumber.pdb $currentNumber.chain.pdb
currentNumber=$(( currentNumber+1))
done

rm *_L1.pdb



