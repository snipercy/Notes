Kerberos V5 不完全手册
======
[TOC]

# 什么是 Kerberos
>
A commonly found description for Kerberos is "a secure, single sign on, trusted third party
mutual authentication service". It doesn't store any information about UIDs, GIDs, or home's
path. In order to propagate this information to hosts, you will eventually need yellow page
services: NIS, LDAP, or Samba.

一个在客户端跟服务器端之间或者服务器与服务器之间的**身份验证协议**

在 Kerberos 协议验证用户的身份，它并不授权访问。验证通过会返回TGT，这个票据仅仅用来证明这个用户就是它自己声称的那个用户。在用户身份得以确认后，才可以去申请服务。

# 基础概念

- **princals(安全个体):**被认证的个体，有一个名字和口令，客户端和服务器都有一个唯一的名字。 kerberos为kerberos principal分配tickets使其可以访问由kerberos加密的hadoop服务。 通常它长这样：`primary/instance@realm`，各个字段含义如下：
```
primary: user or service name
instance: optional for user principals, but required for service principals 
realm: the Kerberos realm 

EXAMPLE:
User: joe@FOO.COM 
Service: imap/bar.foo.com@FOO.COM
```

- **keytab** : 包含principals和加密principal key的文件。 keytab文件对于每个host是**唯一**的，因为<t style="color:red">**key中包含hostname</t>**。keytab文件用于不需要人工交互和保存纯文本密码，实现到kerberos上验证一个主机上的principal。 因为服务器上可以访问keytab文件即可以以principal的身份通过kerberos的认证，所以，keytab文件应该被妥善保存，应该只有少数的用户可以访问。
> stores long-term keys for one or more principals. Keytabs are used most often to allow server applications to accept authentications from clients, but can also be used to obtain initial credentials for client applications.([ref](http://web.mit.edu/kerberos/krb5-latest/doc/basic/keytab_def.html#keytab-definition)):


- **AS (Authentication Server): ** 认证服务器

- **KDC(key distribution center ): ** 是一个网络服务，提供ticket 和临时会话密钥

- **TSG(Ticket Granting Server):** 许可证服务器

- **TGT(Ticket Granting Ticket):** 可理解为票据的票据，client从kdc获取的

- **Ticket:**一个记录，客户用它来向服务器证明自己的身份，包括客户标识、会话密钥、时间戳。

- **realm:** The Kerberos administrative domain. (自定义)

- **密钥**: Kerberos消息被多种加密密钥加密以确保没人能够篡改客户的票据或者Kerberos消息中的其他数据。
    + 长期密钥（Long-term key）: 一个密钥（只有目标服务器和KDC知道），并用来加密客户端访问这个目标服务器票据的密钥。
    + Client/server会话密钥（session key）: 一个短期的、单此会话的密钥，是在用户的身份和权限已经被确认后由KDC建立的用于这个用户的跟某个服务器之间的加密往来信息使用的密钥
    + KDC/用户 会话密钥（session key）: 是KDC跟用户共享的一个密钥，被用于加密这个用户跟KDC之间的消息。

# Kerberos 原理简介

1. Kerberos原理-验证过程：
![tgt](I:\\git\\Notes\\image\\tgt.jpg)

2. Kerberos原理-认证过程：
![tgs](I:\\git\\Notes\\image\\tgs.jpg)
<t style="color:grey">(对应上图中client与service通信过程)</t>

>
（1）Client将之前获得TGT和要请求的服务信息(服务名等)发送给KDC，KDC中的Ticket Granting Service将为Client和Service之间生成一个Session Key用于Service对Client的身份鉴别。然后KDC将这个Session Key和用户名，用户地址（IP），服务名，有效期, 时间戳一起包装成一个Ticket(这些信息最终用于Service对Client的身份鉴别)发送给Service， 不过Kerberos协议并没有直接将Ticket发送给Service，而是通过Client转发给Service，所以有了第二步。
（2）此时KDC将刚才的Ticket转发给Client。由于这个Ticket是要给Service的，不能让Client看到，所以KDC用协议开始前KDC与Service之间的密钥将Ticket加密后再发送给Client。同时为了让Client和Service之间共享那个密钥(KDC在第一步为它们创建的Session Key)，KDC用Client与它之间的密钥将Session Key加密随加密的Ticket一起返回给Client。
（3）为了完成Ticket的传递，Client将刚才收到的Ticket转发到Service. 由于Client不知道KDC与Service之间的密钥，所以它无法算改Ticket中的信息。同时Client将收到的Session Key解密出来，然后将自己的用户名，用户地址（IP）打包成Authenticator用Session Key加密也发送给Service。
（4）Service 收到Ticket后利用它与KDC之间的密钥将Ticket中的信息解密出来，从而获得Session Key和用户名，用户地址（IP），服务名，有效期。然后再用Session Key将Authenticator解密从而获得用户名，用户地址（IP）将其与之前Ticket中解密出来的用户名，用户地址（IP）做比较从而验证Client的身份。
（5）如果Service有返回结果，将其返回给Client。


# 解决的Hadoop安全认证问题

先对集群中确定的机器由管理员手动添加到kerberos数据库中(addprinc node1)，在KDC上分别产生主机与各个节点的keytab(包含了host和对应节点的名字，还有他们之间的密钥，ktadd -k a.keytab principal)，并将这些keytab分发到对应的节点上。通过这些 keytab 文件，节点可以从KDC上获得与目标节点通信的密钥，进而被目标节点所认证，提供相应的服务，防止了被冒充的可能性。

**如何保证安全**

1. kerberos 的安全是建立在主机都是安全的而网络不是安全的假定之上的。所以kerberos的安全其实就在于把主机的安全做好；尤其是KDC那台机器的安全。出于安全的考虑，跑KDC的机器上不能再跑别的服务，如果KDC被攻陷了，那么所有的密码就全部泄露了；

2. 如果只是服务的机器被攻陷了，那么需要更改服务的 principal 的密码；

3. 如果是用户的机器被攻陷了，那么在 ticket 超时（一般是数小时的时间里）之前，用户都是不安全的，攻击者还有可能尝试反向用户的密码；

4. Kerberos依赖其它的服务来存放用户信息（登录shell、UID、GID啥的），因此需要注意到这些信息依然是很容易遭受攻击并且泄露的；


**TIPS**

1. (中间人攻击)由于任何人都可以向KDC请求任何用户的TGT（使用用户密码加密的session key），那么攻击者就有可能请求一个这样的包下来尝试解密，他们有充足的时间离线去做这个工作，一旦解开了，他们也就拿到了用户的密码。简单密码几乎一解就开，所以不能设置简单密码，也不能在字典里。另外还可以打开Kerberos的预验证机制来防御这种攻击，预验证机制就是在KDC收到用户请求TGT的请求之后，要求用户先发一个用自己密码加密的时间戳过来给KDC，KDC如果确实可以用自己存储的用户密码解密，才发TGT给用户，这样攻击者在没有用户密码的时候就拿不到可用于反向的包含用户密码的TGT包了。在MIT kerberos中在配置文件中default_principal_flags = + preauth可以打开这个机制。但这个机制也并不是无懈可击的，攻击者依然可以通过嗅探的方式在正常用户请求TGT时拿到上述的那个包（这个难度显然就高了一些）；

2. 攻击者可能伪造一个KDC，然后用一个伪造的实际不存在的用户向这个KDC请求验证，通过后他就得到了一个用户登录系统的 shell。这种攻击需要在客户端防御，需要客户端主动去验证一下KDC是否是正确的KDC。具体来说就是客户端在得到TGT后进一步要求KDC给一个本物理机的principal（也就是一个用物理机密钥加密的串），然后尝试用物理机存储的密码去解密，由于伪造的KDC没有物理机（host／hostname）的principal密码，所以它无法给出这个包，也就被客户端认定为是伪造的KDC，认证失败。这个机制需要在客户端开启（认证服务器端么），默认是关闭的，设置validate=true来开启；

# 实战篇(杂)
请参考官网手册或conference上相关手册

- 修改密码
```shell
shell% kpasswd
Password for david:    <- Type your old password.
Enter new password:    <- Type your new password.
Enter it again:  <- Type the new password again.
Password changed.
shell%
```

	修改密码后需要注意，一旦密码修改后，同步整个集群的信息需要花一些时间。
> If you need to get new Kerberos tickets shortly after changing your password, try the new password. If the new password doesn’t work, try again using the old one.

- Granting access to your account
可以将我们的权限转给别人用，而不用将密码给别人，通过再家目录创建/配置 .k5login 即可，例子：
```
ycheng@SCH.STM.EDU
jack@EXAMPLE.COM
```
>This file would allow the users jennifer and david to use your user ID, provided that they had Kerberos tickets in their respective realms. If you will be logging into other hosts across a network, you will want to include your own Kerberos principal in your .k5login file on each of these hosts.

- 生成 ticket 
``` shell
shell% kinit david@EXAMPLE.COM
Password for david@EXAMPLE.COM: <-- [Type david's password here.]
shell%
```
第一次生成的就是 TGT，当 kinit 不加参数:
 >
 By default, kinit assumes you want tickets for your own username in your default realm. eg: root@TEST.COM

- 查看 tickets
``` shell
shell% klist
Ticket cache: /tmp/krb5cc_ttypa
Default principal: jennifer@ATHENA.MIT.EDU
Valid starting     Expires            Service principal
06/07/04 19:49:21  06/08/04 05:49:19  krbtgt/ATHENA.MIT.EDU@ATHENA.MIT.EDU
shell%
```
> the “service principal” describes each ticket. The ticket-granting ticket has a first component krbtgt, and a second component which is the realm name
> [do-build](http://web.mit.edu/kerberos/krb5-latest/doc/build/doing_build.html#do-build)

~~**源码安装**：
- 下载并解压好源码
- path/src/configure
- make
- make install   or  make install DESTDIR=/path/to/destdir
- make check~~

**二进制文件安装**:

```shell
# 安装 server 端
yum install krb5-server krb5-libs krb5-auth-dialog 

# 安装 client 端
yum install krb5-workstation krb5-libs krb5-auth-dialog

# 修改配置文件 /etc/krb5.conf 

# 创建/初始化 Kerberos database
/usr/sbin/kdb5_util create -s 

# 添加 database 管理员
/usr/sbin/kadmin.local -q "chengy admin/admin"

# 设置 ACL 
echo */admin@EXAMPLE.COM     * >> /var/kerberos/krb5kdc/kadm5.acl

# 启动
/sbin/chkconfig krb5kdc on   # 开机自启动
/sbin/chkconfig kadmin on 	 # 开机自自动
# OR 手动自动
/etc/rc.d/init.d/krb5kdc start
/etc/rc.d/init.d/kamdin start

# 检查是否正常工作
kinit admin/admin@EXAMPLE.COM   # 认证用户
klist 

# ktadd
# -norandkey 只有kadmin.local 才有
kadmin.local -q "ktadd -norandkey -k hdfs.keytab  bdoc@TEST.COM bdoc/admin@TEST.COM"
OR:
ktadd -k hdfs.keytab bdoc@TEST.COM

# 查看 keytab
klist -k hdfs.keytab

# kadmin
不kinit，使用keytab文件拥有admin权限
kadmin -kt bdoc.keytab -p bdoc/admin@TEST.COM -q "listprincs"

# 使用 keytab
scp hdfs.keytab Slave1:/home/hdfs/
ssh Slave1
kinit -k -t hdfs.keytab hdfs/Slave1@TEST.COM

# 给远程机Slave1,bdoc用户添加kadmin权限
kadmin.local -q "addprinc bdoc/admin@TEST.COM"
```
