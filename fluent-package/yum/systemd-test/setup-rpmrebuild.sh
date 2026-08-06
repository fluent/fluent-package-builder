# Installing rpmrebuild from EPEL keeps hanging on the CI runners, so take it
# straight from the upstream project instead.
function install_rpmrebuild()
{
    curl -L -o rpmrebuild.noarch.rpm https://sourceforge.net/projects/rpmrebuild/files/latest/download
    sudo $DNF install -y ./rpmrebuild.noarch.rpm
}

case $distribution in
    amazon)
        case $version in
            2023)
                install_rpmrebuild
                ;;
            2)
                sudo amazon-linux-extras install -y epel
                sudo $DNF install -y rpmrebuild
                ;;
        esac
        ;;
    *)
        install_rpmrebuild
        # hotfix for rpmrebuild 2.20 bug
        # See https://sourceforge.net/p/rpmrebuild/bugs/18/
        pkg_version=$(rpm -q rpmrebuild)
        case $pkg_version in
            rpmrebuild-2.20*)
                curl -LO https://sourceforge.net/p/rpmrebuild/bugs/18/attachment/rpmrebuild-2.20-rpm2archive-bug.patch
                hotfix=$(realpath rpmrebuild-2.20-rpm2archive-bug.patch)
                (cd /usr/lib/rpmrebuild && sudo patch -p2 < $hotfix)
                ;;
        esac
        ;;
esac
