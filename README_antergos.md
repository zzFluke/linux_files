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

1. Run the following command to rank antergos mirrors
   ```
   sudo rankmirrors -n 0 /etc/pacman.d/antergos-mirrorlist > /tmp/antergos-mirrorlist && sudo cp /tmp/antergos-mirrorlist /etc/pacman.d
   ```

2. Use pacman to install the following packages:

   * namcap (needed to verify custom built packages)
   * tigervnc
   * inkscape
   * texlive-most (I select bibtexextra, core, fontsextra, formatextra,
     latexextra, pictures, and science)
   * pdf2svg (for inkscape/textext)
   * ibus-chewing (for chinese input)
   * x2goclient
   * qbittorrent
   * gnome-disk-utility (for configuring automounting disks at startup)
   * dropbox
   * pacaur
   * networkmanager-openconnect (for cisco anyconnect VPN)
   * pacman-contrib (get pactree for pacaur)
   * qpdf (for splitting PDFs)
   * ruby (for some optional dependencies of subversion and texlive-core)
   * pepper-flash (for chromium flash player)
   * adobe-source-han-sans-otc-fonts (asian fonts)
   * adobe-source-han-serif-otc-fonts (asian fonts)
   * noto-fonts (some fonts)
   * noto-fonts-cjk (more fonts for asian characters)
   * noto-fonts-tc (more fonts for traditional chinese)

4. Use pacman to install the following Python-related packages:

   * ipython
   * python-pip
   * python-scipy
   * python-pyqt5
   * python-matplotlib
   * python-h5py
   * python-networkx
   * python-pytest
   * python-jinja
   * python-pyzmq
   * python2-lxml (for inkscape/textext).
   * python-yaml

5. Use the command `pacaur -S` to install the following packages:

   * textext (for inkscape latex rendering)
   * ttf-tw (for Taiwan standard Chinese fonts)
   * mint-themes (for better Cinnamon themes)
   * nemo-dropbox (for nemo integration)
   
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

9. install the following with `pacman` for C++ development:

   * boost
   * cmake
   * yaml-cpp

10. To setup chinese input, at the command line, run:
    ```
    ibus-setup
    ```
    
    then make a soft link from `.xprofile_antergos_cinnamon` to `.xprofile`.
    Since LightDM sources .xprofile, this will make ibus run at startup.
    
11. Switch themes to the following settings to have things more readable:

    * Window borders: Mint-Y-Dark
    * Icons: Mint-Y
    * Controls: Mint-Y-Dark
    * Mouse Pointer: Adwaita
    * Desktop: Mint-Y-Dark

## Switching to Nvidia drivers

I find that with Nouveau driver, chromium sometimes have glitchy graphics,
and one time the whole system even froze up (journalctl shows some fifo
write fault error).  I decide to switch to Nvidia driver.

1. install nvidia installer:
   ```
   sudo pacman -S nvidia-installer
   ```

2. 

## Customizations

1. To disable terminal tab completion sound, edit `/etc/inputrc`, and add/uncomment the line:
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

### CLion

1. In Editor/General, set "Strip trailing spaces on Save" to "All", and 
   uncheck "Always keep trailing spaces on caret line".
   
2. In Keymap, set to "Eclipse"

3. In Editor/Code Style, set hard wrap at 100 columns.

4. In inspection settings, uncheck "Unused class", "Unused method", 
   "Unused struct", and "Unused Global Definition".

## Optional Programs

From AUR:

  * mudlet (for playing MUD)

## Program Notes

### Pacman

1. There is a bug with color=never option that caused `pacaur` to crash.
   This is solved by uncommenting the line containing a single word "Color" 
   in `/etc/pacman.conf`.

Sometime for some reason, some package cannot be downloaded due to GPG key
being invalid.  This is finally solved by running:

```
sudo pacman -Scc (yes to all options)
sudo pacman-key --refresh-keys
sudo pacman -Syyu
```

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
