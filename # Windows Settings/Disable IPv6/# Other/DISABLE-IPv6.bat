:  befor running this batch make sure you network connection
:   name = (  Local Area Connection  ) or change the name in the next command
: download the (  nvspbind  )  from msdn microsoft & put it with this batch in the same folder
: after running this bach the IPv6 will uncheck as if you did it manual


nvspbind /d "Local Area Connection" ms_tcpip6

shutdown /r /t 1