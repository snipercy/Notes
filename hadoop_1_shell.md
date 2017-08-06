
## hive
jdbc:hive2://20.26.29.46:10000/test_zhejian23?hadoop.security.bdoc.access.id=f21c375953df0c0fcf17;hadoop.security.bdoc.access.key=16e7104c92df7e5728296584c3bda7abdb49689c

beeline 连接hive  zk模式
!connect jdbc:hive2://dsjtest-16.novalocal:2181,dsjtest-17.novalocal:2181,dsjtest-18.novalocal:2181/default;serviceDiscoveryMode=zookeeper;zooKeeperNamespace=hiveserver2?hadoop.security.bdoc.access.id=0aca8fd72c0e57dad87f;hadoop.security.bdoc.access.key=hive

### rest api
> 参考地址 https://cwiki.apache.org/confluence/display/Hive/WebHCat+Reference

- 获取所有的数据库列表
```
curl -s 'http://localhost:50111/templeton/v1/ddl/database?user.name=hive&like=*' 

json output:
{
    "databases": [
       "newdb",
        "newdb2"
    ]
}

```

- 删除某个数据库
```
curl -s -X DELETE "http://localhost:50111/templeton/v1/ddl/database/{db_name}?user.name=hive"

json output:
{
  "database":"newdb"
}

```




# hdfs 
## datanode 启动不了

ps aux | grep -ri datanode | grep -v grep | cut -c 9-15 |xargs kill -9;rm -f /var/run/hadoop/hdfs/hadoop_secure_dn.pid;

每个datanode节点执行一下

## namenode 启动不了

``` /var/lib/ambari-agent/ambari-sudo.sh su hdfs -l -s /bin/bash -c 'export JAVA_HOME=/usr/jdk64/jdk1.7.0_67; ulimit -c unlimited ;  /cmss/bch/bc1.3.1/hadoop/sbin/hadoop-daemon.sh --config /cmss/bch/bc1.3.1/hadoop/etc/hadoop start namenode' ```
报错：
```
Java HotSpot(TM) 64-Bit Server VM warning: INFO: os::commit_memory(0x00000000bc800000, 864026624, 0) failed; error='Cannot allocate memory' (errno=12)
```
原因：内存不足(free -m)



# Hadoop 

## 运行MR

-m map数 -r reduce数 -mt map执行时间毫秒 -rt reduce执行时间毫秒


/cmss/bch/bc1.3.1/hadoop/bin/hadoop jar /cmss/bch/bc1.3.1/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.6.0-bc1.3.1.jar pi -D mapreduce.job.queuename=root.chengy.renter_1.dev_11 1 1000

/cmss/bch/bc1.3.2/hadoop/bin/hadoop jar /cmss/bch/bc1.3.2/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-2.6.0-bc1.3.2.jar sleep -m 10 -r 10 -mt 5000 -rt 5000


# slider

刪除僵尸進程：(slider stop/destroy 失效的情况下使用)
yarn application -kill {appID}

指定队列启动 slider 应用
``` shell
slider start appname -D slider.yarn.queue=queuefullname 
```

slider 创建应用模板：/slider/template/{appConfig.json, resources.json}

# ambari

手动启动服务：(启动 namenode)

```
var/lib/ambari-agent/ambari-sudo.sh su hdfs -l -s /bin/bash -c 'export JAVA_HOME=/usr/jdk64/jdk1.7.0_67; 
ulimit -c unlimited ; 
/cmss/bch/bc1.3.1/hadoop/sbin/hadoop-daemon.sh --config /cmss/bch/bc1.3.1/hadoop/etc/hadoop start namenode'
```

# HDFS
> 
HDFS允许管理员对各个目录设定文件的个数(name quotas)或者空间使用(space quotas)总量。其中“name quotas”和“space quotas”可以分别设定。

## Name Quotas
Name Quota用来控制目录下文件或者子目录的个数。如果超过了设定的quota，那么创建文件或者目录将会失败。
目录重命名不会改变原有的quotas。
但是，如果现有的目录和文件个数已经违反了Quota设定，尝试对目录设定quota也会成功。
 
