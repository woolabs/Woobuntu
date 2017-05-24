#!/bin/sh

#Author : woolabs team 
#Maintainer : lxj616@wooyun

install_xfce_desktop=0
install_gnome_desktop=0
install_unity_desktop=0

install_nvidia_driver=0
install_virtualbox_additions=0

show_help() {

echo " __    __            _                 _         ";
echo "/ / /\ \ \___   ___ | |__  _   _ _ __ | |_ _   _ ";
echo "\ \/  \/ / _ \ / _ \| '_ \| | | | '_ \| __| | | |";
echo " \  /\  / (_) | (_) | |_) | |_| | | | | |_| |_| |";
echo "  \/  \/ \___/ \___/|_.__/ \__,_|_| |_|\__|\__,_|";
echo "                                                 ";

echo "Usage:"
echo "-c        Used in chroot environment to mount proc & sysfs inside"
echo "-x        Install Xubuntu related packages"
echo "-g        Install gnome-ubuntu related packages"
echo "-u        Install Ubuntu original related packages"
echo "-N        Pre-install NVIDIA driver (Use with causion)"
echo "-V        Pre-install Virtualbox-guest additions (Use with causion)"
echo ""
echo "Example:"
echo ""
echo "./woobuntu_chroot_build.sh -x"

}

do_chroot_mount() {

    mount -t proc none /proc/
    mount -t sysfs none /sys/

}

if [ $# = 0 ]
then
    show_help
    exit 0
fi

while getopts "h?cxguNV" opt; do
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    c)  do_chroot_mount
        ;;
    x)  install_xfce_desktop=1
        ;;
    g)  install_gnome_desktop=1
        ;;
    u)  install_unity_desktop=1
        ;;
    N)  install_nvidia_driver=1
        ;;
    V)  install_virutalbox_additions=1
        ;;
    esac
done

#Here is the chroot env , do something here

#Everything inside /root dir
cd /root

#Override default repositories
cat > /etc/apt/sources.list <<EOF
# See http://help.ubuntu.com/community/UpgradeNotes for how to upgrade to
# newer versions of the distribution.
deb http://archive.ubuntu.com/ubuntu/ xenial main restricted
deb-src http://archive.ubuntu.com/ubuntu/ xenial main restricted

## Major bug fix updates produced after the final release of the
## distribution.
deb http://archive.ubuntu.com/ubuntu/ xenial-updates main restricted
deb-src http://archive.ubuntu.com/ubuntu/ xenial-updates main restricted

## N.B. software from this repository is ENTIRELY UNSUPPORTED by the Ubuntu
## team, and may not be under a free licence. Please satisfy yourself as to
## your rights to use the software. Also, please note that software in
## universe WILL NOT receive any review or updates from the Ubuntu security
## team.
deb http://archive.ubuntu.com/ubuntu/ xenial universe
deb-src http://archive.ubuntu.com/ubuntu/ xenial universe
deb http://archive.ubuntu.com/ubuntu/ xenial-updates universe
deb-src http://archive.ubuntu.com/ubuntu/ xenial-updates universe

## N.B. software from this repository is ENTIRELY UNSUPPORTED by the Ubuntu 
## team, and may not be under a free licence. Please satisfy yourself as to 
## your rights to use the software. Also, please note that software in 
## multiverse WILL NOT receive any review or updates from the Ubuntu
## security team.
deb http://archive.ubuntu.com/ubuntu/ xenial multiverse
deb-src http://archive.ubuntu.com/ubuntu/ xenial multiverse
deb http://archive.ubuntu.com/ubuntu/ xenial-updates multiverse
deb-src http://archive.ubuntu.com/ubuntu/ xenial-updates multiverse

## N.B. software from this repository may not have been tested as
## extensively as that contained in the main release, although it includes
## newer versions of some applications which may provide useful features.
## Also, please note that software in backports WILL NOT receive any review
## or updates from the Ubuntu security team.
deb http://archive.ubuntu.com/ubuntu/ xenial-backports main restricted universe multiverse
deb-src http://archive.ubuntu.com/ubuntu/ xenial-backports main restricted universe multiverse

## Uncomment the following two lines to add software from Canonical's
## 'partner' repository.
## This software is not part of Ubuntu, but is offered by Canonical and the
## respective vendors as a service to Ubuntu users.
# deb http://archive.canonical.com/ubuntu xenial partner
# deb-src http://archive.canonical.com/ubuntu xenial partner

deb http://security.ubuntu.com/ubuntu xenial-security main restricted
deb-src http://security.ubuntu.com/ubuntu xenial-security main restricted
deb http://security.ubuntu.com/ubuntu xenial-security universe
deb-src http://security.ubuntu.com/ubuntu xenial-security universe
deb http://security.ubuntu.com/ubuntu xenial-security multiverse
deb-src http://security.ubuntu.com/ubuntu xenial-security multiverse


EOF
#Update before fetching packages
apt-get update -y

#Support exfat filesystem
apt-get install exfat-utils -y

#Unattended install (deb selections)
apt-get install debconf-utils -y

echo wireshark-common	wireshark-common/install-setuid	boolean	true | debconf-set-selections

echo ttf-mscorefonts-installer	msttcorefonts/accepted-mscorefonts-eula	boolean	true | debconf-set-selections

echo ttf-mscorefonts-installer	msttcorefonts/present-mscorefonts-eula	note | debconf-set-selections

#Fix _apt user privilege errors
mkdir -p /var/lib/update-notifier/package-data-downloads/partial/
chmod a+w /var/lib/update-notifier/package-data-downloads/partial/

terminalcmd="xfce4-terminal"

if [ $install_xfce_desktop -eq 1 ]
then

    #Chinese language support
    apt-get install firefox-locale-zh-hans libreoffice-help-en-us fcitx-sunpinyin thunderbird-locale-en fcitx fcitx-ui-classic wbritish myspell-en-za myspell-en-gb hunspell-en-ca fcitx-frontend-gtk2 fcitx-module-cloudpinyin fonts-arphic-ukai fcitx-pinyin thunderbird-locale-en-us mythes-en-au fcitx-table-wubi thunderbird-locale-zh-hans myspell-en-au thunderbird-locale-zh-cn libreoffice-l10n-en-gb fcitx-frontend-qt4 libreoffice-l10n-zh-cn libreoffice-help-en-gb libreoffice-help-zh-cn libreoffice-l10n-en-za openoffice.org-hyphenation mythes-en-us fcitx-frontend-qt5 thunderbird-locale-en-gb hyphen-en-us fcitx-frontend-gtk3 fonts-arphic-uming fonts-noto-cjk fcitx-ui-qimpanel -y

    #vnc
    mkdir -p /etc/skel/.vnc
    cat > /etc/skel/.vnc/xstartup <<EOF
#!/bin/sh

# Uncomment the following two lines for normal desktop:
unset SESSION_MANAGER
exec /etc/X11/xinit/xinitrc

startxfce4 &

[ -x /etc/vnc/xstartup ] && exec /etc/vnc/xstartup
[ -r \$HOME/.Xresources ] && xrdb \$HOME/.Xresources
xsetroot -solid grey
vncconfig -iconic &
x-terminal-emulator -geometry 80x24+10+10 -ls -title "\$VNCDESKTOP Desktop" &
x-window-manager &
EOF
    chmod 777 /etc/skel/.vnc/xstartup
    cp -r /etc/skel/.vnc /root

    #Terminalrc
    mkdir -p /etc/skel/.config/xfce4/terminal
    cat > /etc/skel/.config/xfce4/terminal/terminalrc <<EOF
