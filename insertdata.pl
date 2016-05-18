#!/usr/bin/perl
use DBI;

# -------------------------------------------------------------------
# Func   : Main()
# -------------------------------------------------------------------
my $dbuser       = "root";
my $dbpasswd     = "password";
my $dbhost       = "localhost";
my $mysql_socket = "/tmp/mysql.sock";
my $db           = "dmusp";
my $dbport       = '3306';

my $starttime = &get_time();
open( FH, ">>./inservalue.log" ) or die $!;
print "-" x 80, "\n\n";
print FH "-" x 80, "\n\n";
print "$starttime started\n\n";
print FH "$starttime started\n\n";
my $a = 0;
my $b = 0;
my $c = 0;

# connect database
my $dbh = &connet_mysql( $dbhost, $dbport, $db, $dbuser, $dbpasswd );
my $connetdbtime = &get_time();
print "$connetdbtime connet mysql succeed!\n";
print FH "$connetdbtime connet mysql succeed!\n";

open( FILE, "182.txt" ) or die $!;
while (<FILE>) {
    chomp;
    my $sql1 = qq{select Phone from `ChannelBlackList_2012-01-20` where Phone='$_'};
    my $sql2 = qq{insert into `ChannelBlackList_2012-01-20` (Phone,UpdateTime) values ('$_',now())};
    my $sth1 = &execute_sql( $dbh, $sql1 );
    my $result_ref = $sth1->fetchrow_hashref();
    if ( $result_ref->{Phone} == $_ ) {
        $b++;
    }
    else {
        my $sth2 = &execute_sql( $dbh, $sql2 );
        $sth2->finish();
        $c++;
    }

    # end sql
    $sth1->finish();
    $a++;
    
    if ( $a % 1000 == 0 ){
        my $mytime=&get_time();
        print "$mytime $a\n";
    }
}

print FH "total=$a\t\tskip=$b\t\tinsert=$c\n";
print "total=$a\t\tskip=$b\t\tinsert=$c\n";
close FILE;

my $endtime = &get_time();
#print FH "\n";
print FH "$endtime finised\n\n";
print "\n";
print "$endtime finised\n\n";
print FH "-" x 30, "\n\n";
print "-" x 30, "\n\n";
close FH;

# disconnect from database
$dbh->disconnect();

# -------------------------------------------------------------------
# Func   : Connect Database
# Sample :
#          &connet_mysql($dbhost,$dbport,$db,$dbuser,$dbpasswd);
# -------------------------------------------------------------------
sub connet_mysql {
    # setup database connection variables
    my ( $dbhost, $dbport, $db, $dbuser, $dbpasswd ) = @_;
    my $driver = "mysql";
    # connect to database
    my $dsn = "DBI:$driver:database=$db;host=$dbhost;mysql_socket=$mysql_socket;port=$dbport";
    my $mysql_dbh = DBI->connect( $dsn, $dbuser, $dbpasswd ) or die "Connect to mysql database error:" . DBI->errstr;
    return $mysql_dbh;
}

# -------------------------------------------------------------------
# Func   : Execute SQL
# Sample :
#          &execute_sql($dbh,$sql);
# -------------------------------------------------------------------
sub execute_sql {
    my ( $dbh, $sql ) = @_;
    my $sth = $dbh->prepare($sql);
    $sth->execute();
    return $sth;
}

# -------------------------------------------------------------------
# Func   : get time
# Sample :
#          &get_time();
# -------------------------------------------------------------------
sub get_time {
    my $interval = $_[0] * 60;
    my ( $sec, $min, $hour, $day, $mon, $year, $weekday, $yeardate,$savinglightday ) = ( localtime( time + $interval ) );
    $sec  = ( $sec < 10 )  ? "0$sec"  : $sec;
    $min  = ( $min < 10 )  ? "0$min"  : $min;
    $hour = ( $hour < 10 ) ? "0$hour" : $hour;
    $day  = ( $day < 10 )  ? "0$day"  : $day;
    $mon = ( $mon < 9 ) ? "0" . ( $mon + 1 ) : ( $mon + 1 );
    $year += 1900;
    return "$year-$mon-$day $hour:$min:$sec";
}
