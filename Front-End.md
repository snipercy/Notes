###1. 边界属性：

* border-color
* border-width
* border-style
* border-radius: 10ps or 50%(圆形)

###2. img

```html
<img src="#" alt="alt text">
```

alt属性：
* 当图片加载失败时显示
* 可以让搜索引擎感知到

###3. list

```html
unordered list
<ul>
  <li>milk</li>
  <li>cheese</li>
</ul>

ordered list
<ol>
  <li></li>
</ol>
```

###4. input placeholder
 placeholder text is what appears in your text input before your user has input
anything.

```html
<input type="text" placeholder="default">
```

###5. form input button

```html
<form action="/submit-cat-photo">
  <input type="text" placeholder="cat photo URL" required>
  <button type="submit">Submit</button>
</form>
```

###6. bootstrap

* button: btn btn-block btn-primary btn-info btn-danger

* 表格排列
```html
<div class="row">
	<div class="col-xs-6"></div>
	<div class="clo-xs-6"></div>
</div>
```

* 矢量图
```html
<i class='fa fa-trash'></i>
<i class='fa fa-info-circle'></i>
<i class='fa fa-thumbs-up'></i>
```

```html
<button class="btn btn-block btn-danger"><i class="fa fa-trash"></i>Del</button>
```

###7. jQuery
there are three ways of targeting elements:

by type:```$("button")```

by class:``` $(".btn")```

by **id**:```$("#target1")```

```js
$(document).ready(function() {
    $("button").addClass("animated bounce");   
    $(".well").addClass("animated shake");	  
    $("#target3").addClass("animated fadeOut");
    $("").removeCladd("");
    $("#target1").css("color","red");
    $("#target1").prop("disabled", "true");
    $("#target5").clone().appendTo("#left-well");



  })
  ```