[Configuration]
ColorForeground=#b7b7b7
ColorBackground=#131926
ColorCursor=#0f4999
ColorSelection=#163b59
ColorSelectionUseDefault=FALSE
ColorBoldUseDefault=FALSE
ColorPalette=#000000000000;#aaaa00000000;#4444aaaa4444;#aaaa55550000;#11156066fda5;#aaaa2222aaaa;#1a1a9292aaaa;#aaaaaaaaaaaa;#777777777777;#ffff87878787;#4c4ce6e64c4c;#deded8d82c2c;#25ed925efe50;#cccc5858cccc;#4c4ccccce6e6;#ffffffffffff
FontName=文泉驿等宽微米黑 11
MiscAlwaysShowTabs=FALSE
MiscBell=FALSE
MiscBordersDefault=TRUE
MiscCursorBlinks=FALSE
MiscCursorShape=TERMINAL_CURSOR_SHAPE_BLOCK
MiscDefaultGeometry=80x24
MiscInheritGeometry=FALSE
MiscMenubarDefault=TRUE
MiscMouseAutohide=FALSE
MiscToolbarDefault=FALSE
MiscConfirmClose=TRUE
MiscCycleTabs=TRUE
MiscTabCloseButtons=TRUE
MiscTabCloseMiddleClick=TRUE
MiscTabPosition=GTK_POS_TOP
MiscHighlightUrls=TRUE
MiscScrollAlternateScreen=TRUE
ScrollingLines=999999
TabActivityColor=#0f4999
ScrollingOnOutput=FALSE
EOF
    cp -r /etc/skel/.config /root
    #Set terminal command in every .desktop entry
    terminalcmd="xfce4-terminal"

fi 

if [ $install_gnome_desktop -eq 1 ]
then
    #Chinese language support
    apt-get install fcitx fcitx-bin fcitx-config-common fcitx-config-gtk fcitx-data fcitx-frontend-all fcitx-frontend-gtk2 fcitx-frontend-gtk3 fcitx-frontend-qt4 fcitx-frontend-qt5 fcitx-module-cloudpinyin fcitx-module-dbus fcitx-module-kimpanel fcitx-module-lua fcitx-modules fcitx-module-x11 fcitx-pinyin fcitx-sunpinyin fcitx-table fcitx-table-wubi fcitx-ui-classic fcitx-ui-qimpanel firefox-locale-en firefox-locale-zh-hans fonts-arphic-ukai fonts-arphic-uming hyphen-en-us libfcitx-config4 libfcitx-core0 libfcitx-gclient0 libfcitx-qt0 libfcitx-qt5-1 libfcitx-utils0 libmng2 libmysqlclient18 libpresage1v5 libpresage-data libqt4-dbus libqt4-declarative libqt4-network libqt4-script libqt4-sql libqt4-sql-mysql libqt4-xml libqt4-xmlpatterns libqt5quickwidgets5 libqtcore4 libqtdbus4 libqtgui4 libreoffice-help-zh-cn libreoffice-l10n-zh-cn libsunpinyin3v5 libtinyxml2.6.2v5 myspell-en-au myspell-en-gb myspell-en-za mysql-common mythes-en-us openoffice.org-hyphenation presage qdbus qt-at-spi qtchooser qtcore4-l10n sunpinyin-data wbritish -y --force-yes
    #Set terminal command in every .desktop entry
    terminalcmd="gnome-terminal"

fi

if [ $install_unity_desktop -eq 1 ]
then
    #Chinese language support
    apt-get install libreoffice-l10n-zh-cn hunspell-en-ca thunderbird-locale-en-us thunderbird-locale-zh-cn firefox-locale-zh-hans openoffice.org-hyphenation mythes-en-us wbritish thunderbird-locale-zh-hans fcitx-table-wubi thunderbird-locale-en-gb firefox-locale-en hyphen-en-us fonts-arphic-uming myspell-en-za fonts-arphic-ukai myspell-en-au thunderbird-locale-en mythes-en-au libreoffice-l10n-en-za myspell-en-gb libreoffice-help-zh-cn fcitx-sunpinyin libreoffice-help-en-gb libreoffice-l10n-en-gb -y
    #Set terminal command in every .desktop entry
    terminalcmd="gnome-terminal"

fi

#vnc
apt-get install vnc4server -y

#Openconnect and useful stuff
apt-get install openvpn network-manager-openconnect-gnome -y

#nodejs
apt-get install npm -y

#Ubuntu kylin software center
wget https://launchpad.net/ubuntu-kylin-software-center/1.3/1.3.10/+download/ubuntu-kylin-software-center_1.3.10-0~329~ubuntu16.04.1_all.deb
dpkg -i ubuntu-kylin-software-center_1.3.10-0~329~ubuntu16.04.1_all.deb
apt-get -f install -y
rm ubuntu-kylin-software-center_1.3.10-0~329~ubuntu16.04.1_all.deb

#sougou-pinyin
#wget http://cdn2.ime.sogou.com/dl/index/1446541585/sogoupinyin_2.0.0.0068_amd64.deb
#dpkg -i sogoupinyin_2.0.0.0068_amd64.deb
#apt-get -f install -y
#rm sogoupinyin_2.0.0.0068_amd64.deb

#wps for linux
#wget http://kdl.cc.ksosoft.com/wps-community/download/a19/wps-office_9.1.0.4975~a19p1_amd64.deb
#dpkg -i wps-office_9.1.0.4975~a19p1_amd64.deb
#rm wps-office_9.1.0.4975~a19p1_amd64.deb

#restricted-extras
apt-get install ubuntu-restricted-extras -y

#Optional desktop envs
#apt-get install gnome -y

#Graphic sudo
apt-get install gksu -y

#Web servers and languages
#apt-get install apache2 php5 mysql-server php5-mysql -y
#cat > /usr/share/applications/apache2-start.desktop <<EOF
#[Desktop Entry]
#Type=Application
#Name=apache2-start
#Exec=$terminalcmd -e 'sh -c "gksudo service apache2 start; exec bash"'
#Icon=application-default-icon
#EOF

#cat > /usr/share/applications/apache2-stop.desktop <<EOF
#[Desktop Entry]
#Type=Application
#Name=apache2-stop
#Exec=$terminalcmd -e 'sh -c "gksudo service apache2 stop; exec bash"'
#Icon=application-default-icon
#EOF

#cat > /usr/share/applications/mysql-start.desktop <<EOF
#[Desktop Entry]
#Type=Application
#Name=mysql-start
#Exec=$terminalcmd -e 'sh -c "gksudo service mysql start; exec bash"'
#Icon=application-default-icon
#EOF

#cat > /usr/share/applications/mysql-stop.desktop <<EOF
#[Desktop Entry]
#Type=Application
#Name=mysql-stop
#Exec=$terminalcmd -e 'sh -c "gksudo service mysql stop; exec bash"'
#Icon=application-default-icon
#EOF

#Download tools & torrent downloader
apt-get install uget aria2 curl -y

#rar 7z
apt-get install rar unrar p7zip -y

#keepnote
apt-get install keepnote -y

#keepass
apt-get install keepassx -y

#Shadowsocks proxychains
apt-get install shadowsocks proxychains -y

#tor
#apt-get install tor -y

#sshuttle
apt-get install sshuttle -y

#openssh-server
#apt-get install openssh-server -y
#service ssh stop

#VLC
#apt-get install vlc -y

#Chromium-browser
apt-get install chromium-browser -y
apt-get install browser-plugin-freshplayer-pepperflash -y

#cairo-dock
apt-get install cairo-dock -y

#woobuntu self build
apt-get install squashfs-tools dchroot mkisofs -y

#VScode
#mkdir -p /opt/woobuntu
#cd /opt/woobuntu
#wget https://az764295.vo.msecnd.net/public/0.10.3/VSCode-linux64.zip
#unzip VSCode-linux64.zip
#rm VSCode-linux64.zip
#cd /root
#cat > /usr/share/applications/vscode.desktop <<EOF
#[Desktop Entry]
#Version=1.0
#Type=Application
#Name=VSCode
#Icon=application-default-icon
#Exec=/opt/woobuntu/VSCode-linux-x64/Code
#NoDisplay=false
#Categories=woobuntu;
#StartupNotify=true
#Terminal=false
#EOF

#sublime-text
#apt-get install sublime-text -y

#bless editor
apt-get install bless -y

#Vim
apt-get install vim git -y

#Vim color
cat > /root/.vimrc <<EOF
syntax enable
set background=dark
colorscheme evening

set nocompatible              " be iMproved, required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

Bundle 'Valloric/YouCompleteMe'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin on    " required
EOF

#vim plugin
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
vim +PluginInstall +qall
apt-get install build-essential python-dev cmake -y
cd ~/.vim/bundle/YouCompleteMe
./install.py
#cp -r ~/.vim /etc/skel
#chmod -R 777 /etc/skel/.vim
#cp /root/.vimrc /etc/skel/
#chmod 666 /etc/skel/.vimrc
#cd /root
apt-get install vim-syntastic -y
apt-get install vim-addon-manager -y
#vam install youcompleteme
vam install syntastic
cp -r ~/.vim /etc/skel
chmod -R 777 /etc/skel/.vim
cp /root/.vimrc /etc/skel/
chmod 666 /etc/skel/.vimrc
cd /root

