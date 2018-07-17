# Arch Linux install notes
This document described the steps I took to setup my Arch Linux system.

## Why Arch (instead of Antergos or Manjaro)

1. I read that Manjaro have some hacky insecure stuffs.

2. For this install I need LVM + LUKS encryption, and Antergos installer
   is just not working for me.

## Hardware Notes

1. This is tested on LG Gram 2018 15 inch model.
2. LG gives you an ethernet dongle, so I don't have to worry about wifi.

## Distro Installation

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
    
## Post Installation

### Misc System Setup with Root

1. Login as root.  Update system clock:
   ```
   timedatectl set-ntp true
   ```

2. Write the following to `/etc/hosts`:
   ```
   127.0.0.1 localhost
   ::1       localhost
   127.0.1.1 <HOSTNAME>.localdomain <HOSTNAME>
   ```

3. Use `ip link` to find ethernet name, then use `systemctl start dhcpcd@<ETHERNET_NAME>.servce` to start internet.

4. Install and enable Intel microcode updates:
   ```
   pacman -S intel-ucode
   grub-mkconfig -o /boot/grub/grub.cfg
   ```
   the grub command enables intel microcode loading in bootloader stage.
   
5. As root, add user to sudoer file by running:
   ```
   EDITOR=emacs visudo
   ```
   and uncommenting the line `%wheel ALL=(ALL) ALL`.

### Desktop Environment Installation

1. Install the following pacman packages for GUI:
   * cinnamon
   * lightdm
   * light-locker
   * gnome-terminal
   * blueberry (for bluetooth support)
   * gnome-keyring
   * gnome-screenshot
   * chromium
   * dhclient (NetworkManager only works with dhclient for public wifi)

2. Exit root, sign in as user, and create a folder `pkgs_arch` in home directory for AUR packages.  Go in that directory.

3. Get lightdm-slick-greeter from AUR, and build with:
   ```
   git clone https://aur.archlinux.org/lightdm-slick-greeter.git
   cd lightdm-slick-greeter
   makepkg -si
   ```

4. Modify the file `/etc/lightdm/lightdm.conf` with the following:
   ```
   [Seat:*]
   ...
   greeter-session=lightdm-yourgreeter-greeter
   ...
   ```

5. Create a new file `/etc/NetworkManager/conf.d/dhcp-client.conf`, with the    content:
   ```
   [main]
   dhcp=dhclient
   ```
   NetworkManager is not built with dhcpd support (the default Arch Linux 
   DHCP program).  This allows NetworkManager to connect to public wifi.
   
6. Run the following to start the dekstop environment:
   ```
   systemctl enable lightdm.service
   systemctl start lightdm.service
   ```
7. Once GUI started, enable NetworkManager:
   ```
   systemctl enable NetworkManager.service
   systemctl start NetworkManager.service
   ```

8. Enable `fstrim.timer` to trim SSDs periodically:
   ```
   systemctl enable fstrim.timer
   systemctl start fstrim.timer
   ```

## Initial Setups

1. In mouse and trackpad settings, enable multi-click for right click.

1. In terminal perferences, change color scheme to tango dark.

2. In file explorer, set all new folders to use list view in preferences, 
   and show hidden files (by using right-click context menu).
   
3. Copy `.ssh/config` and private/public keys over.  Create a softlink for erichang.key.

5. Follow the instructions at <https://github.com/pkerichang/linux_files.git>.

6. close terminal, and restart.

## Finishing Setups

1. Use pacman to install the following packages:

   * namcap (Needed to verify custom built packages)
   * tigervnc
   * inkscape
   * zathura
   * zathura-pdf-mupdf (A PDF viewer with keyboard shortcuts)
   * texlive-most (I select bibtexextra, core, fontsextra, formatextra,
     latexextra, pictures, and science)
   * pdf2svg (for inkscape/textext)
   * ibus-chewing (for chinese input)
   * x2goclient
   * qbittorrent
   * networkmanager-openconnect (for cisco anyconnect VPN)
   * qpdf (for splitting PDFs)
   * ruby (for some optional dependencies of subversion and texlive-core)
   * pepper-flash (for chromium flash player)
   * adobe-source-han-sans-otc-fonts (asian fonts)
   * adobe-source-han-serif-otc-fonts (asian fonts)
   * noto-fonts (some fonts)
   * noto-fonts-cjk (more fonts for asian characters)	

2. Use pacman to install the following Python-related packages:

   * ipython
   * cython
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

3. Install the following packages from AUR:

   * textext (for inkscape latex rendering)
   * ttf-tw (for Taiwan standard Chinese fonts)
   * noto-fonts-tc
   * mint-x-icons
   * mint-y-icons
   * mint-themes (for better Cinnamon themes)
   * dropbox
   * nemo-dropbox (for nemo integration)
   
4. Start chromium, download Pycharm and CLion, then install.

5. install the following with `pacman` for C++ development:

   * boost
   * cmake
   * yaml-cpp

6. To setup chinese input, at the command line, run:
   ```
   ibus-setup
   ```
    
   then make a soft link from `.xprofile_antergos_cinnamon` to `.xprofile`.
   Since LightDM sources .xprofile, this will make ibus run at startup.
    
7. Switch themes to the following settings to have things more readable:

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
   
3. add chromium shortcut to task bar.  The executable is `/usr/bin/chromium`, the icon is at
   `/usr/share/app-info/icons/archlinux-arch-extra/128x128/chromium_chromium.png`.

### CLion

1. In Editor/General, set "Strip trailing spaces on Save" to "All", and 
   uncheck "Always keep trailing spaces on caret line".
   
2. In Keymap, set to "Eclipse"

3. In Editor/Code Style, set hard wrap at 100 columns.

4. In inspection settings, uncheck "Unused class", "Unused method", 
   "Unused struct", and "Unused Global Definition".

## Optional Programs

1. Mudlet:

   Because I need to build from source (since I added traditional chinese
   encoding), I need to figure out the dependencies manually.  This is
   the steps I took to compile:

   * clone mudlet from AUR, run `makepkg -si`.
  
   * get a list of dependencies on AUR, git clone those and install them
    using `makepkg`.
  
   * install the following with `pacman` (found by running cmake to
     figure out the missing dependencies):
    
     * lua51-filesystem
     * qt5-tools
     * qt5-multimedia
     * qt5-gamepad
     * libzip
     * yajl
     * pugixml
    
   * make a build folder, then cd and build using cmake.  Finally, 
     make a softlink from ${MUDLET_DIR}/build/src/mudlet to ${HOME}/bin
     
   * copy the directory ${MUDLET_DIR}/src/mudlet-lua/lua to 
     /usr/local/share/mudlet/lua

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
