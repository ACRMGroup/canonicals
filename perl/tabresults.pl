#!/usr/local/bin/perl
#*************************************************************************
#
#   Program:    tabresults
#   File:       tabresults.perl
#   
#   Version:    V1.0
#   Date:       02.10.95
#   Function:   Turn key residue results from clan into a LaTeX table
#   
#   Copyright:  (c) Dr. Andrew C. R. Martin 1995
#   Author:     Dr. Andrew C. R. Martin
#   Address:    Biomolecular Structure & Modelling Unit,
#               Department of Biochemistry & Molecular Biology,
#               University College,
#               Gower Street,
#               London.
#               WC1E 6BT.
#   Phone:      (Home) +44 (0)1372 275775
#               (Work) +44 (0)171 387 7050 X 3284
#   EMail:      INTERNET: martin@biochem.ucl.ac.uk
#               
#*************************************************************************
#
#   This program is not in the public domain, but it may be copied
#   according to the conditions laid out in the accompanying file
#   COPYING.DOC
#
#   The code may be modified as required, but any modifications must be
#   documented so that the person responsible can be identified. If 
#   someone else breaks this code, I don't want to be blamed for code 
#   that does not work! 
#
#   The code may not be sold commercially or included as part of a 
#   commercial product except as described in the file COPYING.DOC.
#
#*************************************************************************
#
#   Description:
#   ============
#
#*************************************************************************
#
#   Usage:
#   ======
#
#*************************************************************************
#
#   Revision History:
#   =================
#
#*************************************************************************
$InCrit = 0;

while(<>)
{
    chop;
    if($InCrit)
    {
        if(/END ALLCRITICALRESIDUES/)
        {
            $InCrit = 0;
        }
        else
        {
            if(/CLUSTER/)
            {
                ($junk,$clusnum) = split;
            }
            elsif(/WARNING/)
            {
            }
            else
            {
                $resid = substr($_,0,6);
                ($chain,$resnum,$rest) = split(/[ \t\n]+/, $_, 3);
                ($junk,$res) = split(/\(/);
                ($res,$junk) = split(/\)/,$res);

                if($resid ne "")
                {
                    if($res eq "ACDEFGHIKLMNPQRSTVWY")
                    {
                        $Summary{$resid}->[$clusnum] = "*";
                    }
                    elsif($res eq "ACDEFHIKLMNQRSTVWY")
                    {
                        $Summary{$resid}->[$clusnum] = "!(GP)";
                    }
                    elsif($res eq "ACDEGHIKLMNPQRSTV")
                    {
                        $Summary{$resid}->[$clusnum] = "aliph";
                    }
                    elsif($res eq "ACDEHIKLMNQRSTV")
                    {
                        $Summary{$resid}->[$clusnum] = "aliph/!(GP)";
                    }
                    elsif($res eq "ACDEFGHIKLMNPQRSTVWY-")
                    {
                        $Summary{$resid}->[$clusnum] = "*/-";
                    }
                    elsif($res eq "ACDEFHIKLMNQRSTVWY-")
                    {
                        $Summary{$resid}->[$clusnum] = "!(GP)/-";
                    }
                    elsif($res eq "ACDEGHIKLMNPQRSTV-")
                    {
                        $Summary{$resid}->[$clusnum] = "aliph/-";
                    }
                    elsif($res eq "ACDEHIKLMNQRSTV-")
                    {
                        $Summary{$resid}->[$clusnum] = "aliph/!(GP)/-";
                    }
                    else
                    {
                        $Summary{$resid}->[$clusnum] = $res;
                    }
                }
            }
        }
    }
    else
    {
        if(/BEGIN ALLCRITICALRESIDUES/)
        {
            $InCrit = 1;
        }
    }
}

# Print a LaTeX header for the table
print "\\begin{sidewaystable}\n";
print "\\centering\n";
print "\\tiny\n";
print "\\begin{tabular}{|l|";
for($i=0; $i<$clusnum; $i++)
{
    print "l";
}
print "|} \\hline\n";
print "Residue ";
for($i=1; $i<=$clusnum; $i++)
{
    print "& $i ";
}
print "\\\\ \\hline";


# Run through the clusters
foreach $resid (sort keys %Summary)
{
    print "\n";
    print "$resid ";
    for($i=1; $i<= $clusnum; $i++)
    {
        printf "& %-12s ", $Summary{$resid}->[$i];
    }
    print "\\\\";
}
print " \\hline\n";


# End the LaTeX table
print "\\end{tabular}\n";
print "\\caption{\\label{tab:} }\n";
print "\\end{sidewaystable}\n";
