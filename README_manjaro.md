# Manjaro install notes
This document described the steps I took to setup my Manjaro VM.

## Install/setup

0. Download and install the i3 distribution of Manjaro.

1. First, run `sudo pacman -Syu` to update, then install the following using 'sudo pacman -S':

   * git
   * emacs
   * firefox

2. Customize environment:

   1. copy SSH config and private/public keys over to .ssh folder.
   2. Create a softlink if you do not have erichang.key.
   3. Follow the instructions on <https://github.com/pkerichang/linux_files.git>.
   4. change .i3/config symlink to point to config_manjaro.
   5. run i3-msg reload to reload i3 configurations.

3. Use pacman to install the following packages:

   * xorg-xev
   * pacaur
   * tigervnc

4. Use the command `pacaur -S` to install the following packages:

   * pycharm-professional

5. Start firefox, download Anaconda, then install.

## Customizations

1. edit /etc/inputrc, and add/uncomment the line:
   ```
   set bell-style none
   ```
   to disable terminal tab completion sound.