#!/usr/bin/perl -w

use strict;

use LWP::UserAgent;
use HTTP::Request::Common;

my $userAgent = LWP::UserAgent->new(agent => 'perl post');
$userAgent->timeout(5);
my $message = "<vehicleInfo>
     <plateNumber>粤AD183N</plateNumber>
</vehicleInfo>";

my $response = $userAgent->request(POST "http://$ARGV[0]:10001/carInfo/query",
Content_Type => 'text/xml',
Content => $message);

#print $response->error_as_HTML unless $response->is_success;
#print  $response->is_success;
if ($response->is_success){
print "1\n";
}
else{
print "0\n";
}
#print $response->as_string;
