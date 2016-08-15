- String 字符串常量
- StringBuffer 字符串变量（线程安全）
- StringBuilder 字符串变量（非线程安全）

### 字符串

String 处理不变的字符串，任何对 String 的改变都会引发**新的 String** 对象的生成

- String： 不可改变
- StringBuffer： 可变字符串序列，内存中保存的痛String一样，都是有序char数组，不同的是 StringBuffer 对象的值都是可变的。
- StringBuilder： 与 StringBuffer 区别是线程安全

```java
String s1 = "hello";			// 静态创建字符串
String s2 = new String("你好"); // 动态创建字符串
```


判断相等：

	s1 == s2;					// s1 与 s2 是否指向同一个对象
	s1.equals(s5);				// 内容是否完全一致
	s1.equalsIgnoreCase(s2);	// 忽略大小写比较

String 类的”=“、”+“、”+=“，看似运算符重载，实际只是Java编译器做了一点手脚，对String运算符做了特殊处理。

```java
String s = "hello ";
s += "world";		 // 编译器转换成：s = (new StringBuilder()).append(s).append("world").toString();
```

`StringBuffer`  处理可变字符串（线程安全），不可被继承（final）
`StringBuilder` 处理可变字符串（线程不安全，拥有更高的性能），不可被继承（final），JDK1.5引入

