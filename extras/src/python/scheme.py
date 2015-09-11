#!/usr/bin/env python
#************************************************************#
#                                                            #
#    Author: Jacob Hurst                                     #
#    File name: scheme.py                                    #
#    Date: Wednesday 4 Mar 2009                              #
#    Description: sets up scheme data.                      #
#                                                            #
#************************************************************#

class ChothiaScheme(object):
    def __init__(self, config_file="/home/bsm2/jacob/projects/acaca/config/chothianums.dat"):
        fin = open(config_file)
        lines = fin.readlines()
        count = 0
        self.chothia_nums = {} 
        for line in lines:
            parts = line.split()
            self.chothia_nums[parts[0]] = count
            count = count + 1
    ##******************************************************#
    def compare(self, a, b):
        c = cmp(self.chothia_nums[a], self.chothia_nums[b])
        if c != 0:
                return c
        return cmp(a, b)

    ##******************************************************#
    def hope_cmp(self, another_dic):
        for k in sorted(another_dic.keys(),cmp=self.compare):
            yield k, another_dic[k]

if __name__ == "__main__":
    well = {'L3':1,'L7':2,'L4':1}
    cS = ChothiaScheme()
    for key, data in cS.hope_cmp(well):
        print key, data
          
