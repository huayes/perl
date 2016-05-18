#!/usr/bin/perl
use strict;
use warnings;
#use List::Util qw/sum/;
use POSIX ":sys_wait_h";
#my @len;
###number of proc##
my $num_proc = 0;
###number of collected##
my $num_collect = 0;
my $collect;
###get the child signal###
$SIG{CHLD} = sub {$num_proc--};
my $counter = 0;
my @concurrency = qw(1 2 );
open( BB, ">>test.UP_TestSelect_Benchmark" ) or die "can't open file:$!";
print BB "concurrency \t numofqueries \t averagetime\n";
foreach my $concurrency(@concurrency){ 
#open( BB, ">>test.UP_TestSelect_1_${concurrency}_102400_Benchmark" ) or die "can't open file:$!";
#print BB "concurrency \t numqueries \t averagetime\n";
#print BB "1 \t 2 \t 3";
#for (my $i=0;$i<2;$i++){
###fork a new process##
my $pid = fork();
if (!defined($pid)){
print "Error in fork:$!";
exit 1;
}
if($pid==0){
###child proc##
print "$concurrency\n";
#print "Child $counter: My pid = $$\n";
#sleep(5);
#print "Child $counter: end\n";
my $mysqlslap = "mysqlslap -uroot -pxxxx -C --number-of-queries=102400 --concurrency=$concurrency --iterations=3 --query='call test.UP_TestSelect'|grep 'Average number of seconds'";
open I, "$mysqlslap |" || die "Cannot open pipe";
#my @mysqld;
while(<I>){
# $_ =~ /Average number of seconds/;
$_  =~	/(\d+\.\d+)/;
#my @line = grep { /queries:/ } $_;
#@mysqld = split(/\s+/, $_);  
print BB "$concurrency \t 102400 \t $1\n"; 
#print "$1\n";
#     #	 }
    }
close I;
sleep 1;
exit 0;
}
#print "$num_proc\n";
#print "$counter-$num_proc-$num_collect\n";
$num_proc++;
#print "$counter-$num_proc-$num_collect\n";
# @len=$mysqld[8];
#print "@len\n";
#print "$sum\n";
#print "$avg\n";
### if need to collect zombies##
if(($counter-$num_proc-$num_collect)>0){
while(($collect=waitpid(-1,WNOHANG))>0){
$num_collect++;
}
}
#print "$counter-$num_proc-$num_collect\n";
do{
sleep(1);
}until ($num_proc<1);
$counter++;
#}
}
close BB;
exit 0;
