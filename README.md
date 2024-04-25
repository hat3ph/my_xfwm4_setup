# my_xfwm4_setup
My minimal XFWM4 setup using Ubuntu  or Debian minimal install.

## Autostarting Applications
Edit $HOME/.xsessionrc to autostart applications.

Example:
```
# change monitor resolution
#xrandr --output Virtual-1 --mode 1440x900 &
# start thunar file manager in daemon mode
thunar --daemon &
# run xdg autostart
dex -a &
# slow gtk apps startup
dbus-update-activation-environment --systemd DBUS_SESSION_BUS_ADDRESS DISPLAY XAUTHORITY &
# start xfce4-panel
xfce4-panel &
# start sxhkd
sxhkd &
# start pnmixer audio systray applet
pnmixer &
# start NetworkManager applet
nm-applet &
# run xscreensaver
xscreensaver --nosplash &
# setup wallpaper using feh
feh --bg-fill --randomize /usr/share/backgrounds/gnome/* &
```
## Keyboard Shortcut key using sxhkd
Edit $HOME/.config/sxhkd/sxhkdrc to customize your shortcut key.

Example:
```
# open terminal
super + t
	xfce4-terminal
# open rofi drun mode
super + r
	rofi -show drun
# open rofi power menu mode
super + p
	rofi -show power-menu -modi "power-menu:$HOME/.local/bin/rofi-power-menu --choices=lockscreen/logout/reboot/shutdown --confirm=''"
```
