#! /usr/local/bin/perl

eval '(exit $?0)' && eval 'exec /usr/local/bin/perl $0 ${1+"$@"}'
&& eval 'exec /usr/local/bin/perl $0 $argv:q'
if 0;


#====================================================================
#
#           QUERY MAC ADDRESSES FROM 3COM SWITCH
#
#    The following program automatically gets a list of MAC 
#    addresses on a 3com switch and which port each address 
#    is on using Ethernet MIB:dot1dTpFdbTable.
#
#    NOTE:  Portions of this code used from David M. Town <dtown@cpan.
+org>
#           table.pl
#
#====================================================================


use strict;
use Net::SNMP qw(snmp_dispatcher oid_lex_sort);

#=== Setup session to remote host ===
my ($session, $error) = Net::SNMP->session(
   -hostname  => $ARGV[0] || 'localhost',
   -community => $ARGV[1] || 'public',
   -port      => $ARGV[2] || 161
);
#=====================================

#=== Was the session created? ===
if (!defined($session)) {
   printf("ERROR: %s\n", $error);
   exit 1;
}
#==================================

#=== OIDs queried to retrieve information ====
my $TpFdbAddress = '1.3.6.1.2.1.17.4.3.1.1';
my $TpFdbPort    = '1.3.6.1.2.1.17.4.3.1.2';
#=============================================


#=== Print the returned MAC addresses ===
printf("\n== MAC Addresses: %s ==\n\n", $TpFdbAddress);

my $result;

if (defined($result = $session->get_table(-baseoid => $TpFdbAddress)))
+ {
   foreach (oid_lex_sort(keys(%{$result}))) {
      printf("%s => %s\n", $_, $result->{$_});
   }
   print "\n";
} else {
   printf("ERROR: %s\n\n", $session->error());
}
#==========================================

#=== Print the returned MAC ports ===
printf("\n== MAC Ports: %s ==\n\n", $TpFdbPort);

my $result;

if (defined($result = $session->get_table(-baseoid => $TpFdbPort))) {
   foreach (oid_lex_sort(keys(%{$result}))) {
      printf("%s => %s\n", $_, $result->{$_});
   }
   print "\n";
} else {
   printf("ERROR: %s\n\n", $session->error());
}
#=============================================

#=== Close the session and exit the program ===
$session->close;
exit 0;