# Woobuntu #

     __    __            _                 _         
    / / /\ \ \___   ___ | |__  _   _ _ __ | |_ _   _ 
    \ \/  \/ / _ \ / _ \| '_ \| | | | '_ \| __| | | |
     \  /\  / (_) | (_) | |_) | |_| | | | | |_| |_| |
      \/  \/ \___/ \___/|_.__/ \__,_|_| |_|\__|\__,_|
      
    Usage:
    -f	The ubuntu base image you wanna use for woobuntu build
    -o	The output woobuntu image
    -x	Xubuntu optimization for zh_CN & pre-configuration
    -g  gnome-ubuntu optimization for zh_CN & pre-configuration
    -u  Ubuntu original optimization for zh_CN & pre-configuration
    -N  Pre-install NVIDIA driver (Use with causion)
    -V  Pre-install Virtualbox-guest additions (Use with causion)

    Example:

    ./woobuntu_build.sh -f xenial-desktop-amd64.iso -o woobuntu-current-amd64.iso -x


Woobuntu is a automated script based on Ubuntu (currently 16.04) , to create Chinese language infosec research environment with tools & language-stuff . If you're NOT a Chinese , you may consider choosing Kali Linux in English instead .

Woobuntu 是一个基于Ubuntu（目前是16.04版本）的自动配置脚本，它可以自动化安装并配置中文语言环境的安全工具与依赖环境。

Woobuntu 支持两种配置方式，分别为 定制安装镜像 与 直接Ubuntu上安装

## 定制安装镜像（推荐）##

首先你需要下载一个Ubuntu安装镜像，推荐xubuntu-16.04-desktop-amd64.iso，但是理论上其他桌面版本的Ubuntu均支持

    vim woobuntu_chroot_build.sh

注释掉你不需要的工具，或者自己添加你想要的工具

脚本需要root权限运行

    sudo su root

以xubuntu为例:

    ./woobuntu_build.sh -f xubuntu-16.04-desktop-amd64.iso -o woobuntu-current-amd64.iso -x

以gnome-ubuntu为例:

    ./woobuntu_build.sh -f ubuntu-gnome-16.04-desktop-amd64.iso -o woobuntu-current-amd64.iso -g

更多帮助信息请参阅脚本运行提示:

    ./woobuntu_build.sh -h

## 自动安装至已有的Ubuntu系统（仅供有经验的Ubuntu用户使用） ##
                                                 
    ./woobuntu_chroot_build.sh -h

    Usage:
    -c        Used in chroot environment to mount proc & sysfs inside
    -x        Install Xubuntu related packages
    -g        Install gnome-ubuntu related packages
    -u        Install Ubuntu original related packages
    -N        Pre-install NVIDIA driver (Use with causion)
    -V        Pre-install Virtualbox-guest additions (Use with causion)

    Example:

    ./woobuntu_chroot_build.sh -x

## 手动安装至已有的Ubuntu系统 ##

    vim woobuntu_chroot_build.sh

从中选取你需要的工具，然后复制粘贴即可

## 软件中心 ##

您可以在安装完Woobuntu之后使用软件中心安装可选的软件包，其中包括了各种靶场，wine QQ，WPS，搜狗输入法等，Woobuntu不再默认集成这些软件

软件中心作为独立模块，位于

https://github.com/lxj616/woobuntu-installer

## wooyun-firefox Profile ##

目前wooyun定制的firefox个人profile也独立成了一个模块

版本为firefox 47.0+build3-0ubuntu0.16.04.1

https://github.com/lxj616/wooyun-firefox


