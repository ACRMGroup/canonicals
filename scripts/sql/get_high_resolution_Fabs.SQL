SELECT pdb_code
  FROM abstruc_data
 WHERE (resol > 0 AND resol < 2.5)
   AND (rfactor > 0 AND rfactor < 0.25);
