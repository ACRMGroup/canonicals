#! /usr/bin/perl

use XML::DOM;
use strict 'vars';

# ---------- GLOBAL VARIABLES DECLARATION SECTION ----------

   my $inputFilename="";
   my $outputFilename="";
   my $line="";
   my $parser;
   my $doc;
   my $antibodyPDB;
   my $name;
   my $pdb;
   my $pdbID;
   my $frag;
   my $fragValue;

# ------ END OF GLOBAL VARIABLES DECLARATION SECTION -------

if($#ARGV < 0)
{
   print "\nUsage: ./parse_xml_file.pl <Input file> <Output file (Optional)\n\n";
   exit(0);
}

$inputFilename=$ARGV[0];

if($#ARGV == 1)
{
   $outputFilename=$ARGV[1];
}

$parser=XML::DOM::Parser->new();
$doc=$parser->parsefile($inputFilename);

foreach $antibodyPDB ( $doc->getElementsByTagName('antibody') )
{
   $pdbID = $antibodyPDB->getAttribute('pdb');
   $frag = $antibodyPDB->getElementsByTagName('frag');
   $fragValue = $frag->item(0)->getFirstChild->getNodeValue;

   if( ($fragValue =~ /FV/i) || ($fragValue =~ /FAB/i) )
   {
      $pdbID = lc($pdbID);
      print $pdbID,"\n";
   }
}
