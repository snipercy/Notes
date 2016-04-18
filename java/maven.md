# maven

构建一个 helloworld 项目

```shell
mvn archetype:generate -DgroupId=com.mycompany.helloworld -DartifactId=helloworld -Dpackage=com.mycompany.helloworld -Dversion=1.0-SNAPSHOT

mvn package 

java -cp target/helloworld-1.0-SNAPSHOT.jar com.mycompany.helloworld.App
```

## 核心概念
- POM (Project Object Model)
- Maven 插件
- Maven 生命周期
- Maven 依赖管理
- Maven 库

### POM

一个项目所有的配置都放置在 POM 文件中：定义项目的类型、名字，管理依赖关系，定制插件的行为等等。比如说，你可以配置 compiler 插件让它使用 java 1.5 来编译。

groupId, artifactId, packaging, version 叫作 maven 坐标它能唯一的确定一个项目。有了 maven 坐标，我们就可以用它来指定我们的项目所依赖的其他项目，插件，或者父项目。一般 maven 坐标写成如下的格式：
	
	groupId:artifactId:packaging:version

像我们的例子就会写成：

	com.mycompany.helloworld: helloworld: jar: 1.0-SNAPSHOT

上面的 helloworld 示例很简单，但是大项目一般会分成几个子项目。在这种情况下，每个子项目就会有自己的 POM 文件，然后它们会有一个共同的父项目。这样只要构建父项目就能够构建所有的子项目了。子项目的 POM 会继承父项目的 POM。另外，所有的 POM 都继承了一个 Super-POM。Super-POM 设置了一些默认值，比如在第一篇文章中提到的默认的目录结构，默认的插件等等，它遵循了惯例优于配置的原则。所以尽管我们的这个 POM 很简单，但是这只是你看得见的一部分。运行时候的 POM 要复杂的多。 如果你想看到运行时候的 POM 的全部内容的话，可以运行下面的命令：
	$mvn help:effective-pom

### Maven 插件

`mvn archetype:generate` 生成一个项目，
`archetype` 是一个插件的名字，generate是目标(goal)的名字。这个命令的意思是告诉 maven 执行 archetype 插件的 generate 目标。插件目标通常会写成 pluginId:goalId

一个目标是一个工作单元，而插件则是一个或者多个目标的集合。比如说Jar插件，Compiler插件，Surefire插件等。Jar 插件包含建立 Jar 文件的目标， Compiler 插件包含编译源代码和单元测试代码的目标。Surefire 插件的话，则是运行单元测试。

所以，mvn 本身不会做太多的事情，它不知道怎么样编译或者怎么样打包。它把构建的任务交给插件去做。插件定义了常用的构建逻辑，能够被重复利用。这样做的好处是，一旦插件有了更新，那么所有的 maven 用户都能得到更新。

### Maven 生命周期

构建项目的第二个命令是 `mvn package `。这里的 package 是一个 maven 的生命周期阶段 (lifecycle phase )。生命周期指项目的构建过程，它包含了一系列的有序的阶段 (phase)，而一个阶段就是构建过程中的一个步骤。

那么生命周期阶段和上面说的插件目标之间是什么关系呢？插件目标可以绑定到生命周期阶段上。一个生命周期阶段可以绑定多个插件目标。当 maven 在构建过程中逐步的通过每个阶段时，会执行该阶段所有的插件目标。

maven 能支持不同的生命周期，但是最常用的是默认的Maven生命周期 (default Maven lifecycle )。如果你没有对它进行任何的插件配置或者定制的话，那么上面的命令 mvn package 会依次执行默认生命周期中直到包括 package 阶段前的所有阶段的插件目标：

	process-resources 阶段：resources:resources
	compile 阶段：compiler:compile
	process-classes 阶段：(默认无目标)
	process-test-resources 阶段：resources:testResources
	test-compile 阶段：compiler:testCompile
	test 阶段：surefire:test
	prepare-package 阶段：(默认无目标)
	package 阶段：jar:jar

### Maven 依赖管理

maven 坐标能够确定一个项目。换句话说，我们可以用它来解决依赖关系。在 POM 中，依赖关系是在 `dependencies` 中定义的。在上面的 POM 例子中，我们用 dependencies 定义了对于 junit 的依赖：

```xml
  <dependencies> 
    <dependency> 
      <groupId>junit</groupId> 
      <artifactId>junit</artifactId> 
      <version>3.8.1</version> 
      <scope>test</scope> 
    </dependency> 
  </dependencies> 
```

那这个例子很简单，但是实际开发中我们会有复杂得多的依赖关系，因为被依赖的 jar 文件会有自己的依赖关系。那么我们是不是需要把那些间接依赖的 jar 文件也都定义在POM中呢？答案是不需要，因为 maven 提供了传递依赖的特性。

所谓传递依赖是指 maven 会检查被依赖的 jar 文件，把它的依赖关系纳入最终解决的依赖关系链中。针对上面的 junit 依赖关系，如果你看一下 maven 的本地库（我们马上会解释 maven 库）~/.m2/repository/junit/junit/3.8.1/ ，

![mvn.png]()

你会发现 maven 不但下载了 junit-3.8.1.jar，还下载了它的 POM 文件。这样 maven 就能检查 junit 的依赖关系，把它所需要的依赖也包括进来。

在 POM 的 dependencies 部分中，scope 决定了依赖关系的适用范围。我们的例子中 junit 的 scope 是 test，那么它只会在执行 compiler:testCompile and surefire:test 目标的时候才会被加到 classpath 中，在执行 compiler:compile 目标时是拿不到 junit 的。

我们还可以指定 scope 为 provided，意思是 JDK 或者容器会提供所需的jar文件。比如说在做web应用开发的时候，我们在编译的时候需要 servlet API jar 文件，但是在打包的时候不需要把这个 jar 文件打在 WAR 中，因为servlet容器或者应用服务器会提供的。

scope 的默认值是 compile，即任何时候都会被包含在 classpath 中，在打包的时候也会被包括进去。


### Maven 库

当第一次运行 maven 命令的时候，你需要 Internet 连接，因为它要从网上下载一些文件。那么它从哪里下载呢？它是从 maven 默认的远程库(http://repo1.maven.org/maven2) 下载的。这个远程库有 maven 的核心插件和可供下载的 jar 文件。

但是不是所有的 jar 文件都是可以从默认的远程库下载的，比如说我们自己开发的项目。这个时候，有两个选择：要么在公司内部设置定制库，要么手动下载和安装所需的jar文件到本地库。

本地库是指 maven 下载了插件或者 jar 文件后存放在本地机器上的拷贝。在 Linux 上，它的位置在 ~/.m2/repository，在 Windows XP 上，在 C:\Documents and Settings\username\.m2\repository ，在 Windows 7 上，在 C:\Users\username\.m2\repository。当 maven 查找需要的 jar 文件时，它会先在本地库中寻找，只有在找不到的情况下，才会去远程库中找。

运行下面的命令能把我们的 helloworld 项目安装到本地库：

	$mvn install

一旦一个项目被安装到了本地库后，你别的项目就可以通过 maven 坐标和这个项目建立依赖关系。比如如果我现在有一个新项目需要用到 helloworld，那么在运行了上面的 mvn install 命令后，我就可以如下所示来建立依赖关系：

```
    <dependency>
      <groupId>com.mycompany.helloworld</groupId>
      <artifactId>helloworld</artifactId>
      <version>1.0-SNAPSHOT</version>
    </dependency> 
```

好了，maven 的核心概念就简单的介绍到这里。至于在 Eclipse 中如何使用 maven，这个网上很多了，google 一下就行。
 
