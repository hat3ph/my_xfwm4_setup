#!/bin/bash

# optional components installation
my_xfwm4_install=yes # set no if just want to install xfwm4
firefox_deb=yes # install firefox using the deb package
sxhkd_config=yes # set no if do not want to configure sxhkd
rofi_power_menu_config=yes # set no if do not want to install rofi-power-menu
theming=yes # set no if do not want to install nordic theme
xfce4_panel_config=yes # set yes to enable custom xfce4-panel settings
audio=yes # set no if do not want to use pipewire audio server
thunar=yes # set no if do not want to install thunar file manager
login_mgr=yes # set no if do not want to install SDDM login manager
nm=yes # set no if do not want to use network-manager for network interface management
nano_config=no # set no if do not want to configure nano text editor

install () {
	# install xfwm4 and other packages
	if [[ $my_xfwm4_install == "yes" ]]; then
		sudo apt-get update && sudo apt-get upgrade -y
		sudo apt-get install xorg xinit xfce4-terminal xfwm4 xfce4-panel sxhkd feh xscreensaver \
			lxappearance papirus-icon-theme xdg-utils xdg-user-dirs policykit-1 libnotify-bin dunst nano \
			less software-properties-gtk policykit-1-gnome dex gpicview geany gv flameshot unzip -y
		echo "exec xfwm4" > $HOME/.xinitrc
        cp ./config/xsessionrc $HOME/.xsessionrc
	 	# enable acpid
   		#sudo apt-get install acpid -y
     	#sudo systemctl enable acpid
	fi

	# install Nordic gtk theme https://github.com/EliverLara/Nordic
 	if [[ $theming == "yes" ]]; then
		mkdir -p $HOME/.themes
		wget -P /tmp https://github.com/EliverLara/Nordic/releases/download/v2.2.0/Nordic.tar.xz
		tar -xvf /tmp/Nordic.tar.xz -C $HOME/.themes
		
		# gtk2 and gtk3 settings
		mkdir -p $HOME/.config/gtk-3.0
		cp ./config/gtk2 $HOME/.gtkrc-2.0
		#sed -i "s/administrator/"$USER"/g" $HOME/.gtkrc-2.0
		cp ./config/gtk3 $HOME/.config/gtk-3.0/settings.ini
		cp ./config/gtk.css $HOME/.config/gtk-3.0/gtk.css
	
		# setup xfwm4 to use Nordic theme
		#xfconf-query -c xfwm4 -p /general/theme -t "string" -s "Nordic"

		# copy wallpapers
  		mkdir -p $HOME/Pictures/wallpapers
   		cp ./wallpapers/* $HOME/Pictures/wallpapers/

		# add additional geany colorscheme
		mkdir -p $HOME/.config/geany/colorschemes
		git clone https://github.com/geany/geany-themes.git /tmp/geany-themes
		cp -r /tmp/geany-themes/colorschemes/* $HOME/.config/geany/colorschemes/

  		# insall dracula xfce4-terminal theme
    	mkdir -p $HOME/.local/share/xfce4/terminal/colorschemes
      	git clone https://github.com/dracula/xfce4-terminal.git /tmp/xfce4-terminal
		cp /tmp/xfce4-terminal/Dracula.theme $HOME/.local/share/xfce4/terminal/colorschemes

		# install dracula themes
  		mkdir -p $HOME/.icons
    	wget -P /tmp https://github.com/dracula/gtk/releases/download/v4.0.0/Dracula-cursors.tar.xz
      	tar -xvf /tmp/Dracula-cursors.tar.xz -C $HOME/.icons

		mkdir -p $HOME/.themes
		wget -P /tmp https://github.com/dracula/gtk/releases/download/v4.0.0/Dracula.tar.xz
  		tar -xvf /tmp/Dracula.tar.xz -C $HOME/.themes
	fi

	# copy tint2rc settings
	#mkdir -p $HOME/.config/tint2
	#cp ./config/tint2rc $HOME/.config/tint2/tint2rc

	# copy xfce4-panel settings
	if [[ $xfce4_panel_config == "yes" ]]; then
		mkdir -p $HOME/.config/xfce4/panel/launcher-{8,10,14,15}
		mkdir -p $HOME/.config/xfce4/xfconf/xfce-perchannel-xml
		cp ./config/xfce4-panel.xml $HOME/.config/xfce4/xfconf/xfce-perchannel-xml/
		cp ./config/17140153922.desktop $HOME/.config/xfce4/panel/launcher-8/
		cp ./config/17140154333.desktop $HOME/.config/xfce4/panel/launcher-10/
		cp ./config/17140154514.desktop $HOME/.config/xfce4/panel/launcher-14/
		cp ./config/17140154635.desktop $HOME/.config/xfce4/panel/launcher-15/
	fi

	# configure nano with line number
	if [[ $nano_config == "yes" ]]; then
		if [[ -f $HOME/.nanorc ]]; then mv $HOME/.nanorc $HOME/.nanorc_`date +%Y_%d_%m_%H_%M_%S`; fi
		cp /etc/nanorc $HOME/.nanorc
		sed -i 's/# set const/set const/g' $HOME/.nanorc
	fi

    	# configure sxhkd
	if [[ $sxhkd_config == "yes" ]]; then
 		mkdir -p $HOME/.config/sxhkd
   		cp ./config/sxhkdrc $HOME/.config/sxhkd/sxhkdrc
	fi

	# install rofi-power-menu
 	if [[ $rofi_power_menu_config == "yes" ]]; then
  		sudo apt-get install rofi -y
		mkdir -p $HOME/.local/bin
		cp ./bin/power.sh $HOME/.local/bin
		chmod +x $HOME/.local/bin/power.sh
	fi

	# use pipewire with wireplumber or pulseaudio-utils
	if [[ $audio == "yes" ]]; then
		# install pulseaudio-utils to audio management for Ubuntu 22.04 due to out-dated wireplumber packages
		if [[ ! $(cat /etc/os-release | awk 'NR==3' | cut -c12- | sed s/\"//g) == "22.04" ]]; then
			sudo apt-get install pipewire pipewire-pulse wireplumber pavucontrol-qt pnmixer -y
		else
			sudo apt-get install pipewire pipewire-media-session pulseaudio pulseaudio-utils pavucontrol-qt pnmixer -y
		fi
		mkdir -p $HOME/.config/pnmixer
		cp ./config/pnmixer $HOME/.config/pnmixer/config
	fi

	# optional to install thunar file manager
	if [[ $thunar == "yes" ]]; then
		sudo apt-get install thunar gvfs gvfs-backends thunar-archive-plugin thunar-media-tags-plugin avahi-daemon -y
		#mkdir -p $HOME/.config/xfce4
		#echo "TerminalEmulator=lxterminal" > $HOME/.config/xfce4/helpers.rc
	fi

	# optional to install SDDM or lxDM login manager
	if [[ $login_mgr == "yes" ]]; then
 		sudo mkdir -p /usr/share/xsessions
	 	sudo cp ./config/xfwm4.desktop /usr/share/xsessions
		if [[ -n "$(uname -a | grep Ubuntu)" ]]; then
  			sudo apt-get install sddm -y
		else
			sudo apt-get install lxdm -y
		fi
	fi

	# install firefox without snap
	# https://www.omgubuntu.co.uk/2022/04/how-to-install-firefox-deb-apt-ubuntu-22-04
	if [[ $firefox_deb == "yes" ]]; then
		if [[ -n "$(uname -a | grep Ubuntu)" ]]; then
			sudo install -d -m 0755 /etc/apt/keyrings
			wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | \
				sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
			echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | \
				sudo tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null
			echo -e "Package: *\nPin: origin packages.mozilla.org\nPin-Priority: 1000" | \
				sudo tee /etc/apt/preferences.d/mozilla
			sudo apt-get update && sudo apt-get install firefox -y
		else
			sudo apt-get install firefox-esr -y
			# change from firefox to firefox-esr for application launcher
			#sed -i 's/firefox/firefox-esr/g' $HOME/.config/tint2/tint2rc
			sed -i 's/firefox/firefox-esr/g' $HOME/.config/xfce4/panel/launcher-10/17140154333.desktop
		fi
  	fi

	# optional install NetworkManager
	if [[ $nm == yes ]]; then
		sudo apt-get install network-manager network-manager-gnome -y
		if [[ -n "$(uname -a | grep Ubuntu)" ]]; then
			for file in `find /etc/netplan/* -maxdepth 0 -type f -name *.yaml`; do
				sudo mv $file $file.bak
			done
			echo -e "# Let NetworkManager manage all devices on this system\nnetwork:\n  version: 2\n  renderer: NetworkManager" | \
			sudo tee /etc/netplan/01-network-manager-all.yaml
		else
			sudo cp /etc/NetworkManager/NetworkManager.conf /etc/NetworkManager/NetworkManager.conf.bak
			sudo sed -i 's/managed=false/managed=true/g' /etc/NetworkManager/NetworkManager.conf
			sudo mv /etc/network/interfaces /etc/network/interfaces.bak
			head -9 /etc/network/interfaces.bak | sudo tee /etc/network/interfaces
			sudo systemctl disable networking.service
		fi
	fi

	# disable unwanted services
 	if [[ -n "$(uname -a | grep Ubuntu)" ]]; then
 		sudo systemctl disable systemd-networkd-wait-online.service
  		sudo systemctl disable multipathd.service
	fi
}

printf "\n"
printf "Start installation!!!!!!!!!!!\n"
printf "88888888888888888888888888888\n"
printf "My xfwm4 Install        : $my_xfwm4_install\n"
printf "Firefox as DEB packages : $firefox_deb\n"
printf "sxhkd Config            : $sxhkd_config\n"
printf "Rofi power menu         : $rofi_power_menu_config\n"
printf "Custom Theming          : $theming\n"
printf "Custom XFCE4-Panel      : $xfce4_panel_config\n"
printf "Pipewire Audio          : $audio\n"
printf "Thunar File Manager     : $thunar\n"
printf "Login Manager           : $login_mgr\n"
printf "NetworkManager          : $nm\n"
printf "Nano's configuration    : $nano_config\n"
printf "88888888888888888888888888888\n"

while true; do
read -p "Do you want to proceed with above settings? (y/n) " yn
	case $yn in
		[yY] ) echo ok, we will proceed; install; echo "Remember to reboot system after the installation!";
			break;;
		[nN] ) echo exiting...;
			exit;;
		* ) echo invalid response;;
	esac
done
