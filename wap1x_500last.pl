#!/usr/bin/perl
open(FILE3,">/tmp/500_shliang.dat") or die "can not open file:$!";
print FILE3 "sum\twap1x_sum\twap1x_500_sum\n";
for(my $date=20110521;$date <=20110523;$date++)
{
	my $sum=0,$wap1x_sum=0,$wap1x_500_sum=0;
	open(FILE2,">/tmp/${date}.500.dat") or die "can not open file:$!";
  my $filelist=`ls /sas/NokiaSAS/destdat/*GW*$date*`;
  #$filelist =~ s/\n/ /g;
  my @files = split "\n",$filelist;
  #print @files;
  my $i=0;
  foreach my $file (@files)
  {
        `zcat $file>/tmp/${date}.tmp.shliang`;
        print "$i $file\n";
        open(FILE,"/tmp/${date}.tmp.shliang") or die "can not open $file:$!";
        while(<FILE>)
        {
                my $line=$_;
                $sum++;
                if($line =~ /,[1-4],\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/)
                {
                	$wap1x_sum++;
                	if($line =~ /,500,[1-4],\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/){
                		$wap1x_500_sum++;
                		print FILE2 $line;
                		}
                }
               }
        close FILE;
        $i++;
        }  
  print FILE3 "$sum\t$wap1x_sum\t$wap1x_500_sum\n";
  unlink("/tmp/${date}.tmp.shliang");
       }
close FILE3;
close FILE2;

