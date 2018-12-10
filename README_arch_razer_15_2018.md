# Archlinux Installation
This document described the steps I took to setup my Arch Linux system.

## Installation options

1. Installed with LVM on LUKS encryption, no dual boot.

2. Using systemd-boot instead of GRUB on UEFI, as it's more lightweight.

## Hardware Notes

1. Installed on Razer Blade 15in 2018 model.

## Installation Media

1. Plug in USB.  Open "Disks" GUI utility, delete existing USB partitions and
   create a new FAT partition. Also, note the disk name, mine is `/dev/sde`.

2. Download Arch ISO, burn to USB using the command:
   ```
   sudo dd bs=4M if=<ISO file> of=<disk name> status=progress oflag=sync
   ```

   then eject and unplug USB.

## Boot from USB disk

1. Plug in USB to laptop, boot and enter BIOS setup (by pressing F12
   repeatedly).  Disable fast boot under "Boot" (Linux don't use/need it),
   and  disable secure boot under "Security", then save and exit.  On reboot,
   press F12 again and choose to boot from USB.

2. Use `fdisk -l` to find the disk name (`/dev/nvme0n1` for me), then run:
   ```
   gdisk <disk name>
   ```

   Enter `o` to erase everything and get new GPT table.  Then enter `w` to
   save and exit `gdisk`.

## Erase Disk

Reference: https://wiki.archlinux.org/index.php/Dm-crypt/Drive_preparation

1. Run:
   ```
   cryptsetup open --type plain -d /dev/urandom <disk name> to_be_wiped
   ```
   to start wiping the disk.  Type "YES" when prompted.

2. Run:
   ```
   dd bs=4M if=/dev/zero of=/dev/mapper/to_be_wiped status=progress
   ```
   to overwrite disk with all zeros.  Finally, run:
   ```
   cryptsetup close to_be_wiped
   ```
   to close the temporary container.

## Disk setup

Reference: https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_an_entire_system#LVM_on_LUKS
Reference (UEFI): https://wiki.voidlinux.eu/Install_LVM_LUKS_on_UEFI_GPT

Note: We're using UEFI boot, so instead of a boot partition, a UEFI
partition is created instead.

1. Run `gdisk` again, use `o` to create new partition table.  Then,
   use `n` to add the first partition, first sector (i.e. start location)
   is default, second sector is `+260M`, to create a 260MB partition.
   The type code is `EF00` for EFI System.  This will be the EFI boot
   partition.

   For the second partition, both sectors are default (to use up rest of
   the space), and type code is `8300`.  Then, use `w` to save and write
   the partitions.

   Use fdisk -l to find the names of the two partitions.  Format UEFI
   with FAT32 by typing:
   ```
   mkfs.vfat -F32 <UEFI partition name>
   ```

2. Setup encryption on the second partition, by calling:
   ```
   cryptsetup luksFormat --type luks2 <main partition name>
   cryptsetup open <main partition name> <CRYPT_NAME>
   ```

   where `CRYPT_NAME` is a name of your choice (I use CRYPT_EC).  Enter
   your passphrase when prompted.

3. Create encrypted partitions with:
   ```
   pvcreate /dev/mapper/<CRYPT_NAME>
   vgcreate <VOL_GRP_NAME> /dev/mapper/<CRYPT_NAME>
   lvcreate -L 8G <VOL_GRP_NAME> -n swap
   lvcreate -L 40G <VOL_GRP_NAME> -n root
   lvcreate -l 100%FREE <VOL_GRP_NAME> -n home
   ```

   again `VOL_GRP_NAME` is a name of your choice (I use ARCH_EC).  This
   creates separate root and home partitions.

   NOTE: technically, to ensure 100% hibernation success, swap space
   need to be large enough to store all memory in DRAM.  However,
   there is some magical compression that happen, and I don't think I'll
   hibernate with bunch of used memory anyways, so I just pick 8G.

4. Create filesystems on those partitions with:
   ```
   mkfs.ext4 /dev/mapper/<VOL_GRP_NAME>/root
   mkfs.ext4 /dev/mapper/<VOL_GRP_NAME>/home
   mkswap /dev/mapper/<VOL_GRP_NAME>/swap
   ```

5. Mount the new systems:
   ```
   mount /dev/mapper/<VOL_GRP_NAME>/root /mnt
   mkdir /mnt/home
   mount /dev/mapper/<VOL_GRP_NAME>/home /mnt/home
   swapon /dev/mapper/<VOL_GRP_NAME>/swap
   mkdir /mnt/boot
   mount <UEFI partition name> /mnt/boot
   ```

## OS Install

Reference (wireless): https://wiki.archlinux.org/index.php/Wireless_network_configuration
Reference (install): https://wiki.archlinux.org/index.php/installation_guide
Reference (noatime): https://wiki.debian.org/SSDOptimization
Reference (systemd-boot): https://wiki.archlinux.org/index.php/Systemd-boot
Reference (suspend-to-disk): https://wiki.archlinux.org/index.php/Dm-crypt/Swap_encryption
Reference (boot configuration): https://wiki.archlinux.org/index.php/Dm-crypt/System_configuration#Boot_loader



1. First, we need to connect to wifi.  Use `ip link` to find the wireless interface name
   (`wlp2s0` for me).  Then, create a new `netctl` profile with:
   ```
   cp /etc/netctl/examples/wireless-wpa /etc/netctl/<profile_name>
   ```

2. Edit the file using `nano`.  Change "Interface" field to wireless interface name,
   change "ESSID" field to name of the wifi network, change "key" field to the wifi
   password.  Finally, press Ctrl+O, Enter, then Ctrl+X to save and exit.

3. Change to directory `/etc/netctl`, run `netctl start <profile_name>`.  Then you
   should be connected to the internet.

4. Install the base system with:
   ```
   pacstrap /mnt base base-devel emacs git grub efibootmgr dialog intel-ucode wpa_supplicant
   ```

5. Generate fstab with:
   ```
   genfstab -U /mnt >> /mnt/etc/fstab
   ```

6. chroot to the new system:
   ```
   arch-chroot /mnt
   ```

   then edit `/etc/fstab` (using `emacs`), change all `relatime` to `noatime`
   (To reduce disk writes for SSDs).

7. Setup system clock:
   ```
   ln -sf /usr/share/zoneinfo/US/Pacific /etc/localtime
   hwclock --systohc
   ```

8. Set hostname.  I choose "Husky":
   ```
   echo <HOSTNAME> > /etc/hostname
   ```
   and add the following to `/etc/hosts`:
   ```
   127.0.0.1    localhost
   ::1          localhost
   127.0.1.1    <HOSTNAME>.localdomain <HOSTNAME>
   ```

9. Set locale.  Uncomment "en_US.UTF-8 UTF-8" from the file
   `/etc/locale.gen`, then run:
   ```
   local-gen
   echo LANG=en_US.UTF-8 > /etc/locale.conf
   echo KEYMAP=us > /etc/vconsole.conf
   ```

10. Set root password:
    ```
    passwd
    ```

11. Add new user:
    ```
    useradd -m -g users -G wheel <USERNAME>
    passwd <USERNAME>
    ```

    then type in the user password.

12. etc file `/etc/mkinitcpio.conf`.  Change "HOOKS" field to the following:
    ```
    HOOKS=(base systemd autodetect keyboard sd-vconsole modconf block sd-encrypt sd-lvm2 filesystems fsck)
    ```
    The notable changes are:

    1. "udev" changed to "systemd"
    2. "keyboard" moved before "block", added "sd-vconsole" before "block".
    3. added "sd-encrypt" and "sd-lvm2" after "block" and before
       "filesystems".

    ```
    mkinitcpio -p linux
    ```

    The only warnings should be:

    ```
    WARNING: Possibly missing firmware for module: aic94xx
    WARNING: Possibly missing firmware for module: wd719x
    ```

    these are drivers for advance server hardware.

13. Install systemd-boot with:
    ```
    bootctl --path=/boot install
    ```

    edit `/boot/loader/loader.conf`, and add the following lines:
    ```
    timeout 2
    editor no
    default arch
    ```

14. Add the file `/boot/loader/entries/arch.conf`, with the following:
    ```
    title   Arch Linux
    linux   /vmlinuz-linux
    initrd  /intel-ucode.img
    initrd  /initramfs-linux.img
    options rd.luks.name=<UUID>=cryptroot root=/dev/<VOL_GRP_NAME>/root resume=/dev/<VOL_GRP_NAME>/swap rd.luks.options=discard
    ```

    where UUID is uuid of the main partition, found with `blkid`.

15. Exit the chroot environment and shutdown:
    ```
    exit
    umount -R /mnt
    swapoff -a
    shutdown 0
    ```
    Thne unplug USB, then restart.

## Post Installation

### Misc System Setup with Root

1. Login as root.  Update system clock:
   ```
   timedatectl set-ntp true
   ```

2. As root, add user to sudoer file by running:
   ```
   EDITOR=emacs visudo
   ```
   and uncommenting the line `%wheel ALL=(ALL) ALL`.

3. Uncomment the "Color" option in `/etc/pacman.conf`.

4. Start wifi using instructions from before.  Then, before installing
   `thermald`, install `lm_sensors` and run the script `sensors-detect` on
   command line.  Then enable/start `lm_sensors.service`.  Finally, run:

   ```
   pacman -S thermald
   ```

8. (This doesn't work, left as reference) To generate configuration file for
   thermald, clone the auto config generation repo with:
   ```
   git clone https://github.com/intel/dptfxtract.git
   ```
   then run the script with root permission to generate configuration file
   in `/var/run/thermald`, and copy it to `/etc/thermald/thermald-conf.xml`.
   When done, enable `thermald` with:
   ```
   systemctl enable thermald.service
   systemctl start thermald.service
   ```

### Desktop Environment Installation

1. Install the following pacman packages for GUI:
   * cinnamon
   * lightdm
   * light-locker
   * gnome-terminal
   * blueberry (for bluetooth support)
   * gnome-keyring
   * chromium
   * flameshot (Great screenshot tool)
   * dhclient (NetworkManager only works with dhclient for public wifi)
   * clang (needed to build tools later)
   * cmake (needed to build tools later)

2. Exit root, sign in as user, and create a folder `pkgs_arch` in home
   directory for AUR packages.  Go in that directory.

3. Setup `yay`, an AUR helper, from AUR using makepkg:
   ```
   git clone https://aur.archlinux.org/yay.git
   cd yay
   makepkg -si
   ```

   answer yes when asked to install.

4. Install the following with `yay -S`:
   * lightdm-slick-greeter
   * lightdm-settings
   * systemd-boot-pacman-hook

5. Modify the file `/etc/lightdm/lightdm.conf` with the following:
   ```
   [LightDM]
   ...
   logind-check-graphical=true
   ...
   [Seat:*]
   ...
   greeter-session=lightdm-slick-greeter
   ...
   ```

   The `logind-check-graphical` option is used to tell lightDM to wait
   until the graphics driver are loaded before starting, thus preventing
   black screen.

6. Create a new file `/etc/NetworkManager/conf.d/dhcp-client.conf`, with the
   content:
   ```
   [main]
   dhcp=dhclient
   ```

   NetworkManager is not built with dhcpd support (the default Arch Linux
   DHCP program).  This allows NetworkManager to connect to public wifi.

7. Run the following to start the dekstop environment:
   ```
   systemctl enable lightdm.service
   systemctl start lightdm.service
   ```
8. Once GUI started, stop `netctl@<wifi name>.service`, then enable
   NetworkManager:
   ```
   systemctl enable NetworkManager.service
   systemctl start NetworkManager.service
   ```

9. Enable `fstrim.timer` to trim SSDs periodically:
   ```
   systemctl enable fstrim.timer
   systemctl start fstrim.timer
   ```

10. Also install `tlp`.  Just follow instructions on Arch wiki.

## Initial Setups

1. In mouse and trackpad settings, enable multi-click for right click.
   Also disable reverse scrolling direction.

2. In terminal perferences, change color scheme to tango dark.

3. In file explorer, set all new folders to use list view in preferences,
   and show hidden files (by using right-click context menu).

4. Copy `.ssh/config` and private/public keys over.  Create a softlink
   for erichang.key.  Make config file and private key permission to be
   600.

5. Next, we need to install some packages needed by emacs.  Install
   `ycmd-git` and `universal-ctags-git` from AUR.

6. Install `ripgrep` with `pacman`.

7. Follow the instructions at <https://github.com/pkerichang/linux_files.git>.

8. close terminal, and restart.

9. Start emacs, wait for it to download and install packages.

10. setup emacs server-client systemd service by running:
   ```
   systemctl --user enable emacsd.service
   systemctl --user start emacsd.service
   ```

## Finishing Setups

1. Use `pacman` to install the following packages:

   * tigervnc
   * inkscape
   * vlc
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
   * gtk-engines
   * gtk-engine-murrine (to prevent GTK warnings on engine loading).
   * nemo-fileroller (for extraction capability)
   * libreoffice (install from fresh)
   * rsync (for remote file syncing)
   * xorg-xrandr
   * mlocate (for the locate command)
   * cups (for printing)
   * cups-pdf (for printing to pdf)

2. Use `pacman` to install the following Python related packages:

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
   * python-virtualenv
   * python-pytest-xdist (for distributed unit testing)
   * python-sortedcontainers

3. Start emacs, run `M-x jedi:install-server` to install jedi
   server for Python editing.


4. Use `yay` to install the following C++ related packages:

   * boost
   * yaml-cpp (for reading/writing yaml files)
   * spdlog-git (from AUR, for logging in C++)
   * catch2 (C++ unit testing)

5. Use `yay` to install the following AUR packages:

   * textext (for inkscape latex rendering)
   * ttf-tw (for Taiwan standard Chinese fonts)
   * noto-fonts-tc
   * mint-x-icons
   * mint-y-icons
   * mint-themes (for better Cinnamon themes)
   * xviewer (for image viewing)
   * qdirstat (for disk usage viewing)

6. Start chromium, download Pycharm, then install.

7. To setup chinese input, at the command line, run:
   ```
   ibus-setup
   ```

   then make a soft link from `.xprofile_antergos_cinnamon` to `.xprofile`.
   Since LightDM sources `.xprofile`, this will make ibus run at startup.

8. Switch themes to the following settings (in System Settings->Themes) to
   have things more readable:

   * Window borders: Mint-Y-Dark
   * Icons: Mint-Y
   * Controls: Mint-Y-Dark
   * Mouse Pointer: Adwaita
   * Desktop: Mint-Y-Dark

9. Start CUPS printing service:
   ```
   sudo systemctl enable org.cups.cupsd.service
   sudo systemctl start org.cups.cupsd.service
   ```

## Graphics Card Setup

1. Install and setup `optimus-manager` package:
   ```
   yay -S optimus-manager
   sudo systemctl enable optimus-manager.service
   sudo systemctl start optimus-manager.service
   optimus-manager --set-startup intel
   ```

   To switch video card, run `optimus-manager --swtich <intel/nvidia>`.
   NOTE: I noticed that I need to restart in order for this to take effect.


## Customizations

1. To disable terminal tab completion sound, edit `/etc/inputrc`, and
   add/uncomment the line:
   ```
   set bell-style none
   ```

2. Create the file `/etc/modprobe.d/nobeep.conf`, with a single line:
   ```
   blacklist pcspkr
   ```
   to disable annoying beeps when screen locks.

3. In clock settings, change time display format to 12Hr, and add date and
   second display.

4. Right click task bar, in Panel Settings, change height to 24, and all
   icon scales optimally with panel size.

5. Delete all task bar applets except menu, system tray, and time.  Then
   add panel launcher and window list applet.  Right click task bar and
   enable "Panel edit mode" to drag those applets to the right place.
   Finally, add chormium to panel launcher (You can drag and drop from
   menu).

### Pycharm/CLion

1. In Editor/General, set "Strip trailing spaces on Save" to "All", and
   uncheck "Always keep trailing spaces on caret line".

2. In Keymap, set to "Eclipse"

3. In Editor/Code Style, set hard wrap at 100 columns.

4. add the following line to the file `/etc/sysctl.d/90-override.conf`,
   create it if it doesn't exist:

   ```
   fs.inotify.max_user_watches = 524288
   ```
   then run the command:
   ```
   sudo sysctl -p --system
   ```

## Optional Programs

### Emacs

Usage Notes:

1. M-. jumps to code definition, M-, goes back to previous location.  M-t
   shows all occurs of the current word.

2. In new project directory, create a file named `clang-format` with the
   content:
   ```
   BaseOnStyle: LLVM
   IndentWidth: 4
   ```

   for `clang-format` to format code properly.

3. Use `M-q` to auto-fill the current paragraph to line wrapping.

4. Use `C-h` to quit minibuffer (useful when you have multiple minibuffers
   open due to repeated search).

5. Use `C-x b` to switch between buffers.  You will get a list of buffers to
   select.

6. Use `C-c g` to grep within the git repository.

7. When searching inside Ivy across multiple files, use `C-c C-o` to enter
   ivy-occur mode, which will display results in a buffer.  Then, you can press
   `w` to enable wgrep edit mode.  After editing and saving, the changes will
   propagate to all buffers, and you can use `C-x s !` to save all buffers at
   once.

#### Emacs-magit

1. Use `M-x magit` to start git commit in emacs.

2. Use arrow keys to move around, use TAB to expand and see diff file, use `s`
   to stage unstaged files.  Use `g` to refresh files.

3. Use `c` to pop up commit options.  You can toggle switches and specify
   options, after you're done, you can then use `C-c C-c` to set the current
   options as default.  Press `c` again to commit.

## Miscellaneous Notes

### Open magnet links with qbittorrent

Edit `~/.config/mimeapps.list`, in the "Default Applications" section, add
the line:
```
x-scheme-handler/magnet=qbittorrent.desktop
```

### USB stick

Sometimes a badly configured USB stick won't get automounted.  This is because
by default, if `udev` doesn't recognize a device, it will try to mount it using
MTP (the smart phoen file transfer protocol).  If this happens, you need to add
an exception rule to `udev` to treat it as USB drive by doing the following:

1. Plug in USB stick, then in the terminal, type `dmesg`.  Look for latest
   message regarding a new USB divice, and find values of `idVendor` and
   `idProduct`.  For me, `idVendor = abcd`, and `idProduct = 1234`.

2. Add a new file `/etc/udev/rules.d/90-myusb.rules` (with root permission),
   with the following line:

   ```
   SUBSYSTEMS=="usb", ENV{MODALIAS}=="usb:abcd:1234", ENV{MODALIAS}="usb-storage"
   ```

   where you substitute the correct values for `idVendor` and `idProduct`.

3. Reboot (there should be a non-reboot way, but I didn't find out/verify).

### Inkscape

Latex rendering in Inkscape got broken by Ghostscript 9.22 when they remove the
DELAYBIND option, which breaks the pstoedit program.  The current experimental
workaround is to use the textext extension, which has an experimental feature
to use pdf2svg instead of pstoedit.

To get this to work, follow installation instructions above to install all the
required packages. Then, download the file textext.py from the following URL:

https://bitbucket.org/pitgarbe/textext/issues/57/pdf2svg-migration

place this textext.py in the folder /usr/share/inkscape/extensions.  Make sure
to make a backup of the original.

### Reinstall Emacs packages

On 2017/08/06, Arch linux upgrade internal Python version from 3.6 to 3.7, and
broke some emacs packages (some assume fixed version number).  To re-install
all emacs packages, do the following:

1. stop emacs daemon by running:

   ```
   systemctl --user stop emacsd.service
   ```

1. remove ~/.emacs.d and ~/.emacs.elc (just rename it in case you need them
   later.)

2. start emacs, wait for packages to download.  You'll see some errors, but you
   can ignore them.

3. run `M-x jedi:install-server`.  Restart emacs, double check that there are
   no errors.

### Adding network printer using CUPS

1. Open web browser, go to `localhost:631`.

2. Go to administrative tab, click "Add Printer".  Use "root" as username and
   type in root password.

3. Follow through the instructions.  Print a test page from the web interface
   at the end to make sure it works.

### External Monitor

1. After plugging in HDMI, it seems like I need to open the cinnamon display
   dialog before the screen shows up.

2. To add task bar to external monitor, right click on current task bar,
   select "Modify Panel", then "Add panel", then click on the highlighted
   location on the external monitor.

   You can copy task bar configuration over by right clicking the original
   task bar.
