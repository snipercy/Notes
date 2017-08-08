## 查看物理 cpu 个数、核数、逻辑 cpu 个数
```
# 总核数 = 物理CPU个数 X 每颗物理CPU的核数 
# 总逻辑CPU数 = 物理CPU个数 X 每颗物理CPU的核数 X 超线程数

# 查看物理CPU个数
cat /proc/cpuinfo| grep "physical id"| sort| uniq| wc -l

# 查看每个物理CPU中core的个数(即核数)
cat /proc/cpuinfo| grep "cpu cores"| uniq

# 查看逻辑CPU的个数
cat /proc/cpuinfo| grep "processor"| wc -l
```

## ubuntu 下交换大小写和ctrl按键键位

```sudo vim /etc/default/keyboard```
增加一行：
``` XKBOPTIONS="ctrl:nocaps" ```

``` sudo dpkg-reconfigure keyboard-configuration ```
选择默认安装即可

## zsh安装和配置

ubuntu: ``` sudo apt-get install zsh ```

centos: ``` sudo yum install zsh ```

切换shell：
- 方法一：敲命令``` chsh -s /bin/zsh```
- 方法二：修改配置文件：/etc/passwd

配置： 使用社区的oh-my-zsh默认配置

``` sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" ```
or
wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | sh

## 生成指定大小的文件
``` sd if=/dev/zero of=50M.file bs=1M count=50 ``` 

## 文件访问权限设置
### 通过 chmod 来修改
``` chmod u=rwx,g=rwx,o=rx /user/dir1 /user/dir2 ```

### 通过 acl (粒度更细) 来修改
- 获取: ``` getfacl /user/dir /user/file ```

- 设置 user1 对 /user/file1 拥有rwx权限: ``` setfacl -m d:u:user1:rwx /user/file1 ```

- 设置 group1 对 /user/file1 拥有rwx权限: ``` setfacl -m d:g:group1:rwx /user/file1 ```

- 更多关于acl操作：[man acl](http://linuxcommand.org/man_pages/setfacl1.html)

## tomcat 启动
以可以debug方式启动：
./catalina.sh jpda run


