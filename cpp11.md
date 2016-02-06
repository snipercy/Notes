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
左值就是一个有名字的对象，而右值则是一个无名对象（临时对象）。move语义允许修改右值（以前右值被看作是不可修改的，等同于const T&类型）。

C++的class或者struct以前都有一些隐含的成员函数：默认构造函数（仅当没有显示定义任何其他构造函数时才存在），拷贝构造函数，析构函数还有拷贝赋值操作符。拷贝构造函数和拷贝赋值操作符提供bit-wise的拷贝（浅拷贝），也就是逐个bit拷贝对象。也就是说，如果你有一个类包含指向其他对象的指针，拷贝时只会拷贝指针的值而不会管指向的对象。在某些情况下这种做法是没问题的，但在很多情况下，实际上你需要的是深拷贝，也就是说你希望拷贝指针所指向的对象。而不是拷贝指针的值。这种情况下，你需要显示地提供拷贝构造函数与拷贝赋值操作符来进行深拷贝。
如果你用来初始化或拷贝的源对象是个右值（临时对象）会怎么样呢？你仍然需要拷贝它的值，但随后很快右值就会被释放。这意味着产生了额外的操作开销，包括原本并不需要的空间分配以及内存拷贝。

c++11增加了新的引用类型：`右值引用(R-value reference)`，标记为`typename &&`。它们能够以non-const值的方式传入，允许对象去改动它们。

```c++
void naiveswap(string &a, string &b)
{
 string temp = a;
 a=b;
 b=temp;
}
```
上面的代码，在交换两个string的过程中产生了对象的构造，内存分配还有对象的拷贝构造以及临时对象的析构等，成本较高。

`string`类中保存了一个动态内存分存的char*指针，如果一个string对象发生拷贝构造（如：函数返回），string类里的`char*`内存只能通过创建一个新的临时对象，并把函数内的对象的内存copy到这个新的对象中，然后销毁临时对象及其内存。

通过右值引用，string的构造函数需要改成“move构造函数”，如下所示。这样一来，使得对某个stirng的右值引用可以单纯地从右值复制其内部C-style的指针到新的string，然后留下空的右值。这个操作不需要内存数组的复制，而且空的暂时对象的析构也不会释放内存，更有效率。
```c++
class string
{
    string (string&&); //move constructor
    string&& operator=(string&&); //move assignment operator
};
```

现在说说`move constructor`和`move assignment operator`。这两个函数接收`T&&`类型的参数，也就是一个右值。在这种情况下，它们可以修改右值对象，“偷走”它们内部指针所指向的对象。
show me the code（看一段代码来感受下）

```c++
#include<cstdlib>
#include<string>
#include<cassert>

template<typename T>
class Buffer {
	size_t _size;
	std::unique_ptr<T[]> _buffer;
public:
	std::string _name;
// default constructor

	Buffer() : _size(16), _buffer(new T[16]) {
		printf("default constructor\n");
	}

// constructor
	Buffer(const std::string &name, size_t size) :
			_name(name),
			_size(size),
			_buffer(new T[size]) {
		printf("constructor\n");
	}


// copy constructor
	Buffer(const Buffer &copy) :
			_name(copy ._name),
			_size(copy ._size),
			_buffer(new T[copy._size]) {
		printf("copy constructor\n");
		T *source = copy._buffer.get();
		T *dest = _buffer.get();
		std::copy(source, source + copy._size, dest);
	}

// copy assignment operator
	Buffer &operator=(const Buffer &copy) {
		if (this != &copy) {
			printf("copy assignment constructor\n");
			_name = copy._name;
			if (_size != copy._size)
			{
				_buffer = nullptr;
				_size = copy._size;
				_buffer = _size > 0 ? new T[_size] : nullptr;
			}
			T *source = copy._buffer.get();
			T *dest = _buffer.get();
			std::copy(source, source + copy._size, dest);
		}
		return *this;
	}

// move constructor
	Buffer(Buffer &&temp) :
			_name(std::move(temp ._name)),
			_size(temp ._size),
			_buffer(std::move(temp ._buffer)){
		printf("move constructor\n");
		temp._buffer = nullptr;
		temp._size = 0;
	}

// move assignment operator
	Buffer &operator=(Buffer &&temp)
	{
		assert(this != &temp);
		// assert if this is not a temporary
		printf("move assignment constructor\n");

		_buffer = nullptr;
		_size = temp._size;
		_buffer = std::move(temp._buffer);

		_name = std::move(temp._name);
		temp._buffer = nullptr;
		temp._size = 0;

		return *this;
	}
};

template<typename T>
Buffer<T> getBuffer(const std::string &name) {
	return Buffer<T>(name, 128); 
}

int main() {
	//Buffer<int> b1;
	//Buffer<int> b2("buf2", 64);
	//Buffer<int> b3 = b2;
	Buffer<int> b4 = getBuffer<int>("buf4"); // ①
	//b1 = getBuffer<int>("buf5"); // ② 
	return 0;
}
```
语句①：getBuffer函数返回的应该是临时对象，为右值，所以`b4`构造时调用的应该是`move constructor`。但是实际上，b4的对象的构造仅仅只调用了一次constructor函数。
原因是，c++的编译器中有一种叫`返回值优化(RVO, Return Value Optimization)`的东东。(c++的编译器真的做了很多事情，要学好用好c++必须得清楚编译器做了啥，不然会弄巧成拙)

