## 13.2.0 - 2025-12-07
### Added
- Utils for KDE info center
- Intel graphics and SOF firmware
- dosfstools and zstd tools
### Changed
- Move to Debian 13 and KDE Plasma 6
- systemd-resolved as regular package
### Removed
- Legacy podman-compose instructions
- xserver-xorg-input-synaptics package

## 12.12.1 - 2025-11-30
### Added
- pulseaudio-utils package
- systemd-journal group to default user
- keymaps support for it layout
### Removed
- Redundant VPN support
- xdg-desktop-portal-gnome package

## 12.12.0 - 2025-09-21
### Changed
- Move clean up scripts to Calamares post-install
- Set verbose log for Calamares

## 12.11.0 - 2025-06-02
### Added
- Image build using Podman compose
- Power management and sensors support
### Changed
- Switch the boot spinner theme to BGRT (Boot Graphics Resource Table)
### Removed
- Mail Transfer Agent (MTA)

## 12.10.0 - 2025-03-24
### Added
- Zip tools
### Changed
- Reset the KDE preferred browser to fallback the default

## 12.9.0 - 2025-01-14
### Added
- Extended security limits for audio group
- Polkit rule for managing PackageKit with sudo group
### Removed
- Redundant localization configs
### Changed
- One session setup for both console and graphical mode
- Automatic system timezone during install

## 12.8.0 - 2024-12-28
### Changed
- Improve Calamares settings
- Better scripts organization

## 12.7.1 - 2024-10-28
### Added
- ZRam support using systemd-zram-generator
### Changed
- Get rid of debootstrap (from kiwi-ng 10.0.28)
- systemd-timesyncd instead of chrony

## 12.7.0 - 2024-09-29
### Added
- Custom user Flatpak setup
- Custom machine setup
- Broadcom WiFi support
### Changed
- Improve scan and print support
- Better live system cleanup
- Minimize dependencies

## 12.6.1 - 2024-08-17
### Added
- Workstation edition with scan and print support
- Networking: systemd-resolved and firewalld
### Changed
- Ensure Flathub is the primary repo
### Fixed
- Terminal window title for root user

## 12.6.0 - 2024-07-31
### Initial release
