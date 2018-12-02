# Arch Linux install notes
This document described the steps I took to setup my Arch Linux system.

## Why Arch (instead of Antergos or Manjaro)

1. I read that Manjaro have some hacky insecure stuffs.

2. For this install I need LVM + LUKS encryption, and Antergos installer is just not working for me.

## Hardware Notes

1. This is tested on LG Gram 2018 15 inch model.

2. LG gives you an ethernet dongle, so I don't have to worry about wifi.

## Distro Installation

1. Download Arch ISO, burn to USB using the command:
   ```
   dd bs=4M if=<ISO file> of=/dev/sdX status=progress oflag=sync
   ```

   You can find the USB disk name with `sudo fdisk -l`.

   Then, plug in USB, boot computer and enter bios (by pressing F2 for this laptop).  Disable secure
   EFI boot in bios, make USB the top boot priority, then boot into USB.

2. Do disk partition with the command:
   ```
   gdisk /dev/sdX
   ```

   First command, use `o` to erase everything and get new GPT table.  Then, use `n` to add the first
   partition, first sector is default, second sector is `+100M`, to create a 100MB partition.  The
   type code is `EF00` for EFI System.  This will be the EFI boot partition.

   For the second partition, make it 250 MB boot partition, by having first sector be default and
   sector sector be `+250M`.  Type code is `8300`.  For the final partition, both sectors are
   default (to use up rest of the space), and type code is also `8300`.

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

   where `CRYPT_NAME` is a name of your choice (I use CRYPT_EC).  Enter your passphrase when
   prompted.

5. Create encrypted partitions with:
   ```
   pvcreate /dev/mapper/<CRYPT_NAME>
   vgcreate <VOL_GRP_NAME> /dev/mapper/<CRYPT_NAME>
   lvcreate --size 512M <VOL_GRP_NAME> --name swap
   lvcreate --size 40G <VOL_GRP_NAME> --name root
   lvcreate -l +100%FREE <VOL_GRP_NAME> --name home
   ```

   again `VOL_GRP_NAME` is a name of your choice (I use ARCH_EC).  This creates separate root and
   home partitions.

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

    then edit fstab (using `emacs`), change all `relatime` to `noatime` (This is needed for SSDs).

    Also add the following entry to fstab:
    ```
    /dev/mapper/<VOL_GRP_NAME>-home /home ext4 defaults 0 1
    ```
    so that the home partition is correctly mapped.

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

