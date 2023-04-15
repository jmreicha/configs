configs
=======

A repository for all my configs and dotfiles.  I also keep track of my preferred
command line productivity tools here.

The easiest way to use this repo is to clone the rep and run the `install.sh`
script. Check the following examples for various installation options.

My current preferred system is `Nix` on Mac OS. To install and configure:

```bash
cd configs
./install.sh --install
```

There are other options, including an option to configure a system only and skip
installation.

```bash
cd configs
./install.sh --configure
```

Another option is to run the full installation and configuration for a given
platform.

```bash
cd configs
./install.sh --all
```