#xdotool
apt-get install libxtst-dev -y
apt-get install xorg-dev -y
mkdir -p /opt/woobuntu
cd /opt/woobuntu
git clone https://github.com/jordansissel/xdotool
cd xdotool
make
make install
cd ..
rm -rf xdotool
cd /root

#zsh&oh-my-zsh @redrain_you_jie_cao
apt-get install zsh git -y
git clone git://github.com/robbyrussell/oh-my-zsh.git /etc/skel/.oh-my-zsh
cp /etc/skel/.oh-my-zsh/templates/zshrc.zsh-template /etc/skel/.zshrc
#chsh -s /bin/zsh
#conky
apt-get install git conky-all curl -y

cat > /etc/skel/.conkyrc <<EOF
# set to yes if you want Conky to be forked in the background
 background yes

cpu_avg_samples 2
net_avg_samples 2

out_to_console no

 # X font when Xft is disabled, you can pick one with program xfontsel
#font 7x12
#font 6x10
#font 7x13
#font 8x13
#font 7x12
#font *mintsmild.se*
#font -*-*-*-*-*-*-34-*-*-*-*-*-*-*
#font -artwiz-snap-normal-r-normal-*-*-100-*-*-p-*-iso8859-1

# Use Xft?
 use_xft yes

 # Xft font when Xft is enabled
 xftfont Sans:size=8

own_window_transparent no
#own_window_colour hotpink
# Text alpha when using Xft
xftalpha 0.8

# on_bottom yes

# mail spool
mail_spool \$MAIL

# Update interval in seconds
update_interval 1
# Create own window instead of using desktop (required in nautilus)
own_window yes
own_window_transparent yes
own_window_hints undecorated,below,sticky,skip_taskbar,skip_pager
own_window_type override

# Use double buffering (reduces flicker, may not work for everyone)
double_buffer yes

# Minimum size of text area
minimum_size 260 5
maximum_width 400

# Draw shades?
draw_shades no

# Draw outlines?
draw_outline no

# Draw borders around text
draw_borders no

# Stippled borders?
stippled_borders no

# border margins
border_margin 4

# border width
border_width 1

# Default colors and also border colors
default_color white
default_shade_color white
default_outline_color white

# Text alignment, other possible values are commented
#alignment top_left
#minimum_size 10 10
gap_x 15
gap_y 70
alignment top_right
#alignment bottom_left
#alignment bottom_right

# Gap between borders of screen and text

# Add spaces to keep things from moving about?  This only affects certain objects.
use_spacer none

# Subtract file system buffers from used memory?
no_buffers yes

# set to yes if you want all text to be in uppercase
uppercase no

# none, xmms, bmp, audacious, infopipe (default is none)
# xmms_player bmp

# boinc (seti) dir
# seti_dir /opt/seti

# Possible variables to be used:
#
#      Variable         Arguments                  Description                
#  acpiacadapter                     ACPI ac adapter state.                   
#  acpifan                           ACPI fan state                           
#  acpitemp                          ACPI temperature.                        
#  adt746xcpu                        CPU temperature from therm_adt746x       
#  adt746xfan                        Fan speed from therm_adt746x             
#  battery           (num)           Remaining capasity in ACPI or APM        
#                                    battery. ACPI battery number can be      
#                                    given as argument (default is BAT0).     
#  buffers                           Amount of memory buffered                
#  cached                            Amount of memory cached                  
#  color             (color)         Change drawing color to color            
#  cpu                               CPU usage in percents                    
#  cpubar            (height)        Bar that shows CPU usage, height is      
#                                    bar's height in pixels                   
#  downspeed         net             Download speed in kilobytes              
#  downspeedf        net             Download speed in kilobytes with one     
#                                    decimal                                  
#  exec              shell command   Executes a shell command and displays    
#                                    the output in torsmo. warning: this      
#                                    takes a lot more resources than other    
#                                    variables. I'd recommend coding wanted   
#                                    behaviour in C and posting a patch :-).  
#  execi             interval, shell Same as exec but with specific interval. 
#                    command         Interval can't be less than              
#                                    update_interval in configuration.        
#  fs_bar            (height), (fs)  Bar that shows how much space is used on 
#                                    a file system. height is the height in   
#                                    pixels. fs is any file on that file      
#                                    system.                                  
#  fs_free           (fs)            Free space on a file system available    
#                                    for users.                               
#  fs_free_perc      (fs)            Free percentage of space on a file       
#                                    system available for users.              
#  fs_size           (fs)            File system size                         
#  fs_used           (fs)            File system used space                   
#  hr                (height)        Horizontal line, height is the height in 
#                                    pixels                                   
#  i2c               (dev), type, n  I2C sensor from sysfs (Linux 2.6). dev   
#                                    may be omitted if you have only one I2C  
#                                    device. type is either in (or vol)       
#                                    meaning voltage, fan meaning fan or temp 
#                                    meaning temperature. n is number of the  
#                                    sensor. See /sys/bus/i2c/devices/ on     
#                                    your local computer.                     
#  kernel                            Kernel version                           
#  loadavg           (1), (2), (3)   System load average, 1 is for past 1     
#                                    minute, 2 for past 5 minutes and 3 for   
#                                    past 15 minutes.                         
#  machine                           Machine, i686 for example                
#  mails                             Mail count in mail spool. You can use    
#                                    program like fetchmail to get mails from 
#                                    some server using your favourite         
#                                    protocol. See also new_mails.            
#  mem                               Amount of memory in use                  
#  membar            (height)        Bar that shows amount of memory in use   
#  memmax                            Total amount of memory                   
#  memperc                           Percentage of memory in use              
#  new_mails                         Unread mail count in mail spool.         
#  nodename                          Hostname                                 
#  outlinecolor      (color)         Change outline color                     
#  pre_exec          shell command   Executes a shell command one time before 
#                                    torsmo displays anything and puts output 
#                                    as text.                                 
#  processes                         Total processes (sleeping and running)   
#  running_processes                 Running processes (not sleeping),        
#                                    requires Linux 2.6                       
#  shadecolor        (color)         Change shading color                     
#  stippled_hr       (space),        Stippled (dashed) horizontal line        
#                    (height)        
#  swapbar           (height)        Bar that shows amount of swap in use     
#  swap                              Amount of swap in use                    
#  swapmax                           Total amount of swap                     
#  swapperc                          Percentage of swap in use                
#  sysname                           System name, Linux for example           
#  time              (format)        Local time, see man strftime to get more 
#                                    information about format                 
#  totaldown         net             Total download, overflows at 4 GB on     
#                                    Linux with 32-bit arch and there doesn't 
#                                    seem to be a way to know how many times  
#                                    it has already done that before torsmo   
#                                    has started.                             
#  totalup           net             Total upload, this one too, may overflow 
#  updates                           Number of updates (for debugging)        
#  upspeed           net             Upload speed in kilobytes                
#  upspeedf          net             Upload speed in kilobytes with one       
#                                    decimal                                  
#  uptime                            Uptime                                   
#  uptime_short                      Uptime in a shorter format               
#
#  seti_prog                         Seti@home current progress
#  seti_progbar      (height)        Seti@home current progress bar
#  seti_credit                       Seti@hoome total user credit


# variable is given either in format \$variable or in \${variable}. Latter
# allows characters right after the variable and must be used in network
# stuff because of an argument
#\${font Dungeon:style=Bold:pixelsize=10}I can change the font as well
#\${font Verdana:size=10}as many times as I choose
#\${font Perry:size=10}Including UTF-8,
# stuff after 'TEXT' will be formatted on screen
#\${font Grunge:size=12}\${time %a  %b  %d}\${alignr -25}\${time %k:%M}


TEXT
\${color white}SYSTEM \${hr 1}\${color}

Hostname: \$alignr\$nodename
Kernel: \$alignr\$kernel
Uptime: \$alignr\$uptime
Temp: \${alignr}\${acpitemp}°C

