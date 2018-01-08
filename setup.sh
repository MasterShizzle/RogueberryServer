#?!/bin/bash

echo "Setting up environment..."

# Set up directories
echo "Installing dependencies..."
sudo apt-get -y install git-core build-essential bison flex libncurses5-dev 

# Get sources

# Nethack
echo "Installing NetHack..."
# git clone http://git.code.sf.net/p/nethack/NetHack
wget https://s3.amazonaws.com/nethack.org/3.6.0/nethack-360-src.tgz
tar -xzvf nethack-360-src.tgz

cp raspbian-jessie.hints nethack-3.6.0/sys/unix/hints/raspbian-jesse
cd nethack-3.6.0/
sh ./sys/unix/setup.sh sys/unix/hints/raspbian-jesse
make all
sudo make install
