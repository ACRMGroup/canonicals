/*************************************************************************

   Program:    
   File:       decr.c
   
   Version:    V3.2
   Date:       02.10.95
   Function:   DEfine Critical Residues
   
   Copyright:  (c) Dr. Andrew C. R. Martin 1995
   Author:     Dr. Andrew C. R. Martin
   Address:    Biomolecular Structure & Modelling Unit,
               Department of Biochemistry & Molecular Biology,
               University College,
               Gower Street,
               London.
               WC1E 6BT.
   Phone:      (Home) +44 (0)1372 275775
               (Work) +44 (0)171 387 7050 X 3284
   EMail:      INTERNET: martin@biochem.ucl.ac.uk
               
**************************************************************************

   This program is not in the public domain, but it may be copied
   according to the conditions laid out in the accompanying file
   COPYING.DOC

   The code may be modified as required, but any modifications must be
   documented so that the person responsible can be identified. If someone
   else breaks this code, I don't want to be blamed for code that does not
   work! 

   The code may not be sold commercially or included as part of a 
   commercial product except as described in the file COPYING.DOC.

**************************************************************************

   Description:
   ============

**************************************************************************

   Usage:
   ======

**************************************************************************

   Revision History:
   =================
   V1.0  01.08.95 Original
   V3.2  02.10.95 Modified for completely conserved residues

*************************************************************************/
/* Includes
*/
#include "decr.h"

/************************************************************************/
/* Defines and macros
*/

/************************************************************************/
/* Globals
*/
USHORT sPropsArray[20];   /* Properties for each of the 20 amino acids  */
char   sResArray[20];     /* Amino acid 1-letter codes in same order    */

/************************************************************************/
/* Prototypes
*/
#include "decr.p"

/************************************************************************/
/*>BOOL FindNeighbourProps(PDB *pdb, PDB *start, PDB *stop, int clusnum,
                           LOOPINFO *loopinfo)
   ---------------------------------------------------------------------
   Input:   PDB      *pdb        PDB linked list for whole structure
            PDB      *start      Start of loop in pdb
            PDB      *stop       Record after end of loop in pdb
            int      clusnum     Cluster number
   Output:  LOOPINFO *loopinfo   Details of loop and contacting residues
                                 (Space is allocated within this 
                                 structure)
   Returns: BOOL                 Success of memory allocations

   Peforms all allocations in a LOOPINFO structure and fills it in with
   details of the loop and contacting residues.

   01.08.95 Original    By: ACRM
   02.08.95 Added AALoop and AAContact, clusnum parameter
*/
BOOL FindNeighbourProps(PDB *pdb, PDB *start, PDB *stop, int clusnum,
                        LOOPINFO *loopinfo)
{
   PDB  *p, *p_next,
        *q, *q_next,
        **contacts;
   int  ncontacts   = 0,
        maxcontacts = ALLOCQUANTUM,
        looplen     = 0;
   BOOL InArray;

   /* Allocate an array to store the contact PDB pointers               */
   if((contacts=(PDB **)malloc(maxcontacts*sizeof(PDB)))==NULL)
      return(FALSE);
   
   /* Step through the loop                                             */
   for(p=start,looplen=0; p!=stop; p=p_next)
   {
      /* Find the following residue                                     */
      p_next = FindEndPDB(p);
      looplen++;

      /* For each residue N-ter to the loop                             */
      for(q=pdb; q!=start && q!=NULL; q=q_next)
      {
         q_next = FindEndPDB(q);

         /* If loop residue makes contact with this non-loop residue    */
         if(ResidueContact(p,p_next,q,q_next,CONTACTDIST))
         {
            /* If this non-loop residue is not already stored           */
            TESTINARRAY(contacts,ncontacts,q,InArray);
            if(!InArray)
            {
               /* Store the contact residue pointer                     */
               contacts[ncontacts++] = q;

               /* Increase the contacts array size                      */
               if(ncontacts==maxcontacts)
               {
                  maxcontacts += ALLOCQUANTUM;
                  if((contacts=(PDB **)
                      realloc(contacts, maxcontacts*sizeof(PDB)))==NULL)
                     return(FALSE);
               }
            }
         }
      }
                  
      /* For each residue C-ter to the loop                             */
      for(q=stop; q!=NULL; q=q_next)
      {
         q_next = FindEndPDB(q);

         /* If loop residue makes contact with this non-loop residue    */
         if(ResidueContact(p,p_next,q,q_next,CONTACTDIST))
         {
            /* If this non-loop residue is not already stored           */
            TESTINARRAY(contacts,ncontacts,q,InArray);
            if(!InArray)
            {
               /* Store the contact residue pointer                     */
               contacts[ncontacts++] = q;

               /* Increase the contacts array size                      */
               if(ncontacts==maxcontacts)
               {
                  maxcontacts += ALLOCQUANTUM;
                  if((contacts=(PDB **)
                      realloc(contacts, maxcontacts*sizeof(PDB)))==NULL)
                     return(FALSE);
               }
            }
         }
      }
   }

   /* Set values in the loopinfo structure                              */
   loopinfo->ncontacts = ncontacts;
   loopinfo->contacts  = contacts;
   loopinfo->length    = looplen;

   /* Allocate an array to store the loop residue pointers              */
   if((loopinfo->residues=(PDB **)malloc(looplen*sizeof(PDB)))==NULL)
   {
      free(contacts);
      loopinfo->contacts = NULL;
      return(FALSE);
   }
   
   /* Copy residue pointers into this array                             */
   for(p=start,looplen=0; p!=stop; p=p_next)
   {
      p_next = FindEndPDB(p);
      loopinfo->residues[looplen++] = p;
   }

   /* Allocate memory for property arrays                              */
   loopinfo->ResProps = 
      (USHORT *)malloc(looplen*sizeof(USHORT));
   loopinfo->ContactProps = 
      (USHORT *)malloc(ncontacts*sizeof(USHORT));
   loopinfo->AALoop = 
      (char *)malloc(looplen*sizeof(char));
   loopinfo->AAContact = 
      (char *)malloc(ncontacts*sizeof(char));
   loopinfo->ResFlag = 
      (BOOL *)malloc(looplen*sizeof(BOOL));
   loopinfo->ContactFlag = 
      (BOOL *)malloc(ncontacts*sizeof(BOOL));
   

   if(loopinfo->ResProps     == NULL || 
      loopinfo->ContactProps == NULL ||
      loopinfo->AALoop       == NULL ||
      loopinfo->AAContact    == NULL ||
      loopinfo->ResFlag      == NULL ||
      loopinfo->ContactFlag  == NULL)
   {
      if(loopinfo->ResProps     != NULL) free(loopinfo->ResProps);
      if(loopinfo->ContactProps != NULL) free(loopinfo->ContactProps);
      if(loopinfo->AALoop       != NULL) free(loopinfo->AALoop);
      if(loopinfo->AAContact    != NULL) free(loopinfo->AAContact);
      if(loopinfo->contacts     != NULL) free(loopinfo->contacts);
      if(loopinfo->residues     != NULL) free(loopinfo->residues);
      if(loopinfo->ResFlag      != NULL) free(loopinfo->ResFlag);
      if(loopinfo->ContactFlag  != NULL) free(loopinfo->ContactFlag);

      loopinfo->ResProps     = NULL;
      loopinfo->ContactProps = NULL;
      loopinfo->AALoop       = NULL;
      loopinfo->AAContact    = NULL;
      loopinfo->contacts     = NULL;
      loopinfo->residues     = NULL;
      loopinfo->ResFlag      = NULL;
      loopinfo->ContactFlag  = NULL;
      
      return(FALSE);
   }

   FillLoopInfo(loopinfo);
   loopinfo->clusnum = clusnum;
    
   return(TRUE);
}


