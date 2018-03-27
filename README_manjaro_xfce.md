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
   4. create a softlink from .xinitrc_manjaro_xfce to .xinitrc.
   5. create a softlink from .xprofile_manjaro_xfce to .xprofile.

3. Use pacman to install the following packages:

   * pacaur
   * tigervnc
   * inkscape
   * texlive-most (I select bibtexextra, core, fontsextra, formatextra,
     latexextra, pictures, and science).
   * pdf2svg (for inkscape/textext).
   * ibus-chewing (for chinese input).
 
4. Use pacman to install the following Python-related packages:

   * ipython
   * python-scipy
   * python-pyqt5
   * python-matplotlib
   * python2-lxml (for inkscape/textext).

5. Use the command `pacaur -S` to install the following packages:

   * pdftk (for splitting PDFs)
   * textext (for inkscape latex rendering)
   * dropbox
   * thunar-dropbox (Thunar integration with Dropbox).

6. Start firefox, download Pycharm, then install.

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

3. Run the command:
   ```
   inxi -G
   ```
   to determine graphics card driver.  If you want to switch to NVIDIA
   drivers, run:
   ```
   sudo mhwd -a pci nonfree 0300
   ```
   then reboot.

4. edit /etc/fstab to include the following line:
   
   /dev/sdc1 /run/media/erichang/Quaternary ntfs defaults,auto 0 0

    to mount NTFS drive at startup.
    
5. in firefox, disable hardware acceleration to prevent screen tearing.

6. disable dropbox auto-start for now, as for some reason icon will not
   show up in system tray.

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
