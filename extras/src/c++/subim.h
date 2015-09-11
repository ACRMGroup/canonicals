#include  <stdio.h>
#include  <string.h>
#include  <stddef.h>
#include  <stdlib.h>
#include  <ctype.h>
# include "chaintype.h"

void find_chain_types_subim(char **aaSequences,int *chainType,int numberOfSequences);

void det_sgpe(char *tseq, long int *chainClass, long int *sgpe);

REAL calc_stat(long sgp, char *tseq, long deb);

void saisie_seq(char *tseq);
