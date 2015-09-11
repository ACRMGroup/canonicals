#! /acrm/usr/local/bin/perl

# my $string = "[HY]P[ST][DY]";
# my $string = "A[BC]D[EF]";
my $string = "ABCD[EF]GHI[IJ]";


my @parts = split(//, $string);

$flag = 0;
foreach $part (@parts)
{
        if($part =~ /\[/)
        {
                $flag = 1;
                next;
        }

        if($part =~ /\]/)
        {
                if($#temp != -1)
                {
                        @target = @temp;
                        @temp = ();
                }

                $flag = 2;
                next;
        }

        # Have not encountered any "[" yet. So keep adding to @target without worrying about anything.

        if ($flag == 0)
        {
                push(@target, $part);
                next;
        }

        # Encountered "[" but havent seen the "]" yet.
        # Need to add more array elements because we are inside the "[]". Each character inside "[]" makes a new array element in @temp.
        # For e.g. if we are through with "[HY]P" and are now at "S", then we'd first add HPS and YPS to @temp, then HPT and YPT.
        # Need to use @target which would have HP and YP at this time

        if ($flag == 1)
        {
                foreach $element (@target)
                {
                        $newString = $element.$part;
                        push (@temp, $newString);
                }

                if($#target == -1)
                {
                        push(@temp, $part);
                }
        }

        # Just saw "]" or saw "]" earlier but haven't seen another "[" yet.
        # Need to append the character to existing elements in @target. No new array elements needed.
        # For e.g. H and Y are in @target. At P, we'd have HP and YP.
        # At the end of "[HY]", @temp has H and Y. Assign @temp to @target so that we can use the latest list of array elements for appending
        # this character. Latest list implies @temp obtained from when $flag is 1 in which we would have just added new elements to this array.

        if ($flag == 2)
        {
                #@target = @temp;
                foreach $element (@target)
                {
                        $newString = $element.$part;
                        push (@temp, $newString);
                }
                @target = @temp;
                @temp = ();

        }
}

if($#temp != -1)
{
        @target = @temp;
}

# Print all the elements.

foreach $part (@target)
{
   print $part, "\n";
}
