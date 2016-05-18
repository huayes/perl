#!/usr/bin/perl


while(1){

my $NEWIP;
my $OLDIP=`cat /data/bw_mon/modify_iptable/tmpip1`;
my $tmpfile='/data/bw_mon/modify_iptable/tmpip1';
if( !(-e $tmpfile) ){
	print "$tmpfile is notexist\n";
        `touch $tmpfile`;
}

print "$OLDIP";
chomp($OLDIP);

use Net::DNS;
$res = new Net::DNS::Resolver;
$res->nameservers("202.96.128.86","8.8.8.8");
$query = $res->search("cninsure-2011.gicp.net");
#$query = $res->search("www.baoxian.com");
  if ($query) {
      foreach $rr ($query->answer) {
          next unless $rr->type eq "A";
          #print $rr->address, "\n";
          #chomp($str);
          $NEWIP = $rr->address;
         chomp($NEWIP);
      }
  }
  else {
      print "query failed: ", $res->errorstring, "\n";
	  next;
  }

print "$NEWIP\n";
if($NEWIP ne $OLDIP){
print "restart iptables\n";
#system("sed -i s\/$OLDIP\/$NEWIP\/ '/etc/init.d/iptables.sh'");
`sed -i s/${OLDIP}/${NEWIP}/ '/etc/init.d/iptables.sh'`;
#`sed -e 's/${OLDIP}/${NEWIP}/g' '/etc/init.d/iptables.sh'`;
print "$OLDIP";
`/etc/init.d/iptables.sh`;
`echo "$NEWIP">$tmpfile`;
#`perl -pi -e "s|$OLDIP|$NEWIP|g" "/etc/init.d/iptables.sh"`;
}
sleep(35);
}
