# 链表（双向链表）

链表，方便顺序访问、高效的重排能力、方便增删节点。

## 链表和链表节点

链表节点:
```c
typedef struct listNode {
	struct listNode* prev;
	struct listNode* next;
	void* value;
}listNode;
```

虽然仅仅使用多个listNode结构就可以组成链表，但使用adlist.h/list来持有链表的话，操作起来会更方便：
```c
typedef struct list {
	// 表头节点
	listNode* head;

	// 表尾节点
	listNode* tail;

	// 链表所包含的节点数量
	unsigned long len;

	// 节点值复制函数
	void *(*dup)(void *ptr);

	// 节点值释放函数
	void (*free)(void *ptr);

	// 节点值对比函数
	int (*match)(void* ptr, void* key);
}list;
```
图示如下：
![pic](https://github.com/snipercy/Notes/blob/master/image/list.jpg)

Redis的链表实现的特性可以总结如下：
- **双端**
- **无环**：表头节点的prev 和 表尾的next指向NULL，对链表的访问以NULL为终点
- **带表头指针和表尾指针**
- **带表长度计数器**
- **多态**: 链表节点使用void*侄子能给来保存节点的值，并且可以通过list结构的dup、free、match三个属性为节点值设置类型特定函数，所有
链表可以用于保存各种不同类型的值。

