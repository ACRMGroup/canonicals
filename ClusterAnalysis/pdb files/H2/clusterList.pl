#!/user/bin/perl

my $data = 'H2_clan.out';

unless ( open (DATA, $data) ) {
	#dies with a message if the file doesn't open
	die "Not able to open $data\n";
}

#saves the data into a single string
my @content = <DATA>;
close DATA;
my $contentString = join ('', @content);

#changes the format of the data in order to use ProFit
my $delete1 = 'NR_CombinedAb_Chothia/';
my $delete2 = '-H50-H58';
my $add     = 'pdb_cut.pdb';

$contentString =~ s/$delete1//g;
$contentString =~ s/$delete2//g;
$contentString =~ s/pdb/$add/g;

#divides the string based on the newline
@content2 = split ("\n", $contentString);
#searches for "BEGIN ASSIGNMENTS"
my $arrayPosition = 0;
while (@content2[$arrayPosition] ne 'BEGIN ASSIGNMENTS'){
	++$arrayPosition;
}

#skips "BEGIN ASSIGNMENTS"
++$arrayPosition;

#sorts the data until it reaches "END ASSIGNMENTS"
while (@content2[$arrayPosition] ne 'END ASSIGNMENTS'){
	#divide a line of data to a number and a name
	my @line = split (' ',@content2[$arrayPosition]);

	#either creates or finds the correct category
	unless ( open (FILE, ">>$line[0]") ){
	print "cannot open $line[0]"; 
	exit;	
	}

	#writes onto the appropriate text file
	print FILE "$line[1]\n";
	close FILE;

	#checks the next array
	++$arrayPosition;
}
exit;