/************************************************************************/
/*>BOOL ResidueContact(PDB *p_start, PDB *p_stop, PDB *q_start, 
                       PDB *q_stop, REAL dist)
   ------------------------------------------------------------
   Input:   PDB  *p_start    Start of first residue
            PDB  *p_stop     Record after end of first residue
            PDB  *q_start    Start of second residue
            PDB  *q_stop     Record after end of second residue
            REAL dist        Maximum distace to define contact
   Returns: BOOL             In contact?

   See if a contact of <= dist Angstroms is made between atoms in the 
   residue bounded by pointers p_start/p_stop and sidechain atoms
   bounded by q_start/q_stop

   01.08.95 Original    By: ACRM
*/
BOOL ResidueContact(PDB *p_start, PDB *p_stop, PDB *q_start, PDB *q_stop,
                    REAL dist)
{
   PDB *p, *q;

   /* Ignore contact with itself                                        */
   if(p==q)
      return(FALSE);

   /* Square the distance to save on doing square roots                 */
   dist *= dist;
   
   for(p=p_start; p!=p_stop; NEXT(p))
   {
      for(q=q_start; q!=q_stop; NEXT(q))
      {
         if(strncmp(q->atnam,"N   ",4) &&
            strncmp(q->atnam,"CA  ",4) &&
            strncmp(q->atnam,"C   ",4) &&
            strncmp(q->atnam,"O   ",4))
         {
            if(DISTSQ(p,q) <= dist)
               return(TRUE);
         }
      }
   }

   return(FALSE);
}

/************************************************************************/
/*>void FillLoopInfo(LOOPINFO *loopinfo)
   -------------------------------------
   I/O:     LOOPINFO  *loopinfo     Input with PDB pointer arrays filled
                                    in listing the loop and contact 
                                    residues.
                                    Output with the residue property and
                                    contact property arrays completed.

   Fill in residue property flags in a loopinfo structure for both the
   loop and contacting residues.

   01.08.95 Original    By: ACRM
   02.08.95 Added AALoop and AAContact
*/
void FillLoopInfo(LOOPINFO *loopinfo)
{
   int  i;
   char res;
   
   
   for(i=0; i<loopinfo->length; i++)
   {
      res = throne((loopinfo->residues[i])->resnam);
      loopinfo->AALoop[i] = res;
      loopinfo->ResProps[i] = SetProperties(res);
   }
   for(i=0; i<loopinfo->ncontacts; i++)
   {
      res = throne((loopinfo->contacts[i])->resnam);
      loopinfo->AAContact[i] = res;
      loopinfo->ContactProps[i] = SetProperties(res);
   }
}