CPU: \${alignr}\${freq dyn} MHz
Processes: \${alignr}\$processes (\$running_processes running)
Load: \${alignr}\$loadavg

CPU1 \${alignr}\${cpu cpu1}%
\${cpubar 4 cpu1}

Ram \${alignr}\$mem / \$memmax (\$memperc%)
\${membar 4}
swap \${alignr}\$swap / \$swapmax (\$swapperc%)
\${swapbar 4}

Highest CPU \$alignr CPU%  MEM%
\${top name 1}\$alignr\${top cpu 1}   \${top mem 1}
\${top name 2}\$alignr\${top cpu 2}   \${top mem 2}
\${top name 3}\$alignr\${top cpu 3}   \${top mem 3}

Highest MEM \$alignr CPU%  MEM%
\${top_mem name 1}\$alignr\${top_mem cpu 1}   \${top_mem mem 1}
\${top_mem name 2}\$alignr\${top_mem cpu 2}   \${top_mem mem 2}
\${top_mem name 3}\$alignr\${top_mem cpu 3}   \${top_mem mem 3}

\${color white}FILE SYSTEM \${hr 1}\${color}

Root: \${alignr}\${fs_free /} / \${fs_size /}
\${fs_bar 4 /}
Home: \${alignr}\${fs_free /home} / \${fs_size /home}
\${fs_bar 4 /home}

\${color white}NETWORK \${hr 1}\${color}

Down \${downspeed wlan0} k/s \${alignr}Up \${upspeed wlan0} k/s
\${downspeedgraph wlan0 25,107} \${alignr}\${upspeedgraph wlan0 25,107}
Total \${totaldown wlan0} \${alignr}Total \${totalup wlan0}
EOF

#Fonts - source code pro
#wget https://github.com/adobe-fonts/source-code-pro/archive/2.010R-ro/1.030R-it.zip
#unzip 1.030R-it.zip
#cp source-code-pro-2.010R-ro-1.030R-it/OTF/*.otf /usr/local/share/fonts/
#rm 1.030R-it.zip
#rm -rf source-code-pro-2.010R-ro-1.030R-it

#fonts
apt-get install ttf-wqy-microhei -y

#dev-tools - only for developers
#apt-get install ia32-libs -y
apt-get install golang-go -y
#apt-get install bison build-essential curl flex git gnupg gperf libesd0-dev liblz4-tool libncurses5-dev libsdl1.2-dev libwxgtk2.8-dev libxml2 libxml2-utils lzop openjdk-7-jdk openjdk-7-jre pngcrush schedtool squashfs-tools xsltproc zip zlib1g-dev -y
apt-get install git-core build-essential libssl-dev libncurses5-dev unzip -y
apt-get install subversion mercurial -y
apt-get install build-essential subversion libncurses5-dev gawk gcc-multilib flex git-core gettext libssl-dev -y

apt-get install bison g++-multilib git gperf libxml2-utils make python-networkx zip bison build-essential curl flex git gnupg gperf libesd0-dev liblz4-tool libncurses5-dev libsdl1.2-dev libxml2 libxml2-utils lzop libwxgtk3.0-dev openjdk-8-jdk openjdk-8-jre pngcrush schedtool squashfs-tools xsltproc zip zlib1g-dev g++-multilib gcc-multilib lib32ncurses5-dev lib32readline6-dev -y

#adb
apt-get install android-tools-adb android-tools-fastboot -y

#Whois
apt-get install whois -y

#steghide
apt-get install steghide -y

#chntpw
apt-get install chntpw -y

#guymager
apt-get install guymager -y

#foremost
apt-get install foremost -y

#extundelete
apt-get install extundelete -y

#exifprobe
apt-get install exifprobe -y

#zenmap
apt-get install zenmap -y

#masscan @sharecast
apt-get install git gcc make libpcap-dev -y
mkdir -p /opt/woobuntu
cd /opt/woobuntu
git clone https://github.com/robertdavidgraham/masscan
cd masscan
make
make install
cd ..
rm -rf masscan
cd /root

#httrack
apt-get install httrack -y

#dsniff - dnsspoof
apt-get install dsniff -y

#tcpreplay
apt-get install tcpreplay -y

#sslsplit
apt-get install sslsplit -y

#sslstrip
apt-get install sslstrip -y

#siege
apt-get install siege -y

#medusa
apt-get install medusa -y

#binwalk
#apt-get install binwalk -y

#radare2
apt-get install radare2 -y

#edb-debugger
#sudo apt-get install build-essential libboost-dev libqt5xmlpatterns5-dev qtbase5-dev qt5-default -y
#mkdir -p /opt/woobuntu
#cd /opt/woobuntu
#git clone --recursive https://github.com/eteran/edb-debugger.git
#cd edb-debugger
#git clone --depth=50 --branch=3.0.4 https://github.com/aquynh/capstone.git
#pushd capstone
#./make.sh
#sudo ./make.sh install
#popd
#qmake
#make
#make install
#cd ..
#rm -rf edb-debugger
#cd /root
#cat > /usr/share/applications/edb-debugger.desktop <<EOF
#[Desktop Entry]
#Version=1.0
#Type=Application
#Name=edb-debugger
#Icon=application-default-icon
#Exec=edb
#NoDisplay=false
#Categories=woobuntu_reverse;
#StartupNotify=true
#Terminal=false
#EOF

#Wireshark
apt-get install wireshark -y
cat > /usr/share/applications/wireshark-asroot.desktop <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=wireshark
Icon=application-default-icon
Exec=gksudo wireshark
NoDisplay=false
Categories=woobuntu_network;
StartupNotify=true
Terminal=false
EOF

#reaver
apt-get install reaver -y

#Aircrack-ng
apt-get install libssl-dev -y
apt-get install git libsqlite3-dev libnl-3-dev libnl-genl-3-dev -y
git clone https://github.com/aircrack-ng/aircrack-ng
cd aircrack-ng
make
make strip
make install
cd /root
rm -rf aircrack-ng

#mdk3
git clone https://github.com/lxj616/mdk3-v6.git
cd mdk3-v6
make
make install
cd /root
rm -rf mdk3-v6

#hackrf
apt-get install gnuradio gr-osmosdr hackrf -y

#hostapd-wpe
mkdir -p /opt/woobuntu/config
cd /opt/woobuntu
git clone https://github.com/hph86/hostapd-wpe.git
wget http://hostap.epitest.fi/releases/hostapd-2.5.tar.gz
tar -zxf hostapd-2.5.tar.gz
rm hostapd-2.5.tar.gz
cd hostapd-2.5
patch -p1 < ../hostapd-wpe/hostapd-wpe.patch 
cd hostapd
sed -r 's/#CONFIG_LIBNL32=y/CONFIG_LIBNL32=y/' .config -i
make
cd ../../hostapd-wpe/certs
./bootstrap
cd /opt/woobuntu/config
#deprecated
#wget https://raw.githubusercontent.com/sensepost/mana/master/run-mana/conf/hostapd-karma.conf
cd /root
cat > /opt/woobuntu/wifi_hijack.sh <<EOF
#!/bin/bash
source /etc/profile.d/rvm.sh
cd /opt/woobuntu/metasploit-framework
./msfconsole -r /opt/woobuntu/config/msf_capture.rc
EOF

chmod 777 /opt/woobuntu/wifi_hijack.sh

cat > /opt/woobuntu/config/dnsmasq.conf <<EOF
domain-needed 
bogus-priv 
expand-hosts 
domain=example.com 
dhcp-range=192.168.1.20,192.168.1.125,24h 
EOF

#pixiewps
mkdir -p /opt/woobuntu
cd /opt/woobuntu
git clone https://github.com/wiire/pixiewps
cd pixiewps/
cd src/
make
make install
cd ..
rm -rf pixiewps
cd /root

#reaver-wps-fork-t6x
mkdir -p /opt/woobuntu
cd /opt/woobuntu
git clone https://github.com/t6x/reaver-wps-fork-t6x
cd reaver-wps-fork-t6x*/
cd src/
./configure
make
make install
cd ..
rm -rf reaver-wps-fork-t6x
cd /root

#Fruitywifi
#mkdir -p /opt/woobuntu
#cd /opt/woobuntu
#git clone https://github.com/xtr4nge/FruityWifi.git
#cd /root

