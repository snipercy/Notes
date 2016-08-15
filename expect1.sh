#!/usr/bin/expect 

set timeout 3 

set username [lindex $argv 0] 
set password [lindex $argv 1] 
set remhost [lindex $argv 2] 
set command [lindex $argv 3] 
spawn ssh $username@$remhost $command 

expect { 
"*re you sure you want to continue connecting*" 
{ 
send "yes\n" 
expect { 
"*assword*" 
{ 
send "$password\n" 
} 
} 
} 
"*assword*" 
{ 
send "$password\n" 
} 
} 
expect eof