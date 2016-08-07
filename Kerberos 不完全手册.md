Kerberos 不完全手册之原理篇
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

## Kerberos 如何工作

Kerberos的认证过有点复杂，要给它说明白不是一件容易的事。所以，在本节中我们先介绍一个简单Authentication例子，
可以认为它是以简版的kerseros。希望通过分析简版kerseros可以让我们理解kerberos的本质，然后分析简版Kerberos的
不足之处，从而引入真正的kerberos。~~当然，高手可以跳过，选择性的看就好。~~

简版的问题：如何获取session key ---》 引入了kdc

### 1. Authentication
该步骤的目的：证明你就是你
如何证明：
clinet 和 server 共享一个CSKey
a. client 向 server 发送两自己的身份信息，一组用CSKey加密过数据A和一组是未加密数据B
b. server 端用 CSKey 解密数据A，并与未加密的数据B进行比较，相同则认证成功。

### 2. Authorization

在Kerberos系统中，客户端和服务器都有一个唯一的名字，叫做Principal。同时，客户端和服务器都有自己的密码，并且它们的密码只有自己和认证服务器AS知道。

Kerberos 服务(kerberos官网)是一种通过网络提供安全验证处理的客户机/服务器体系结构。通过验证，可保证网络事务的发送者和接收者的身份真实。该服务还可以检验来回传递的数据的有效性（完整性），并在传输过程中对数据进行加密（保密性）。使用 Kerberos 服务，可以安全登录到其他计算机、执行命令、交换数据以及传输文件。此外，该服务还提供授权服务，这样，管理员便可限制对服务和计算机的访问。而且，作为 Kerberos 用户，您还可以控制其他用户对您帐户的访问。



