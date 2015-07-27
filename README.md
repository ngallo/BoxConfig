# Setup / Config script for configuring OSX, Linux and Windows #

## Machine Setup ##

The machine setup is used to get an empty OSX installation up to where it
needs to be. It depends heavily on brew.sh and brew cask to install
everything but it installs these first so it should automate the process of
building a new osx install.

The machine Setup files are in the Setup folder. There is one generic script,
mbpsetup.sh that is used to bootstrap brew and cask and then do the
installation.

This means I can be up and running with a new Mac by typing:

    git clone 'https://github.com/byrney/Config.git'
    cd Config/Setup && bash kat.bash

There are several 'category scripts' that can be used to set up base
system, dev tools, image manipulation and so on.

Then there are scripts for controlling which machines get what. For example
kat.bash and keira.bash set up two of my machines. These are just a list of
categories to install. kat.bash might look like this

    #!/bin/bash -eu
    bash mbpsetup.sh base.bash utils.bash dev.bash

### How it works ###

mbpsetup installs xcode commandline tools, homebrew and homebrew cask and then
sources each of the files on the commandline.

It provides functions to install brew packages, casks or gems if they
have not been installed before. If they already exist they don't get run
again. This is crucial to being able to maintain the script and add
new packages over time without reinstalling existing packages  (or failing
part way because they are already there).

Each of the category scripts simply calls the functions in mbpsetup. So a
script to install image tools would look like this:

    inst_brew imagemagick
    inst_brew exiftool
    inst_cask picasa




## User Configuration ##

These are my config files so I can clone them onto a new machine easily.

There is an install script (install.sh) and a configuration file (install.cfg)
which control how the various dotfiles will get copied or linked into the home
directory.

It only needs bash and grep to work. I'm using it on OSX (Darwin), Debian and
Redhat (Linux) and Msys Windows (MINGW32_NT-6.2)

To use clone the repo and do

     bash install.sh -h

for the help

      Usage:     ./install.sh -nv -s source_dir -d dest_dir -m hostname -o os configfile

           -n     dry run, don't make any changes
           -s     source dirrectory. Defaults to the location of install.sh
           -d     destination directory. Defaults to $HOME
           -c     copy files instead of linking
           -v     verbose output
           -m     override machine hostname (defaults to output of hostname)
           -o     override operating system (defaults to output of uname)
           -h     display this message

       configfile is a colon seperated list of destination:source:host_pattern:os_pattern

         .bashrc:my_bashrc.bash:satur.*:Linux|Darwin

	   will link/copy source_dir/my_bashrc.bash to dest_dir/.bashrc if the
	   hostname begins with satur (saturday, saturn etc..) and uname is either
	   Darwin or Linux.  Patterns are passed to grep -E  an empty pattern will
	   match any host/platform

Edit the config file (install.cfg) or create a new one. Then see what will
happen

     bash install.sh -nv install.cfg

remove the 'n' to really run it.  Any files that get clobbered will be moved
to $HOME/backups-yyyymmdd. In the default mode (link) you should be able to
run it again and nothing will be touched.  In copy mode, the files will keep
geting backed up