16. etc file `/etc/mkinitcpio.conf`.  Add 'ext4' to `MODULES`.  Add 'encrypt' and 'lvm2' to `HOOKS`,
    in that order, before 'filesystems'.  Afterwards, regenerate initrd image with:

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
    GRUB_CMDLINE_LINUX="cryptdevice=/dev/sdX3:luks:allow-discards resume=/dev/mapper/<VOL_GRP_NAME>-swap"
    ```

    (remove the resume line if you disable swap, see later) note that "allow-discards" option
    enable SSD triming (which improves performance), but comes with some security risk
    because of information leakage.

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

3. Use `ip link` to find ethernet name, then use `systemctl start dhcpcd@<ETHERNET_NAME>.servce` to
   start internet.

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

6. Uncomment the "Color" option in `/etc/pacman.conf`.

7. Install `thermald`, a daemon used to monitor CPU and prevent overheating.  I was experiencing
   freezes when CPU run on full power and overheats.

   before installing `thermald`, install `lm_sensors` and run the script `sensors-detect` on
   command line.  Then enable/start `lm_sensors.service`.

   ```
   pacman -S thermald
   ```

8. To generate configuration file for thermald, clone the auto config generation repo with:
   ```
   git clone git@github.com:intel/dptfxtract.git
   ```
   then run the script with root permission to generate configuration file in `/var/run/thermald`,
   and copy it to `/etc/thermald/thermald-conf.xml`.  When done, enable `thermald` with:
   ```
   systemctl enable thermald.service
   systemctl start thermald.service
   ```

9. Also install `tlp`.  Just follow instructions on Arch wiki.

### Trying to fix freezing

I keep on having problems with freezes when doing large workload, some research suggests having
an encrypted LVM swap partition could cause this.  To disable:

1. As root, comment out the swap partition entry in `/etc/fstab`.

2. As root, run `swapoff -a`.

3. Run `swapon -v`, make sure there's no output.  Run `free -m`, make sure nothing in swap.

4. Restart, if you want peace of mind.

5. That didn't solve it.  Trying intel_idle.max_cstate = 1 in kernel parameter.

6. Didn't work either, try removing /etc/modprobe.d/i915.conf, which enable guc firmware.

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

2. Exit root, sign in as user, and create a folder `pkgs_arch` in home directory for AUR packages.
   Go in that directory.

3. Setup `yay`, an AUR helper, from AUR using makepkg:
   ```
   git clone https://aur.archlinux.org/yay.git
   cd yay
   makepkg -si
   ```

   answer yes when asked to install.

4. the following with `yay -S`:
   * lightdm-slick-greeter
   * lightdm-settings

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

   The `logind-check-graphical` option is used to tell lightDM to wait until the graphics driver
   are loaded before starting, thus preventing black screen.

6. Create a new file `/etc/NetworkManager/conf.d/dhcp-client.conf`, with the    content:
   ```
   [main]
   dhcp=dhclient
   ```

   NetworkManager is not built with dhcpd support (the default Arch Linux DHCP program).  This
   allows NetworkManager to connect to public wifi.

7. Run the following to start the dekstop environment:
   ```
   systemctl enable lightdm.service
   systemctl start lightdm.service
   ```
8. Once GUI started, enable NetworkManager:
   ```
   systemctl enable NetworkManager.service
   systemctl start NetworkManager.service
   ```

9. Enable `fstrim.timer` to trim SSDs periodically:
   ```
   systemctl enable fstrim.timer
   systemctl start fstrim.timer
   ```

## Intel UHD Graphics Driver Setup

1. enable early kernel mode setting by editing the following line in
   `/etc/mkinitcpio.conf`:
   ```
   MODULES=(ext4 i915)
   ```
   Then, create the file `/etc/modprobe.d/i915.conf`, with the line:
   ```
   options i915 enable_guc=3
   ```
   Finally, update boot image with the command:
   ```
   mkinitcpio -p linux
   ```

## Initial Setups

1. In mouse and trackpad settings, enable multi-click for right click.

2. In terminal perferences, change color scheme to tango dark.3

3. In file explorer, set all new folders to use list view in preferences, and show hidden files (by
   using right-click context menu).

4. Copy `.ssh/config` and private/public keys over.  Create a softlink for erichang.key.

5. Next, we need to install some packages needed by emacs.  Install `ycmd-git` and `universal-ctags-git` from AUR.

6. Install `ripgrep` with `pacman`.

7. Follow the instructions at <https://github.com/pkerichang/linux_files.git>.

8. close terminal, and restart.

9. Start emacs, wait for it to download and install packages.

10. setup emacs server-client systemd service by running:
   ```
   systemctl --user enable emacsd.service
   systemctl --user start emacsd.service
   ```

11. after starting emacs, run `M-x jedi:install-server` to install jedi server for Python editing.


## Finishing Setups

1. Use `pacman` to install the following packages:

   * namcap (Needed to verify custom built packages)
   * tigervnc
   * inkscape
   * vlc
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

4. Use `yay` to install the following C++ related packages:

   * boost
   * cmake
   * yaml-cpp (for reading/writing yaml files)
   * spdlog-git (from AUR, for logging in C++)

5. Use `yay` to install the following AUR packages:

   * textext (for inkscape latex rendering)
   * ttf-tw (for Taiwan standard Chinese fonts)
   * noto-fonts-tc
   * mint-x-icons
   * mint-y-icons
   * mint-themes (for better Cinnamon themes)
   * dropbox
   * nemo-dropbox (for nemo integration)
   * xviewer (for image viewing)
   * qdirstat (for disk usage viewing)

6. Start chromium, download Pycharm, then install.

7. To setup chinese input, at the command line, run:
   ```
   ibus-setup
   ```

   then make a soft link from `.xprofile_antergos_cinnamon` to `.xprofile`.  Since LightDM sources
   `.xprofile`, this will make ibus run at startup.

8. Switch themes to the following settings (in System Settings->Themes) to have things more readable:

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

3. add chromium shortcut to task bar.  You should be able to just drag and drop from menu.

### Pycharm/CLion

1. In Editor/General, set "Strip trailing spaces on Save" to "All", and uncheck "Always keep
   trailing spaces on caret line".

2. In Keymap, set to "Eclipse"

3. In Editor/Code Style, set hard wrap at 100 columns.

4. add the following line to the file `/etc/sysctl.d/90-override.conf`, create it if it doesn't
   exist:

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

1. M-. jumps to code definition, M-, goes back to previous location.  M-t shows all occurs of the
   current word.

2. In new project directory, create a file named `clang-format` with the content:
   ```
   BaseOnStyle: LLVM
   IndentWidth: 4
   ```

   for `clang-format` to format code properly.

3. Use `M-q` to auto-fill the current paragraph to line wrapping.

4. Use `C-h` to quit minibuffer (useful when you have multiple minibuffers open due to repeated
   search).

5. Use `C-x b` to switch between buffers.  You will get a list of buffers to select.

6. Use `C-c g` to grep within the git repository.

7. When searching inside Ivy across multiple files, use `C-c C-o` to enter ivy-occur mode, which
   will display results in a buffer.  Then, you can press `w` to enable wgrep edit mode.  After
   editing and saving, the changes will propagate to all buffers, and you can use `C-x s !` to save
   all buffers at once.

#### Emacs-magit

1. Use `M-x magit` to start git commit in emacs.

2. Use arrow keys to move around, use TAB to expand and see diff file, use `s` to stage unstaged
   files.  Use `g` to refresh files.

3. Use `c` to pop up commit options.  You can toggle switches and specify options, after you're
   done, you can then use `C-c C-c` to set the current options as default.  Press `c` again to
   commit.


### Mudlet

(Note: My pull request has been incorporated, so no need to build from source anymore.  This is left
here as reference) Because I need to build from source (since I added traditional chinese encoding),
I need to figure out the dependencies manually.  This is the steps I took to compile:

1. install mudlet from AUR using `yay` to get all the dependencies.  For reference, the following
   are needed from `pacman`:

   * lua51-filesystem
   * qt5-tools
   * qt5-multimedia
   * qt5-gamepad
   * libzip
   * yajl
   * pugixml

2. clone a separate mudlet repo, make a build folder, then cd and build using cmake.
   Finally, make a softlink from
   `${MUDLET_DIR}/build/src/mudlet` to `${HOME}/bin`

5. copy the directory `${MUDLET_DIR}/src/mudlet-lua/lua` to `/usr/local/share/mudlet/lua`

## Miscellaneous Notes

### Open magnet links with qbittorrent

Edit `~/.config/mimeapps.list`, in the "Default Applications" section, add the line:
```
x-scheme-handler/magnet=qbittorrent.desktop
```

### USB stick

Sometimes a badly configured USB stick won't get automounted.  This is because by default, if `udev`
doesn't recognize a device, it will try to mount it using MTP (the smart phoen file transfer
protocol).  If this happens, you need to add an exception rule to `udev` to treat it as USB drive by
doing the following:

1. Plug in USB stick, then in the terminal, type `dmesg`.  Look for latest message regarding a new
   USB divice, and find values of `idVendor` and `idProduct`.  For me, `idVendor = abcd`, and
   `idProduct = 1234`.

2. Add a new file `/etc/udev/rules.d/90-myusb.rules` (with root permission), with the following
   line:

   ```
   SUBSYSTEMS=="usb", ENV{MODALIAS}=="usb:abcd:1234", ENV{MODALIAS}="usb-storage"
   ```

   where you substitute the correct values for `idVendor` and `idProduct`.

3. Reboot (there should be a non-reboot way, but I didn't find out/verify).

### Inkscape

Latex rendering in Inkscape got broken by Ghostscript 9.22 when they remove the DELAYBIND option,
which breaks the pstoedit program.  The current experimental workaround is to use the textext
extension, which has an experimental feature to use pdf2svg instead of pstoedit.

To get this to work, follow installation instructions above to install all the required packages.
Then, download the file textext.py from the following URL:

https://bitbucket.org/pitgarbe/textext/issues/57/pdf2svg-migration

place this textext.py in the folder /usr/share/inkscape/extensions.  Make sure to make a backup of
the original.

### Reinstall Emacs packages

On 2017/08/06, Arch linux upgrade internal Python version from 3.6 to 3.7, and broke some emacs
packages (some assume fixed version number).  To re-install all emacs packages, do the following:

1. stop emacs daemon by running:

   ```
   systemctl --user stop emacsd.service
   ```

1. remove ~/.emacs.d and ~/.emacs.elc (just rename it in case you need them later.)

2. start emacs, wait for packages to download.  You'll see some errors, but you can ignore them.

3. run `M-x jedi:install-server`.  Restart emacs, double check that there are no errors.

### Adding network printer using CUPS

1. Open web browser, go to `localhost:631`.

2. Go to administrative tab, click "Add Printer".  Use "root" as username and type in root password.

3. Follow through the instructions.  Print a test page from the web interface at the end to make
   sure it works.
