#!/bin/bash

#Step 1) Check if root--------------------------------------
if [[ $EUID -ne 0 ]]; then
   echo "Please execute script as root." 
   exit 1
fi
#-----------------------------------------------------------

#Step 2) Update repository----------------------------------
cd /boot/
File=config.txt
if grep -q "avoid_warnings=0" "$File";
        then
		sed -i '/avoid_warnings=0/d' "$File";
fi
if grep -q "avoid_warnings=1" "$File";
        then
                echo "warnings already disable. Doing nothing."
        else
                echo "avoid_warnings=1" >> "$File"
                echo "warnings disable."
fi
#-----------------------------------------------------------

#Step 3) Install gpiozero module----------------------------
sudo apt-get install -y python-dev python-pip python-gpiozero
sudo pip install psutil pyserial

#-----------------------------------------------------------

#Step 4) Download Python script-----------------------------
cd /opt/
sudo mkdir dkn
cd /opt/dkn
script=fan_ctrl-dkn.py

if [ -e $script ];
	then
		echo "Script fan_ctrl-dkn.py already exists. Updating..."
		rm $script
		wget "https://raw.githubusercontent.com/th3drk0ne/DKN-Fan-Controller/main/fan_ctrl-dkn.py"
		echo "Update complete."
	else
		wget "https://raw.githubusercontent.com/th3drk0ne/DKN-Fan-Controller/main/fan_ctrl-dkn.py"
                echo "Download  complete."
fi
#-----------------------------------------------------------

#Step 5) Enable Python script to run on start up------------
cd /etc/
RC=rc.local


#Adding new configuration----------- 
if grep -q "sudo python \/opt\/dkn\/fan_ctrl-dkn.py \&" "$RC";
	then
		echo "File /etc/rc.local already configured. Doing nothing."
	else
		sed -i -e "s/^exit 0/sudo python \/opt\/dkn\/fan_ctrl-dkn.py \&\n&/g" "$RC"
		echo "File /etc/rc.local configured."
fi
#-----------------------------------------------------------

#Step 6) Reboot to apply changes----------------------------
echo "Fan Control Board installation done. Will now reboot after 3 seconds."
sleep 4
sudo reboot
#-----------------------------------------------------------