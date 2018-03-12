# Mac Install instructions
This document describes the steps I took to setup my Mac.

## Install/Setup

1. First install homebrew, then run `brew update` followed by `brew upgrade`.  When done, install the following using `brew install`:
   
   1. bash
      
      after install, add `/usr/local/bin/bash` to the file `/etc/shells`, and use `chsh` to change default shell to homebrew bash.
   
   2. git
   3. tiger-vnc
   4. pstoedit (for Inkscape LaTeX extension).

2. Next, install the follwing using `brew cask install`:
   
   1. xquartz
   2. tigervnc-viewer
   3. emacs
   4. inkscape
   5. x2goclient
   6. mactex 

3. Now, go online, and download the following programs and install them:
   
   1. Google Chrome.
   2. Dejavu fonts
      
      after downloading and unzipping, open with fontbook, then click on the install button at the bottom.

   3. Dropbox
   4. Tunnelblick
      
      Copy configuration files and drag-and-drop the .ovpn file to the Configurations tab.

   5. Office 2016
      
      go to www.office.com, sign in, then download installer.

   6. Anaconda Python
   7. Pycharm
   8. Karabiner-Elements

      map right command to right control instead (so it works as i3 modifier).

4. Then, install the following apps from the app store:
   
   1. Amphetamine

## Customizations

1. Command-line environment

   1. copy SSH config and private/public keys over to .ssh folder.
   2. Create a softlink if you do not have erichang.key.
   3. Follow the instructions on <https://github.com/pkerichang/linux_files.git>.

2. Mouse

   uncheck "natural direction" for mouse scrolling.

3. Keyboard

   disable keyboard binding Ctrl+Left and Ctrl+Right for mission control, as this interferes with i3 key bindings.

4. Display

   change resolution to scaled, and the finest resolution.

5. Terminal

   1. Open preferences.
   2. In General tab, change the profile on startup and when new windows/tabs open to homebrew.
   3. In Profiles tab, set Homebrew profile to default (there's a default button at the bottom that you have to click).
   4. Set the homebrew text RGB code to (200, 200, 200).  
   5. In the Shell section of Homebrew profile, change it so the terminal closes if the shell exists cleanly.

6. Finder

   In preferences, check show all file extensions.  in View->Show view options, set defaults to be list view, sorted by date modified.

7. Inkscape

   1. In preferences, set stroke style to always be the last one ones.
   2. Note that sometimes Document Properties will not show up in multi-monitor setup.  You may have to unplug external monitor
      to see the dialog window.
