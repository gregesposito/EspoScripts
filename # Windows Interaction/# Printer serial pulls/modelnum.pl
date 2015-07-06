#!/usr/bin/perl -w 
#Script using PJL to gather serialnum from a printer on port 9100 
#Syntax: ./serialnum.pl <ip-address> 
use IO::Socket; 
if (@ARGV < 1){ 
print "usage: modelnum ip-address\n"; 
exit 
} 
$ip = $ARGV[0]; 
#open the socket 
my $sock = new IO::Socket::INET ( 
PeerAddr => $ip, 
PeerPort => '9100', 
Proto => 'tcp', 
); 
die "Could not create socket - $!\n" unless $sock; 
#send page query to socket 
send($sock, "\033%-12345X\@PJL INFO ID\r\n",0); 
recv($sock,$RESPONSE,0xFFFFF,0); 
(my $junk2,$pc2) = split (/\r\n/s,$RESPONSE); 
#Find the modelnum 
print $pc2;
#."\n";
#.$junk; 
close($sock);