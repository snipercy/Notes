Kafka 日志删除
======

# 概述

kafka 是一个重度依赖系统文件系统的message queue，消息都是直接存于硬盘，与一些基于内存的 message queue 速度相比，kafka 并不慢甚至更快，原因有顺序读写、零拷贝、日志分段等。而这些保存在硬盘中的数据也不能无休止地存在，故 kafka 提供了多种机制来删除它们。

本文将讨论的是基于文件大小的删除机制，可通过参数 `log.retention.bytes/retention.bytes` 设置文件大小的上限。

# 基于文件大小的删除机制

有两个地方可以设置参数 retention.bytes：server 配置文件和 topic-level （后者的设置会覆盖前者），官网对该参数的解释如下：

![在server配置中的解释](E:\doc\img\log.retention.bytes.jpg)

![在topic-level中的解释](E:\doc\img\retention.bytes.jpg)

实践中，设置了某一 topic 的 retention.bytes 为4096B，server 和 topic 中相关配置见下图

![server-conf](E:\doc\img\server-conf.jpg)

![topic-conf](E:\doc\img\topic-conf.jpg)

下图显示出 log 文件的大小已经为 4206B，超出了我们设置的4096B。

![log-size](E:\doc\img\log-size.jpg)

那么该参数是如何起作用的？一言不合就看代码：

![startup](E:\doc\img\startup.jpg)

kafka 会启动一个定时任务去删除日志，每隔 retentionCheckMs 毫秒（由参数 log.retention.check.interval.ms 指定）就执行一次 cleanupLogs 函数：

![cleanupLogs](E:\doc\img\cleanupLogs.jpg)

上面的函数对所有日志文件调用了 deleteOldSegments() （log.cleanup.policy 应设置为 delete）

![deleteOldSegs](E:\doc\img\code1.jpg)

可以看出 deleteOldSegments() 会调用 deleteRetentionSizeBreachedSegments() 来执行基于 retention.bytes 的删除策略：首先，它计算出最多可以删除的文件大小（diff = size - config.config.retentionSize），接下来调用的 deleteOldSegments(shouldDelete) 会遍历（从最老的开始）所有的 segments，对于小于diff并且不是 active segment 则可以被删除。下图是 deleteOldSegments(shouldDelete) 会调用到的一段关键代码。

![deletableSegments](E:\doc\img\deletableSegments.jpg)

以上代码筛选出满足删除条件的 segments，至于如何删除它们，不再贴代码撑篇幅了，其主要逻辑是：对可删除segment 的文件名添加后缀（.delete）以标识，再启动一个定时任务去删除它们，定时任务的延时可通过参数 file.delete.delay.ms 指定。

# 总结
所以，只有当删除某 inactive segment 后，数据仍然超过我们设定的 retention.bytes，才会删除该 segment；如果删除该 segment 后，数据大小小于设定值，则不删除该 segment。

该参数的探究并不是最终的目的，我们是想要限定一个topic的大小。要解决该问题只需弄清楚上文的 deleteRetentionSizeBreachedSegments() 中的 size 表示的是某个 partition 下所有日志总和还是 topic 下所有日志总和即可，经验证 size 表示的是前者。所以，topic的大小限制应为：partitionNum * retention.bytes。