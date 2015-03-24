#!/bin/bash
# Script Name: AtoMiC CouchPotato installer
# Author: htpcBeginner.com
# Publisher: http://www.htpcBeginner.com
# Version: 1.0 (March 29, 2013) - Initial release
# Version: 1.1 (October 03, 2013) - Bugfixes
# Version: 2.0 (April 13, 2014) - Updated script to work with Trusty Tahr
# Version: 3.0 (March 14, 2015) - Improved code and user friendliness
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#

# DO NOT EDIT ANYTHING UNLESS YOU KNOW WHAT YOU ARE DOING.
YELLOW='\e[93m'
RED='\e[91m'
ENDCOLOR='\033[0m'
CYAN='\e[96m'
GREEN='\e[92m'
SCRIPTPATH=$(pwd)

clear
echo 
echo -e $RED
echo -e " ┬ ┬┬ ┬┬ ┬ ┬ ┬┌┬┐┌─┐┌─┐┌┐ ┌─┐┌─┐┬┌┐┌┌┐┌┌─┐┬─┐ ┌─┐┌─┐┌┬┐"
echo -e " │││││││││ ├─┤ │ ├─┘│  ├┴┐├┤ │ ┬│││││││├┤ ├┬┘ │  │ ││││"
echo -e " └┴┘└┴┘└┴┘o┴ ┴ ┴ ┴  └─┘└─┘└─┘└─┘┴┘└┘┘└┘└─┘┴└─o└─┘└─┘┴ ┴"
echo -e $CYAN
echo -e "                __     __           "
echo -e "  /\ |_ _ |\/|./      (_  _ _. _ |_ "
echo -e " /--\|_(_)|  ||\__    __)(_| ||_)|_ "
echo -e "                              |     "
echo -e $GREEN'AtoMiC CouchPotato Installer Script'$ENDCOLOR
echo 
echo -e $YELLOW'--->CouchPotato installation will start soon. Please read the following carefully.'$ENDCOLOR

echo -e '1. The script has been confirmed to work on Ubuntu variants, Mint, and Ubuntu Server.'
echo -e '2. While several testing runs identified no known issues, www.htpcBeginner.com or the authors cannot be held accountable for any problems that might occur due to the script.'
echo -e '3. If you did not run this script with sudo, you maybe asked for your root password during installation.'
echo -e '4. By proceeding you authorize this script to install any relevant packages required to install and configure CouchPotato.'
echo -e '5. Best used on a clean system (with no previous CouchPotato install) or after complete removal of previous CouchPotato installation.'

echo

read -p 'Type y/Y and press [ENTER] to AGREE and continue with the installation or any other key to exit: '
RESP=${REPLY,,}

if [ "$RESP" != "y" ] 
then
	echo -e $RED'So you chickened out. May be you will try again later.'$ENDCOLOR
	echo
	exit 0
fi

echo 

echo -n 'Type the username of the user you want to run CouchPotato as and press [ENTER]. Typically, this is your system login name (IMPORTANT! Ensure correct spelling and case): '
read UNAME

if [ ! -d "/home/$UNAME" ] || [ -z "$UNAME" ]; then
  echo -e $RED'Bummer! You may not have entered your username correctly. Exiting now. Please rerun script.'$ENDCOLOR
  echo
  exit 0
fi

echo

echo -e $YELLOW'--->Refreshing packages list...'$ENDCOLOR
sudo apt-get update

echo
sleep 1

echo -e $YELLOW'--->Installing prerequisites...'$ENDCOLOR
sudo apt-get -y install git-core python python-cheetah

echo
sleep 1

echo -e $YELLOW'--->Checking for previous versions of CouchPotato...'$ENDCOLOR
sleep 1
sudo /etc/init.d/couchpotato* stop >/dev/null 2>&1
sudo killall couchpotato* >/dev/null 2>&1
echo -e 'Any running CouchPotato processes killed'
sleep 1
sudo update-rc.d -f couchpotato remove >/dev/null 2>&1
sudo rm /etc/init.d/couchpotato >/dev/null 2>&1
sudo rm /etc/default/couchpotato >/dev/null 2>&1
echo -e 'Existing CouchPotato init scripts removed'
sleep 1
sudo update-rc.d -f couchpotato remove >/dev/null 2>&1
mv /home/$UNAME/.couchpotato /home/$UNAME/.couchpotato_`date '+%m-%d-%Y_%H-%M'` >/dev/null 2>&1
echo -e 'Any existing CouchPotato files were moved to '$CYAN'/home/'$UNAME'/.couchpotato_'`date '+%m-%d-%Y_%H-%M'`$ENDCOLOR

echo
sleep 1

echo -e $YELLOW'--->Downloading latest CouchPotato...'$ENDCOLOR
cd /home/$UNAME
git clone git://github.com/RuudBurger/CouchPotatoServer.git /home/$UNAME/.couchpotato || { echo -e $RED'Git not found.'$ENDCOLOR ; exit 1; }
chmod 775 -R /home/$UNAME/.couchpotato >/dev/null 2>&1
sudo chown $UNAME: /home/$UNAME/.couchpotato >/dev/null 2>&1

echo
sleep 1

echo -e $YELLOW'--->Configuring CouchPotato Install...'$ENDCOLOR
cd /home/$UNAME/.couchpotato/init
echo "# COPY THIS FILE TO /etc/default/couchpotato" >> couchpotato || { echo 'Could not create default file.' ; exit 1; }
echo "# OPTIONS: CP_HOME, CP_USER, CP_DATA, CP_PIDFILE, PYTHON_BIN, CP_OPTS, SSD_OPTS" >> couchpotato
echo "CP_HOME=/home/"$UNAME"/.couchpotato/" >> couchpotato
echo "CP_DATA=/home/"$UNAME"/.couchpotato/" >> couchpotato

echo -e 'Enabling user'$CYAN $UNAME $ENDCOLOR'to run CouchPotato...'
echo "CP_USER="$UNAME >> couchpotato
sudo mv couchpotato /etc/default/
sudo chmod +x /etc/default/couchpotato

echo
sleep 1

echo -e $YELLOW'--->Enabling CouchPotato AutoStart at Boot...'$ENDCOLOR
sudo cp ubuntu /etc/init.d/couchpotato || { echo $RED'Creating init file failed.'$ENDCOLOR ; exit 1; }
sudo chown $UNAME: /etc/init.d/couchpotato
sudo chmod +x /etc/init.d/couchpotato
sudo update-rc.d couchpotato defaults

echo
sleep 1

echo -e 'Starting CouchPotato'
sudo /etc/init.d/couchpotato start >/dev/null 2>&1

echo
echo -e $GREEN'--->All done. '$ENDCOLOR
echo -e 'CouchPotato should start within 10-20 seconds and your browser should open.'
echo -e 'If not you can start it using '$CYAN'/etc/init.d/couchpotato start'$ENDCOLOR' command.'
echo -e 'Then open '$CYAN'http://localhost:5050'$ENDCOLOR' in your browser.'
echo
echo -e $YELLOW'If this script worked for you, please visit '$CYAN'http://www.htpcBeginner.com'$YELLOW' and like/follow us.'$ENDCOLOR
echo -e $YELLOW'Thank you for using the AtoMiC CouchPotato install script from www.htpcBeginner.com.'$ENDCOLOR 
echo
sleep 5
URL=http://www.htpcbeginner.com/atomic-thanks
[[ -x $BROWSER ]] && exec "$BROWSER" "$URL"
path=$(which xdg-open || which gnome-open) && exec "$path" "$URL" >/dev/null 2>&1
