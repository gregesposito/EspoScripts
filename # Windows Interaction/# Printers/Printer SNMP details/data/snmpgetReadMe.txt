==============================================================================
SnmpGet v1.01 - Obtains the value of the SNMP variable from any network device.
==============================================================================

Copyright (C) 2009 SnmpSoft Company. All Rights Reserved.

Contents
--------
  1. Overview
  2. Features
  3. Usage & Parameters
  4. Examples
  5. License & Disclaimer
  6. Version History


1. Overview
------------
  SNMP – is a standard protocol for network monitoring and network devices
  management. Almost  all active  network devices  support SNMP.  Moreover,
  SNMP  is supported  by the majority  of operational  systems and by many 
  network applications.

  SnmpGet allows  for the organization  of network  monitoring  using SNMP.
  Monitoring  is realized by  reading the values of SNMP  variables from a 
  remote  network device.  The variables can be of  various types  and may
  represent a wide range of information, such as current parameters of the
  configuration,  the status  of operations execution,  and information on 
  possible errors and failures. 

  The list of available variables  depends on the network device itself or
  on the SNMP software. You can find the list of variables,  available for
  reading in certain situations, with the help of a separate tool SnmpWalk.
  Some variables  are available for writing. By changing their values with
  SnmpSet,  you  can   change  certain  parameters  of  a  network  device
  configuration or perform some actions.

  SnmpGet it is command-line tool; thus, it is very easy to use in scripts,
  which  allow  for  the  automation  of  much  routine  work  of  network
  administrators.  Except for IPv4,  this tool also supports IPv6; it will
  not   cause  any   problems  while   you  are  upgrading   your  network
  infrastructure.  Moreover, SnmpGet supports  a regular  version  of  the 
  SNMPv1/SNMPv2c protocol and also a safer SNMPv3 which enables you to use
  this tool without risking the violation of corporate safety policies.
  

2. Features
------------
  + Support of SNMP v1/v2c and SNMPv3
  + Support of IPv4 and IPv6
  + Command line interface (CLI)
  + Allows for any type of SNMP variable
  + Various Auth. & Privacy protocols
  + Windows NT/2000/XP/2003/Vista/2008

  
3. Usage & Parameters
----------------------
  SnmpGet.exe [-q] -r:host [-p:port] [-t:timeout] [-v:version] [-c:community]
        [-ei:engine_id] [-sn:sec_name] [-ap:auth_proto] [-aw:auth_passwd]
        [-pp:priv_proto] [-pw:priv_passwd] [-ce:cont_engine] [-cn:cont_name]
        -o:var_oid

   -q               Quiet mode (suppress header; print variable value only)
   -r:host          Name or network address (IPv4/IPv6) of remote host.
   -p:port          SNMP port number on remote host. Default: 161
   -t:timeout       SNMP timeout in seconds (1-600). Default: 5
   -v:version       SNMP version. Supported version: 1, 2c or 3. Default: 1
   -c:community     SNMP community string for SNMP v1/v2c. Default: public
   -ei:engine_id    Engine ID. Format: hexadecimal string. (SNMPv3).
   -sn:sec_name     SNMP security name for SNMPv3.
   -ap:auth_proto   Authentication protocol. Supported: MD5, SHA (SNMPv3).
   -aw:auth_passwd  Authentication password (SNMPv3).
   -pp:priv_proto   Privacy protocol. Supported: DES, IDEA, AES128, AES192,
                    AES256, 3DES (SNMPv3).
   -pw:priv_passwd  Privacy password (SNMPv3).
   -cn:cont_name    Context name. (SNMPv3)
   -ce:cont_engine  Context engine. Format: hexadecimal string. (SNMPv3)
   -o:var_oid       Object ID (OID) of SNMP variable to GET.  

4. Examples
------------
  SnmpGet.exe -r:10.0.0.1 -t:10 -c:"admin_rw" -o:.1.3.6.1.2.1.1.4.0
  SnmpGet.exe -r:MainRouter -q -v:2c -p:10161 -o:.1.3.6.1.2.1.1.1.0
  SnmpGet.exe -r:"::1" -v:3 -sn:SomeName -ap:MD5 -aw:SomeAuthPass -pp:DES
               -pw:SomePrivPass -o:.1.3.6.1.2.1.1.8.0  
  

5. License & Disclaimer
------------------------
  FREE USE LICENSE. You  may install  and use  any number of copies
  of  this  SOFTWARE  on your  devices  free of  charge.  You  must
  distribute  a copy of  this license  within  ReadMe.txt file with
  any  copy of the SOFTWARE and  anyone to whom you  distribute the
  SOFTWARE is subject to this license.

  RESTRICTIONS.  You may not  reduce the SOFTWARE to human readable
  form,  reverse engineer,  de-compile,  disassemble, merge,  adapt,
  or modify the SOFTWARE, except  and only to  the extent that such
  activity is expressly permitted by applicable law notwithstanding
  this  limitation.  You may not rent, lease,  or lend the SOFTWARE.
  You may not use the SOFTWARE to perform any unauthorized transfer
  of  information,  such  as  copying  or  transferring  a  file in
  violation of a copyright, or for any illegal purpose.

  NO WARRANTIES.  To the maximum extent permitted by applicable law,
  SnmpSoft Company  expressly   disclaims  any  warranty  for  this
  SOFTWARE. The SOFTWARE and any related documentation are provided
  "as is" without warranty  of any kind,  either express or implied,
  including,   without  limitation,  the  implied   warranties   of
  merchantability  or fitness for a particular  purpose. The entire
  risk  arising out of use or performance  of the  SOFTWARE remains
  with you.


6. Version History
-------------------
  1.01  - FIXED: Redirecting the output to a file

  1.0  - Initial release
  

SnmpSoft Company
================
Simple Network Monitoring Programs
http://www.snmpsoft.com
FreeTools for Network Administrators
http://www.snmpsoft.com/freetools/
  
======================================EOF=====================================