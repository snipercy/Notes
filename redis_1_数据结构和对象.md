# 简单动态字符串SDS

Redis没有直接使用c语言的字符串表示（与null结尾的字符数组），而是构建了一种名为简单动态字符串的抽象类型(`simple dynamic string, SDS`)。

### (1) SDS的定义 sds.h/sdshdr

```c
struct sdshdr {
	// buf数组中已使用的字节数量
	// 等于SDS所保存的字符串的长度
	int len;

	// buf中空闲字节数
	int free;

	// 字节数组，用于保存字符串
	// 字符串的最后一个字符为'\0'，
	// 但len并不包括这个字符
	char buf[];
};
```

带有未使用空间的SDS示例
```
 ------
|sdshdr|
|------|
|free  |
| 5    |
|------|
|len   |
| 5    | 
|------|  
|buf   |->|'R'|'e'|'d'|'i'|'s'|'\0'| | | | | |
 ------   
```
 ### (2) 使用自定义字符串结构的好处

 > * O(1)时间内获得字符串的长度
 > * 有效防止溢出(strcat时先检测dest空间大小)
 > * 惰性空间释放：用于优化SDS的字符串缩短操作，并不立即free，增加free大小；
     SDS也提供相应API，需要时，可以真正地释放未使用空间。
 > * 二进制安全。这也是SDS的buf称为字节数组的原因，redis不是用数组来保存字符，而是用它来保存一系列二进制数据，使得redis不仅可以保存文本数据，还可以保存任意格式的二进制数据。
 > * 兼容部分c字符串函数

 > 在《c语言接口与实现》一书中，介绍了一个和SDS类似的字符串实现。

### (3) 其他

#### 可变参数函数

`va_arg`  Retrieve next argument (macro )
`va_end`  End using variable argument list (macro )
`va_list` Type to hold information about variable arguments (type )

 ```c
 /* example */
#include <stdio.h>      /* printf */
#include <stdarg.h>     /* va_list, va_start, va_arg, va_end */

void PrintFloats (int n, ...)
{
  int i;
  double val;
  printf ("Printing floats:");
  va_list vl;
  va_start(vl,n);
  for (i=0;i<n;i++)
  {
    val=va_arg(vl,double);
    printf (" [%.2f]",val);
  }
  va_end(vl);
  printf ("\n");
}

int main ()
{
  PrintFloats (3,3.14159,2.71828,1.41421);
  return 0;
}
```

output：Printing floats: [3.14] [2.72] [1.41]


#### 关键字`__attribute__`

关键字`__attribute__`可以为变量、结构体、函数添加属性。

* 为变量、结构体添加属性
```c
// 编译器将以16字节（注意是字节byte不是位bit）对齐的方式分配一个变量
int x __attribute__ ((aligned (16))) = 0;

// aligned后面不指定数值，编译器将依据你的目标机器情况使用最大最有益的对齐方式
short array[3] __attribute__ ((aligned));

// packed 属性，与aligned相反，使用packed可以减小对象占用的空间
struct test
{
	char a;
	int x[2] __attribute__ ((packed));
};

```

* 函数属性
函数属性可以帮助开发者把一些特性添加到函数声明中，从而可以使编译器在错误检查方面的功能更强大。
`__attribute__ format`，该__attribute__属性可以给被声明的函数加上类似printf或者scanf的特征，它可以使编译器检查函数声明和函数实际调用参数之间的格式化字符串是否匹配。该功能十分有用，尤其是处理一些很难发现的bug。
format格式语法为：
```format (archetype, string-index, first-to-check)````

format属性告诉编译器，按照printf, scanf, strftime或strfmon的参数表格式规则对该函数的参数进行检查。
“archetype”指定是哪种风格；
“string-index”指定传入函数的第几个参数是格式化字符串；
“first-to-check”指定从函数的第几个参数开始按上述规则进行检查。
具体使用格式如下：
__attribute__((format(printf,m,n)))
__attribute__((format(scanf,m,n)))
其中参数m与n的含义为：
m：第几个参数为格式化字符串（format string）；
n：参数集合中的第一个，即参数“…”里的第一个参数在函数参数总数排在第几，注意，有时函数参数里还有“隐身”的(this)
在使用上，__attribute__((format(printf,m,n)))是常用的，而另一种却很少见到。下面举例说明，其中myprint为自己定义的一个带有可变参数的函数，其功能类似于printf：
```c
//m=1；n=2
extern void myprint(const char *format,...) __attribute__((format(printf,1,2)));
//m=2；n=3
extern void myprint(int l，const char *format,...) 
```

```c
extern void myprint(const char *format,...) 
__attribute__((format(printf,1,2)));

void test()
{
	myprint("i=%d\n",6);
	myprint("i=%s\n",6);
	myprint("i=%s\n","abc");
	myprint("%s,%d,%d\n",1,2);
}
```
运行$gcc –Wall –c attribute.c attribute后，输出结果为：
>
attribute.c: In function `test':
attribute.c:7: warning: format argument is not a pointer (arg 2)
attribute.c:9: warning: format argument is not a pointer (arg 2)
attribute.c:9: warning: too few arguments for format



























