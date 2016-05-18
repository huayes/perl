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
            $semaphore->down(); #p����***ִ��P����P��S��ʱ�ź���S��ֵ��1���������Ϊ����P��S��ִ����ϣ�����ִ��P�����Ľ�����ͣ�Եȴ��ͷ�
            #print "${$semaphore}\n"; #�źŵ�����
            my $thread = threads->create( \&sub1, $day, $_ );            
            $thread->detach();# �����̣߳������ķ���ֵ��ϵͳ�Զ�������Դ
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
# ���Ի�ȡ�ź��������ܹ���ȡ������߳������ź���ʱ����ʾ�����̶߳�������
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
        while ( waitpid( -1, WNOHANG ) > 0 ) { ##-1�������н���״̬
            $zombies--;
        }
    }
    sleep(1);#1 secondsfork a proce 
}
#my $endtime  = time();
#print scalar($endtime-$begintime),"\n";
exit 0;
