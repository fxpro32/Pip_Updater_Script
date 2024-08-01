# Pip_Updater_Script
A very simple Automated Pip Updater Script to bulk update all pip packages

Pip Updater Script - Readme - A simple automated package checker and updater for Pip - By FXPRO

This Pip Updater Script will automatically update all packages on Pip.  I made this script because there is no one single command that updates all packages and due to the constant package updates that were available on Pip, but could be updated even though certain dependencies were not met, thus providing a potentially unstable environment.

The Pip Updater script does the following tasks:
1. Checks which Operating System you are running.  It checks Linux (Fedora/Debian) type OS, Windows OS, and macOS.
2. Once the check is completed, it will output the name of the OS and then check to see if the 'JQ' Package is installed.
3. If its not installed, based on the detected OS, it will run the appropriate install command to install the JQ package which is required for this script to function.
4. If JQ is installed, then it will acknowledge it and output the result
5. Next it will start the pip update procedure routine, by first checking for, and listing all the outdated packages that are available.
6. If there are packages that are outdated, but there are conflicts or dependency issues, the outdated package will not be listed.
7. The script then updates each outdated package (that have no dependency/conflict issues), separately.
8. Then it will output a summary of work/updates completed.
9. The script ends automatically back to terminal prompt.

I hope this helps anyone who has been battling with pip updates and dependency problems and to keep a properly controlled Pip package environment in your OS.

# How to Run the Script?

On linux:
```# bash update_pip_packages.sh```

On Windows:
```# bash update_pip_packages.sh```

On macOS:
```chmod +x update_pip_packages.sh```
```./update_pip_packages.sh```
