echo "=============================="
echo " td-agent Installation Script "
echo "=============================="
echo "This script requires superuser access to install apt packages."
echo "You will be prompted for your password by sudo."

# clear any previous sudo permission
sudo -k

# run inside sudo
sudo sh <<SCRIPT
  
    # use apt-source package which contains keyring
    curl -o td-agent-apt-source.deb https://packages.treasuredata.com/4/ubuntu/bionic/pool/contrib/f/fluentd-apt-source/fluentd-apt-source_2020.8.25-1_all.deb
    apt install -y ./td-agent-apt-source.deb
  
  # update your sources
  apt update

  # install the toolbelt
  apt install -y td-agent

SCRIPT

# message
if [ $? -eq 0 ]; then
  echo ""
  echo "Installation completed. Happy Logging!"
  echo ""
else
  echo ""
  echo "Installation incompleted. Check above messages."
  echo ""
fi
