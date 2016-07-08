hadoop的计算资源的管理是通过一个xml文件（fair-scheduler.xml）进行配置的，在对资源的管理的过程中需要对xml进行修改（增/删/改/查节点）操作所以有必要熟悉java操作xml。
在java中可以选用dom4j库，dom4j就是将xml文件解析成一个dom树，然后对这颗树进行查找删除节点，方便了并且效率也高了，类似的库有JS的JQuery，python的beautifulsoup等。

下面对 dom4j 进行简单的介绍：

##  DOM 对象创建

1. 通过 *.xml 文件获取
 ``` java
SAXReader reader = new SAXReader();
Document doc = reader.read(new File("input.xlm"));
 ```

2. 通过String 转化
 ``` java
String fari-scheduler = "<allocations> <queue name='root'>...</queue> </allocations>" ;
Document doc = DocumentHelper.parseText(text);
 ```

3. 手动创建
```java
	Document doc = DocumentHelper.createDocument();
	Element root = document.addElement("members"); // 创建节点
```

## 操作 DOM

#### 根节点
```java Element root = doc.getRootElement(); ```

#### 取节点(单个)
```java Element memberEle = root.element("member"); // queue 是节点名 ```

####  取节点(多个)
> 取某节点下名为“member” 的**所有**子节点并遍历(```root.elemets("..."))

``` java
List nodes = root.elements("member");
for (Iterator it = nodes.iterator(); it.hasNext();) {
	Element elm = (Element)it.next();
	// do something
}
```

#### 取Text (```.getText()```)
> 去节点中的内容

```java  String text = memberEle.getText(); ```

#### 遍历
> 对某节点下所有子节点进行遍历(```root.elementiterator();```)

``` java
for (Iterator it = root.elementiterator(); it.hasNext();) {
	Element elem = (Element)it.next();
	// do something
}
```

####  添加节点
```java
Element elm = root.addElement("queue"):
elm.setText("....");
```

#### 删除节点
```java 
parentElm.remove(childElm);
```

## 属性相关
> .addAttribute()
> .attributeValue()
> .iteratorIterator()

#### 取得某节点下的某属性
``` java
Element root = document.getRootElement();
Attribute attr = root.atti

// 获取属性文字
String text = attr.getText();
// or
String text2=root.element("name").attributeValue("firstname");

// 添加属性和内容(.addAttribute)
root.addAttribute("name", "cy");
```

#### 遍历(attributeIterator())
``` java
Element root = doc.getRootElement();
for (Iterator it = root.attributerIterator; it.hasNext();) {
	Attribute attribute = (Attribute)it.next();
	String text = attribute.getText();
	print text;
}
```