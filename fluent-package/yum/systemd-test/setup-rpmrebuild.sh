case $distribution in
    amazon)
        case $version in
            2023)
                curl -L -o rpmrebuild.noarch.rpm https://sourceforge.net/projects/rpmrebuild/files/latest/download
                sudo $DNF install -y ./rpmrebuild.noarch.rpm
                ;;
            2)
                sudo amazon-linux-extras install -y epel
                sudo $DNF install -y rpmrebuild
                ;;
        esac
        ;;
    *)
        sudo $DNF install -y epel-release
        sudo $DNF install -y rpmrebuild
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
