# Rogueberry Server: The Raspberry Pi Roguelike Server

### Introduction and Prerequisites
This package contains the wherewithal to download and compile DGameLaunch (along with some favorite Roguelikes of mine) on the Raspberry Pi. The end goal is a Pi running a fully-featured roguelike server with DGameLaunch that supports multiple games and multiple users.

You don't need any experience with Linux to start with, but a basic working knowledge of Linux and how to move around the shell is definitely going to speed things up. Besides your own PC, to follow along with the steps in this file you'll need:

* A Raspberry Pi, model B or higher STRONGLY recommended, along with the means to power it and connect it to the Internet
  * [This page at eLinux](http://elinux.org/RPi_Hardware_Basic_Setup#Typical_Hardware_You_Will_Need) is a great resource if you're just getting started: simply follow the list of hardware for headless deployment and you're good to go.
* An 8Gb or higher capacity SD card
  * Cards are marketed largely by their sustained write speed, which has little bearing on the overall performance of the Raspberry Pi. Go online and shop around: there are more forums and web pages *about* SD card choices than there *are* SD card choices. I used a SanDisk 32Gb Class 10.
* An SD card reader, connected to your PC
* Any Roguelike fan is likely to already have a favorite, but you'll need software to access your Pi from a different computer via SSH (and later Telnet). I recommend [PuTTY](http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html).
* 

Recommended but not necessary:

* Protective cases for your RPi and SD cards
  * If you don't have the wherewithal to get a case or you're just too cheap to buy one, worry not! Just whip out your hot glue gun and [find some toothpicks and a box.](http://www.judepullen.com/designmodelling/raspberry-pi-case/)
* A second SD card
  * It's optional, but... not really. It's easy to just restore a backed-up image to a card you misconfigured, but it's much harder (read: pretty much impossible) to restore a card that's been FUBAR'd by physical means. SD cards get dropped, chewed on, or just plain lost *too* easily, especially with more and more flavors of the Pi now using MicroSD by default.


****

## INSTRUCTIONS

### Configuring Raspbian and Your Network
> NOTE: I highly recommend getting a GitHub account. If you're at all serious about learning to program anything, you'll need to be comfortable with version control systems. This project was what motivated me to start learning git, and my workflow has been better ever since.

This is the boring setup bit, in which we configure and install the necessary prerequisite softwares and reboot the Raspberry Pi a bunch of times.

1. You'll want to get a working image of the latest stable Raspbian on your Pi. At the time of this writing I'm using the 4.4 kernel of [Raspbian Jessie Lite](https://www.raspberrypi.org/downloads/raspbian/). [This page](http://elinux.org/RPi_Easy_SD_Card_Setup#SD_card_setup) has all the instructions and links you need to do the install.
2. Boot your Pi into Raspbian and connect to it via SSH. We've got some housekeeping to do.
3. Enter in `pi` and your password to login, then use `sudo raspi-config` to access the configuration menu.
  1. In this menu select the **Expand filesystem** option to claim the entire SD card as useable space.
  2. If you're letting other users connect to your Pi at any point in the future, then you NEED to change the default password.
  3. In **Boot Options**, choose "Console", no autologin.
  4. Enable **Wait for Network at Boot**
  5. You can choose to overclock, or not, at your leisure.
  6. Go to **Advanced Options**
    1. Change the Hostname if you like. I'm using "rogueberry".
    2. Change Memory Split to 0. You're not doing anything graphical, so we want the CPU to have all the resources we can give it.
    3. The SSH option should be enabled by default, but if it's not go here and choose to enable SSH if, for some reason, you're connecting via a non-networked means.
    4. Finally, if you're getting weird errors or using an older binary, there may be updates to the config tool itself. The last option on this page will fix that.
4. Choose `<Finish>` and let the Pi reboot if the config tool asks you to. If not, go ahead and do it anyway by typing `sudo reboot`.
5. [ModMyPi's page](http://www.modmypi.com/blog/how-to-give-your-raspberry-pi-a-static-ip-address-update) has a simple method for getting your RPi booting to a static IP address, which I highly recommend.
6. After booting, get back to the command prompt and run `sudo apt-get update && sudo apt-get -y upgrade` to update all the repositories and software. This might take a while, but you won't need to do it that often.

At this point, you've got a non-specialized, fully functional Raspbian installation that will boot up and run "headless". I find it *immensely* helpful to power down and make a backup image of your card to save your progress at this point, as it's useful for more things than just the modest task we've set out on. A pre-configured image can save you a lot of time, and it applies to any other steps in any other projects. Good backups save time and frustration.

Got that? Whenever something cool happens, power down and back up your data. You have been warned.

\[[Back to Top](#introduction-and-prerequisites)\]

### Compiling and Configuring Software

#### Game 1: Nethack

1. SSH into your Pi. Start with the base software to download and compile stuff.
```shell
$ sudo apt-get -y install git-core
```
2. Pull the setup files from github:
```shell
$ git clone https://github.com/MasterShizzle/RogueberryServer.git
$ cd RogueberryServer
$ nano install.sh
```
The script by default installs everything on /opt/rogueberry/.


We'll use the Nethack version that's on nethack.alt.org's server, since it's got a great selection of patches installed. You can check out http://alt.org/nethack/naonh.php for a list of the patches they've got. All we want to do is change some of the destination directories:

```shell
$ cd nh343-nao
$ nano Makefile
```

In the Makefile, there are two parameters that need to change. They occurred at lines 17 and 18 in my version:
```
	# make NetHack
	PREFIX   = /home/pi/RogueberryServer/bin
	GAME     = nethack
```
This makes sure that Nethack compiles into the directory we made with the install script. Hit Ctrl-X to save, Y to confirm overwrite, and you're back at the prompt. Now open up the next file:
```shell
$ nano src/Makefile
```
We need to change the name of the executable here as well. You can do a Ctrl-W search for "GAME" to get you there. Mine was on line 296.
```
	# make NetHack
	GAME     = nethack
```
Again, this will change the name of the executable. Save and exit.

Once you're back at the nh343-nao directory:
```shell
$ make all
```
... and wait for GCC to finish doing its voodoo that it do. 

(It takes a while. My Pi was overclocked to 800MHz and it took about 15 minutes. You'll see a number of warnings pop up while this is going on; just ignore them. The compilers are rather new, and the source code (and its syntax, naming conventions, etc.) are rather old in comparison.)

Once this is done...
```shell
$ sudo make install
```
... will finish everything up. Nethack itself is compiled and done.

****

#### Step 2: Configuring DGameLaunch
Now we have to configure dgamelaunch's config file for our needs. Type in this:
```shell
$ id games
```
Make sure you get the following output or something similar: `uid=5(games) gid=60(games) groups=60(games)`

If your games user is a bit different, no worries. Just make sure you know the gid and uid of the `games` user and move on to the next step.

We're going to use the config files that are already present:
