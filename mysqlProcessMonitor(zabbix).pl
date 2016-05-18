#!/usr/bin/perl
use DBI;

# -------------------------------------------------------------------
# Func   : Main()
# -------------------------------------------------------------------
my $dbuser       = "root";
my $dbpasswd     = "password";
my $dbhost       = "localhost";
my $mysql_socket = "/tmp/mysql.sock";
my $db           = "information_schema";
my $dbport       = '3306';

my $starttime = &get_time();
open( FH, ">>/data/logs/zabbix/mysqlmonitor.log" ) or die $!;
print FH "-" x 80, "\n\n";
print FH "$starttime started\n\n";
my $number = 1;

# connect database
my $dbh = &connet_mysql( $dbhost, $dbport, $db, $dbuser, $dbpasswd );
my $connetdbtime = &get_time();
print FH "$connetdbtime connet mysql succeed!\n";
# execute sql
my $sql1 = qq{select * from PROCESSLIST where TIME>=300 and command<>'Sleep' and not UCASE(info) like 'ALTER TABLE%' and not UCASE(info) like 'CREATE TABLE%%'};
my $sth1 = &execute_sql( $dbh, $sql1 );
my $executsth1time = &get_time();
print FH qq{$executsth1time execute "$sql1" succeed!\n};
# get sql result

while ( my $result_ref = $sth1->fetchrow_hashref() ) {
    my $delim = "";
    foreach ( keys %{$result_ref} ) {
        print FH $delim, $_, "\t", $result_ref->{$_};
        $delim = "\n";
    }
    print FH "\n";
    $number += 1;
}

# end sql
$sth1->finish();
if ( $number == 1 ) {
	print "0\n";
	my $nodotime = &get_time();
	#print "$nodotime empty set\n";
	print FH "$nodotime empty result set\n";
	}
if ( $number > 1 ) {
	  print "1\n";
}
my $endtime = &get_time();
print FH "\n";
print FH "$endtime finised\n\n";
#print "\n";
#print "$endtime finised\n\n";
print FH "-" x 30, "\n\n";
#print "-" x 30, "\n\n";
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
    $mysql_dbh->{AutoCommit} = 0;
    $mysql_dbh->{RaiseError} = 1;
    $mysql_dbh->{PrintError} = 1;
    #$mysql_dbh->do("set names utf8");
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
    my ( $sec, $min, $hour, $day, $mon, $year, $weekday, $yeardate, $savinglightday ) = ( localtime( time + $interval ) );
    $sec  = ( $sec < 10 )  ? "0$sec"  : $sec;
    $min  = ( $min < 10 )  ? "0$min"  : $min;
    $hour = ( $hour < 10 ) ? "0$hour" : $hour;
    $day  = ( $day < 10 )  ? "0$day"  : $day;
    $mon = ( $mon < 9 ) ? "0" . ( $mon + 1 ) : ( $mon + 1 );
    $year += 1900;
    return "$year-$mon-$day $hour:$min:$sec";
}

