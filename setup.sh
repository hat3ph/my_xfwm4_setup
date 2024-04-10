#!/bin/bash

# optional components installation
my_xfwm4_install=yes # set no if just want to install xfwm4
firefox_deb=yes # install firefox using the deb package
sxhkd_config=yes # set no if do not want to configure sxhkd
rofi_power_menu_confi=yes # set no if do not want to install rofi-power-menu
audio=yes # set no if do not want to use pipewire audio server
thunar=yes # set no if do not want to install thunar file manager
login_mgr=yes # set no if do not want to install SDDM login manager
nm=yes # set no if do not want to use network-manager for network interface management
nano_config=no # set no if do not want to configure nano text editor

install () {
	# install xfwm4 and other packages
	if [[ $my_xfwm4_install == "yes" ]]; then
		sudo apt-get update && sudo apt-get upgrade -y
		sudo apt-get install xorg xinit xfce4-terminal xfwm4 tint2 rofi sxhkd feh gnome-backgrounds lxappearance papirus-icon-theme \
			xdg-utils xdg-user-dirs policykit-1 libnotify-bin dunst nano less software-properties-gtk \
			policykit-1-gnome dex gpicview geany gv flameshot feh xscreensaver unzip -y
		#echo "xfwm4-session" > $HOME/.xinitrc
        cp ./config/xinitrc $HOME/.xinitrc
	fi

	# install Nordic gtk theme https://github.com/EliverLara/Nordic
	mkdir -p $HOME/.themes
	wget -P /tmp https://github.com/EliverLara/Nordic/releases/download/v2.2.0/Nordic.tar.xz
	tar -xvf /tmp/Nordic.tar.xz -C $HOME/.themes

	mkdir -p $HOME/.config/gtk-3.0
	cp ./config/gtk2 $HOME/.gtkrc-2.0
	sed -i "s/administrator/"$USER"/g" $HOME/.gtkrc-2.0
	cp ./config/gtk3 $HOME/.config/gtk-3.0/settings.ini

	# add additional geany colorscheme
	mkdir -p $HOME/.config/geany/colorschemes
	git clone https://github.com/geany/geany-themes.git /tmp/geany-themes
	cp -r /tmp/geany-themes/colorschemes/* $HOME/.config/geany/colorschemes/

	# configure nano with line number
	if [[ $nano_config == "yes" ]]; then
		if [[ -f $HOME/.nanorc ]]; then mv $HOME/.nanorc $HOME/.nanorc_`date +%Y_%d_%m_%H_%M_%S`; fi
		cp /etc/nanorc $HOME/.nanorc
		sed -i 's/# set const/set const/g' $HOME/.nanorc
	fi

    # configure sxhkd
	if [[ $sxhkd_config == "yes" ]]; then
        mkdir -p $HOME/.config/sxhkd
		cp .config/sxhkdrc $HOME/.config/sxhkd
	fi

    # install rofi-power-menu
    if [[ $rofi_power_menu_config == "yes" ]]; then
        mkdir -p $HOME/.local/bin
        git clone https://github.com/jluttine/rofi-power-menu /tmp/rofi-power-menu
        cp /tmp/rofi-power-menu/rofi-power-menu $HOME/.local/bin
        chmod +x $HOME/.local/bin/rofi-power-menu

        # install Nerd fonts for rofi-power-menu
        mkdir -p $HOME/.fonts
        wget -P /tmp https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.0/JetBrainsMono.zip
        unzip /tmp/JetBrainsMono.zip -d $HOME/.fonts/
        fc-cache -fv
    fi

	# use pipewire with wireplumber or pulseaudio-utils
	if [[ $audio == "yes" ]]; then
		# install pulseaudio-utils to audio management for Ubuntu 22.04 due to out-dated wireplumber packages
		if [[ ! $(cat /etc/os-release | awk 'NR==3' | cut -c12- | sed s/\"//g) == "22.04" ]]; then
			sudo apt-get install pipewire pipewire-pulse wireplumber pavucontrol pnmixer -y
		else
			sudo apt-get install pipewire pipewire-media-session pulseaudio pulseaudio-utils pavucontrol pnmixer -y
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

	# optional to install SDDM or LightDM login manager
	if [[ $login_mgr == "yes" ]]; then
		if [[ -n "$(uname -a | grep Ubuntu)" ]]; then
			sudo apt-get install sddm -y
		else
			sudo apt-get install lightdm lightdm-gtk-greeter-settings -y
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