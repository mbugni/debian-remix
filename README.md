# Debian Remix

## Purpose
This project builds a TDE ([Trinity Desktop Environment][02]) Linux and aims to be a complete system for personal computing with localization support. It is based on [Debian 11][08]. You can [download a live image][01] and try the software, and then install it in your PC if you want.
You can also customize the image starting from available scripts.

Main goals of this system are:
* lightweight enviroment suitable for old PC (legacy BIOS and/or 32-bit)
* adding common extra-repos
* supporting external devices (like printers and scanners)

## How to build the live image (on Debian 12)
[See a detailed description][03] about how to build a live media using kiwi-ng.

### Prepare the working directories
Clone the project into your `<source-path>` to get sources:

```shell
$ git clone https://github.com/mbugni/debian-remix.git /<source-path>
```

Choose or create a `<target-path>` folder where to put results.

### Prepare the build environment
Install Podman:

```shell
$ sudo apt --assume-yes install podman containers-storage fuse-overlayfs
```

Install [podman-compose](https://github.com/containers/podman-compose/tree/main?tab=readme-ov-file#installation)
1.3.0 or later.

### Build the image for amd64 platform
Choose a variant (eg: workstation with localization support) that corresponds to a profile (eg: `Workstation-l10n`).

Available profiles/variants are:
* `Console` (command line only, mainly for testing)
* `Desktop` (minimal TDE environment with basic tools)
* `Workstation` (TDE environment with more features like printing and scanning support)

For each variant you can append `-l10n` to get italian localization (eg: `Desktop-l10n`).

Build the .iso image by running the `podman-compose` command from the project root directory:

```shell
$ sudo podman-compose run --rm --env KIWI_PROFILE=<variant> \
--env KIWI_TARGET_DIR=<target-path> system-build-amd64
```

The build can take a while (30 minutes or more), it depends on your machine performances.
Environment arguments are optional, available variables are:

| Variable        | Description             | Default value      |
|:---------------:|:-----------------------:|:------------------:|
| KIWI_PROFILE    | Image variant           | `Workstation-l10n` |
| KIWI_TARGET_DIR | Build target directory  | `.`                |

### Build the image for i386 platform

The command is very similar to the `amd64` platform one:

```shell
$ sudo podman-compose run --rm --env KIWI_PROFILE=<variant> \
--env KIWI_TARGET_DIR=<target-path> system-build-i386
```

The standard resulting image is not bootable, so the build process fix it and produce a new
`Debian-Remix.i386-bios.iso` image.

See also [legacy systems tips](./legacy-systems-tips.md).

## Transferring the image to a bootable media
You can use a tool like [Ventoy][07] to build multiboot USB devices, or simply transfer the image to a single
USB stick using the `dd` command:

```shell
$ sudo dd if=/<target-path>/Debian-Remix.i686-<version>.iso of=/dev/<stick-device>
```

## ![Bandiera italiana][04] Per gli utenti italiani
Questo progetto costruisce un sistema Linux con TDE ([Trinity Desktop Environment][02]) per computer ad uso personale con il supporto in italiano. È basato su [Debian 11][08]. Nell'[immagine .iso][01] che si ottiene sono già installati i pacchetti e le configurazioni per il funzionamento in italiano del sistema (come l'ambiente grafico, i repo extra etc).

Il sistema ha come obiettivi principali:
* un ambiente grafico leggero adatto anche a vecchi PC (BIOS legacy e/o a 32-bit)
* aggiunta dei repository comuni
* supporto per dispositivi esterni (come stampanti e scanner)

## Change Log
All notable changes to this project will be documented in the [`CHANGELOG.md`](CHANGELOG.md) file.

The format is based on [Keep a Changelog][05].

[01]: https://github.com/mbugni/debian-remix/releases
[02]: https://www.trinitydesktop.org/
[03]: https://osinside.github.io/kiwi
[04]: http://flagpedia.net/data/flags/mini/it.png
[05]: https://keepachangelog.com/
[06]: https://docs.podman.io/
[07]: https://www.ventoy.net/
[08]: https://www.debian.org/releases/bullseye
