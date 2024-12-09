echo "=============================="
echo " fluent-package Installation Script "
echo "=============================="
echo "This script requires superuser access to install rpm packages."
echo "You will be prompted for your password by sudo."

# clear any previous sudo permission
sudo -k

# run inside sudo
sudo sh <<SCRIPT

  # add GPG key
  rpm --import https://packages.treasuredata.com/GPG-KEY-td-agent
  rpm --import https://packages.treasuredata.com/GPG-KEY-fluent-package

  # add fluent package repository to yum
  cat >/etc/yum.repos.d/fluent-package.repo <<'EOF';
[fluent-package]
name=Fluentd Project
baseurl=https://packages.treasuredata.com/5/amazon/2/\$basearch
enabled=1
gpgcheck=1
gpgkey=https://packages.treasuredata.com/GPG-KEY-td-agent
       https://packages.treasuredata.com/GPG-KEY-fluent-package
EOF

  # update your sources
  yum check-update

  # install the toolbelt
  yes | yum install -y fluent-package

SCRIPT

# message
echo ""
echo "Installation completed. Happy Logging!"
echo ""