#android-tools
mkdir -p /opt/woobuntu/android-tools
cd /opt/woobuntu/android-tools
wget https://bitbucket.org/JesusFreke/smali/downloads/smali-2.2.0.jar
wget https://github.com/iBotPeaches/Apktool/releases/download/v2.2.2/apktool_2.2.2.jar
wget https://github.com/pxb1988/dex2jar/releases/download/2.0/dex-tools-2.0.zip
unzip dex-tools-2.0.zip
cd /root

#Wifite
apt-get install git tshark pyrit -y
mkdir -p /opt/woobuntu/wifite
cd /opt/woobuntu/wifite
wget https://raw.github.com/derv82/wifite/master/wifite.py
chmod +x wifite.py
sed -r 's/\/usr\/share\/wfuzz\/wordlist\/fuzzdb\/wordlists-user-passwd\/passwds\/phpbb.txt/\/opt\/woobuntu\/dict\/10_million_password_list_top_100000.txt/' wifite.py -i
cd /usr/bin
ln -s /opt/woobuntu/wifite/wifite.py wifite
cd /root
cat > /usr/share/applications/wifite.desktop <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=wifite
Icon=application-default-icon
Exec=$terminalcmd -e 'sh -c "gksudo airmon-ng check kill;sudo wifite --aircrack;exec bash"'
NoDisplay=false
Categories=woobuntu_network;
StartupNotify=true
Terminal=false
EOF

#SecList
mkdir -p /opt/woobuntu/dict
cd /opt/woobuntu/dict
wget https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/10_million_password_list_top_100.txt
wget https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/10_million_password_list_top_500.txt
wget https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/10_million_password_list_top_1000.txt
wget https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/10_million_password_list_top_10000.txt
wget https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/10_million_password_list_top_100000.txt
cd /root

#Burp
apt-get install default-jre -y
mkdir -p /opt/woobuntu/burp
cd /opt/woobuntu/burp
wget https://portswigger.net/DownloadUpdate.ashx?Product=Free --content-disposition 
ln -s *.jar burp.jar
cd /root
cat > /usr/share/applications/burp.desktop <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=burp
Icon=application-default-icon
Exec=java -jar /opt/woobuntu/burp/burp.jar
NoDisplay=false
Categories=woobuntu_web;
StartupNotify=true
Terminal=false
EOF

#jd-gui
wget https://github.com/java-decompiler/jd-gui/releases/download/v1.4.0/jd-gui_1.4.0-0_all.deb
dpkg -i jd-gui_1.4.0-0_all.deb
rm jd-gui_1.4.0-0_all.deb

#sqlmap
apt-get install git -y
mkdir -p /opt/woobuntu
cd /opt/woobuntu
git clone https://github.com/sqlmapproject/sqlmap
cd /usr/bin
ln -s /opt/woobuntu/sqlmap/sqlmap.py sqlmap
cd /root

#commix
mkdir -p /opt/woobuntu
cd /opt/woobuntu
git clone https://github.com/stasinopoulos/commix.git
cd commix
python commix.py --install
cd /root

#docker.io
#wget -qO- https://get.docker.com/ | sh

#service docker start
#docker pull lxj616/docker-kali-custom-tools
#service docker stop

#cat > /usr/share/applications/docker-metasploit.desktop <<EOF
#[Desktop Entry]
#Version=1.0
#Type=Application
#Name=docker-metasploit
#Icon=application-default-icon
#Exec=$terminalcmd -e 'sh -c "sudo docker run --rm --name=lxj616 --cap-add=ALL --privileged=true -t -i lxj616/docker-kali-custom-tools /usr/bin/msfconsole;exec bash"'
#NoDisplay=false
#Categories=woobuntu;
#StartupNotify=true
#Terminal=false
#EOF

#Metasploit-community
#mkdir -p /opt/woobuntu
#cd /opt/woobuntu
#wget http://downloads.metasploit.com/data/releases/metasploit-latest-linux-x64-installer.run
#chmod +x metasploit-latest-linux-x64-installer.run
#./metasploit-latest-linux-x64-installer.run
#rm metasploit-latest-linux-x64-installer.run
#cd /root
#cat > /usr/share/applications/service_metasploit_start.desktop <<EOF
#[Desktop Entry]
#Version=1.0
#Type=Application
#Name=service_metasploit_start
#Icon=application-default-icon
#Exec=$terminalcmd -e '/bin/bash -c "service metasploit start; exec bash"'
#NoDisplay=false
#Categories=woobuntu;
#StartupNotify=true
#Terminal=false
#EOF
#cat > /usr/share/applications/service_metasploit_stop.desktop <<EOF
#[Desktop Entry]
#Version=1.0
#Type=Application
#Name=service_metasploit_stop
#Icon=application-default-icon
#Exec=$terminalcmd -e '/bin/bash -c "service metasploit stop; exec bash"'
#NoDisplay=false
#Categories=woobuntu;
#StartupNotify=true
#Terminal=false
#EOF
#cat > /usr/share/applications/metasploit.desktop <<EOF
#[Desktop Entry]
#Version=1.0
#Type=Application
#Name=metasploit_console
#Icon=application-default-icon
#Exec=$terminalcmd -e '/bin/bash -c "sudo msfconsole; exec bash"'
#NoDisplay=false
#Categories=woobuntu;
#StartupNotify=true
#Terminal=false
#EOF

#Metasploit-framework
apt-get install git ruby ruby-dev nmap git-core curl zlib1g-dev build-essential libpq5 libpq-dev libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev software-properties-common libffi-dev libpcap-dev autoconf libgmp-dev -y
mkdir -p /opt/woobuntu
cd /opt/woobuntu
git clone https://github.com/rapid7/metasploit-framework
ruby_verison=`cat /opt/woobuntu/metasploit-framework/.ruby-version`
sudo gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
curl -L https://get.rvm.io | bash -s stable --autolibs=enabled --ruby=$ruby_verison
source /usr/local/rvm/scripts/rvm
echo "source /etc/profile.d/rvm.sh" >> /root/.bashrc
echo "source /etc/profile.d/rvm.sh" >> /etc/skel/.bashrc
rvm install $ruby_verison
rvm use $ruby_verison --default
cd /opt/woobuntu/metasploit-framework
rvm --default use ruby-$ruby_verison@metasploit-framework
gem install bundler
bundle install
cd /root
for filename in $(ls /opt/woobuntu/metasploit-framework|grep msf)
do

cat > /usr/local/bin/$filename <<EOF
#!/bin/bash
source /etc/profile.d/rvm.sh
cd /opt/woobuntu/metasploit-framework
./$filename \$@
EOF
chmod a+x /usr/local/bin/$filename

done
cat > /usr/share/applications/msfconsole.desktop <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=metasploit
Icon=application-default-icon
Exec=$terminalcmd -e '/bin/bash -c "source /etc/profile.d/rvm.sh;cd /opt/woobuntu/metasploit-framework;./msfconsole; exec bash"'
NoDisplay=false
Categories=woobuntu_exploitation;
StartupNotify=true
Terminal=false
EOF
#armitage
#mkdir -p /opt/woobuntu
#cd /opt/woobuntu
#wget http://www.fastandeasyhacking.com/download/armitage150813.tgz
#tar -zxvf armitage150813.tgz
#rm armitage150813.tgz
#cd /root
#cat > /usr/share/applications/armitage.desktop <<EOF
#[Desktop Entry]
#Version=1.0
#Type=Application
#Name=armitage
#Icon=application-default-icon
#Exec=/bin/bash -c "service metasploit start;cd /opt/woobuntu/armitage;gksudo ./armitage"
#NoDisplay=false
#Categories=woobuntu;
#StartupNotify=true
#Terminal=false
#EOF

#Arachni
mkdir -p /opt/woobuntu
cd /opt/woobuntu
wget https://github.com/Arachni/arachni/releases/download/v1.5.1/arachni-1.5.1-0.5.12-linux-x86_64.tar.gz
tar -zxvf arachni-1.5.1-0.5.12-linux-x86_64.tar.gz
rm arachni-1.5.1-0.5.12-linux-x86_64.tar.gz
mv arachni* arachni
cat > /root/warmup.js <<EOF
console.log("warmup");
phantom.exit();
EOF
cd arachni
./bin/arachni_shell -c 'phantomjs /root/warmup.js'
sed -r 's/(.*)"/\1:\/opt\/woobuntu\/arachni\/bin"/' /etc/environment -i
cd /root
cat > /usr/share/applications/arachni.desktop <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=arachni
Icon=application-default-icon
Exec=$terminalcmd -e '/bin/bash -c "gksudo /opt/woobuntu/arachni/bin/arachni_web; exec bash"'
NoDisplay=false
Categories=woobuntu_web;
StartupNotify=true
Terminal=false
EOF



