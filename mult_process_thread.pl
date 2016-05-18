#!/usr/bin/perl
use strict;
use warnings;
use threads;
use Thread::Semaphore;
use POSIX ":sys_wait_h";
##==number of zombies pro==
my $zombies = 0;
my $max_thread = 4;
my $semaphore  = Thread::Semaphore->new ($max_thread);
my $startday   = 20110615;
my $endday     = 20110617;
my $cdrfilepath = "/home/shliang/cdrfile/";
#my $begintime  = time();
###==get the child signal==
$SIG{CHLD} = sub { $zombies++ };

for ( my $day = $startday ; $day <= $endday ; $day++ ) {
##==fork a new process==
    my $pid = fork();
    if ( !defined($pid) ) {
        print "Error in fork:$!";
        exit 1;
    }
    if ( $pid == 0 ) {
        my @hoursarry =
          qw(00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23);
        foreach (@hoursarry) {
            $semaphore->down(); #p操作***执行P操作P（S）时信号量S的值减1，若结果不为负则P（S）执行完毕，否则执行P操作的进程暂停以等待释放
            #print "${$semaphore}\n"; #信号灯数量
            my $thread = threads->create( \&sub1, $day, $_ );            
            $thread->detach();# 剥离线程，不关心返回值，系统自动回收资源
        }

        &Wait2Quit();

        sub sub1 {
            my ( $day, $hour ) = @_;
            opendir( AA, $cdrfilepath );
            my  @cdrfilearry = grep { /.+GW.+$day$hour.+/ } readdir(AA);
            closedir(AA);
            #print "@cdrfilearry";
            open( BB, ">>$day" ) or die "can't open file:$!";
            my $counter = 0;
            foreach my $filename (@cdrfilearry) {
                chomp $filename;
                #print "$filename\n";
                open( IN, "gzip -dc $cdrfilepath$filename|" );
                while (<IN>) {
                    if ( $_ =~ /a77.photo.store.qq.com/ ) {
                        # print $_;
                        $counter++;
                    }
                }
                close IN;
            }
            print BB "$day$hour:$counter\n";
            close BB;
            $semaphore->up();
        }

        sub Wait2Quit {
            #print "Waiting to quit...\n";
            my $num = 0;
            while ( $num < $max_thread ) {
# 尝试获取信号量，当能够获取到最大线程数个信号量时，表示所有线程都结束了
                $semaphore->down();
                $num++;
                #               print "$num thread quit.\n";
            }
            #       print "All $max_thread thread quit.\n";
        }
        exit 0;
    }
##==if need to collect zombies==
    if ( $zombies > 0 ) {
        while ( waitpid( -1, WNOHANG ) > 0 ) { ##-1监听所有进程状态
            $zombies--;
        }
    }
    sleep(1);#1 secondsfork a proce 
}
#my $endtime  = time();
#print scalar($endtime-$begintime),"\n";
exit 0;
