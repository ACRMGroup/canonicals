

/************************************************************************/
/*>DATALIST *FindMultiMedian(int **clusters, REAL **data, int NVec, 
                             int VecDim, int NClus, int *member, 
                             int ClusNum)
   -------------------------------------------------------------------
   Input:   int   **clusters    Clustring table
            REAL  **data        Data which is clustered
            int   NVec          Number of vectors
            int   VecDim        Dimension of vectors
            int   NClus         Number of clusters we have selected
            int   *member       Array of cluster number assignments for
                                each vector. This includes any cluster
                                merging which may have been done on RMS
            int   ClusNum       The cluster number we are interested in
   Returns: DATALIST *          Pointer to median for this cluster.

   Calculates the median of cluster ClusNum out of NClus clusters. Looks
   int the member array to find other clusters which have been merged
   into ClusNum. Then finds the vector closest to the median and returns
   a character pointer to the associated loop identifier.

   06.07.95 Original based on FindMedian    By: ACRM
   02.08.95 Fixed array access from [NClus] to [NClus-2]
*/
DATALIST *FindMultiMedian(int **clusters, REAL **data, int NVec, 
                          int VecDim, int NClus, int *member, int ClusNum)
{
   DATALIST *p = NULL;
   int      i, j,
            TrueClusNum,
            best;
   REAL     *minval, 
            *maxval,
            *medval,
            mindist,
            dist;
   BOOL     Done = FALSE;

   /* Allocate arrays to store min and max values in each dimension     */
   if((minval=(REAL *)malloc(VecDim*sizeof(REAL)))==NULL)
      return(NULL);
   if((maxval=(REAL *)malloc(VecDim*sizeof(REAL)))==NULL)
   {
      free(minval);
      return(NULL);
   }

   /* We just use the same storage space for the median values          */
   medval = minval;

   /* Run through the member array which contains our merged cluster
      numbers. The position in this array (+1) is one of the true
      cluster numbers associated with this merged cluster
   */
   for(TrueClusNum=1, Done=FALSE; TrueClusNum<=NClus; TrueClusNum++)
   {
      if(member[TrueClusNum-1] == ClusNum)
      {
         /* Find the min and max values in each dimension               */
         for(i=0; i<NVec; i++)
         {
            if(clusters[i][NClus-2] == TrueClusNum)
            {
               /* On first item, just copy in the data                  */
               if(!Done)
               {
                  for(j=0; j<VecDim; j++)
                     minval[j] = maxval[j] = data[i][j];
                  Done = TRUE;
               }
               else
               {
                  for(j=0; j<VecDim; j++)
                  {
                     if(data[i][j] < minval[j])
                        minval[j] = data[i][j];
                     if(data[i][j] > maxval[j])
                        maxval[j] = data[i][j];
                  }
               }
            }
         }
      }
   }

   /* If we didn't find this cluster number, return NULL                */
   if(!Done)
   {
      free(minval);
      free(maxval);
      return(NULL);
   }

   /* Now store the median values                                       */
   for(j=0; j<VecDim; j++)
      medval[j] = (minval[j] + maxval[j]) / (REAL)2.0;
      
   /* Now run through again and find which is closest to the medval     */
   for(TrueClusNum=1, Done=FALSE; TrueClusNum<=NClus; TrueClusNum++)
   {
      if(member[TrueClusNum-1] == ClusNum)
      {
         for(i=0; i<NVec; i++)
         {
            if(clusters[i][NClus-2] == TrueClusNum)
            {
               if(!Done)
               {
                  best    = i;
                  mindist = (REAL)0.0;
                  for(j=0; j<VecDim; j++)
                     mindist += (data[i][j] - medval[j]) *
                                (data[i][j] - medval[j]);
                  
                  Done = TRUE;
               }
               else
               {
                  dist = (REAL)0.0;
                  for(j=0; j<VecDim; j++)
                     dist += (data[i][j] - medval[j]) *
                             (data[i][j] - medval[j]);
                  if(dist < mindist)
                  {
                     mindist = dist;
                     best    = i;
                  }
               }
            }
         }
      }
   }

   /* Now run through the global data linked list to find the `best'
      example's loop pointer
   */
   for(p=gDataList, i=0; p!=NULL && i<best; NEXT(p), i++) ;

   /* Free up the arrays                                                */
   free(minval);
   free(maxval);

   /* Return the loop pointer                                           */
   return(p);
}
