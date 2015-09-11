#!/bin/sh

$stem=`basename $1 \..*`
asurf $1
rm $stem.rsa $stem.log
as2bval $stem.asa | sumbval -q -a >$2
rm $stem.asa
