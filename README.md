configs
=======

A repository of my custom configs

.vimrc
---

Uses the Vundle package manager to download and install a few useful helpers:

 * Go syntax highlighting and workflow
 * Terraform syntax highlighting
 * Huge number of custom color schems
 
To install the these plugins on a freshly set up machine you can run `:Bundleinstall` from within a Vim buffer to go get additional packages.

Outside of the plugins, this .rc does a number of things.  You can look at the `.vimrc` file for more specifics and examples.

Profile.ps1
---

Customizes the following:

* Creates a custom color scheme for the PowerShell prompt
* Adds in additional Vim functionality

To use, copy the Profile.ps1 file to the following location (Win 7):

<code>C:\Users\Username\My Documents\WindowsPowerShell</code>

.tmux.conf
---

The primary purpose of this config is to bind the keys in a similar fashion to the way they are bound in screen.

This file should be placed into the <code>~/.tmux.conf</code> file if it is not already present.  A tmux reload may be required.

Reference Table:

* <code>logout</code> close current split or window
* <code>^a d</code> detach from session
* <code>^a -</code> create horizontal split
* <code>^a |</code> create vertical split
* <code>^a up</code> move up between splits
* <code>^a down</code> move down between splits
* <code>^a ,</code> rename current window
* <code>^a n</code> move forward one window
* <code<^a p</code> move backward one window
* <code>^a c</code> create new window
* <code>^a [0-9]</code> jump to numbered window
