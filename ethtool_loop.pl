#!/usr/bin/perl
	
	  my @eth = ("eth0","eth1","eth2","eth3");
foreach my $eth(@eth){
	  	print "$eth\n";
	 my @eths =	`ethtool $eth`;
	   #	$arry =~ /Link detected: (.+)/;
	  LINE:print "@eths\n";
	  redo;

	   #	last;
	   	}
	   	
	   #	}
#	last LINE;
#	}
	
	#print "haha\n";
	