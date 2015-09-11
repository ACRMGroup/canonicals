BOOL FindNeighbourProps(PDB *pdb, PDB *start, PDB *stop, int clusnum,
                        LOOPINFO *loopinfo)
;
BOOL ResidueContact(PDB *p_start, PDB *p_stop, PDB *q_start, PDB *q_stop,
                    REAL dist)
;
void FillLoopInfo(LOOPINFO *loopinfo)
;
BOOL MergeProperties(int NLoops, LOOPINFO *loopinfo, int clusnum,
                     CLUSTERINFO *clusterinfo)
;
void BlankClusterInfo(CLUSTERINFO *clusterinfo)
;
int FlagCommonResidues(int NLoops, LOOPINFO *loopinfo, int clusnum)
;
void PrintProps(FILE *fp, USHORT props)
;
void InitProperties(void)
;
USHORT SetProperties(char res)
;
void PrintSampleResidues(FILE *fp, USHORT props)
;
void CleanLoopInfo(LOOPINFO *loopinfo, int NMembers)
;
void CleanClusInfo(CLUSTERINFO *cinfo)
;
void PrintMergedProperties(FILE *fp, int clusnum, CLUSTERINFO cinfo,
                           int NMembers)
;
