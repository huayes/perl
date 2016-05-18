#!/usr/bin/perl
use strict;
use warnings;
use Net::SSH::Expect;
use DBI;


# -------------------------------------------------------------------
# Func   : Main()
# -------------------------------------------------------------------
my $dbhost        = "192.168.0.212";
my $dbport        = '3306';
my $db            = "test";
my $dbuser        = "ssh";
my $dbpasswd      = "password";

my $user          = 'user';
my $pass          = 'password';
my $root_pass     = 'password';
#my $new_user_pass = '1234';
my $sshport       = '22';
my $logpath       = "./mysqlmonitor.log";

# connect database
my $dbh = &connet_mysql($dbhost,$dbport,$db,$dbuser,$dbpasswd);
# execute sql
my $sql = qq{select * from users};
my $sth = &execute_sql($dbh,$sql);

while ( my $result_ref = $sth->fetchrow_hashref() ) {
	
	&ssh_host( $result_ref->{"Web Site"}, "$sshport", $result_ref->{"Login Name"}, $result_ref->{"Password"}, $result_ref->{"NewPassword"});
}



# end sql
$sth->finish();

# disconnect from database
$dbh->disconnect();


sub ssh_host() {
    my ( $host, $sshport, $user, $pass,$new_user_pass ) = @_;
    my $ssh = Net::SSH::Expect->new(
        host        => $host,
        port        => $sshport,
        password    => $pass,
        user        => $user,
        no_terminal => 0,
        raw_pty     => 1,
        timeout     => 6,
    );

	open FH, ">> ./changepasswd.log" or die $!;
	
    #print FH "-" x 80, "\n";
    my $start_time = &get_time(0);
    print "$start_time - $host, $sshport, $user, $pass,$new_user_pass\n";
    print FH "$start_time - $host, $sshport, $user, $pass,$new_user_pass,";
    $ssh->debug(0);
    
         
    
    if ( !$ssh->run_ssh() )
	{   
    	print FH "SSH Connect Fail: $!";
    	die "SSH Connect Fail: $!";
	}
	else
	{
    	print FH "SSH Connect Sucess";
		
	}

    $ssh->waitfor( 'password:\s*$', 6 );
    print $ssh->before();
    print $ssh->match();
    print $ssh->after();

    $ssh->send($pass);
    $ssh->waitfor( '#\s*', 6 );
    print $ssh->before();
    print $ssh->match();
    print $ssh->after();
    
    
    $ssh->send("passwd $user");
    $ssh->waitfor( 'password:\s*$', 6 );
    print $ssh->before();
    print $ssh->match();
    print $ssh->after();
    
    $ssh->send("$new_user_pass");
    $ssh->waitfor( 'password:\s*$', 6 );
    print $ssh->before();
    print $ssh->match();
    print $ssh->after();

    $ssh->send("$new_user_pass");
    $ssh->waitfor( '#\s*', 6 );
    print $ssh->before();
    print $ssh->match();
    print $ssh->after();

    #print "id\n";
#    my $ls = $ssh->exec("id");
#    print "$ls\n";
    
    $ssh->send("id");
    print $ssh->read_all();

    print "\nClose ssh:";
    print $ssh->close();
    print "\n";
    close FH;
}



# -------------------------------------------------------------------
# Func   : Connect Database
# Sample :
#          &connet_mysql($dbhost,$dbport,$db,$dbuser,$dbpasswd);
# -------------------------------------------------------------------
sub connet_mysql {
	# setup database connection variables
	my ($dbhost,$dbport,$db,$dbuser,$dbpasswd) = @_;
	my $driver = "mysql";
	# connect to database
	my $dsn = "DBI:$driver:database=$db;host=$dbhost;port=$dbport";
	my $mysql_dbh = DBI->connect($dsn,$dbuser,$dbpasswd) or die "Connect to mysql database error:". DBI->errstr;
	$mysql_dbh->{AutoCommit} = 0;
	$mysql_dbh->{RaiseError} = 1;
	$mysql_dbh->{PrintError} = 1;
	#$mysql_dbh->do("set names gbk");
	return $mysql_dbh;
}




# -------------------------------------------------------------------
# Func   : Execute SQL
# Sample :
#          &execute_sql($dbh,$sql);
# -------------------------------------------------------------------
sub execute_sql {
	my ($dbh, $sql) = @_;
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
