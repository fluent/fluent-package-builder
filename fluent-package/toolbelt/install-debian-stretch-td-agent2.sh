echo "=============================="
echo " td-agent Installation Script "
echo "=============================="
echo "This script requires superuser access to install apt packages."
echo "You will be prompted for your password by sudo."

# clear any previous sudo permission
sudo -k

# run inside sudo
sudo sh <<SCRIPT
  curl https://packages.treasuredata.com/GPG-KEY-td-agent | apt-key add -

  # add treasure data repository to apt
  echo "deb http://packages.treasuredata.com/2/debian/stretch/ stretch contrib" > /etc/apt/sources.list.d/treasure-data.list

  # update your sources
  apt-get update

  # install the toolbelt
  apt-get install -y td-agent

SCRIPT

# message
echo ""
echo "Installation completed. Happy Logging!"
echo ""
