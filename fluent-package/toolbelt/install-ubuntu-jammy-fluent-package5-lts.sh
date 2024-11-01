echo "=============================="
echo " fluent-package Installation Script "
echo "=============================="
echo "This script requires superuser access to install apt packages."
echo "You will be prompted for your password by sudo."

# clear any previous sudo permission
sudo -k

# run inside sudo
sudo sh <<SCRIPT
  # use apt-source package which contains keyring
  curl -o fluent-apt-source.deb https://packages.treasuredata.com/lts/5/ubuntu/jammy/pool/contrib/f/fluent-lts-apt-source/fluent-lts-apt-source_2023.7.29-1_all.deb
  apt install -y ./fluent-apt-source.deb
  # update your sources
  apt update

  # install the toolbelt
  apt install -y fluent-package

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
