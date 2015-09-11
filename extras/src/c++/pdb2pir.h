/****************************************************************/
/**                                                            **/
/**    Author: Jacob Hurst                                     **/
/**    File name: pdb2pir.h                                    **/
/**    Date: Friday 11 Jul 2008                                **/
/**    Description:  Header file for Andrew Martin's pdb2pir   **/
/**                code                                        **/
/**                                                            **/
/****************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
/**
#include "bioplib/MathType.h"
#include "bioplib/SysDefs.h"
#include "bioplib/pdb.h"
#include "bioplib/seq.h"
#include "bioplib/fsscanf.h"
#include "bioplib/macros.h"
#include "bioplib/general.h"
**/
#include "MathType.h"
#include "SysDefs.h"
#include "pdb.h"
#include "seq.h"
#include "fsscanf.h"
#include "macros.h"
#include "general.h"
/************************************************************************/
/* Defines
*/
#define MAXLAB     64
#define MAXTITLE  160
#define ALLOCSIZE  80
#define MAXBUFF   160
#define GAPPEN     2   /* 12.03.08 Gap penalty was 10!!!                */
#define MAXCHAINS  80

#define safetoupper(x) ((islower(x))?toupper(x):(x))
#define safetolower(x) ((isupper(x))?tolower(x):(x))

typedef struct mres
{
   struct mres *next;
   char modres[8];
   char origres[8];
}  MODRES;

/************************************************************************/
/* Prototypes
*/
int  old_main(int argc, char **argv);
void WritePIR(FILE *out, char *label, char *title, char *sequence,
              char *chains, BOOL ByChain);
void pdb2pir_Usage(void);
char *ReadSEQRES(WHOLEPDB *wpdb, char *chains, MODRES *modres);
MODRES *ReadMODRES(WHOLEPDB *wpdb);
char *FixSequence(char *seqres,    char *sequence,
                  char *seqchains, char *atomchains,
                  char *outchains);
char *CombineSequence(char *align1, char *align2, int align_len);
int GetPDBChains(PDB *pdb, char *chains);
void PrintNumbering(FILE *out, PDB *pdb, MODRES *modres);
/*char *strdup(const char *s);*/
void LookupModres(char *orig, char *new_one, MODRES *modres);