/************************************************************************/
/*>BOOL MergeProperties(int NLoops, LOOPINFO *loopinfo, int clusnum, 
                        CLUSTERINFO *clusterinfo)
   -----------------------------------------------------------------
   Input:   int         NLoops       Number of loops in a cluster
            LOOPINFO    *loopinfo    Array of completed structures for
                                     loops in this cluster
            int         clusnum      The number of the cluster in which
                                     we are interested
   Output:  CLUSTERINFO *clusterinfo Compiled data about this cluster
                                     (Memory allocated within this
                                     structure)
   Returns: BOOL                     Success of memory allocations

   Allocate memory in and complete a clusterinfo structure with merged
   property data for the residues ids common to all loops.

   03.08.95 Original    By: ACRM
   08.08.95 Added setting of clusterinfo->length from first loop's
            length
   02.09.95 Added ->ConsRes[] and ->absolute[] handling
            Corrected check on NULLs for each free() to != rather 
            than ==
*/
BOOL MergeProperties(int NLoops, LOOPINFO *loopinfo, int clusnum,
                     CLUSTERINFO *clusterinfo)
{
   int  i,j,k,
        NRes,
        first;
   BOOL GotResid;

   /* Find the residue IDs common to all loops in this cluster          */
   if((NRes = FlagCommonResidues(NLoops, loopinfo, clusnum)) < 0)
      return(FALSE);
   clusterinfo->NRes = NRes;
   clusterinfo->length = loopinfo[0].length;

   /* If there weren't any common residues (or FlagCommonResidues() found
      no loops in this cluster, just return
   */
   if(NRes == 0)
      return(TRUE);

   /* Allocate memory in the clusterinfo structure to store properties
      for these residues
   */
   clusterinfo->resnum         = (int *)malloc(NRes * sizeof(int));
   clusterinfo->chain          = (char *)malloc(NRes * sizeof(char));
   clusterinfo->insert         = (char *)malloc(NRes * sizeof(char));
   clusterinfo->ConservedProps = (USHORT *)malloc(NRes * sizeof(USHORT));
   clusterinfo->RangeOfProps   = (USHORT *)malloc(NRes * sizeof(USHORT));
   clusterinfo->absolute       = (BOOL *)malloc(NRes * sizeof(BOOL));
   clusterinfo->ConsRes        = (char *)malloc(NRes * sizeof(char));

   if((clusterinfo->resnum         == NULL) ||
      (clusterinfo->chain          == NULL) ||
      (clusterinfo->insert         == NULL) ||
      (clusterinfo->ConservedProps == NULL) ||
      (clusterinfo->RangeOfProps   == NULL) ||
      (clusterinfo->absolute       == NULL) ||
      (clusterinfo->ConsRes        == NULL))
   {
      if(clusterinfo->resnum != NULL)
         free(clusterinfo->resnum);
      if(clusterinfo->chain  != NULL)
         free(clusterinfo->chain);
      if(clusterinfo->insert != NULL)
         free(clusterinfo->insert);
      if(clusterinfo->ConservedProps != NULL)
         free(clusterinfo->ConservedProps);
      if(clusterinfo->RangeOfProps != NULL)
         free(clusterinfo->RangeOfProps);
      if(clusterinfo->ConsRes != NULL)
         free(clusterinfo->ConsRes);
      if(clusterinfo->absolute != NULL)
         free(clusterinfo->absolute);
      return(FALSE);
   }
   
   for(i=0; i<NRes; i++)
   {
      clusterinfo->ConsRes[i]  = '-';
      clusterinfo->absolute[i] = TRUE;
   }
   

   /* Find the first loop in the specified cluster                      */
   first = (-1);
   for(i=0; i<NLoops; i++)
   {
      if(loopinfo[i].clusnum == clusnum)
      {
         first = i;
         break;
      }
   }
   
   /* This shouldn't happen as it's checked for in FlagCommonResidues() */
   if(first == (-1))
   {
      fprintf(stderr,"INTERR: FlagCommonResidues() found cluster %d, but \
MergeProperties() can't\n",clusnum);
      return(FALSE);
   }

   /* Copy in the flagged residue ids from the first loop               */
   for(j=0,k=0; j<loopinfo[first].length; j++)   /* Loop residues       */
   {
      if(loopinfo[first].ResFlag[j])
      {
         clusterinfo->chain[k]  = loopinfo[first].residues[j]->chain[0];
         clusterinfo->resnum[k] = loopinfo[first].residues[j]->resnum;
         clusterinfo->insert[k] = loopinfo[first].residues[j]->insert[0];
         clusterinfo->ConservedProps[k] = loopinfo[first].ResProps[j];
         clusterinfo->RangeOfProps[k]   = loopinfo[first].ResProps[j];
         clusterinfo->ConsRes[k]        = loopinfo[first].AALoop[j];
         
         k++;
      }
   }
   for(j=0; j<loopinfo[first].ncontacts; j++)    /* Contacting residues */
   {
      if(loopinfo[first].ContactFlag[j])
      {
         clusterinfo->chain[k]  = loopinfo[first].contacts[j]->chain[0];
         clusterinfo->resnum[k] = loopinfo[first].contacts[j]->resnum;
         clusterinfo->insert[k] = loopinfo[first].contacts[j]->insert[0];
         clusterinfo->ConservedProps[k] = loopinfo[first].ContactProps[j];
         clusterinfo->RangeOfProps[k]   = loopinfo[first].ContactProps[j];
         clusterinfo->ConsRes[k]        = loopinfo[first].AAContact[j];

         k++;
      }
   }

   /* Examine the loopinfo array for each loop                          */
   for(i=0; i<NLoops; i++)
   {
      /* Is it the cluster of interest?                                 */
      if(loopinfo[i].clusnum == clusnum)
      {
         /* Work our way through the loop properties array              */
         for(j=0; j<loopinfo[i].length; j++)
         {
            /* If it's a flagged (common) residue                       */
            if(loopinfo[i].ResFlag[j])
            {
               /* Find it in the residue id arrays                      */
               GotResid = FALSE;
               for(k=0; k<clusterinfo->NRes; k++)
               {
                  if((clusterinfo->chain[k] == 
                      loopinfo[i].residues[j]->chain[0]) &&
                     (clusterinfo->resnum[k] ==
                      loopinfo[i].residues[j]->resnum)   &&
                     (clusterinfo->insert[k] ==
                      loopinfo[i].residues[j]->insert[0]))
                  {
                     GotResid = TRUE;
                     break;
                  }
               }               
               
               if(GotResid)
               {
                  /* If this residue id is already stored, combine 
                     properties from this loop into the array  
                  */
                  clusterinfo->ConservedProps[k] &= 
                     loopinfo[i].ResProps[j];
                  clusterinfo->RangeOfProps[k]   |= 
                     loopinfo[i].ResProps[j];
                  if(clusterinfo->ConsRes[k] != loopinfo[i].AALoop[j])
                     clusterinfo->absolute[k] = FALSE;
               }
               else
               {
                  /* This shouldn't happen!                             */
                  fprintf(stderr,"Cockup! Residue in loop %d flagged as \
common but not in loop 0\n",i);
                  WritePDBRecord(stderr,loopinfo[i].residues[j]);
               }
            }
         }

         /* Repeat for the contacting residue array                     */
         for(j=0; j<loopinfo[i].ncontacts; j++)
         {
            /* If it's a flagged (common) residue                       */
            if(loopinfo[i].ContactFlag[j])
            {
               /* Find it in the residue id arrays                      */
               GotResid = FALSE;
               for(k=0; k<clusterinfo->NRes; k++)
               {
                  if((clusterinfo->chain[k] == 
                      loopinfo[i].contacts[j]->chain[0]) &&
                     (clusterinfo->resnum[k] ==
                      loopinfo[i].contacts[j]->resnum)   &&
                     (clusterinfo->insert[k] ==
                      loopinfo[i].contacts[j]->insert[0]))
                  {
                     GotResid = TRUE;
                     break;
                  }
               }               

               if(GotResid)
               {
                  /* If this residue id is already stored, combine 
                     properties from this loop into the array  
                  */
                  clusterinfo->ConservedProps[k] &= 
                     loopinfo[i].ContactProps[j];
                  clusterinfo->RangeOfProps[k]   |= 
                     loopinfo[i].ContactProps[j];
                  if(clusterinfo->ConsRes[k] != loopinfo[i].AAContact[j])
                     clusterinfo->absolute[k] = FALSE;
               }
               else
               {
                  /* This shouldn't happen!                             */
                  fprintf(stderr,"Cockup! Residue in loop %d flagged as \
common but not in loop 0\n",i);
                  WritePDBRecord(stderr,loopinfo[i].contacts[j]);
               }
            }
         }
      }
   }
   return(TRUE);
}

