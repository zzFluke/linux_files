# Manjaro install notes
This document described the steps I took to setup my Manjaro VM with i3.

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
   6. make a soft link from .xsession_i3 to .xsession.

3. Use pacman to install the following packages:

   * xorg-xev
   * pacaur
   * tigervnc
   * ff-theme-util 
     (for some reason this command is called when startup.  I install this to eliminate erros in .xsession-errors).

4. Use the command `pacaur -S` to install the following packages:

   * pycharm-professional
   * pdftk (for splitting PDFs).

5. Start firefox, download Anaconda, then install.

6. make an empty directory $HOME/.local/share/icons/default.
   
   This is used to eliminate a copy error in .xsession-errors.

## Customizations

1. Edit /etc/inputrc, and add/uncomment the line:
   ```
   set bell-style none
   ```
   to disable terminal tab completion sound.

2. Create the file `/etc/modprobe.d/nobeep.conf`, with a single line:
   ```
   blacklist pcspkr
   ```
   to disable annoying beeps when screen locks.

3. the file ${HOME}/.xsession with permission 755, with a single line of 
   "eval $(ssh-agent)", is used to run ssh-agent at startup.  This file will be run by 
   lightdm (which Manjaro i3 uses) if it is executable.  A corresponding line 
   "AddKeysToAgent=yes" is added in .ssh/config so that keys are added to ssh-agent on 
   first use without needing ssh-add.

