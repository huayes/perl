#!/usr/bin/perl
use strict;
use warnings;
use Net::SSH::Expect;

my $user          = 'shliang';
my $pass          = 'password';
my $root_pass     = 'password';
my $new_user_pass = 'password';
my $sshport       = '22';

my $file = '/home/aaa/iplist';
open FILE, "< $file" or die "can't open file $file ($!)";

while (<FILE>) {
    next if $_ =~ /^#/;
    print $_;
    &ssh_host( "$_", "$sshport", "$user", "$pass" );
}
close(FILE);
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
