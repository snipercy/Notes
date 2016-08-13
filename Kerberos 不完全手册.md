Kerberos 不完全手册之原理篇  [未完。。。]
======
[TOC]

## 什么是 Kerberos
>
A commonly found description for Kerberos is "a secure, single sign on, trusted third party
mutual authentication service". It doesn't store any information about UIDs, GIDs, or home's
path. In order to propagate this information to hosts, you will eventually need yellow page
services: NIS, LDAP, or Samba.

说到安全就难免会想到3A认证，Kerberos 提供了是3A中的认证 (Authentication) 和授权(Authorization)服务。

## Kerberos 使用场景

1. 单点登陆。考虑这样一个场景，hadoop集群提供了多种服务，每种服务都有认证的
的需求，不可能让每个服务器自己实现一套认证系统，~~bdoc(苏研的hadoop运营管理平台)
就需要提供一个中心认证服务器供这些服务器使用~~。

2. 服务的授权。~~ bdoc 主要是使用 Kerberos 提供服务的授权~~

## 基本概念
这部分将简单介绍 安全协议中一般会用到的术语以及 Kerberos 协议定义的术语，后文再涉及到相关术语均使用缩写代替，也不再解释：

- **3A认证**：
    + **Authentication: 认证**，验证用户的身份与可使用的网络服务
    + **Authorization: 授权**，依据认证结果开放网络服务给用户，`授权`是建立在`认证`的基础上，没有可靠的认证谈不上授权
    + **Accounting: 审计**，记录用户对各种网络服务的用量，并提供给计费系统

- **AS (Authentication Server): ** 认证服务器
- **KDC(key distribution center ): ** 是一个网络服务，提供ticket 和临时会话密钥
- **TSG(Ticket Granting Server):** 许可证服务器
- **TGT(Ticket Granting Ticket):** 可理解为票据的票据
- **Ticket:**一个记录，客户用它来向服务器证明自己的身份，包括客户标识、会话密钥、时间戳。
- **realm:** The Kerberos administrative domain 
- **princals(安全个体):**被认证的个体，有一个名字和口令，客户端和服务器都有一个唯一的名字。通常它长这样：`primary/instance@realm`，各个字段含义如下：
```
primary: user or service name
instance: optional for user principals, but required for service principals 
realm: the Kerberos realm 

EXAMPLE:
User: joe@FOO.COM 
Service: imap/bar.foo.com@FOO.COM
```

- **keytab** ([ref](http://web.mit.edu/kerberos/krb5-latest/doc/basic/keytab_def.html#keytab-definition)): stores long-term keys for one or more principals. Keytabs are used most often to allow server applications to accept authentications from clients, but can also be used to obtain initial credentials for client applications.

## Kerberos 如何工作

~~Kerberos的认证过有点复杂，要给它说明白不是一件容易的事。所以，在本节中我们先介绍一个简单Authentication例子，
可以认为它是以简版的kerseros。希望通过分析简版kerseros可以让我们理解kerberos的本质，然后分析简版Kerberos的
不足之处，从而引入真正的kerberos。当然，高手可以跳过，选择性的看就好。~~

~~简版的问题：如何获取session key ---》 引入了kdc~~

### 1. Authentication
该步骤的目的：证明你就是你
如何证明：
clinet 和 server 共享一个CSKey
a. client 向 server 发送两自己的身份信息，一组用CSKey加密过数据A和一组是未加密数据B
b. server 端用 CSKey 解密数据A，并与未加密的数据B进行比较，相同则认证成功。

### 2. Authorization

在Kerberos系统中，客户端和服务器都有一个唯一的名字，叫做Principal。同时，客户端和服务器都有自己的密码，并且它们的密码只有自己和认证服务器AS知道。

Kerberos 服务(kerberos官网)是一种通过网络提供安全验证处理的客户机/服务器体系结构。通过验证，可保证网络事务的发送者和接收者的身份真实。该服务还可以检验来回传递的数据的有效性（完整性），并在传输过程中对数据进行加密（保密性）。使用 Kerberos 服务，可以安全登录到其他计算机、执行命令、交换数据以及传输文件。此外，该服务还提供授权服务，这样，管理员便可限制对服务和计算机的访问。而且，作为 Kerberos 用户，您还可以控制其他用户对您帐户的访问。




tips: 
##  password management

## 1. 修改密码

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

## 2. Granting access to your account

可以将我们的权限转给别人用，而不用将密码给别人，通过再家目录创建/配置 .k5login 即可，例子：
```
ycheng@SCH.STM.EDU
jack@EXAMPLE.COM
```
This file would allow the users jennifer and david to use your user ID, provided that they had Kerberos tickets in their respective realms. If you will be logging into other hosts across a network, you will want to include your own Kerberos principal in your .k5login file on each of these hosts.

### 3. .k5login




##  Tick management

- 生成 ticket 

``` shell
shell% kinit -f -l 3h david@EXAMPLE.COM
Password for david@EXAMPLE.COM: <-- [Type david's password here.]
shell%
```

第一次生成的就是 TGT 

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

## 安装 KDCs

> [do-build](http://web.mit.edu/kerberos/krb5-latest/doc/build/doing_build.html#do-build)

按照官方文档的建议，当你将 Kerberos 用于生产环境时，it is best to have multiple slave KDCs alongside with a master KDC to ensure the continued availability of the Kerberized services. 
>
master KDC contains  writable realm databse, slave 会每隔一段时间更新本地db（只读的）

 All database changes (such as password changes) are made on the master KDC.
  Slave KDCs provide Kerberos ticket-granting services, but not database administration, when the master KDC is unavailable. 

> 
**Warning**
1. 节点间时间要同步
2. 确保按照 KDCs 节点的安全

步骤：

- 下载并解压好源码
- path/src/configure
- make
- make install   or  make install DESTDIR=/path/to/destdir
- make check