#AntSword
mkdir -p /opt/woobuntu
cd /opt/woobuntu
wget https://github.com/antoor/antSword/releases/download/1.2.0/AntSword-v1.2.0-linux-x64.zip
unzip AntSword-v1.2.0-linux-x64.zip
rm AntSword-v1.2.0-linux-x64.zip
mv AntSword* AntSword
cd /root
wget https://github.com/antoor/antSword/releases/download/1.3.0/app.asar.zip
unzip app.asar.zip
rm app.asar.zip
mv app.asar /opt/woobuntu/AntSword/resources/
chmod a+r /opt/woobuntu/AntSword/resources/app.asar
cd /root
cat > /usr/share/applications/antsword.desktop <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=antsword
Icon=application-default-icon
Exec=/opt/woobuntu/AntSword/AntSword
NoDisplay=false
Categories=woobuntu_web;
StartupNotify=false
Terminal=false
EOF

#BDFactory

apt-get install python-pip python-setuptools -y
mkdir -p /opt/woobuntu
cd /opt/woobuntu
git clone https://github.com/secretsquirrel/the-backdoor-factory
cd the-backdoor-factory
./install.sh
cd /root

#golismero
mkdir -p /opt/woobuntu
apt-get install python2.7 python2.7-dev python-pip python-docutils git perl nmap sslscan -y
cd /opt/woobuntu
git clone https://github.com/golismero/golismero.git
cd golismero
pip install -r requirements.txt
pip install -r requirements_unix.txt
chmod a+x golismero.py
cd /root
ln -s /opt/woobuntu/golismero/golismero.py /usr/bin/golismero

#spiderfoot
#mkdir -p /opt/woobuntu
#cd /opt/woobuntu
#git clone https://github.com/smicallef/spiderfoot.git
#sudo apt-get install git python-dev python-pip python-m2crypto python-netaddr python-pypdf python-stem python-lxml -y
#sudo pip install cherrypy mako
#chmod -R 777 spiderfoot
#cd /root
#cat > /usr/share/applications/spiderfoot.desktop <<EOF
#[Desktop Entry]
#Version=1.0
#Type=Application
#Name=spiderfoot
#Icon=application-default-icon
#Exec=$terminalcmd -e '/bin/bash -c "/opt/woobuntu/spiderfoot/sf.py; exec bash"'
#NoDisplay=false
#Categories=woobuntu_web;
#StartupNotify=true
#Terminal=false
#EOF


#beEF
apt-get install ruby sqlite3 ruby-sqlite3 -y
mkdir -p /opt/woobuntu
cd /opt/woobuntu
git clone https://github.com/beefproject/beef
ruby_verison=`cat /opt/woobuntu/beef/.ruby-version`
sudo gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
curl -L https://get.rvm.io | bash -s stable --autolibs=enabled --ruby=$ruby_verison
source /usr/local/rvm/scripts/rvm
echo "source /etc/profile.d/rvm.sh" >> /root/.bashrc
echo "source /etc/profile.d/rvm.sh" >> /etc/skel/.bashrc
rvm install $ruby_verison
rvm use $ruby_verison --default
cd /opt/woobuntu/beef
rvm --default use ruby-$ruby_verison@beef
gem install bundler
bundle install
cd /root
cat > /usr/share/applications/beef.desktop <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=beef
Icon=application-default-icon
Exec=$terminalcmd -e '/bin/bash -c "source /etc/profile.d/rvm.sh;cd /opt/woobuntu/beef;./beef; exec bash"'
NoDisplay=false
Categories=woobuntu_web;
StartupNotify=true
Terminal=false
EOF
chmod -R a+w /opt/woobuntu/beef

#wpscan
sudo apt-get install libcurl4-openssl-dev libxml2 libxml2-dev libxslt1-dev ruby-dev build-essential libgmp-dev -y
mkdir -p /opt/woobuntu
cd /opt/woobuntu
git clone https://github.com/wpscanteam/wpscan.git
chmod -R a+rw wpscan
sudo gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
curl -L https://get.rvm.io | bash -s stable --autolibs=enabled --ruby=2.2.4
source /usr/local/rvm/scripts/rvm
rvm install 2.2.4
rvm use 2.2.4 --default
cd /opt/woobuntu/wpscan
rvm --default use ruby-2.2.4@wpscan
gem install bundler
bundle install
cd /root

cat > /usr/bin/wpscan <<EOF
#!/bin/bash
source /etc/profile.d/rvm.sh
cd /opt/woobuntu/wpscan
./wpscan.rb \$@
EOF
chmod a+x /usr/bin/wpscan


#Weevely
apt-get install python-dev python-dateutil python-pip -y
pip install prettytable Mako PyYAML PySocks
mkdir -p /opt/woobuntu
cd /opt/woobuntu
git clone https://github.com/epinna/weevely3.git
ln -s /opt/woobuntu/weevely3/weevely.py /usr/bin/weevely
cd /root

#Mitmf
mkdir /opt/woobuntu
cd /opt/woobuntu
apt-get install python-dev python-setuptools libpcap0.8-dev libnetfilter-queue-dev libssl-dev libjpeg-dev libxml2-dev libxslt1-dev libcapstone3 libcapstone-dev  python-pip -y
#pip install virtualenvwrapper
#source /usr/local/bin/virtualenvwrapper.sh
#mkvirtualenv MITMf -p /usr/bin/python2.7
git clone https://github.com/byt3bl33d3r/MITMf
cd MITMf && git submodule init && git submodule update --recursive
pip install -r requirements.txt
cd /root

#mitmproxy
#apt install python3-pip
apt install mitmproxy -y
#mkdir /opt/woobuntu
#cd /opt/woobuntu
#git clone https://github.com/mitmproxy/mitmproxy.git
#cd mitmproxy
#pip install -r requirements.txt
#cd /root

#dnsmasq
#apt-get install dnsmasq -y
#service dnsmasq stop

#wine
dpkg --add-architecture i386 
apt-get update
apt-get install wine -y
apt-get install zlib1g-dev:i386 -y

#wine-qq
#cd /root
#unzip wine-qqintl.zip
#cd wine-qqintl
#dpkg -i wine-qqintl_0.1.3-2_i386.deb
#apt-get -f install -y 
#cd /root
#rm -rf wine-qqintl
#rm wine-qqintl.zip
#cd /root

#firefox
apt-get install firefox -y
mv .mozilla /etc/skel
cd /etc/skel
chmod -R 777 .mozilla
cd /root
mkdir -p /opt/woobuntu
cd /opt/woobuntu
git clone https://github.com/lxj616/wooyun-firefox.git
chmod -R 777 wooyun-firefox
cd /root

#Configure the system

#User-dirs
mkdir -p /etc/skel/.config
cat > /etc/skel/.config/user-dirs.dirs <<EOF
XDG_DESKTOP_DIR="\$HOME"
XDG_DOWNLOAD_DIR="\$HOME"
XDG_TEMPLATES_DIR="\$HOME"
XDG_PUBLICSHARE_DIR="\$HOME"
XDG_DOCUMENTS_DIR="\$HOME"
XDG_MUSIC_DIR="\$HOME"
XDG_PICTURES_DIR="\$HOME"
XDG_VIDEOS_DIR="\$HOME"
EOF

#timezone
#dpkg-reconfigure tzdata

#Locale
#locale-gen zh_CN.UTF-8
#update-locale LANG=zh_CN.utf8

#Disable web service auto start on boot
#/usr/sbin/update-rc.d -f postgresql disable
/usr/sbin/update-rc.d -f ssh disable
service metasploit stop
/usr/sbin/update-rc.d -f metasploit disable
#/usr/sbin/update-rc.d -f docker disable
#/usr/sbin/update-rc.d -f apache2 disable
#echo "manual" > /etc/init/mysql.override

