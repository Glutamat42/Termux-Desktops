# Memory consumption of Debian DEs

Testscenario: Fresh Debian Trixie installation in Virtualbox. Installed the DE via tasksel during setup. Logged in to DE, started terminal and ran `df -h && free -h`.

| Environment              | Packages (Total Install)  | df Used (GiB)  | Memory Usage (GiB) |
|--------------------------|---------------------------|----------------|------------------|
| reference (no DE)        | 135                       | 1.10           | 0.31             |
| xfce                     | 1220                      | 3.80           | 0.63             |
| cinnamon                 | 1625                      | 4.80           | 1.20             |
| kde                      | 2001                      | 6.50           | 1.70             |
| lxde                     | 1207                      | 3.70           | 0.55             |
| gnome-flashback          | 1351                      | 4.20           | 1.20             |
| lxqt                     | 1264                      | 4.30           | 0.60             |
| openbox + minimal tools  | ~350                      | 1.90           | 0.42             |

# Setting up openbox
I decided to use openbox. During the setup script choose to install openbox. This will install a minimal version of openbox. 

After the setup script finished, continue with the setup script in scripts/openbox. For now the you have to clone the repo into the chroot and then run the script as your user inside the chhroot.

To run applications inside openbox press Alt + Space. This will open an application launcher. type the application name (e.g. firefox or l3afpad) and press enter to start it.