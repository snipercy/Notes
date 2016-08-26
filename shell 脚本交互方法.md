##  文件重定向

command << delimiter  从标准输入中读入，直至遇到delimiter分界符，分界符是可以任意指定的，即使和关键重复也没事，但是为了可读性建议使用`EOF`作为分界符，举例如下：

```shell
#!/bin/bash
kadmin.local << eof
listprincs
q
eof

```
解释下上述脚本：kadmin.local 是 [kerberos]() server端的一个管理工具，键入该命令后进入 kerberos 管理终端界面，然后输入 listprincs 就列出已创建的 princals，q退出并回到shell

## ~~ 管道 ~~
```shell
echo $ADMIN_PASSWD | kadmin -q "addprinc -pw $2 ${PRINC}" 
```

##  expect
expect就是一个专门用来实现自动交互功能的工具。
su自动登录到root账户，懒得每次都输入root密码
```shell
#!/usr/bin/expect  
spawn su root  
expect "password: "  
send "123456\r"  
expect eof  
exit
```
