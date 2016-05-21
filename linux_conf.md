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