/************************************************************************/
/*>void BlankClusterInfo(CLUSTERINFO *clusterinfo)
   -----------------------------------------------
   Output:  CLUSTERINFO  *clusterinfo    Cleared structure.

   Set all pointers in a clusterinfo structure to NULL

   02.08.95 Original    By: ACRM
   08.08.95 Added length
   02.10.95 Added absolute and ConsRes
*/
void BlankClusterInfo(CLUSTERINFO *clusterinfo)
{
   clusterinfo->resnum         = NULL;
   clusterinfo->chain          = NULL;
   clusterinfo->insert         = NULL;
   clusterinfo->ConservedProps = NULL;
   clusterinfo->RangeOfProps   = NULL;
   clusterinfo->absolute       = NULL;
   clusterinfo->ConsRes        = NULL;
   clusterinfo->NRes           = 0;
   clusterinfo->length         = 0;
}


/************************************************************************/
/*>int FlagCommonResidues(int NLoops, LOOPINFO *loopinfo, int clusnum)
   -------------------------------------------------------------------
   Input:   int      NLoops     Number of loops
            int      clusnum    Cluster number of interest
   I/O:     LOOPINFO *loopinfo  Array of structures containing loop info
                                On output, the ResFlag and ContactFlag
                                arrays are filled in with the residues
                                common to all loops in the array
   Returns: int                 Number of residues in common
                                (-1 if a memory allocation failed)

   Runs through the NLoops loops in the loopinfo structure array, looking
   at cluster clusnum. Finds residue ids common to all loops in this
   cluster and flags them in the loopinfo structures.

   Returns the total number of common residues.

   03.08.95 Original   By: ACRM
*/
int FlagCommonResidues(int NLoops, LOOPINFO *loopinfo, int clusnum)
{
   int  i, j, k,
        looplen,
        *resnum,
        *count,
        nres,
        retval = (-1),
        first;
   char *chain,
        *insert;

   /* Find how many residues there are in the first example and allocate
      memory of this size
   */
   nres = loopinfo[0].length + loopinfo[0].ncontacts;

   chain  = (char *)malloc(nres * sizeof(char));
   insert = (char *)malloc(nres * sizeof(char));
   resnum = (int *)malloc(nres * sizeof(int));
   count  = (int *)malloc(nres * sizeof(int));

   /* If allocations all OK, continue                                   */
   if((chain  != NULL) && (insert != NULL) && 
      (resnum != NULL) && (count  != NULL))
   {
      /* Initialise retval to 0 to say that allocations succeeded       */
      retval = 0;
      
      /* Find the first loop which is in the required cluster           */
      first = (-1);
      for(i=0; i<NLoops; i++)
      {
         if(loopinfo[i].clusnum == clusnum)
         {
            first = i;
            break;
         }
      }
      
      /* If a loop is found in the required cluster                     */
      if(first != (-1))
      {
         /* Copy the residue ids into the arrays for first loop         */
         looplen = loopinfo[first].length;
         for(j=0; j<looplen; j++)                /* Loop residues       */
         {
            chain[j]  = loopinfo[first].residues[j]->chain[0];
            resnum[j] = loopinfo[first].residues[j]->resnum;
            insert[j] = loopinfo[first].residues[j]->insert[0];
            count[j]  = 1;
         }
         for(j=0; j<loopinfo[0].ncontacts; j++)  /* Contacting residues */
         {
            chain[looplen+j]  = loopinfo[first].contacts[j]->chain[0];
            resnum[looplen+j] = loopinfo[first].contacts[j]->resnum;
            insert[looplen+j] = loopinfo[first].contacts[j]->insert[0];
            count[looplen+j]  = 1;
         }
         
         
         /* Run through the rest of the loops incrementing the count if
            the residue label is found in this loop
         */
         for(i=first+1; i<NLoops; i++)
         {
            if(loopinfo[i].clusnum == clusnum)
            {
               for(j=0; j<loopinfo[i].length; j++)    /* Loop residues  */
               {
                  for(k=0; k<nres; k++)
                  {
                     if((chain[k] ==loopinfo[i].residues[j]->chain[0]) &&
                        (resnum[k]==loopinfo[i].residues[j]->resnum)   &&
                        (insert[k]==loopinfo[i].residues[j]->insert[0]))
                        (count[k])++;
                  }
               }
               
               for(j=0; j<loopinfo[i].ncontacts; j++) /* Contacting res */
               {
                  for(k=0; k<nres; k++)
                  {
                     if((chain[k] ==loopinfo[i].contacts[j]->chain[0]) &&
                        (resnum[k]==loopinfo[i].contacts[j]->resnum)   &&
                        (insert[k]==loopinfo[i].contacts[j]->insert[0]))
                        (count[k])++;
                  }
               }
            }
         }
         
         /* Run through the loops again flagging all residues which are 
            common to all loops.
         */
         for(i=first; i<NLoops; i++)
         {
            if(loopinfo[i].clusnum == clusnum)
            {
               for(j=0; j<loopinfo[i].length; j++)    /* Loop residues  */
               {
                  loopinfo[i].ResFlag[j] = FALSE;
                  for(k=0; k<nres; k++)
                  {
                     if((chain[k] ==loopinfo[i].residues[j]->chain[0])  &&
                        (resnum[k]==loopinfo[i].residues[j]->resnum)    &&
                        (insert[k]==loopinfo[i].residues[j]->insert[0]) &&
                        (count[k] ==NLoops))
                     {
                        loopinfo[i].ResFlag[j] = TRUE;
                        break;
                     }
                  }
               }
               
               for(j=0; j<loopinfo[i].ncontacts; j++) /* Contacting res */
               {
                  loopinfo[i].ContactFlag[j] = FALSE;
                  for(k=0; k<nres; k++)
                  {
                     if((chain[k] ==loopinfo[i].contacts[j]->chain[0])  &&
                        (resnum[k]==loopinfo[i].contacts[j]->resnum)    &&
                        (insert[k]==loopinfo[i].contacts[j]->insert[0]) &&
                        (count[k] ==NLoops))
                     {
                        loopinfo[i].ContactFlag[j] = TRUE;
                        break;
                     }
                  }
               }
            }
         }
         
         /* Count the common residues as the return value               */
         retval = 0;
         for(k=0; k<nres; k++)
         {
            if(count[k] == NLoops)
               retval++;
         }
      }  /* There was a loop in the specified cluster                   */
   }  /* Memory allocations OK                                          */
   
   /* Free up allocated memory                                          */
   if(chain  != NULL) free(chain);
   if(insert != NULL) free(insert);
   if(resnum != NULL) free(resnum);
   if(count  != NULL) free(count);
   
   return(retval);
}


