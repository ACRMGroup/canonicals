/************************************************************************/
/*>REAL ClusterDistance(REAL *vector, REAL **data, int NData, int VecLen,
                        CLUSTER *clusters, int clusnum, int method)
   ----------------------------------------------------------------------
   Measure the distance between a vector and a cluster using the specified
   clustering method.

   Returns -1 on failure

   27.07.95 Original    ByL ACRM
*/
REAL ClusterDistance(REAL *vector, REAL **data, int NData, int VecLen,
                     CLUSTER *clusters, int clusnum, int method)
{
   int  i, j, k,
        First,
        Secnd,
        NumInClus,
        NMembers;
   BOOL *Unclustered = NULL;
   REAL **DistMat    = NULL,
        *VecDist     = NULL,
        result;
   
   /* Allocate memory for arrays                                        */
   Unclustered = (BOOL *)malloc(NData * sizeof(BOOL));
   VecDist     = (REAL *)malloc(NData * sizeof(REAL));
   DistMat     = (REAL **)Array2D(sizeof(REAL), NData, NData);
   
   /* Check allocations                                                 */
   if(Unclustered==NULL || DistMat==NULL || VecDist==NULL)
   {
      if(Unclustered != NULL) free(Unclustered);
      if(VecDist     != NULL) free(VecDist);
      if(DistMat     != NULL) FreeArray2D((char **)DistMat, NData, NData);
   
      return((REAL)(-1.0));
   }
   
   /* Calculate distances between all items                             */
   for(i=0; i<NData; i++)
   {
      for(j=0; j<NData; j++)
      {
         DistMat[i][j] = (REAL)0.0;
         for(k=0; k<VecLen; k++)
         {
            DistMat[i][j] += (data[i][k] - data[j][k]) *
                             (data[i][k] - data[j][k]);
         }
         if(method == 1)
            DistMat[i][j] /= (REAL)2.0;
            
         DistMat[j][i] = DistMat[i][j];
      }

      Unclustered[i] = TRUE;
   }

   /* Calculate distance from our vector to each item                   */
   for(i=0; i<NData; i++)
   {
      VecDist[i] = (REAL)0.0;
      for(k=0; k<VecLen; k++)
      {
         VecDist[i] += (data[i][k] - vector[k]) *
                       (data[i][k] - vector[k]);
      }
   }
      

   switch(method)
   {
   case 1:              /* Ward's minimum variance method               */
      First    = (-1);
      NMembers = 0;
      for(i=0; i<NData; i++)
      {
         if(clusters[i].clusnum == clusnum)
         {
            if(First == (-1))
            {
               First    = i;
            }
            else
            {
               Secnd    = i;
               
               if(Unclustered[Secnd])
               {
                  Unclustered[Secnd] = FALSE;
                  
                  /* Recalc distances within the matrix                 */
                  for(k=0; k<NData; k++)
                  {
                     if(Unclustered[k] && (k != First))
                     {
                        DistMat[First][k] = 
                           (NMembers+1) * DistMat[First][k] +
                           2            * DistMat[Secnd][k] -
                           DistMat[First][Secnd];
                        DistMat[k][First] = DistMat[First][k];
                     }
                  }

                  /* Calculate distances to our vector                  */
                  VecDist[First] = 
                     (NMembers+1) * VecDist[First] +
                     2            * VecDist[Secnd] -
                     DistMat[First][Secnd];
               }
            }
            NMembers++;
         }
      }
      result = VecDist[First];
      break;
   case 2:              /* Single linkage                               */
      result = INF;
      
      for(i=0; i<NData; i++)
      {
         if(clusters[i].clusnum == clusnum)
         {
            if(VecDist[i] < result)
               result = VecDist[i];
         }
      }
      break;
   case 3:              /* Complete linkage                             */
      result = (REAL)(-1);
      
      for(i=0; i<NData; i++)
      {
         if(clusters[i].clusnum == clusnum)
         {
            if(VecDist[i] > result)
               result = VecDist[i];
         }
      }
      break;
   case 4:              /* Group average method                         */
      result   = (REAL)0.0;
      NMembers = 0;

      for(i=0; i<NData; i++)
      {
         if(clusters[i].clusnum == clusnum)
         {
            result += VecDist[i];
            NMembers++;
         }
      }
      result /= (REAL)NMembers;
      break;
   case 5:              /* McQuitty's method                            */
      First    = (-1);
      for(i=0; i<NData; i++)
      {
         if(clusters[i].clusnum == clusnum)
         {
            if(First == (-1))
            {
               First    = i;
            }
            else
            {
               Secnd    = i;
               
               if(Unclustered[Secnd])
               {
                  Unclustered[Secnd] = FALSE;
                  
                  /* Recalc distances within the matrix                 */
                  for(k=0; k<NData; k++)
                  {
                     if(Unclustered[k] && (k != First))
                     {
                        DistMat[First][k] = 
                           (REAL)0.5 * DistMat[First][k] +
                           (REAL)0.5 * DistMat[Secnd][k];
                        DistMat[k][First] = DistMat[First][k];
                     }
                  }

                  /* Calculate distances to our vector                  */
                  VecDist[First] = 
                     (REAL)0.5 * VecDist[First] +
                     (REAL)0.5 * VecDist[Secnd];
               }
            }
         }
      }
      result = VecDist[First];
      break;
   case 6:              /* Median (Gower's) method                      */
      First    = (-1);
      for(i=0; i<NData; i++)
      {
         if(clusters[i].clusnum == clusnum)
         {
            if(First == (-1))
            {
               First    = i;
            }
            else
            {
               Secnd    = i;
               
               if(Unclustered[Secnd])
               {
                  Unclustered[Secnd] = FALSE;
                  
                  /* Recalc distances within the matrix                 */
                  for(k=0; k<NData; k++)
                  {
                     if(Unclustered[k] && (k != First))
                     {
                        DistMat[First][k] = 
                           (REAL)0.5  * DistMat[First][k] +
                           (REAL)0.5  * DistMat[Secnd][k] - 
                           (REAL)0.25 * DistMat[First][Secnd];
                        DistMat[k][First] = DistMat[First][k];
                     }
                  }

                  /* Calculate distances to our vector                  */
                  VecDist[First] = 
                     (REAL)0.5  * VecDist[First] +
                     (REAL)0.5  * VecDist[Secnd] - 
                     (REAL)0.25 * DistMat[First][Secnd];
               }
            }
         }
      }
      result = VecDist[First];
      break;
   case 7:              /* Centroid method                              */
      First    = (-1);
      NMembers = 0;
      for(i=0; i<NData; i++)
      {
         if(clusters[i].clusnum == clusnum)
         {
            if(First == (-1))
            {
               First    = i;
            }
            else
            {
               Secnd    = i;
               
               if(Unclustered[Secnd])
               {
                  Unclustered[Secnd] = FALSE;
                  
                  /* Recalc distances within the matrix                 */
                  for(k=0; k<NData; k++)
                  {
                     if(Unclustered[k] && (k != First))
                     {
                        DistMat[First][k] = 
                           (NMembers * DistMat[First][k] +
                            DistMat[Secnd][k]            -
                            NMembers * DistMat[First][Secnd] /
                            (NMembers + 1)) / (NMembers + 1);
                        DistMat[k][First] = DistMat[First][k];
                     }
                  }

                  /* Calculate distances to our vector                  */
                  VecDist[First] = 
                     (NMembers * VecDist[First] +
                      VecDist[Secnd]            -
                      NMembers * DistMat[First][Secnd] /
                      (NMembers + 1)) / (NMembers + 1);
               }
            }
            NMembers++;
         }
      }
      result = VecDist[First];
      break;
   }
   
   if(Unclustered!=NULL) free(Unclustered);
   if(VecDist!=NULL)     free(VecDist);
   if(DistMat!=NULL)     FreeArray2D((char **)DistMat, NData, NData);

   return(result);
}


