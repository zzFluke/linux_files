# Antergos install notes
This document described the steps I took to setup my Antergos system.

## Distro installation

1. Download Antergos minimal ISO, create bootable USB, and install.

2. For DE I choose Cinnamon, because I have the best experience with
   it before when I try out Manjaro.  It has no screen tearing issues,
   and notification icons actually works (which is important for Dropbox).
   
3. For disk partition, I did not use encryption because I have other Windows
   game stuff on the same disk, and I separate root and home paritition so
   hopefully it's easier to change distro/reinstall without losing data.

4. I use systemd-boot since I see good things (or rather bad things about
   grub) online.

5. NOTE: I ran into a bug where I select encryption first, then cancel it
   later.  However, after installation Antergos cannot boot because it
   thought the disk is encrypted (when it isn't).  I had to reinstall 
   Antergos again.

## Initial Setups

1. In terminal perferences, change color scheme to tango dark.

2. In file explorer, set all new folders to use list view in preferences, 
   and show hidden files (by using right-click context menu).

3. Run the following installation commands to get essential programs:
   ```
   sudo pacman -Syu (make sure system is up to date)
   sudo pacman -S emacs git ttf-dejavu (get git/emacs ready)
   ```
   
4. Copy `.ssh/config` and private/public keys over.  Create a softlink for erichang.key.

5. Follow the instructions at <https://github.com/pkerichang/linux_files.git>.

5. remove the file `.bashrc.aliases`.  We don't use this file.

6. close terminal, and restart.

## Finishing Setups

3. Use pacman to install the following packages:

   * tigervnc
   * inkscape
   * texlive-most (I select bibtexextra, core, fontsextra, formatextra,
     latexextra, pictures, and science)
   * pdf2svg (for inkscape/textext)
   * ibus-chewing (for chinese input)
   * x2goclient
   * qbittorrent
   * gnome-disk-utility (for configuring automounting disks at startup)
   * adobe-source-han-sans-otc-fonts (asian fonts)
   * dropbox
   * pacaur
 
4. Use pacman to install the following Python-related packages:

   * ipython
   * python-scipy
   * python-pyqt5
   * python-matplotlib
   * python-h5py
   * python-networkx
   * python-pytest
   * python-jinja
   * python-pyzmq
   * python2-lxml (for inkscape/textext).

5. Use the command `pacaur -S` to install the following packages:

   * pdftk (for splitting PDFs)
   * textext (for inkscape latex rendering)

6. Start chromium, download Pycharm and CLion, then install.

7. install following (prevent GStreamer plugin errors in xsesson) with pacman:

   * qt5-declarative
   * opencv
   * libkate
   * fluidsynth
   * zbar
   * lilv

8. edit `/etc/lightdm/lightdm.conf`, under the [Seat:*] section, change the line:
   ```
   display-setup-script=xrandr --output DVI-D-1 --primary
   ```
   
   so that the login screen shows up at the right monitor.  To figure out the monitor name, run `xrandr`.

## Customizations

1. TO disable terminal tab completion sound, edit `/etc/inputrc`, and add/uncomment the line:
   ```
   set bell-style none
   ```

2. Create the file `/etc/modprobe.d/nobeep.conf`, with a single line:
   ```
   blacklist pcspkr
   ```
   to disable annoying beeps when screen locks.
   
3. Open Gnome Disk Utility, edit mount options for external drives to mount at startup.

4. Set primary monitor display, if necessary.

5. add chromium shortcut to task bar.  The executable is `/usr/bin/chromium`, the icon is at
   `/usr/share/app-info/icons/archlinux-arch-extra/128x128/chromium_chromium.png`.

## Program Notes

### Inkscape

Latex rendering in Inkscape got broken by Ghostscript 9.22 when they
remove the DELAYBIND option, which breaks the pstoedit program.  The
current experimental workaround is to use the textext extension, which
has an experimental feature to use pdf2svg instead of pstoedit.
   
To get this to work, follow installation instructions above to install
all the required packages.  Then, download the file textext.py from the
following URL:

https://bitbucket.org/pitgarbe/textext/issues/57/pdf2svg-migration

place this textext.py in the folder /usr/share/inkscape/extensions.  Make
sure to make a backup of the original.


## TODO

1. dropbox and cower packages seem broken, so cannot install pacaur and dropbox.  Try later?

2. install ttf-tw chinese font instead (need pacaur)
