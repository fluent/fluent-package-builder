code_name=$(lsb_release --codename --short)
architecture=$(dpkg --print-architecture)
repositories_dir=/fluentd/fluent-package/apt/repositories
java_jdk=openjdk-11-jre
td_agent_version=4.5.1
case ${code_name} in
  xenial)
    distribution=ubuntu
    channel=universe
    mirror=http://archive.ubuntu.com/ubuntu/
    java_jdk=openjdk-8-jre
    ;;
  bionic|focal|hirsute|jammy)
    distribution=ubuntu
    channel=universe
    mirror=http://archive.ubuntu.com/ubuntu/
    ;;
  buster|bullseye)
    distribution=debian
    channel=main
    mirror=http://deb.debian.org/debian
    ;;
  bookworm)
    distribution=debian
    channel=main
    mirror=http://deb.debian.org/debian
    java_jdk=openjdk-17-jre
    ;;
esac
