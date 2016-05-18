#!/usr/bin/perl
use strict;
use warnings;
use DBI;
use Net::SSH::Expect;
# -------------------------------------------------------------------
# Func   : Main()
# -------------------------------------------------------------------
my $dbuser        = "root";
my $dbpasswd      = "password";
my $dbhost        = "localhost";
my $db            = "information_schema";
#my $db            = "u6";
my $dbport        = '3306';
my $user          = 'user';
my $pass          = 'password';
my $root_pass     = 'password';
my $new_user_pass = 'password';
my $sshport       = '22';
# connect database
my $dbh = &connet_mysql($dbhost,$dbport,$db,$dbuser,$dbpasswd);
# execute sql
my $sql = qq{select * from PROCESSLIST where TIME>=300 and command='Sleep'};
#my $sql = qq{select Account,`Login Name`,Password,`Web Site` from user where Account="linux" and `Login Name`="root" };
my $sth = &execute_sql($dbh,$sql);
# get sql result
while ( my $result_ref = $sth->fetchrow_hashref() ) {
#my $delim = "";
#foreach ( keys %{$result_ref} ) {
#print $_;
#print $delim,$_,"=",$result_ref->{$_};
#print $result_ref->{"Login Name"};
#print $result_ref->{$_};
#$delim = ",";
#&ssh_host( "$result_ref->{$_}", "$sshport", "$user", "$pass" );
#}
print $result_ref->{"ID"};
#if ($result_ref->{"TIME"}>300){
my $sql2 = qq {kill $result_ref->{"ID"}};
&execute_sql($dbh,$sql2);
	#print $result_ref->{"ID"},$result_ref->{"USER"},$result_ref->{"HOST"},$result_ref->{"TIME"};
print "\n";
	#}
}
# end sql
$sth->finish();
sleep 60;
#my $sql3 = qq{select * from PROCESSLIST };
my $sql3 = qq{select * from PROCESSLIST where TIME>=300 and command='Query' or command = 'Killed' };
my $sth2 = &execute_sql($dbh,$sql3);
if ( $sth2->fetchrow_hashref() ){
	print "restart mysqld\n";
	&ssh_host( $dbhost, $sshport, $user, $pass );
 }
# end sql3
$sth2->finish();
# disconnect from database
$dbh->disconnect();
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
# Func   : Connect host
# Sample :
#          &ssh_host($host, $sshport, $user, $pass);
# -------------------------------------------------------------------
sub ssh_host() {
    my ( $host, $sshport, $user, $pass ) = @_;
    my $ssh = Net::SSH::Expect->new(
        host        => $host,
        port        => $sshport,
        password    => $pass,
        user        => $user,
        no_terminal => 0,
        raw_pty     => 1,
        timeout     => 6,
    );
    open FH, ">> /tmp/aaa/log_$host" or die $!;
    print FH "-" x 80, "\n";
    my $start_time = localtime;
    print FH "start \tat $start_time\n";
    $ssh->debug(0);
    $ssh->run_ssh() or die "SSH process couldn't start: $!";
    $ssh->waitfor( '\(yes\/no\)\?$', 6 );
    $ssh->send("yes\n");
    $ssh->waitfor( 'password:\s*$/', 6 );
    $ssh->send("$pass");
    $ssh->send("su - root");
    $ssh->waitfor( 'Password:\s*$', 6 );
    $ssh->send("$root_pass");
    $ssh->waitfor( '#\s*', 6 );
    print FH "root login ok. \n";
  #  $ssh->send("passwd $user");
  #  $ssh->waitfor( 'password:\s*$', 6 );
  #  $ssh->send("$new_user_pass");
  #  $ssh->waitfor( 'password:\s*$', 6 );
  #  $ssh->send("$new_user_pass");
  #  $ssh->waitfor( '#\s*', 6 );
    my $restartmysql1 = $ssh->exec("service mysqld1 restart");
    print FH "$restartmysql1\n";
    print FH "mysql restart ok!!!!!!!\n";
    my $end_time = localtime;
    print FH "end \tat $end_time\n";
    $ssh->close();
    print FH "-" x 30, "\n";
    close FH;
}