#Woobuntu menu
cat > /etc/xdg/menus/applications-merged/woobuntu.menu <<EOF
<!DOCTYPE Menu PUBLIC "-//freedesktop//DTD Menu 1.0//EN"
"http://www.freedesktop.org/standards/menu-spec/menu-1.0.dtd">
<Menu>
  <Name>woobuntu</Name>
  <Menu>
    <Name>woobuntu</Name>
    <Directory>woobuntu.directory</Directory>
    <Include>
      <Category>woobuntu</Category>
    </Include>
  <Menu>
    <Name>woobuntu_web</Name>
    <Directory>woobuntu_web.directory</Directory>
    <Include>
        <Category>woobuntu_web</Category>
    </Include>
  </Menu>
  <Menu>
    <Name>woobuntu_reverse</Name>
    <Directory>woobuntu_reverse.directory</Directory>
    <Include>
        <Category>woobuntu_reverse</Category>
    </Include>
  </Menu>
  <Menu>
    <Name>woobuntu_network</Name>
    <Directory>woobuntu_network.directory</Directory>
    <Include>
        <Category>woobuntu_network</Category>
    </Include>
  </Menu>
  <Menu>
    <Name>woobuntu_exploitation</Name>
    <Directory>woobuntu_exploitation.directory</Directory>
    <Include>
        <Category>woobuntu_exploitation</Category>
    </Include>
  </Menu>
  <Menu>
    <Name>woobuntu_android</Name>
    <Directory>woobuntu_android.directory</Directory>
    <Include>
        <Category>woobuntu_android</Category>
    </Include>
  </Menu>
  </Menu>
</Menu>
EOF

cat > /usr/share/desktop-directories/woobuntu.directory <<EOF
[Desktop Entry]
Version=1.0
Type=Directory
Name=Woobuntu
Icon=applications-other
NoDisplay=false
Categories=X-XFCE;X-Xfce-Toplevel;
StartupNotify=false
Terminal=false
EOF

cat > /usr/share/desktop-directories/woobuntu_web.directory <<EOF
[Desktop Entry]
Type=Directory
Name=WEB安全工具
Icon=folder
EOF

cat > /usr/share/desktop-directories/woobuntu_reverse.directory <<EOF
[Desktop Entry]
Type=Directory
Name=逆向及调试工具
Icon=folder
EOF

cat > /usr/share/desktop-directories/woobuntu_network.directory <<EOF
[Desktop Entry]
Type=Directory
Name=网络及WIFI安全工具
Icon=folder
EOF

cat > /usr/share/desktop-directories/woobuntu_exploitation.directory <<EOF
[Desktop Entry]
Type=Directory
Name=漏洞利用工具
Icon=folder
EOF

cat > /usr/share/desktop-directories/woobuntu_android.directory <<EOF
[Desktop Entry]
Type=Directory
Name=Android安全工具
Icon=folder
EOF

#resource
mkdir -p /opt/woobuntu/config
mkdir -p /opt/woobuntu/log
cat > /opt/woobuntu/config/msf_capture.rc <<EOF
use auxiliary/server/capture/pop3
set SRVPORT 110
set SSL false
run
spool /opt/woobuntu/log/console.log

use auxiliary/server/capture/pop3
set SRVPORT 995
set SSL true
run
spool /opt/woobuntu/log/console.log

use auxiliary/server/capture/imap
set SSL false
set SRVPORT 143
run
spool /opt/woobuntu/log/console.log

use auxiliary/server/capture/imap
set SSL true
set SRVPORT 993
run
spool /opt/woobuntu/log/console.log

use auxiliary/server/capture/smtp
set SSL false
set SRVPORT 25
run
spool /opt/woobuntu/log/console.log

use auxiliary/server/capture/smtp
set SSL true
set SRVPORT 465
run
spool /opt/woobuntu/log/console.log

EOF

#Additional software - NetEase-MusicBox @寂寞的瘦子
#sudo pip install pycrypto
#sudo pip2 install NetEase-MusicBox
#sudo apt-get install mpg123 -y
#cat > /usr/share/applications/musicbox.desktop <<EOF
#[Desktop Entry]
#Version=1.0
#Type=Application
#Name=musicbox
#Icon=application-default-icon
#Exec=$terminalcmd -e '/bin/bash -c "musicbox; exec bash"'
#NoDisplay=false
#Categories=woobuntu;
#StartupNotify=true
#Terminal=false
#EOF

#BBScan @lijiejie
mkdir -p /opt/woobuntu
cd /opt/woobuntu
git clone https://github.com/lijiejie/BBScan.git
chmod -R a+rw BBScan
cd BBScan
chmod a+x BBScan.py
pip install -r requirements.txt
cd /root
cat > /usr/bin/bbscan <<EOF
#!/bin/sh
cd /opt/woobuntu/BBScan
python BBScan.py \$@
EOF
chmod 777 /usr/bin/bbscan

#subDomainsBrute @lijiejie
mkdir -p /opt/woobuntu
cd /opt/woobuntu
git clone https://github.com/lijiejie/subDomainsBrute.git
chmod -R a+rw subDomainsBrute
cd subDomainsBrute
chmod a+x subDomainsBrute.py
cd /root
cat > /usr/bin/subDomainsBrute <<EOF
#!/bin/sh
cd /opt/woobuntu/subDomainsBrute
python subDomainsBrute.py \$@
EOF
chmod 777 /usr/bin/subDomainsBrute

#dzscan @matt @ca1n
mkdir -p /opt/woobuntu
cd /opt/woobuntu
git clone https://github.com/code-scan/dzscan.git
cd dzscan
chmod a+x dzscan.py
cd /usr/bin
ln -s /opt/woobuntu/dzscan/dzscan.py dzscan
cd /root

#bcloud @帅气凌云
#git clone https://github.com/LiuLang/bcloud-packages.git
#cd bcloud-packages
#dpkg -i *.deb
#apt-get -f install -y
#cd /root
#rm -rf bcloud-packages

#altman @Mr.K
#mkdir -p /opt/woobuntu
#mv altman /opt/woobuntu
#apt-get install mono-complete libgdiplus gtk-sharp2 -y
#cd /root
#cat > /usr/share/applications/altman.desktop <<EOF
#[Desktop Entry]
#Version=1.0
#Type=Application
#Name=altman
#Icon=application-default-icon
#Exec=mono /opt/woobuntu/altman/Altman.Gtk.exe
#NoDisplay=false
#Categories=woobuntu;
#StartupNotify=true
#Terminal=false
#EOF

#androguard
apt-get install python-dev libbz2-dev libmuparser-dev libsparsehash-dev python-ptrace python-pygments python-pydot graphviz liblzma-dev libsnappy-dev -y
apt-get install python-pyside -y
apt-get install ipython -y
mkdir -p /opt/woobuntu
cd /opt/woobuntu
wget https://github.com/androguard/androguard/archive/v2.0.tar.gz
tar -zxvf v2.0.tar.gz
rm v2.0.tar.gz
cd androguard-2.0
python setup.py install
cd /root
cat > /usr/share/applications/androguard-gui.desktop <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=androguard-gui
Icon=application-default-icon
Exec=androgui.py
NoDisplay=false
Categories=woobuntu_android;
StartupNotify=true
Terminal=false
EOF

#drozer
wget https://www.mwrinfosecurity.com/system/assets/931/original/drozer_2.3.4.deb
dpkg -i drozer_2.3.4.deb
apt-get -f install -y
rm drozer_2.3.4.deb

#andbug
mkdir -p /opt/woobuntu
cd /opt/woobuntu
git clone https://github.com/anbc/AndBug.git
cd AndBug
make
cd ..
chmod -R a+rw AndBug
cd /usr/bin
ln -s /opt/woobuntu/AndBug/andbug andbug
cd /root

#Responder
mkdir -p /opt/woobuntu
cd /opt/woobuntu
git clone https://github.com/Spiderlabs/Responder
chmod -R a+rw Responder
cd Responder
chmod a+x Responder.py
cd /root

