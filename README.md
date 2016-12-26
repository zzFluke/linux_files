# linux_files
Repository of my linux configuration files.

To set up on a new computer:

1. go to home directory, and type:

   ```shell
   > git clone --bare git@github.com:pkerichang/linux_files.git ${HOME}/.mycfg
   > alias mycfg='git --git-dir=${HOME}/.mycfg --work-tree=${HOME}'
   ```

2. make sure all previous settings are backed up, then type:

   ```shell
   > mycfg checkout -f
   ```

3. type:

   ```shell
   > mycfg config status.showUntrackedFiles no
   ```
   
   to hide untracked files.

4. type:

   ```shell
   > mycfg push -u origin master
   ```

   to make the current branch track master at origin.

5. edit .mycfg/config file, and make sure the remote tag looks like the following:

   ```
   [remote "origin"]
        url = git@github.com:pkerichang/linux_files.git
        fetch = +refs/heads/*:refs/remotes/origin/*
   ```

   (for some reasons the fetch line may not be there).  After editing, run:

   ```shell
   > mycfg fetch
   ```

   to fetch remote branch information.

To setup a new branch, type:

   ```shell
   > mycfg checkout -b [name_of_your_new_branch]
   > mycfg push origin [name_of_your_new_branch]
   ```

To update master branch with updated file(s) in other branch:

   ```shell
   > mycfg checkout master
   > mycfg checkout [branch_name] -- [file_name] ...
   ```

To merge master into current branch:

   ```shell
   > git checkout [current_branch_name]
   > git merge master
   ```
