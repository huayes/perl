#!/usr/bin/perl
use strict;
use warnings;
use POSIX ":sys_wait_h";
##==number of pro==
my $num_proc=0;
##==number of collected==
my $num_collect=0;
my $collect;
###==get the child signal==
$SIG{CHLD} = sub {$num_proc--};

###for test#####
my $dir="/home/shliang/cdrfile/";
my $temp=2011061702;
opendir(AA,$dir);
my @list = grep {/.+GW.+$temp.+/} readdir(AA);
closedir (AA);
####end########

for(my $i=1;$i<100;$i++){
##==fork a new process==
my $pid = fork();
if(!defined($pid)){
        print "Error in fork:$!";
        exit 1;
}
if($pid == 0){
        ###==child proc ==
        print "Child:My pid = $$\n";
        #for(my $n=0;$n<2;$n++){
  #print "$n\n"; 
        #}
        foreach my $filename ( @list ){
        chomp $filename;
       open (IN, "gzip -dc $dir$filename|");
      while(<IN>){
       if($_ =~/a77.photo.store.qq.com/){
       print "$.\n";
}
}
}
close IN;
        sleep(5);
        #print "Child:end\n";
        exit 0;
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
}until($num_proc<3);
#print "$i,$num_proc,$num_collect\n";
}
exit 0;