/************************************************************************/
/*>void PrintProps(FILE *fp, USHORT props)
   ---------------------------------------
   Input:   FILE   *fp         Output file pointer
            USHORT props       Properties value

   Print the properties associated with the props value as moderately
   verbose, but parsable, text.

   03.08.95 Original    By: ACRM
*/
void PrintProps(FILE *fp, USHORT props)
{
   if(props == (USHORT)0)
   {
      fprintf(fp,"No conserved properties");
      return;
   }
   
   if(ISSET(props, GLY_FLAG))
   {
      fprintf(fp,"glycine");
      return;
   }
   
   if(ISSET(props, PRO_FLAG))
   {
      fprintf(fp,"proline");
      return;
   }

   fprintf(fp,"/");

   if(ISSET(props, HPHOB_FLAG))
   {
      fprintf(fp,"hydrophobic/");

      if(ISSET(props, AROMATIC_FLAG))
      {
         fprintf(fp,"aromatic/");

         if(ISSET(props, HBOND_FLAG))
            fprintf(fp,"H-bonding/");
         if(ISSET(props, NOHBOND_FLAG))
            fprintf(fp,"non-H-bonding/");
      }
   }
   else
   {
      if(ISSET(props, UNCHARGED_FLAG))
      {
         fprintf(fp,"uncharged/");
      }

      if(ISSET(props, NEGATIVE_FLAG))
         fprintf(fp,"negative/");
      if(ISSET(props, POSITIVE_FLAG))
         fprintf(fp,"positive/");

      if(!ISSET(props, NEGATIVE_FLAG) &&
         !ISSET(props, POSITIVE_FLAG))
      {
         if(ISSET(props, HPHIL_FLAG))
            fprintf(fp,"hydrophilic/");

         if(ISSET(props, HBOND_FLAG))
            fprintf(fp,"H-bonding/");
         if(ISSET(props, NOHBOND_FLAG))
            fprintf(fp,"non-H-bonding/");
      }
   }
   
   if(!ISSET(props, AROMATIC_FLAG))
   {   
      if(ISSET(props, SMALL_FLAG))
         fprintf(fp,"small/");
      if(ISSET(props, MEDIUM_FLAG))
         fprintf(fp,"medium/");
      if(ISSET(props, LARGE_FLAG))
         fprintf(fp,"large/");
   }
   
   if(ISSET(props, ALIPHATIC_FLAG))
      fprintf(fp,"aliphatic/");

   if(ISSET(props, OTHER_FLAG))
      fprintf(fp,"not glycine or proline/");

}


