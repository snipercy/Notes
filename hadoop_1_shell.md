
> HDFS允许管理员对各个目录设定文件的个数(name quotas)或者空间使用(space quotas)总量。其中“name quotas”和“space quotas”可以分别设定。

### Name Quotas
Name Quota用来控制目录下文件或者子目录的个数。如果超过了设定的quota，那么创建文件或者目录将会失败。
目录重命名不会改变原有的quotas。
但是，如果现有的目录和文件个数已经违反了Quota设定，尝试对目录设定quota也会成功。
 
### Space Quotas
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