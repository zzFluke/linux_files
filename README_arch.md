# Arch Linux install notes
This document described the steps I took to setup my Arch Linux system.

## Why Arch (instead of Antergos or Manjaro)

1. I read that Manjaro have some hacky insecure stuffs.

2. For this install I need LVM + LUKS encryption, and Antergos installer
   is just not working for me.

## Hardware Notes

1. This is tested on LG Gram 2018 15 inch model.
2. LG gives you an ethernet dongle, so I don't have to worry about wifi.

## Distro installation

1. Download Arch ISO, burn to USB using the command:
   ```
   dd bs=4M if=<ISO file> of=/dev/sdX status=progress oflag=sync
   ```
   You can find the USB disk name with `sudo fdisk -l`.
   
   Then, plug in USB, boot computer and enter bios (by pressing F2 for 
   this laptop).  Disable secure EFI boot in bios, make USB the top
   boot priority, then boot into USB.

2. Do disk partition with the command:
   ```
   gdisk /dev/sdX
   ```
   First command, use `o` to erase everything and get new GPT table.
   Then, use `n` to add the first partition, first sector is default,
   second sector is `+100M`, to create a 100MB partition.  The type code
   is `EF00` for EFI System.  This will be the EFI boot partition.
   
   For the second partition, make it 250 MB boot partition, by having
   first sector be default and sector sector be `+250M`.  Type code is
   `8300`.  For the final partition, both sectors are default (to use up
   rest of the space), and type code is also `8300`.
      
3. Format the partitions, with:
   ```
   mkfs.vfat -F32 /dev/sdX1
   mkfs.ext2 /dev/sdX2
   ```
   
   If they question you, just confirm.
   
4. Setup encryption on sdX3, by calling:
   ```
   cryptsetup -c aes-xts-plain64 -y --use-random luksFormat /dev/sdX3
   cryptsetup luksOpen /dev/sdX3 <CRYPT_NAME>
   ```
   where `CRYPT_NAME` is a name of your choice (I use CRYPT_EC).  Enter your
   passphrase when prompted.
   
5. Create encrypted partitions with:
   ```
   pvcreate /dev/mapper/<CRYPT_NAME>
   vgcreate <VOL_GRP_NAME> /dev/mapper/<CRYPT_NAME>
   lvcreate --size 512M <VOL_GRP_NAME> --name swap
   lvcreate --size 40G <VOL_GRP_NAME> --name root
   lvcreate -l +100%FREE <VOL_GRP_NAME> --name home
   ```
   again `VOL_GRP_NAME` is a name of your choice (I use ARCH_EC).  This
   creates separate root and home partitions.

6. Create filesystems on those partitions with:
   ```
   mkfs.ext4 /dev/mapper/<VOL_GRP_NAME>-root
   mkfs.ext4 /dev/mapper/<VOL_GRP_NAME>-home
   mkswap /dev/mapper/<VOL_GRP_NAME>-swap
   ```

7. Mount the new systems:
   ```
   mount /dev/mapper/<VOL_GRP_NAME>-root /mnt
   swapon /dev/mapper/<VOL_GRP_NAME>-swap
   mkdir /mnt/boot
   mount /dev/sdX2 /mnt/boot
   mkdir /mnt/boot/efi
   mount /dev/sdX1 /mnt/boot/efi
   ```
   
8. Install the base system with:
   ```
   pacstrap /mnt base base-devel emacs git grub efibootmgr dialog
   ```

9. Generate fstab with:
   ```
   genfstab -pU /mnt >> /mnt/etc/fstab
   ```
   
10. chroot to the new system:
    ```
    arch-chroot /mnt /bin/bash
    ```
    
    then edit fstab (using `emacs`), change all `relatime` to `noatime`
    (This is needed for SSDs).
   
11. Setup system clock:
    ```
    rm /etc/localtime
    ln -s /usr/share/zoneinfo/US/Pacific /etc/localtime
    hwclock --systohc --utc
    ```
    
12. Set hostname.  I choose "Husky":
    ```
    echo <HOSTNAME> > /etc/hostname
    ```
    
13. Set locale.  Uncomment "en_US.UTF-8 UTF-8" from the file 
    `/etc/locale.gen`, then run:
    ```
    echo LANG=en_US.UTF-8 > /etc/locale.conf
    echo KEYMAP=us > /etc/vconsole.conf
    local-gen
    ```

14. Set root password:
    ```
    passwd
    ```

15. Add new user:
    ```
    useradd -m -g users -G wheel <USERNAME>
    ```
    
16. etc file `/etc/mkinitcpio.conf`.  Add 'ext4' to `MODULES`.  Add 'encrypt'
    and 'lvm2' to `HOOKS`, in that order, before 'filesystems'.  Afterwards,
    regenerate initrd image with:
    ```
    mkinitcpio -p linux
    ```
    The only warnings should be:
    ```
    WARNING: Possibly missing firmware for module: aic94xx
    WARNING: Possibly missing firmware for module: wd719x
    ```
    these are drivers for advance server hardware.
    
17. Setup grub with:
    ```
    grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=ArchLinux
    ```
    then, edit the following lines in `/etc/default/grub`:
    ```
    GRUB_CMDLINE_LINUX="cryptdevice=/dev/sdX3:luks:allow-discards:resume=/dev/mapper/<VOL_GRP_NAME>-swap"
    ```
    note that "allow-discards" option enable SSD triming (which improves performance), but
    comes with some security risk because of information leakage.
    
    Finally, run the following command to finish setup:
    ```
    grub-mkconfig -o /boot/grub/grub.cfg
    ```
    the only warnings (quite a few lines) should be:
    ```
    WARNING: Failed to connect to lvmetad.  Falling back to device scanning.
    ```

18. Exit the chroot environment:
    ```
    exit
    umount -R /mnt
    swapoff -a
    ```

19. Shut down, unplug USB, then restart.
    

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

   * textext (for inkscape latex rendering)
   * ttf-tw (for Taiwan standard Chinese fonts)
   * mint-themes (for better Cinnamon themes)
   * nemo-dropbox (for nemo integration)
   * fmt (C++ string formatting library)
   
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
