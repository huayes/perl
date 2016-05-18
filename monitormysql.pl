#!/usr/bin/perl
use DBI;

# -------------------------------------------------------------------
# Func   : Main()
# -------------------------------------------------------------------
my $dbuser       = "root";
my $dbpasswd     = "password";
my $dbhost       = "localhost";
my $mysql_socket = "/var/lib/mysql/mysql.sock";
my $db           = "information_schema";
my $dbport       = '3306';


# connect database
my $dbh = &connet_mysql( $dbhost, $dbport, $db, $dbuser, $dbpasswd );

# execute sql
#my $sql1 = qq{select * from PROCESSLIST where TIME>=300 and command='Sleep'};
my $sql1 = qq{select * from PROCESSLIST where TIME>=300 and command<>'Sleep'};
my $sth1 = &execute_sql( $dbh, $sql1 );

# get sql result

if ( my $result_ref = $sth1->fetchrow_hashref() ) {
        print "1\n";

}
else {
        print "0\n";
        }

# end sql
$sth1->finish();

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
    #$mysql_dbh->do("set names gbk");
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