* `返回值优化(RVO)`是现代c++编译器都拥有的功能。根据effective modern c++中介绍，编译器进行RVO条件有:
 * 1. return 的值类型与 函数签名的返回值类型相同;
 * 2. return的是一个局部对象。

 还是以对象b4的构造为例，若是没有该优化，则需要先调用构造函数构造临时对象，然后再调用复制构造函数构造b4，最后析构临时对象。可以看出，临时对象的存在实在是很浪费的，占用空间，而且只是为b4的构造而存在，b4构造完了之后生命也就终结了。这个临时的对象对于程序员来说是`透明的`，于是编译器干脆在里面做点手脚，不生成它们！
怎么做呢？编译器“偷偷地”在我们写的`getBuffer`函数中增加一个参数 Buffer<T>&，然后把b4的地址传进去（注意，这个时候b4的内存空间已经存在了，但对象还没有被“构造”，即构造函数还没有被调用），然后在函数体内部，直接用b4来代替原来的“临时对象”，在函数体内部就完成b4的构造。

* `具名返回值优化(NRVO)`：和RVO类似，只不过临时对象有名字，`getBuffer`函数改为下面这样即可：
```c++
...
template<typename T>
Buffer<T> getBuffer(const std::string &name) {
	Buffer<T> b(name, 128); 
	return b;
}
...
```

我们可以把语句①修改成这样：
```c++
Buffer<int> b4 = (std::move(getBuffer<int>("buf4"))); // ①
```
这样，返回值优化就失效了，此时，b4构造时会调用`constructor`和`move constructor`，感觉效率上可能会有所损失，毕竟多了一个`move constructor`的开销。

语句②：会调用move assignment operator

总结一下：右值引用是一个提高性能的好东西，要想使用它，需要添加move构造函数的定义。即使在我们编写的代码中没有显示使用它，只要我们用了c++11的STL，也能享受它带来的好处，STL中的string、vector等类都增加了move语义，增加了效率。
使用move时也需要注意，上面发现的move语义导致返回值优化的失效不知道算不算一个坑，本意上我们希望使用右值引用提高程序的效率，但是却导致返回值优化失效了，程序的效率并没有提高。
> 右值引用可以理解为是优化栈空间的利用

[补充材料] (http://stackoverflow.com/questions/4986673/c11-rvalues-and-move-semantics-confusion-return-statement?lq=1)

### 6. 智能指针
c++98的智能指针是auto_ptr，在c++11中被废弃了。c++11引入了两个指针类：`shared_ptr`和`unique_ptr`。
shared_ptr只是单纯的引用计数指针；
unique_ptr是用来取代auto_ptr, 如果内存资源的所有权不需要共享，就应当使用这个（它没有拷贝构造函数），但是它可以转让给另一个unique_ptr（存在move构造函数）。

### 7. Range-based for loops （基于范围的for循环）
```c++
int arr[] = {1,2,3,4,5};
	for(auto e : arr)
	{
		// do something
	}
```
======
c++14改动较小，主要是完成制定C++11标准的剩余工作。
```c++
auto lambda = [](auto x, auto y) {return x + y;};
```
C++11要求Lambda参数使用具体的类型声明，比如：
```c++
auto lambda = [](int x, int y) {return x + y;};
```
此外，新标准中的std::move函数可用于捕获Lambda表达式中的变量，这是通过移动对象而非复制或引用对象实现的：
```c++
std::unique_ptr ptr(new int(10));
auto lambda = [value = std::move(ptr)] {return *value;};
```
