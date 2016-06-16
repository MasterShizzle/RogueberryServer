#?!/bin/bash

echo "Setting up environment..."

# Set up directories
echo "Installing dependencies..."
sudo apt-get -y install git-core build-essential bison flex libncurses5-dev 

# Get sources

# Nethack
echo "Installing NetHack..."
git clone http://git.code.sf.net/p/nethack/NetHack

cp raspbian-jessie.hints NetHack/sys/unix/hints/raspbian-jesse
cd NetHack/
sh ./sys/unix/setup.sh sys/unix/hints/raspbian-jesse
make all
sudo make install
