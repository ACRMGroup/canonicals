#! /acrm/usr/local/bin/perl

# my $string = "[HY]P[ST][DY]";
# my $string = "A[BC]D[EF]";
my $string = "ABCD[EF]GHI[IJ]";

my @parts = split(//, $string);

foreach $part (@parts)
{
   if($part =~ /\[/)
   {
      $flag = 1;
      next;
   }

   if($part =~ /\]/)
   {
      if($#after != -1)
      {
         @before = @after;
         @after = ();
      }

      $flag = 0;
      next;
   }

   if($part =~ /[A-Z]/)
   {
      if( ($#before == -1) || ( ($#before == 0) && ($flag == 1) ) )
      {
         push(@before, $part);
         next;
      }

      foreach $element (@before)
      {
         $afterString = $element.$part;

         if($flag == 1)
         {
            push(@after, $afterString);
         }
         elsif($flag == 0)
         {
            $element = $afterString;
         }
      }
   }

} # End of foreach $part (@parts)


# Print all the elements.

foreach $part (@before)
{
   print $part, "\n";
}
