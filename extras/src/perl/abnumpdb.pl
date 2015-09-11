#!/acrm/usr/local/bin/perl
#*************************************************************************
#
#   Program:    
#   File:       
#   
#   Version:    
#   Date:       
#   Function:   
#   
#   Copyright:  (c) UCL / Dr. Andrew C. R. Martin 2008
#   Author:     Dr. Andrew C. R. Martin
#   Address:    Biomolecular Structure & Modelling Unit,
#               Department of Biochemistry & Molecular Biology,
#               University College,
#               Gower Street,
#               London.
#               WC1E 6BT.
#   Phone:      +44 (0)207 679 7034
#   EMail:      andrew@bioinf.org.uk
#               martin@biochem.ucl.ac.uk
#   Web:        http://www.bioinf.org.uk/
#               
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
use strict;
#use CGI;
umask 0000;

$::kabatnum = "/home/bsm/martin/abnum/installed/numbering/kabatnum.pl";

#$::cgi = new CGI;
$::wkdir = "/tmp/HB_$$";
`mkdir $::wkdir`;

my $scheme = "-c";
my $output = "output.txt";
my $pdb    = $ARGV[0];

Process($pdb, 1, $scheme, $output, 0);

`rm -rf $::wkdir`;

#*************************************************************************
sub Process
{
    my($pdb, $plain, $scheme, $output, $dofile) = @_;
    my($results, $pdbfile);

    $pdbfile = "$::wkdir/in.pdb";
    if(GrabPDB($pdbfile, $pdb))
    {
        print STDERR "$::kabatnum $scheme $output $pdbfile 2>&1\n";
        $results = `$::kabatnum $scheme $pdbfile 2>&1`;
        if($results =~ /failed/)
        {
            ErrorPage("$results" . "\nCurrently there is a problem with PDB files having a residue number of zero.");
        }
        else
        {
            if(!$plain)
            {
                if($dofile)
                {
                    print $::cgi->header(-type=>'chemical/x-pdb');
                }
                else
                {
                    print $::cgi->header(-type=>'text/plain');
                }
            }
            print $results;
        }
    }
    else
    {
        ErrorPage("Either the PDB file you specified did not exist, or contained no ATOM records");
    }
}

#*************************************************************************
# sub GrabPDB(STRING $outfile, STRING $fnm)
# -----------------------------------------
# Dump PDB file read from the form into a temp file identified by $fnm
#
# 16.07.04 Original   By: ACRM
#
sub GrabPDB
{
    my ($outfile, $filename) = @_;
    my $ok = 0;
    open(PDB, $filename);
    open(TMPFILE, ">$outfile") ||
        ErrorPage("Internal error: Unable to write PDB file");
    while(<PDB>)
    {
        if(/^ATOM/)
        {
            print TMPFILE;
            $ok = 1;
        }
    }
    close TMPFILE;

    return($ok);
}

#*************************************************************************
sub PrintHeader
{
    # Start the new HTML page with the actual submission form
    print $::cgi->header;

    print <<_EOF;
<html>
<head>
   <title>AbNum results</title>
   <link rel='stylesheet' href='/bo.css' />
</head>

<body>
<h1>Abnum: PDB numbering</h1>
_EOF
}

#*************************************************************************
sub PrintTrailer
{
    print <<_EOF;

</body>
</html>

_EOF
}

#*************************************************************************
# sub ErrorPage(STRING $text)
# ---------------------------
# Display an error page containing the specified text.
#
# 10.02.99 Original   By: ACRM
# 18.12.08 Changed to write to STDERR and removed HTML
sub ErrorPage
{
    my($text) = @_;


    print STDERR <<__EOF;
$pdb
$text
__EOF

    exit 0;
}