## Space Quotas
Space Quota 控制目录下文件占用的磁盘空间总量。如果 Space quota 不允许一个block写入目录，那么block分配将会失败。 目录重命名不会改变原有的Quotas，如果rename导致违法Quotas将会导致操作失败。
一个新建的目录没有Quotas限制。Quota最大值为Long.MAX_VALUE。
***(实验发现：最大只能设置为Long_MAX_VALUE - 1)***如果此值为0，允许创建文件（元数据不占space quota），
但是任何此文件将不能添加任何blocks(即只能创建空文件)。目录，不消耗本地文件系统的空间(它只不过是namespace标记)，因此不计入space Quota。存储metadata的文件也不会计入Quota。文件的replication factor也会占用quota，修改一个文件的replication factor会改变相应目录下Quota的空间(Quota结余或者超限)。
 
## 管理指令
- 查看文件目录的Quota：` hdfs dfs -count [-q, -h] <directory> `
显示结果列含义如下：
```shell
$ hdfs dfs -count :  
DIR_COUNT, FILE_COUNT, CONTENT_SIZE, PATHNAME

$ hdfs dfs -count -q :  
QUOTA, REMAINING_QUATA, SPACE_QUOTA, REMAINING_SPACE_QUOTA, DIR_COUNT, FILE_COUNT, CONTENT_SIZE, PATHNAME

// The -h option shows sizes in human readable format.
// The -v option displays a header line.
```


- Quota：默认目录没有任何Quota。
``` hdfs dfsadmin -setQuota <num> <directory> ```

- 清楚Quota，此后目录的quota为“none”(无限制)
``` hdfs dfsadmin -clrQuota <directory> ```

- Quota：限定目录下文件存储的空间
``` hdfs dfsadmin -setSpaceQuota <num> <directory>```，
单位：字节。这个是一个硬性的设定，控制目录树下所有文件的总尺寸。
replication也会计算在内，比如1G的文件，如果有3个replication，那么它消耗的Quota为3G。
其中“num”的值后可以跟上“g”、“t”单位名称。

- 清除Space Quota：
``` hdfs dfsadmin -clrSpaceQuota <directory> ```


# hc 手动启动服务：
 /var/lib/ambari-agent/ambari-sudo.sh su hdfs -l -s /bin/bash -c 'export JAVA_HOME=/usr/jdk64/jdk1.7.0_67; ulimit -c unlimited ; /cmss/bch/bc1.3.1/hadoop/sbin/hadoop-daemon.sh --config /cmss/bch/bc1.3.1/hadoop/etc/hadoop start namenode'

# yarn - yarn.scheduler.xml

```html
<queuePlacementPolicy>
<rule name="specified" create="false" />
<rule name="reject" />
</queuePlacementPolicy>
```
queuePlacementPolicy 元素定义了一个规则列表，其中的每个规则会被逐个尝试直到匹配成功。最后一个规则必须是reject或default，表示不再继续匹配规则。
specified 表示提交MR任务(app)时需要指定提交到那个队列上，当指定的队列不存在时不创建队列(create='false')
*当不指定 queuePlacementPolicy 时*，调度器会采用如下规则，即指定的队列未创建，会以用户名为队列名创建队列。
```
<queuePlacementPolicy>
<rule name="specified" />
<rule name="user" />
</queuePlacementPolicy>
```
>实现上面功能我们还可以不使用配置文件，直接设置yarn.scheduler.fair.user-as-default-queue=false，这样应用便会被放入default 队列，而不是各个用户名队列。另外，我们还可以设置yarn.scheduler.fair.allow-undeclared-pools=false，这样用户就无法创建队列了。
yarn ACL
通过fair-scheduler.xml 设置
root 节点设置添加属性：
```
<aclAdministerApps> </aclAdministerApps>
<aclSubmitApps> </aclSubmitApps>
```
上述的两个选项值为 空格 表示任何用户都没有权限使用/管理队列，若不设置默认的acl为`*`，表示任何用户都有权限，那么即使子队列在设置这两个选项也没有作用。这是因为，系统会递归得祖先acl的设置，然后逐步往下级匹配acl，一旦匹配成功则拥有权限，不再往下级匹配了。所以为了让每个队列（叶子节点）所配置的acl生效，需要将根队列设置为 任何人都没有权限。
>
An action on a queue will be permitted if its user or group is in the ACL of that queue or in the ACL of any of that queue's ancestors. So if queue2 is inside queue1, and user1 is in queue1's ACL, and user2 is in queue2's ACL, then both users may submit to queue2.


# error log
User [dr.who] is not authorized to view the logs for container_1476067904027_0058_01_000001 in log file [node5_45454]

core-site.xml
hadoop.http.staticuser.user=yarn

yarn.admin.acl  =  yarn,dr.who

mapreduce.job.acl-view-job = dr.who


24号：
创建kylin失败：
