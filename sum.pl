#!/usr/bin/perl
for(my $date=20110519;$date <=20110525;$date++)
{
	open(FILE2,">/tmp/${date}.url.dat") or die "can not open file:$!";
  my $filelist=`ls /sas/NokiaSAS/destdat/*GW*$date*`;
  #$filelist =~ s/\n/ /g;
  my @files = split "\n",$filelist;
  #print @files;
  my $i=1;
  foreach my $file (@files)
        {
        `zcat $file>/tmp/${date}.tmp.shliang`; ###zcat for linux gzcat for solaris
        print "$i $file\n";
        open(FILE,"/tmp/${date}.tmp.shliang") or die "can not open $file:$!";
        while(<FILE>)
             {
                my $line=$_;
               
                if($line =~ /push.sj3g88.com/)
                {
                		print FILE2 $line;
                		}
             }
             close FILE;
             $i++;
        }
   unlink("/tmp/${date}.tmp.shliang"); 
   close FILE2;
}  
