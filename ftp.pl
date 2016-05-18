#!/usr/bin/perl -w
use Net::FTP::Recursive;

#my $dotime = `date +%Y%m%d`;
my $Yesterday = `date -d yesterday +%Y%m%d`;
my $ftp_server = "host";
my $ftp_login = "user";
my $ftp_password = 'password';


my $starttime = &get_time(0);
open( FH, ">>/data/callcenter_backup/ftpdownload.log" ) or die $!;
print "-" x 80, "\n\n";
print FH "-" x 80, "\n\n";
print FH "$starttime started download $Yesterday\'s datas\n\n";
print "$starttime started download $Yesterday\'s datas\n\n";
print "Connecting to FTP server($ftp_server)...\n";
print FH "Connecting to FTP server($ftp_server)...\n";
$ftp = Net::FTP::Recursive->new("$ftp_server", Debug => 0) or die "Cannot connect to $ftp_server:$@\n";
print "Logining by $ftp_login...\n";
print FH "Logining by $ftp_login...\n";
$ftp->login("$ftp_login","$ftp_password") or die "Could not login", $ftp->message;
#$ftp->cwd("/201203") or die "Cannot change working directory ", $ftp->message;
$ftp->binary;
#print "$dotime\n";
chdir "/data/callcenter_backup"; 
$ftp->rget(MatchFiles => "20120528"); 
#$ftp->rget();  
$ftp->quit();
my $endtime = &get_time(0);
print "$endtime download complete...\n";
print FH "$endtime download complete...\n";
print FH "-" x 30, "\n\n";
print "-" x 30, "\n\n";
close FH;

# -------------------------------------------------------------------
# Func   : get time
# Sample :
#          &get_time(0);
# -------------------------------------------------------------------
sub get_time {
    my $interval = $_[0] * 60;
    my ( $sec, $min, $hour, $day, $mon, $year, $weekday, $yeardate,$savinglightday ) = ( localtime( time + $interval ) );
    $sec  = ( $sec < 10 )  ? "0$sec"  : $sec;
    $min  = ( $min < 10 )  ? "0$min"  : $min;
    $hour = ( $hour < 10 ) ? "0$hour" : $hour;
    $day  = ( $day < 10 )  ? "0$day"  : $day;
    $mon  = ( $mon < 9 ) ? "0" . ( $mon + 1 ) : ( $mon + 1 );
    $year += 1900;
    return "$year-$mon-$day $hour:$min:$sec";
}
