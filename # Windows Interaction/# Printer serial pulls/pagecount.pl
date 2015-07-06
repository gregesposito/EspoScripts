#!/usr/bin/perl -w 
#Script using PJL to gather pagecount from a printer on port 9100 
#Syntax: ./pagecount.pl <ip-address> 
use IO::Socket; 
if (@ARGV < 1){ 
print "usage: pagecount.pl ip-address\n"; 
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
send($sock, "\033%-12345X\@PJL INFO PAGECOUNT\r\n",0); 
#Read response from socket 
recv($sock,$RESPONSE,0xFFFFF,0); 
(my $junk,$pc) = split (/\r\n/s,$RESPONSE); 
#Find the pagecount 
$pc =~ s/(PAGECOUNT=)?([0-9]+)/$2/g; 
print $pc."\n"; 
close($sock);