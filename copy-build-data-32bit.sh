# MUST call this from docker container!
# /var/workspace/kernel/<name>/linux

KERNEL=kernel7

# Ask for confirmation of kernel
echo "Kernel: $KERNEL"
read -p "Is the kernel name correct? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Exiting..."
    exit 1
fi


INSTALL_PATH=$(dirname "$PWD")/install-32bit
echo "INSTALL_PATH: $INSTALL_PATH"

# Ask for confirmation
read -p "Are you sure you want to copy? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Exiting..."
    exit 1
fi

mkdir -p $INSTALL_PATH
mkdir -p $INSTALL_PATH/broadcom
mkdir -p $INSTALL_PATH/overlays

# Ask if debug information should be stripped from kernel modules
read -p "Strip debug information from kernel modules? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    STRIP="INSTALL_MOD_STRIP=1"
else
    STRIP=""
fi

# Kernel modules
make -j12 $STRIP ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- INSTALL_MOD_PATH=$INSTALL_PATH modules_install

# Headers
make -j12 ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- INSTALL_HDR_PATH=$INSTALL_PATH headers_install

# Kernel image
cp arch/arm/boot/zImage $INSTALL_PATH/$KERNEL.img

# Device tree blobs
cp arch/arm/boot/dts/broadcom/*.dtb $INSTALL_PATH/broadcom

# Overlays
cp arch/arm/boot/dts/overlays/*.dtb* $INSTALL_PATH/overlays

# Readme
cp arch/arm/boot/dts/overlays/README $INSTALL_PATH/overlays