/************************************************************************/
/*>void InitProperties(void)
   -------------------------
   Initialise static global property flags tables.
   
   01.08.95 Original    By: ACRM
*/
void InitProperties(void)
{
   sResArray[0] = 'A';
   SET(sPropsArray[0], HPHOB_FLAG);
   SET(sPropsArray[0], UNCHARGED_FLAG);
   SET(sPropsArray[0], ALIPHATIC_FLAG);
   SET(sPropsArray[0], SMALL_FLAG);
   SET(sPropsArray[0], OTHER_FLAG);
   SET(sPropsArray[0], NOHBOND_FLAG);

   sResArray[1] = 'C';
   SET(sPropsArray[1], HPHOB_FLAG);
   SET(sPropsArray[1], UNCHARGED_FLAG);
   SET(sPropsArray[1], ALIPHATIC_FLAG);
   SET(sPropsArray[1], SMALL_FLAG);
   SET(sPropsArray[1], OTHER_FLAG);
   SET(sPropsArray[1], NOHBOND_FLAG);

   sResArray[2] = 'D';
   SET(sPropsArray[2], HPHIL_FLAG);
   SET(sPropsArray[2], NEGATIVE_FLAG);
   SET(sPropsArray[2], ALIPHATIC_FLAG);
   SET(sPropsArray[2], SMALL_FLAG);
   SET(sPropsArray[2], OTHER_FLAG);
   SET(sPropsArray[2], NOHBOND_FLAG);

   sResArray[3] = 'E';
   SET(sPropsArray[3], HPHIL_FLAG);
   SET(sPropsArray[3], NEGATIVE_FLAG);
   SET(sPropsArray[3], ALIPHATIC_FLAG);
   SET(sPropsArray[3], MEDIUM_FLAG);
   SET(sPropsArray[3], OTHER_FLAG);
   SET(sPropsArray[3], NOHBOND_FLAG);

   sResArray[4] = 'F';
   SET(sPropsArray[4], HPHOB_FLAG);
   SET(sPropsArray[4], UNCHARGED_FLAG);
   SET(sPropsArray[4], AROMATIC_FLAG);
   SET(sPropsArray[4], LARGE_FLAG);
   SET(sPropsArray[4], OTHER_FLAG);
   SET(sPropsArray[4], NOHBOND_FLAG);

   sResArray[5] = 'G';
   SET(sPropsArray[5], HPHOB_FLAG);
   SET(sPropsArray[5], UNCHARGED_FLAG);
   SET(sPropsArray[5], ALIPHATIC_FLAG);
   SET(sPropsArray[5], SMALL_FLAG);
   SET(sPropsArray[5], GLY_FLAG);
   SET(sPropsArray[5], NOHBOND_FLAG);

   sResArray[6] = 'H';
   SET(sPropsArray[6], HPHIL_FLAG);
   SET(sPropsArray[6], POSITIVE_FLAG);
   SET(sPropsArray[6], ALIPHATIC_FLAG);
   SET(sPropsArray[6], LARGE_FLAG);
   SET(sPropsArray[6], OTHER_FLAG);
   SET(sPropsArray[6], HBOND_FLAG);

   sResArray[7] = 'I';
   SET(sPropsArray[7], HPHOB_FLAG);
   SET(sPropsArray[7], UNCHARGED_FLAG);
   SET(sPropsArray[7], ALIPHATIC_FLAG);
   SET(sPropsArray[7], MEDIUM_FLAG);
   SET(sPropsArray[7], OTHER_FLAG);
   SET(sPropsArray[7], NOHBOND_FLAG);

   sResArray[8] = 'K';
   SET(sPropsArray[8], HPHIL_FLAG);
   SET(sPropsArray[8], POSITIVE_FLAG);
   SET(sPropsArray[8], ALIPHATIC_FLAG);
   SET(sPropsArray[8], LARGE_FLAG);
   SET(sPropsArray[8], OTHER_FLAG);
   SET(sPropsArray[8], NOHBOND_FLAG);

   sResArray[9] = 'L';
   SET(sPropsArray[9], HPHOB_FLAG);
   SET(sPropsArray[9], UNCHARGED_FLAG);
   SET(sPropsArray[9], ALIPHATIC_FLAG);
   SET(sPropsArray[9], MEDIUM_FLAG);
   SET(sPropsArray[9], OTHER_FLAG);
   SET(sPropsArray[9], NOHBOND_FLAG);

   sResArray[10] = 'M';
   SET(sPropsArray[10], HPHOB_FLAG);
   SET(sPropsArray[10], UNCHARGED_FLAG);
   SET(sPropsArray[10], ALIPHATIC_FLAG);
   SET(sPropsArray[10], LARGE_FLAG);
   SET(sPropsArray[10], OTHER_FLAG);
   SET(sPropsArray[10], NOHBOND_FLAG);

   sResArray[11] = 'N';
   SET(sPropsArray[11], HPHIL_FLAG);
   SET(sPropsArray[11], UNCHARGED_FLAG);
   SET(sPropsArray[11], ALIPHATIC_FLAG);
   SET(sPropsArray[11], SMALL_FLAG);
   SET(sPropsArray[11], OTHER_FLAG);
   SET(sPropsArray[11], HBOND_FLAG);

   sResArray[12] = 'P';
   SET(sPropsArray[12], HPHIL_FLAG);
   SET(sPropsArray[12], UNCHARGED_FLAG);
   SET(sPropsArray[12], ALIPHATIC_FLAG);
   SET(sPropsArray[12], MEDIUM_FLAG);
   SET(sPropsArray[12], PRO_FLAG);
   SET(sPropsArray[12], NOHBOND_FLAG);

   sResArray[13] = 'Q';
   SET(sPropsArray[13], HPHIL_FLAG);
   SET(sPropsArray[13], UNCHARGED_FLAG);
   SET(sPropsArray[13], ALIPHATIC_FLAG);
   SET(sPropsArray[13], MEDIUM_FLAG);
   SET(sPropsArray[13], OTHER_FLAG);
   SET(sPropsArray[13], HBOND_FLAG);

   sResArray[14] = 'R';
   SET(sPropsArray[14], HPHIL_FLAG);
   SET(sPropsArray[14], POSITIVE_FLAG);
   SET(sPropsArray[14], ALIPHATIC_FLAG);
   SET(sPropsArray[14], LARGE_FLAG);
   SET(sPropsArray[14], OTHER_FLAG);
   SET(sPropsArray[14], NOHBOND_FLAG);

   sResArray[15] = 'S';
   SET(sPropsArray[15], HPHIL_FLAG);
   SET(sPropsArray[15], UNCHARGED_FLAG);
   SET(sPropsArray[15], ALIPHATIC_FLAG);
   SET(sPropsArray[15], SMALL_FLAG);
   SET(sPropsArray[15], OTHER_FLAG);
   SET(sPropsArray[15], HBOND_FLAG);

   sResArray[16] = 'T';
   SET(sPropsArray[16], HPHIL_FLAG);
   SET(sPropsArray[16], UNCHARGED_FLAG);
   SET(sPropsArray[16], ALIPHATIC_FLAG);
   SET(sPropsArray[16], MEDIUM_FLAG);
   SET(sPropsArray[16], OTHER_FLAG);
   SET(sPropsArray[16], HBOND_FLAG);

   sResArray[17] = 'V';
   SET(sPropsArray[17], HPHOB_FLAG);
   SET(sPropsArray[17], UNCHARGED_FLAG);
   SET(sPropsArray[17], ALIPHATIC_FLAG);
   SET(sPropsArray[17], MEDIUM_FLAG);
   SET(sPropsArray[17], OTHER_FLAG);
   SET(sPropsArray[17], NOHBOND_FLAG);

   sResArray[18] = 'W';
   SET(sPropsArray[18], HPHOB_FLAG);
   SET(sPropsArray[18], UNCHARGED_FLAG);
   SET(sPropsArray[18], AROMATIC_FLAG);
   SET(sPropsArray[18], LARGE_FLAG);
   SET(sPropsArray[18], OTHER_FLAG);
   SET(sPropsArray[18], NOHBOND_FLAG);

   sResArray[19] = 'Y';
   SET(sPropsArray[19], HPHOB_FLAG);
   SET(sPropsArray[19], UNCHARGED_FLAG);
   SET(sPropsArray[19], AROMATIC_FLAG);
   SET(sPropsArray[19], LARGE_FLAG);
   SET(sPropsArray[19], OTHER_FLAG);
   SET(sPropsArray[19], HBOND_FLAG);
}


