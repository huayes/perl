#!/usr/bin/perl
use strict;
use warnings;
use POSIX ":sys_wait_h";
my $num_proc=0;##==number of pro==
my $num_collect=0;##==number of collected==
my $collect;
$SIG{CHLD} = sub {$num_proc--};###==get the child signal==
my $i=1;
my $cdrfilepath = "/home/shliang/cdrfile/";
#my $startday=20110617;
#my $endday  =20110617;
my @days=qw(20110616 20110617);
foreach my $day(@days){
#for(my $day=$startday;$day<=$endday;$day++){
  open( BB, ">>$day" ) or die "can't open file:$!";
  my @hoursarry = qw(00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23);
   foreach my $hours(@hoursarry) {
#for(my $i=1;$i<100;$i++){###for three child
my $pid = fork();##==fork a new process==
if(!defined($pid)){
        print "Error in fork:$!";
        exit 1;
}
if($pid == 0){
        ###==child proc ==
       # print "Child:$day$hours My pid = $$\n";
        #for(my $n=0;$n<2;$n++){
  #print "$n\n"; 
        #}
        &sub1($day,$hours);
        exit 0; ##signal for colect
}
$num_proc++;
#print "$i,$num_proc,$num_collect\n";
##==if need to collect zombies==
if(($i-$num_proc-$num_collect)>0){
        while(($collect=waitpid(-1,WNOHANG))>0){
                $num_collect++;
        }
}
do{
sleep(1);
}until($num_proc<3);###max three children on the same time
$i++;
  }
  #print BB "$day:$counter\n";
  close BB;
#}
}
exit 0;

sub sub1{
	my ($day,$hours)=@_;
 opendir( AA, $cdrfilepath );
           my @cdrfilearry = grep { /.+GW.+$day$hours.+/ } readdir(AA);
           #print "@cdrfilearry\n";
           closedir(AA);
            #print "@cdrfilearry";
            #open( BB, ">>$day" ) or die "can't open file:$!";
            my $counter = 0;
            foreach my $filename (@cdrfilearry) {
                chomp $filename;
                print "$filename\n";
                open( IN, "gzip -dc $cdrfilepath$filename|" );
                while (<IN>) {
                    if ( $_ =~ /a77.photo.store.qq.com/ ) {
                        # print $hours;
                        $counter++;
                        #print BB $_;
                    }
                }
                close IN;
              }
            print BB "$day$hours:$counter\n";
            #$result{$day$hours}=$counter;
            #close BB;
        #sleep(5);
         # print "Child:$counter end\n";
       }
