### 1. Lambda

Lambda表达式的简单语法如下：

```[capture](parameters)->return_type {body}```

```c++
// Lambda例子
// v: vector<int>
std::for_each(std::begin(v), std::end(v), [outer](int n) {std::cout << outer+n << std::endl;});
```
在STL中for_each()最后一个参数需要“函数对象”。函数对象是一个class，这个class重载了operator()，于是这个对象可以像函数那样使用，举个例子：
```c++
// 函数对象例子
template <class T>
class less
{
public:
    bool operator()(const T&l, const T&r)const
    {
        return l < r;
    }
};
```

所以，c++引入Lambda的最主要原因:
> 1. 可以定义匿名函数
  2. 编译器会将其转成函数对象

除了方便外，还有什么好处呢？它比传统的函数或函数对象有什么好处呢？Lambda也被称之为`闭包(closure)`，可能是因为它限制了别人的访问，是私有的，没有函数名。

### 2. 自动类型推导auto和decltype

auto：编译器通过初始化值推到出类型，减少程序员的负担，增加了编译时间，使用该关键字可能使代码看起来更加简洁，可是，也没法通过auto直接看出变量的类型，有得必有失。
decltype：是一个操作符，可以评估括号内表达式的类型。如果表达式是参数，返回参数类型；如果表达式是函数，则返回这个函数的返回值类型。

### 3. 统一初始化语法

C++11用大括号统一了初始化的方法。
例子：
```c++
int arr[4] = {0,1,2,3};
int* ptr = new int[3] {1,2,0};
vector<string> vs = {"first", "second","third"};
map map_ = {
	{"abc","123"},
	{"aaa","345"} };
```

### 4. Delete和Default函数

我们知道c++的编译器在你没有定义某些成员函数的时候会给你的类自动生成这些函数，比如构造函数，拷贝构造函数，赋值构造函数，析构函数。有些时候，我们不想要这些函数，比如，构造函数，因为我们想做实现单例模式。传统的做法是将其声明成private类型。
在C++11中引入了两个指示符，delete意为告诉编译器不自动产生这个函数，default告诉编译器产生一个默认的。
```c++
// default
struct A
{
    A()=default; //C++11
    virtual ~A()=default; //C++11
};

```

```c++
// delete
struct NoCopy
{
    NoCopy & operator =( const NoCopy & ) = delete;
    NoCopy ( const NoCopy & ) = delete;
};
NoCopy a;
NoCopy b(a); //compilation error, copy ctor is deleted
```

在c++中，只要你定义了一个构造函数，编译器就不会给你生成一个默认的了。所以，为了要让默认的和自定义的共存，才引入这个参数：
```c++
struct SomeType
{
 SomeType() = default; // 使用编译器生成的默认构造函数
 SomeType(OtherType value);
};
```
`delete`的其他用法：
* 1. 让对象只能生成在栈内存上：
```c++
struct NonNewable {
    void *operator new(std::size_t) = delete;
};
```
* 2. 阻止函数的其他形参的类型调用：（若尝试以 double 的形参调用 f()，将会引发编译期错误， 编译器不会自动将 double 形参转型为 int 再调用f()）
```c++
void f(int i);
void f(double) = delete;
```

### 5. 右值引用和move语义


### 6. 智能指针
c++98的智能指针是auto_ptr，在c++11中被废弃了。c++11引入了两个指针类：`shared_ptr`和`unique_ptr`。
shared_ptr只是单纯的引用计数指针；
unique_ptr是用来取代auto_ptr
