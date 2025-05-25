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

