#!/bin/zsh
set -e

#
# CONFIG FOR A HEADLESS MAC MINI SERVER. 
#
username="wolf"
publickey="id_rsa.pub"
hostname="m6"

# enable SSH / remote login
systemsetup -setremotelogin on
tee /etc/ssh/sshd_config.d/headless.conf <<EOF
PermitRootLogin no
AllowUsers $username
PasswordAuthentication no
KbdInteractiveAuthentication no
EOF
touch ~/.ssh/authorized_keys
cat ~/.ssh/${publickey} > ~/.ssh/authorized_keys
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
chown ${username}:staff  ~/.ssh/authorized_keys
echo ssh setup and enabled for $username

# No password req for sudo
echo "\n${username} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
echo $username can now sudo without a password

# Disable FileVault, otherwise ssh will not start without entering a password
fdesetup disable

# hostname
scutil --set HostName ${hostname}.local
scutil --set LocalHostName $hostname
scutil --set ComputerName $hostname
echo HostName $hostname set

# disable WiFi .. verify en1 with `networksetup -listallhardwareports`
networksetup -setairportpower en1 off
echo WiFi disabled 

# disable FaceTime
launchctl disable gui/$(id -u)/com.apple.ichat.Assistant
rm ~/Library/Preferences/com.apple.FaceTime.plist
echo FaceTime disabled 

# disable AirDrop
defaults write com.apple.NetworkBrowser DisableAirDrop -bool true
echo AirDrop disabled 

# turn off Discoverability
defaults write com.apple.sharingd DiscoverableMode "Off"
echo Discoverability disabled 

# Spotlight Indexing (mds / mdworker)
mdutil -i off /
launchctl disable system/com.apple.metadata.mds
echo Spotlight Indexing disabled 

# disable  UI helper agent
launchctl disable gui/$(id -u)/com.apple.notificationcenterui
killall NotificationCenter
echo NotificationCenter disabled 

# disable GUI Widgets
defaults write com.apple.WindowManager StandardHideWidgets -bool true

# filesharing
launchctl enable system/com.apple.smbd
launchctl bootstrap system /System/Library/LaunchDaemons/com.apple.smbd.plist 2>/dev/null
echo FileSharing enabled

# energy settings
pmset -a disablesleep 1
pmset -a autorestart 1
pmset -g
echo All Done! 

