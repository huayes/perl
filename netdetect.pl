#!/usr/bin/perl
my $varhsvalue;
while (1) {
    $hsvalue = &gethashvalue();
    $yesnum  = &getyesnum($hsvalue);
    if ( $yesnum >= 2 and $hsvalue ne $varhsvalue ) {
        print "You have connected two or more cables,please keep only one!\n\n";
        $varhsvalue = $hsvalue;
    }
    if ( $yesnum == 0 and $hsvalue ne $varhsvalue ) {
        print "You do not connected any cable, please plug in one!\n\n";
        $varhsvalue = $hsvalue;
    }
    if ( $yesnum == 1 and $hsvalue ne $varhsvalue ) {
        $hsvalue =~ /(.+),(.+),(.+),(.+)/;
        if ( $1 eq yes ) {
            print
"Now the network interface which cable connected is: eth0\nPlease plug the cable to another network interface!\n\n";
        }
        elsif ( $2 eq yes ) {
            print
"Now the network interface which cable connected is: eth1\nPlease plug the cable to another network interface!\n\n";
        }
        elsif ( $3 eq yes ) {
            print
"Now the network interface which cable connected is: eth2\nPlease plug the cable to another network interface!\n\n";
        }
        elsif ( $4 eq yes ) {
            print
"Now the network interface which cable connected is: eth3\nPlease plug the cable to another network interface!\n\n";
        }
        $varhsvalue = $hsvalue;
    }
}

sub gethashvalue {    #获取并生成格式化的数据
    my @eth = ( "eth0", "eth1", "eth2", "eth3" );
    my $a = 0;
    my ( $s0, $s1, $s2, $s3 );
    foreach my $eth (@eth) {
        if ( $a == 0 ) {
            $s0 = &createstatu($eth);
        }
        elsif ( $a == 1 ) {
            $s1 = &createstatu($eth);
        }
        elsif ( $a == 2 ) {
            $s2 = &createstatu($eth);
        }
        elsif ( $a == 3 ) {
            $s3 = &createstatu($eth);
        }
        $a++;
    }
    my $hashresulte = "$s0,$s1,$s2,$s3";
    return $hashresulte;
}

sub createstatu {    #生成链路状态
    my $statue;
    my ($eth) = @_;
    `ethtool $eth >&'tempfile'`;    #包括标准输出与标准错误输出
    open( FILE, 'tempfile' );
    my @line = <FILE>;
    close FILE;
    foreach my $line (@line) {
        if ( $line =~ /Link detected: (.+)/ ) {
            $statue = $1;
        }
        elsif ( $line =~ /No data available/ ) {
            $statue = 'x';
        }
    }
    return $statue;
}

sub getyesnum {    #获取yes个数
    my ($input) = @_;
    my @ss = split( /,/, $input );
    my $b = 0;
    foreach my $ss (@ss) {
        if ( $ss eq 'yes' ) {
            $b += 1;
        }
    }
    return $b;
}