/************************************************************************/
/*>USHORT SetProperties(char res)
   ------------------------------
   Input:   char    res        Residue 1-letter code
   Returns: USHORT             Property flags for residue
                               (0 if not found)

   Set the props variable from a 1-letter code residue by looking it up 
   in the static residue properties table.

   03.08.95 Original    By: ACRM
   08.08.95 Changed so it returns the properties rather than outputting
            them.
*/
USHORT SetProperties(char res)
{
   int   i;
   
   for(i=0; i<20; i++)
   {
      if(sResArray[i] == res)
      {
         return(sPropsArray[i]);
      }
   }
   return((USHORT)0);
}


/************************************************************************/
/*>void PrintSampleResidues(FILE *fp, USHORT props)
   ------------------------------------------------
   Input:   FILE   *fp      Output file pointer
            USHORT props    Properties flags

   Prints sample amino acids which possess a set of properties.

   03.08.95 Original    By: ACRM
   10.08.95 Prints all 20 aas rather than a - if no conserved properties
*/
void PrintSampleResidues(FILE *fp, USHORT props)
{
   int i;

   fprintf(fp,"  (");
   
   if(props == (USHORT)0)
   {
      fprintf(fp,"ACDEFGHIKLMNPQRSTVWY");
   }
   else
   {
      for(i=0; i<20; i++)
      {
         if((sPropsArray[i] & props) == props)
         {
            fprintf(fp,"%c",sResArray[i]);
         }
      }
   }

   fprintf(fp,")");
}


