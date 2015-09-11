#!/usr/bin/perl -s
#*************************************************************************
#
#   Program:    
#   File:       
#   
#   Version:    V1.0
#   Date:       11.09.15
#   Function:   Script to create a CLAN file
#   
#   Copyright:  (c) Dr. Andrew C. R. Martin, UCL, 2011
#   Author:     Dr. Andrew C. R. Martin
#   Address:    Institute of Structural and Molecular Biology
#               Division of Biosciences
#               University College
#               Gower Street
#               London
#               WC1E 6BT
#   EMail:      andrew@bioinf.org.uk
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
#   Expects the template files to be present in the config sub-dir
#*************************************************************************
#
#   Revision History:
#   =================
#
#*************************************************************************
use strict;

use FindBin;
use Cwd qw(abs_path);
my $configDir=abs_path("$FindBin::Bin/config");

my $limit = (defined($::limit)?$::limit:0);

my $dir  = shift @ARGV;
my $loop = shift @ARGV;

my ($start, $stop) = FindCDRBounds($loop);
my @pdblist        = ReadDirectory($dir);
my $header         = ReadClanHeader($configDir, $loop);

WriteClanFile($header, $loop, $start, $stop, $limit, @pdblist);

sub WriteClanFile
{
    my ($header, $loop, $start, $stop, $limit, @pdblist) = @_;
    my $filename = "$loop.clan";
    my $count    = 0;
    if(open(FILE, '>', $filename))
    {
        print FILE $header;

        foreach my $file (@pdblist)
        {
            last if($limit && (++$count > $limit));
            print FILE "loop $file $start $stop\n";
        }
        close FILE;
    }
    else
    {
        die "Can't write CLAN file: $filename";
    }
}



sub ReadClanHeader
{
    my($configDir, $loop) = @_;

    my $filename = "$configDir/$loop.clan";
    die "Clan header config doesn't exist: $filename" if(! -e $filename);

    my $content = `cat $filename`;
    return($content);
}

sub ReadDirectory
{
    my ($dir) = @_;

    my $listing = `\\ls -1 $dir`;
    my @files = split(/\n/, $listing);
    foreach my $file (@files)
    {
        $file = "$dir/$file";
    }
    return(@files);
}



sub FindCDRBounds
{
    my ($loop) = @_;
    my ($start, $stop);

    if($loop eq 'L1')
    {
        $start = 'L24';
        $stop  = 'L34';
    }
    elsif($loop eq 'L2')
    {
        $start = 'L50';
        $stop  = 'L56';
    }
    elsif($loop eq 'L3')
    {
        $start = 'L89';
        $stop  = 'L97';
    }
    elsif($loop eq 'H1')
    {
        $start = 'H26';
        $stop  = 'H35';
    }
    elsif($loop eq 'H2')
    {
        $start = 'H50';
        $stop  = 'H58';
    }
    elsif($loop eq 'H3')
    {
        $start = 'H95';
        $stop  = 'H102';
    }

    return($start, $stop);
}
