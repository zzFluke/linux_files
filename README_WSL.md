additional information on WSL setup:

packages installed:

emacs-24
clang (for compiling fsnotifier)
libqt5gui5 (for QT support)
libsecret-1-0 gnome-keyring (for pycharm native keychain requirement)


DBUS setup:

1. run:

sudo dbus-uuidgen --ensure

this creates the /var/lib/dbus/machine-id file needed by DBUS.

2. run

sudo chmod u+w /etc/machine-id

to make /etc/machine-id writable.

3. run:

sudo cp /var/lib/dbus/machine-id /etc/machine-id

to copy generated machine-id over.

NOTE: dbus can now listen on unix port now.  No need to change to tcp.


Emacs:

after DBUS setup, I was able to install emacs24 from default Ubuntu repo without errors.


PyQt5:
run:

sudo apt-get install libqt5gui5

to install libraries needed by Qt5.

Pycharm:

fsnotifier:

1. modify fsnotifier program to work with WSL.  See repo for information.
2. need to symlink /proc/self/mounts to /etc/mtab for stuff to work.

