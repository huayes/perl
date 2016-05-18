#!/usr/bin/perl
###查域名对应的手机号码##
use strict;
use warnings;
use POSIX ":sys_wait_h";
my $num_proc=0;##==number of pro==
my $num_collect=0;##==number of collected==
my $collect;
$SIG{CHLD} = sub {$num_proc--};###==get the child signal==
my $i=1;
my $cdrfilepath = "/sas/NokiaSAS/destdat/";
my $startday=20110615;
my $endday  =20110617;
for(my $day=$startday;$day<=$endday;$day++){
  #my @hoursarry = qw(00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23);
  #my @urlsarry =qw(zns60.com);
   my @urlsarry =qw(008.downnokia.com 008.nokia-data.com 008.nokia-updata.com 109.236.81.202:8080 173.245.79.90:8080 184.105.203.98);
    open( BB, ">>$day" ) or die "can't open file:$!";
   #foreach my $hours(@hoursarry) {
    foreach my $urls(@urlsarry) {
#for(my $i=1;$i<100;$i++){###for three child
my $pid = fork();##==fork a new process==
if(!defined($pid)){
        print "Error in fork:$!";
        exit 1;
}
if($pid == 0){
        ###==child proc ==
        print "Child:$day My pid = $$\n";
        #for(my $n=0;$n<2;$n++){
  #print "$n\n"; 
        #}
          opendir( AA, $cdrfilepath );
           my @cdrfilearry = grep { /.+GW.+$day.+/ } readdir(AA);
           #print "@cdrfilearry\n";
           closedir(AA);
            #print "@cdrfilearry";
            #open( BB, ">>$day" ) or die "can't open file:$!";
            #my $counter = 0;
            foreach my $filename (@cdrfilearry) {
                chomp $filename;
               # print "$filename\n";
                print "$urls\n";
                open( IN, "gzip -dc $cdrfilepath$filename|" );
                while (<IN>) {
                    if ( $_ =~ /$urls/ ) {
                        my @files = split ",",$_;
                        # print $hours;
                        #$counter++;
                        print BB "$files[5]>$urls\n";
                        exit 0;
                    }
                }
                close IN;
            }
            #print BB "$day$hours:$counter\n";
            #close BB;
        #sleep(5);
#        print "Child:$counter end\n";
        exit 0; ##signal for colect
}
$num_proc++;
#print "$i,$num_proc,$num_collect\n";
##==if need to collect zombies==
if(($i-$num_proc-$num_collect)>0){
        while(($collect=waitpid(-1,WNOHANG))>0){  ##collect exit process
                $num_collect++;
        }
}
do{
sleep(1);
}until($num_proc<3);###max three children on the same time
$i++;
  }
  close BB;
}
exit 0;