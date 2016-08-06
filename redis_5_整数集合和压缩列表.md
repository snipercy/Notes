# 1 整数集合(intset)

用于保存整数值的集合抽象数据结构，它可以保存类型为 int16_t, int32_t, int64_t 的整数值，并且保证集合中不会出现重复的元素，并按序排列。

intset.h/inset:
```c
typedef struct intset {
	// 编码方式
	uint32_t encoding;

	// 集合包含的元素数量
	uint32_t length;

	// 保存元素的数组
	int8_t contents[];
} intset;
```

## 升级

当元素都是int16_t时，每个元素只需占用16bit，若新插入的元素为int32_t或int64_t时则需要进行升级，即扩展contents空间大小，重新分配每个元素所占的bit数。

### 升级的好处

- 节约内存。当然，我们可以全部使用int64_t来保存每个整数，但是耗费了内存空间，所以采用这种升级机制可以有效的节约空间，只需在需要时对整数集合进行升级。

- 提升灵活性。可以随意得将int16_t, int32_t, int64_t类型的整数添加到集合中，而不必担心出现类型错误。

-------

# 2 压缩列表（ziplist）

它是为了节约内存而开发的，是内存连续的数据结构，是列表键和哈希键的底层实现之一。

## 构成

一个压缩列表可以包含多个节点（entry），每个节点可以保存一个字节数组或者一个整数值。

```| zlbytes | zltail | entry1 | ... | entryN | zlend |```

| 属性	  | 类型 	| 长度 	| 用途 	 |
| ------  | -----	| ---	| ----   |
| zlbytes | uint32_t| 4 字节	| 整个压缩表所占内存字节数		 |
| zltail  | uint32_t| 4 字节	| 表尾节点距离其实地址有多少字节	|
| zllen   | uint16_t| 2 字节	| 表所含节点的数量	|
| entryX  | 列表节点	| 不确定	| 节点的长度由节点保存的内容决定	|
| zlend	  | uint8_t | 1 字节	| OxFF，用于标记结尾	|

其中，entry的结构如下：
``` | previous_entry_length | encoding | content | ```
每个entry可以保存一个字节数组或一个整数值。
`previous_entry_length`,记录前一个节点的长度，方便从后往前遍历。
`encoding`, 记录content所保存的数据类型以及长度。
`content`, 可以是一个字节数组或者整数，值得类型和长度由`encoding`决定。









