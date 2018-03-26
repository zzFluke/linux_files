# Manjaro install notes
This document described the steps I took to setup my Manjaro XFCE.

## Install/setup

0. Download and install the XFCE distribution of Manjaro.

1. First, run `sudo pacman -Syu` to update, then install the following using 
   'sudo pacman -S':

   * emacs
   * ttf-dejavu (so emacs can see the DejaVu fonts).

2. Customize environment:

   1. copy SSH config and private/public keys over to .ssh folder.
   2. Create a softlink if you do not have erichang.key.
   3. Follow the instructions at: 
      <https://github.com/pkerichang/linux_files.git>.

3. Use pacman to install the following packages:

   * pacaur
   * tigervnc

4. Use the command `pacaur -S` to install the following packages:

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
