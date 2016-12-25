# linux_files
Repository of my linux configuration files.

To set up on a new computer:

1. go to home directory, and type:

   ```shell
   git clone --bare git@github.com:pkerichang/linux_files.git ${HOME}/.mycfg
   ```

   then type:

   ```shell
   alias mycfg='git --git-dir=${HOME}/.mycfg --work-tree=${HOME}'
   ```

2. make sure all previous settings are backed up, then type:

   ```shell
   mycfg checkout -f
   ```

3. type:

   ```shell
   mycfg config status.showUntrackedFiles no
   ```

4. type:

   ```shell
   mycfg push -u origin master
   ```

   to make the current branch track master at origin.
