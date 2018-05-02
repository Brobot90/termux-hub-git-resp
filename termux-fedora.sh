#!/data/data/com.termux/files/usr/bin/bash

# input validator and help

case "$1" in
	f26_arm)
	    DOCKERIMAGE=http://download.fedoraproject.org/pub/fedora/linux/releases/26/Docker/armhfp/images/Fedora-Docker-Base-26-1.5.armhfp.tar.xz
	    ;;
        f26_arm64)
	    DOCKERIMAGE=https://download.fedoraproject.org/pub/fedora-secondary/releases/26/Docker/aarch64/images/Fedora-Docker-Base-26-1.5.aarch64.tar.xz
	    ;;
	f27_arm)
	    DOCKERIMAGE=http://download.fedoraproject.org/pub/fedora/linux/releases/27/Docker/armhfp/images/Fedora-Docker-Base-27-1.6.armhfp.tar.xz
	    ;;
	f27_arm64)
	    DOCKERIMAGE=https://download.fedoraproject.org/pub/fedora-secondary/releases/27/Docker/aarch64/images/Fedora-Docker-Base-27-1.6.aarch64.tar.xz
	    ;;
	uninstall)
	    chmod -R 777 ~/fedora
	    rm -rf ~/fedora
	    exit 0
	    ;;
	*)
	    echo $"Usage: $0 {f26_arm|f26_arm64|f27_arm|f27_arm64|uninstall}"
	    exit 2
	    ;;
esac


# install necessary packages

apt update && apt install proot tar -y

# get the docker image

mkdir ~/fedora
cd ~/fedora
/data/data/com.termux/files/usr/bin/wget $DOCKERIMAGE -O fedora.tar.xz

# extract the Docker image

/data/data/com.termux/files/usr/bin/tar xvf fedora.tar.xz --strip-components=1 --exclude json --exclude VERSION

# extract the rootfs

/data/data/com.termux/files/usr/bin/tar xpf layer.tar

# cleanup

chmod +w .
rm layer.tar
rm fedora.tar.xz

# fix DNS

echo "nameserver 8.8.8.8" > ~/fedora/etc/resolv.conf

# make a shortcut

cat > /data/data/com.termux/files/usr/bin/startfedora <<- EOM
#!/data/data/com.termux/files/usr/bin/bash
unset LD_PRELOAD && proot --link2symlink -0 -r ~/fedora -b /dev/ -b /sys/ -b /proc/ -b /storage/ -b $HOME -w $HOME /bin/env -i HOME=/root TERM="$TERM" PS1='[termux@fedora \W]\$ ' LANG=$LANG PATH=/bin:/usr/bin:/sbin:/usr/sbin /bin/bash --login
EOM

chmod +x /data/data/com.termux/files/usr/bin/startfedora

# all done

echo "All done! Start Fedora with 'startfedora'. Gets update with regular 'dnf update'. "
