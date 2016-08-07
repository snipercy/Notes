> hadoop的计算资源的管理是通过一个xml文件（fair-scheduler.xml）进行配置的，
在对资源的管理时需要频繁地对修改xml文件（增/删/改/查节点）,
所以有必要熟悉下java如何操作xml。

===============
> [扯淡]关于标记型文本的操作，JS中有JQuery，python中beautifulsoup，java中有dom4j库，
原理都是一样的，就是将xml/html这种标记型文本解析成dom树
（html转换成dom树是由浏览器进行解析的），
然后就可以高效的对该树型结构进行增删改查了。

==============

# dom4j 简单介绍：

##  DOM 对象创建

- 通过 *.xml 文件创建
``` java
SAXReader reader = new SAXReader();
Document doc = reader.read(new File("input.xlm"));
```

- 通过字符串转化
 ``` java
String fari-scheduler = "<allocations> <queue name='root'>...</queue> </allocations>" ;
Document doc = DocumentHelper.parseText(text);
 ```

- 手动构造
```java
	Document doc = DocumentHelper.createDocument();
	Element root = document.addElement("members"); // 创建节点
```

## 操作 DOM

- 根节点
```java Element root = doc.getRootElement(); ```

- 取节点

- 取节点(单个)
``` java 

Element memberEle = root.element("member"); // member 是节点名 

elm.selectObject("queue[@name='renter_1']");
```

- 取节点(多个)
> 取某节点下名为“member” 的**所有**子节点并遍历(```root.elemets("..."))

``` java
List nodes = root.elements("member");
for (Iterator it = nodes.iterator(); it.hasNext();) {
	Element elm = (Element)it.next();
	// do something
}
```

- 父节点
``` elm.getParent() ```

- 取Text (```.getText()```)
> 去节点中的内容

```java  String text = memberEle.getText(); ```

- 遍历
> 对某节点下所有子节点进行遍历(```root.elementiterator();```)

``` java
for (Iterator it = root.elementiterator(); it.hasNext();) {
	Element elem = (Element)it.next();
	// do something
}
```

- 添加节点
```java
Element elm = root.addElement("queue"):
elm.setText("....");
```

- 删除节点
```java 
parentElm.remove(childElm);
```

- 获取父亲节点
elm.getParent();

## 属性相关
> .attributeValue()
> .iteratorIterator()
> .addAttribute()
> .remove(attri)

- 取得某节点下的某属性
``` java
Element root = document.getRootElement();
Attribute attr = root.atti

// 获取属性文字
String text = attr.getText();

// or
String text2=root.element("name").attributeValue("firstname");

// 修改某属性的值
note.element("maxResource").setText("1024mb,1vcores");

// 添加(.addAttribute)
root.addAttribute("name", "cy");

// 删除(remove())
Attributer attribute = root.attribute("queue");
root.remove(attribute);

// 遍历
Element root = doc.getRootElement();
for (Iterator it = root.attributerIterator; it.hasNext();) {
	Attribute attribute = (Attribute)it.next();
	String text = attribute.getText();
	print text;
}

```

## 写入文件

```java
// 不设置编码
XMLWriter writer = new XMLWrite(new FileWriter("output.xml"));
writer.write(document);
writer.close();
```