#nikto
mkdir -p /opt/woobuntu
cd /opt/woobuntu
git clone https://github.com/sullo/nikto
chmod -R a+rw nikto
cd nikto
cp -r program/* .
cd /root

#dirs3arch
mkdir -p /opt/woobuntu
cd /opt/woobuntu
git clone https://github.com/maurosoria/dirs3arch.git
chmod -R a+rw dirs3arch
cd /root

#rainbowcrack
mkdir -p /opt/woobuntu
cd /opt/woobuntu
wget http://project-rainbowcrack.com/rainbowcrack-1.6.1-linux64.zip
unzip rainbowcrack-1.6.1-linux64.zip
rm rainbowcrack-1.6.1-linux64.zip
cd rainbowcrack-1.6.1-linux64
chmod a+x rt*
chmod a+x rcrack
cd /usr/bin
ln -s /opt/woobuntu/rainbowcrack-1.6.1-linux64/rcrack rcrack
ln -s /opt/woobuntu/rainbowcrack-1.6.1-linux64/rtgen rtgen
ln -s /opt/woobuntu/rainbowcrack-1.6.1-linux64/rtsort rtsort
ln -s /opt/woobuntu/rainbowcrack-1.6.1-linux64/rtc2rt rtc2rt
ln -s /opt/woobuntu/rainbowcrack-1.6.1-linux64/rt2rtc rc2rtc
cd /root

#Ollydbg
mkdir -p /opt/woobuntu
cd /opt/woobuntu
wget http://down.52pojie.cn/Tools/Debuggers/%e5%90%be%e7%88%b1%e7%a0%b4%e8%a7%a3%e4%b8%93%e7%94%a8%e7%89%88Ollydbg.rar -O tmp.rar
unrar x tmp.rar
rm tmp.rar
cd /root
cat > /usr/share/applications/ollydbg.desktop <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=ollydbg
Icon=application-default-icon
Exec=wine /opt/woobuntu/吾爱破解专用版Ollydbg/原版/汉化原版/Ollydbg.exe
NoDisplay=false
Categories=woobuntu_reverse;
StartupNotify=true
Terminal=false
EOF

#bettercap
gem install bettercap

#zed attack proxy
mkdir /opt/woobuntu
cd /opt/woobuntu
wget https://github.com/zaproxy/zaproxy/releases/download/2.6.0/ZAP_2.6.0_Linux.tar.gz
tar -zxvf ZAP_2.6.0_Linux.tar.gz
rm ZAP_2.6.0_Linux.tar.gz
cd /root
cat > /usr/share/applications/zap.desktop <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=ZAP
Icon=application-default-icon
Exec=/opt/woobuntu/ZAP_2.6.0/zap.sh
NoDisplay=false
Categories=woobuntu_web;
StartupNotify=true
Terminal=false
EOF

#mana-toolkit
mkdir -p /opt/woobuntu
cd /opt/woobuntu
apt-get install libnl-3-dev libssl-dev python-dnspython python-pcapy dsniff stunnel4 -y
git clone --depth 1 https://github.com/sensepost/mana
cd mana
git submodule init
git submodule update
make
make install
cd /root

#redsocks2
apt-get install libevent-dev libssl-dev -y
mkdir -p /opt/woobuntu
cd /opt/woobuntu
git clone https://github.com/semigodking/redsocks.git
cd redsocks
make
cd /root
cat > /opt/woobuntu/config/redsocks2.conf <<EOF
base {
        log_debug = off;
        log_info = off;
        log = "file:/dev/null";
        daemon = off;
        redirector = iptables;
}

redsocks {
        local_ip = 0.0.0.0;
        local_port = 12345;
        ip = 127.0.0.1;
        port = 1080;
        type = socks5;
        autoproxy = 1;
        timeout = 5;
}

EOF

cat > /opt/woobuntu/config/shadowsocks.json <<EOF
{
      "server": "108.22.156.14",
      "server_port": 8080,
      "password": "password",
      "local_port": 1080,
      "method": "table",
      "timeout": "600"
}

EOF

cat > /opt/woobuntu/EnTaroTassadar.sh <<EOF
echo "R U alkaid?\n"
iptables -t nat -N REDSOCKS
iptables -t nat -A REDSOCKS -d 0.0.0.0/8 -j RETURN
iptables -t nat -A REDSOCKS -d 10.0.0.0/8 -j RETURN
iptables -t nat -A REDSOCKS -d 127.0.0.0/8 -j RETURN
iptables -t nat -A REDSOCKS -d 169.254.0.0/16 -j RETURN
iptables -t nat -A REDSOCKS -d 172.16.0.0/12 -j RETURN
iptables -t nat -A REDSOCKS -d 192.168.0.0/16 -j RETURN
iptables -t nat -A REDSOCKS -d 224.0.0.0/4 -j RETURN
iptables -t nat -A REDSOCKS -d 240.0.0.0/4 -j RETURN
iptables -t nat -A REDSOCKS -p tcp -j REDIRECT --to-ports 12345
iptables -t nat -A OUTPUT -p tcp -m owner --uid-owner alkaid -j REDSOCKS
nohup /opt/woobuntu/redsocks/redsocks2 -c /opt/woobuntu/config/redsocks2.conf &
nohup sslocal -c /opt/woobuntu/config/shadowsocks.json &
echo "En Taro Tassadar!\n"
EOF

chmod +x /opt/woobuntu/EnTaroTassadar.sh

#thefuck
pip install thefuck
echo "eval \$(thefuck --alias)" >> /root/.bashrc
echo "eval \$(thefuck --alias)" >> /etc/skel/.bashrc

#electronic-wechat
cd /opt/woobuntu
wget https://github.com/geeeeeeeeek/electronic-wechat/releases/download/V2.0/linux-x64.tar.gz
tar -zxvf linux-x64.tar.gz
rm linux-x64.tar.gz
cd /root

#woobuntu_installer
mkdir -p /opt/woobuntu
cd /opt/woobuntu
git clone https://github.com/lxj616/woobuntu-installer.git
cd woobuntu-installer
qmake
make
cd /root

if [ $install_xfce_desktop -eq 1 ]
then

    cat > /etc/skel/Woobuntu安装向导.desktop <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Woobuntu安装向导
Comment=
Exec=/bin/bash -c "cd /opt/woobuntu/woobuntu-installer;/opt/woobuntu/woobuntu-installer/woobuntu_installer"
Icon=applications-internet-symbolic
Path=/opt/woobuntu/woobuntu-installer
Terminal=true
StartupNotify=false
EOF
  chmod a+x /etc/skel/Woobuntu安装向导.desktop

fi

if [ $install_gnome_desktop -eq 1 ]
then

    cat > /usr/share/applications/woobuntu_installer.desktop <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=woobuntu软件中心
Icon=application-default-icon
Exec=/bin/bash -c "cd /opt/woobuntu/woobuntu-installer;/opt/woobuntu/woobuntu-installer/woobuntu_installer"
NoDisplay=false
Categories=woobuntu;
Path=/opt/woobuntu/woobuntu-installer
StartupNotify=false
Terminal=true
EOF

fi

if [ $install_unity_desktop -eq 1 ]
then

    cat > /usr/share/applications/woobuntu_installer.desktop <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=woobuntu软件中心
Icon=application-default-icon
Exec=/bin/bash -c "cd /opt/woobuntu/woobuntu-installer;/opt/woobuntu/woobuntu-installer/woobuntu_installer"
NoDisplay=false
Categories=woobuntu;
Path=/opt/woobuntu/woobuntu-installer
StartupNotify=false
Terminal=true
EOF

fi

#version date
date +%Y%m%d > /etc/woobuntu_version

if [ $install_virtualbox_additions -eq 1 ]
then

#virtualbox-guest-additions
apt-get install virtualbox-guest-dkms -y
apt-get install virtualbox-guest-x11 -y

fi

if [ $install_nvidia_driver -eq 1 ]
then

#nvidia driver
apt-get install nvidia-352 -y

fi

#End of chroot env , cleanup and repack

apt-get clean
apt-get -d install apache2 php mysql-server php-mysql isc-dhcp-server -y
#apt-get -d install gcc-4.7 g++-4.7 dnsmasq hostapd libssl-dev wireless-tools iw nginx php5-fpm gettext make intltool build-essential automake autoconf uuid uuid-dev php5-curl php5-cli dos2unix curl sudo unzip lsb-release -y
rm -rf /tmp/*
echo "" > /etc/hosts
cat > /etc/resolv.conf <<EOF
nameserver 8.8.8.8
nameserver 114.114.114.114
EOF
exit

