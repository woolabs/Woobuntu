# Woobuntu #

Woobuntu is a automated script based on Ubuntu (currently 15.10) , to create Chinese language infosec research environment with tools & language-stuff . If you're NOT a Chinese , you may consider chooseing Kali Linux in English instead .

Woobuntu 是一个基于Ubuntu（目前是15.10版本）的自动配置脚本，它可以自动化安装并配置中文语言环境的安全工具与依赖环境。

## 定制安装镜像（推荐）##

首先你需要下载一个Ubuntu安装镜像，推荐xubuntu-15.10-desktop-amd64.iso，但是理论上其他桌面版本的Ubuntu均支持，之后以root权限运行脚本

vim woobuntu_build.sh

注释掉你不需要的工具，或者自己添加你想要的工具

sudo su root
./woobuntu_build.sh xubuntu-15.10-desktop-amd64.iso

## 直接安装至已有的Ubuntu系统 ##

查看 woobuntu_chroot_build.sh

从中选取你需要的工具，然后复制粘贴即可

## 已知存在的问题 ##

由于wine qq的压缩包太大（ > 100M），无法传至github，因此需要手动下载wine qq的安装包放在源码根目录下


