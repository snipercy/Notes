#!/bin/bash

function auto_ssh() {
　　username_server="$1"
　　password="$2"
　　command="$3"

　　ssh_warpper=" 
　　　　spawn ssh -o StrictHostKeyChecking=no $username_server \"$command\"　　\n
　　　　expect { 　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　\n
　　　　　　-nocase \"password:\" {send \"$password\r\"} 　　　　　　　　　　　　　\n
}\n
　　　　expect eof 　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　\n
　　"
　　echo -e $ssh_warpper | /usr/bin/expect
}
