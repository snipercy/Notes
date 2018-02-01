> 
ldap结合kerberos[]()使用,[ref](http://blog.csdn.net/cheng_fangang/article/details/40143261)

LDAP 用来做账号管理，Kerberos作为认证。授权一般来说是由应用来决定的，通过在LDAP 数据库中配置一些属性可以让应用程序来进行授权判断。

单纯基于 LDAP 已经能实现集中的帐号和认证管理了，但考虑到 LDAP 里的密码信息是直接存储在数据库中，在认证时需要将用户名和密码直接发送给 LDAP 服务器，在不是安全和可信的环境下这种模式会有安全隐患。因此使用Kerberos 来实现用户认证。

Kerberos 相关的数据也需要存储在某个数据库中，在这里我们选择使用 LDAP 作为其数据库，目的是为了数据备份的方便（只需要统一备份 LDAP 数据库即可）。如果需要使用其自身的数据库，则需要将下面的 kdb5_ldap_util 命令替换为 kdb5_util。

组织数据方式：
一图胜千言
![LDAP.png](https://github.com/snipercy/Notes/blob/master/image/ldap.png)



目录服务和数据库很类似，但又有着很大的不同之处。数据库设计为方便读写，
但目录服务专门进行了读优化的设计，因此不太适合于经常有写操作的数据存储。
同时，LDAP只是一个协议，它没有涉及到如何存储这些信息，因此还需要一
个后端数据库组件来实现。
这些后端可以 是bdb(BerkeleyDB)、ldbm、shell和passwd等。

LDAP 目录以树状的层次结构来存储数据（这很类同于DNS），最顶层即根部称作“基准DN”，
形如"dc=mydomain,dc=org"或者"o= mydomain.org"，前一种方式更为灵活也是Windows AD中
使用的方式。在根目录的下面有很多的文件和目录，为了把这些大量的数据从逻辑上
分开，LDAP 像其它的目录服务协议一样使用 OU （Organization Unit），
可以用来表示公司内部机构， 如部门等，也可以用来表示设备、人员等。
同时 OU 还可以有子 OU，用来表示更为细致的分类。

LDAP中每一条记录都有一个唯一的区别于其它记录的名字DN（Distinguished Name）,
其处在“叶子”位置的部分称作RDN; 如dn:cn=tom,ou=animals,dc=mydomain,dc=org中tom即为 RDN；
RDN在一个OU中必须是唯一的。

因为LDAP数据是“树”状的，而且这棵树是可以无限延伸的，假设你要树上的一个苹果
（一条记录），你怎么告诉园丁它的位置呢？当然首先要说明是哪一棵树（dc，相当于MYSQL的DB），
然后是从树根到那个苹果所经过的所有“分叉”（ou，呵呵MYSQL里面好象没有这 DD），
最后就是这个苹果的名字（uid，记得我们设计MYSQL或其它数据库表时，通常为了方便管理而
加上一个‘id’字段吗？）。好了！这时我们可以清晰的指明这个苹果的位置了，就是那棵“歪脖树”的东
边那个分叉上的靠西边那个分叉的再靠北边的分叉上的半红半绿的……，晕了！
你直接爬上去吧！我还是说说LDAP里要怎么定义一个字段的位置吧，
树（dc=waibo,dc=com)，分叉（ou=bei,ou=xi,ou= dong），苹果（cn=honglv） :

```shell
dn:cn=honglv,ou=bei,ou=xi,ou=dong,dc=waibo,dc=com  
```

## 基础概念：

### Entry 
条目、记录项。对LDAP的添加、删除、更改、检索的基本对象。

`dn`: 唯一标识一个 entry, (distinguished name). 
eg: baby的 dn : "cn=baby,ou=marketing,ou=people,dc=mydomain,dc=org"

`rdn`: dn逗号最左边的部分，如 上面例子中 rdn : cn=baby。 它与RootDN不同，
RootDN 通常与RootPW同时出现，特指管理LDAP中信息的最高权限用户。

`Base DN` : LDAP 目录树的最顶部就是根(Base DN)， dc=mydomain,dc=org

### Attribute

每个条目都可以有很多属性（Attribute），比如常见的人都有姓名、地址、电话等属性。
每个属性都有名称及对应的值，属性值可以有单个、多个，比如你有多个邮箱。

## 常用命令
```shell
# 搜索
ldapsearch -x

# add
ldapadd -x -D "cn=Manager,dc=hadoop,dc=apache,dc=org" -w passwd -f initdate.ldif
```

