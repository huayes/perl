#!/usr/bin/perl
use LWP::Simple;

# -------------------------------------------------------------------
# Func   : Main()
# -------------------------------------------------------------------

my $username = 'user';
my $password = 'password';
my $from     = "8888";
my $to       = $ARGV[0];
my $title    = $ARGV[1];
my $content  = $ARGV[2];
my $palavra  = "OK:";

open( FILE, ">>/data/log/zabbix/sendsms.log" ) || die("Could not open file");

my $result =  get("http://219.133.59.101/GsmsHttp?username=$username&password=$password&from=$from&to=$to&content=$content");

#print "$result\n";

if ( !$result ) {
    my $time1 = &get_time(0);

    #print "Error! SMS was not sent!\n";
    print FILE "$time1 Error! SMS was not sent!\n";
}
elsif ( $result =~ /$palavra/i ) {
    my $time2 = &get_time(0);

    #print "SMS sent successfully\n";
    print FILE "$time2 SMS sent successfully! Result:$result";
}
else {
    my $time3 = &get_time(0);

    #print "SMS was not sent!\n";
    print FILE "$time3 SMS was not sent!\n";
}
close FILE;

# -------------------------------------------------------------------
# Func   : get time
# Sample :
#          &get_time();
# -------------------------------------------------------------------
sub get_time {
    my $interval = $_[0] * 60;
    my ( $sec, $min, $hour, $day, $mon, $year, $weekday, $yeardate,
        $savinglightday )
      = ( localtime( time + $interval ) );
    $sec  = ( $sec < 10 )  ? "0$sec"  : $sec;
    $min  = ( $min < 10 )  ? "0$min"  : $min;
    $hour = ( $hour < 10 ) ? "0$hour" : $hour;
    $day  = ( $day < 10 )  ? "0$day"  : $day;
    $mon = ( $mon < 9 ) ? "0" . ( $mon + 1 ) : ( $mon + 1 );
    $year += 1900;
    return "$year-$mon-$day $hour:$min:$sec";
}

