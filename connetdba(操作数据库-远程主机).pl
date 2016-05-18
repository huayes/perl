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
my $db            = "user";
my $dbport        = '3306';
my $user          = 'user';
my $pass          = 'password';
my $root_pass     = 'password';
my $new_user_pass = 'password';
my $sshport       = '22';
# connect database
my $dbh = &connet_mysql($dbhost,$dbport,$db,$dbuser,$dbpasswd);
# execute sql
my $sql = qq{select GroupID from users limit 6};
my $sth = &execute_sql($dbh,$sql);
# get sql result
while ( my $result_ref = $sth->fetchrow_hashref() ) {
my $delim = "";
foreach ( keys %{$result_ref} ) {
#print $_;
#print $delim,$_,"=",$result_ref->{$_};
#print $result_ref->{GroupID};
print $result_ref->{$_};
$delim = ",";
#&ssh_host( "$result_ref->{$_}", "$sshport", "$user", "$pass" );
}
print "\n";
}
# end sql
$sth->finish();
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
$mysql_dbh->do("set names gbk");
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
    open FH, ">> /home/aaa/log_$host" or die $!;
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
    $ssh->send("passwd $user");
    $ssh->waitfor( 'password:\s*$', 6 );
    $ssh->send("$new_user_pass");
    $ssh->waitfor( 'password:\s*$', 6 );
    $ssh->send("$new_user_pass");
    $ssh->waitfor( '#\s*', 6 );
    my $ls = $ssh->exec("id");
    print FH "$ls\n";
    print FH "chang password ok!!!!!!!\n";
    my $end_time = localtime;
    print FH "end \tat $end_time\n";
    $ssh->close();
    print FH "-" x 30, "\n";
    close FH;
}