/************************************************************************/
/*>void CleanLoopInfo(LOOPINFO *loopinfo, int NMembers)
   ----------------------------------------------------
   I/O:     LOOPINFO  *loopinfo     Array of loopinfo structures
   Input:   int       NMembers      Number of items in array

   Free up memory allocated within the loopinfo[] array

   08.08.95 Original    By: ACRM
*/
void CleanLoopInfo(LOOPINFO *loopinfo, int NMembers)
{
   int i;
   
   for(i=0; i<NMembers; i++)
   {
      if(loopinfo[i].contacts     != NULL) free(loopinfo[i].contacts);
      if(loopinfo[i].residues     != NULL) free(loopinfo[i].residues);
      if(loopinfo[i].ContactProps != NULL) free(loopinfo[i].ContactProps);
      if(loopinfo[i].ResProps     != NULL) free(loopinfo[i].ResProps);
      if(loopinfo[i].AALoop       != NULL) free(loopinfo[i].AALoop);
      if(loopinfo[i].AAContact    != NULL) free(loopinfo[i].AAContact);
      if(loopinfo[i].ResFlag      != NULL) free(loopinfo[i].ResFlag);
      if(loopinfo[i].ContactFlag  != NULL) free(loopinfo[i].ContactFlag);
      
      loopinfo[i].contacts     = NULL;
      loopinfo[i].residues     = NULL;
      loopinfo[i].ContactProps = NULL;
      loopinfo[i].ResProps     = NULL;
      loopinfo[i].AALoop       = NULL;
      loopinfo[i].AAContact    = NULL;
      loopinfo[i].ResFlag      = NULL;
      loopinfo[i].ContactFlag  = NULL;
   }
}

/************************************************************************/
/*>void CleanClusInfo(CLUSTERINFO *cinfo)
   --------------------------------------
   I/O:     CLUSTERINFO  *cinfo     Pointer to cluster infor structure
                                    to be cleaned

   Frees up memory alliocated in a cluster information structure and
   calls BlankClusterInfo() to clear everything.

   08.08.95 Original    By: ACRM
   02.10.95 Added absolute and ConsRes
*/
void CleanClusInfo(CLUSTERINFO *cinfo)
{
   if(cinfo->resnum         != NULL) free(cinfo->resnum);
   if(cinfo->chain          != NULL) free(cinfo->chain);
   if(cinfo->insert         != NULL) free(cinfo->insert);
   if(cinfo->ConservedProps != NULL) free(cinfo->ConservedProps);
   if(cinfo->RangeOfProps   != NULL) free(cinfo->RangeOfProps);
   if(cinfo->absolute       != NULL) free(cinfo->absolute);
   if(cinfo->ConsRes        != NULL) free(cinfo->ConsRes);

   BlankClusterInfo(cinfo);
}

/************************************************************************/
/*>void PrintMergedProperties(FILE *fp, int clusnum, CLUSTERINFO cinfo,
                              int NMembers)
   --------------------------------------------------------------------
   Input:   FILE        *fp      Output file pointer
            int         clusnum  Cluster number
            CLUSTERINFO cinfo    Cluster information structure
            int         NMembers Number of members of the cluster

   Print property information from merged properties for a cluster

   08.08.95 Original    By: ACRM
   14.08.95 Always prints number of members
   02.10.95 Handles printing of absolutely conserved residues
*/
void PrintMergedProperties(FILE *fp, int clusnum, CLUSTERINFO cinfo,
                           int NMembers)
{
   int i;
   
   fprintf(fp,"CLUSTER %d (Length = %d, Members = %d)\n",
           clusnum,cinfo.length,NMembers);

   if(NMembers < 2)
      fprintf(fp, "WARNING: This cluster has%s%s %s!\n",
              (NMembers?" only ":" "),
              (NMembers?"one":"no"),
              (NMembers?"member":"members"));

   if(cinfo.NRes == 0)
   {
      fprintf(fp, "WARNING: No common residues identified for this \
cluster!\n");
   }
   else
   {
      for(i=0;i<cinfo.NRes;i++)
      {
         fprintf(fp,"%c%3d%c 0x%04x ",
                 cinfo.chain[i],
                 cinfo.resnum[i],
                 cinfo.insert[i],
                 cinfo.ConservedProps[i]);
         PrintProps(fp,cinfo.ConservedProps[i]);
         if(cinfo.absolute[i])
            fprintf(fp," [CONSERVED] (%c)",cinfo.ConsRes[i]);
         else
            PrintSampleResidues(fp,cinfo.ConservedProps[i]);
         fprintf(fp,"\n");
      }
   }

   fprintf(fp,"\n");
}
