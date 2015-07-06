#!/usr/bin/perl -w 
#Script using PJL to gather serialnum from a printer on port 9100 
#Syntax: ./serialnum.pl <ip-address> 
use IO::Socket; 
if (@ARGV < 1){ 
print "usage: serialnum ip-address\n"; 
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
send($sock, "\033%-12345X\@PJL INQUIRE SERIALNUMBER\r\n",0); 
# INFO ID - Pulls Model
# INFO STATUS - Pulls Status Code
# INFO VARIABLES - Pulls Language?
# INQUIRE SERIALNUMBER - Pulls serials, sometimes
#Read response from socket 
recv($sock,$RESPONSE,0xFFFFF,0); 
(my $junk,$pc) = split (/\r\n/s,$RESPONSE); 
#Find the serialnum 
$pc =~ s/(ProductSerialNumber=)?([0-9]+)/$2/g; 
print $pc;
close($sock);