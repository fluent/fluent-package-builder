code_name=$(lsb_release --codename --short)
architecture=$(dpkg --print-architecture)
repositories_dir=/fluentd/fluent-package/apt/repositories
java_jdk=openjdk-11-jre
td_agent_version=4.5.2
fluent_package_lts_version=5.0.5

case ${code_name} in
  jammy|noble)
    distribution=ubuntu
    channel=universe
    mirror=http://archive.ubuntu.com/ubuntu/
    if [ "$architecture" = "arm64" ]; then
        echo "For ${code_name} (arm64), use ubuntu-ports"
        mirror=http://ports.ubuntu.com/ubuntu-ports
    fi
    ;;
  bookworm)
    distribution=debian
    channel=main
    mirror=http://deb.debian.org/debian
    java_jdk=openjdk-17-jre
    ;;
  trixie)
    distribution=debian
    channel=main
    mirror=http://deb.debian.org/debian
    java_jdk=openjdk-25-jre-headless
    ;;
esac

function test_suppressed_needrestart()
{
    LOG_FILE=$1
    # Test: needrestart was suppressed
    if dpkg-query --show --showformat='${Version}' needrestart ; then
        case $code_name in
            focal)
                # dpkg-query succeeds even though needrestart is not installed.
                (! grep "No services need to be restarted." $LOG_FILE)
                ;;
            *)
                grep "No services need to be restarted." $LOG_FILE
                ;;
        esac
    fi
}

function install_aws_cli()
{
    case $architecture in
        amd64)
            curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
            ;;
        arm64)
            curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"
            ;;
    esac
    sudo apt install -y unzip
    unzip awscliv2.zip
    sudo ./aws/install
}
