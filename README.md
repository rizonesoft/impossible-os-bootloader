# Impossible OS — Bootloader

> This is the public bootloader component of [Impossible OS](https://github.com/rizonesoft/impossible-os).
> The bootloader source is kept public to support Secure Boot signing, community audit, and the Microsoft shim-review process.

## What is this?

This repository contains the UEFI bootloader for Impossible OS — a custom x86-64 operating system built from scratch.

The bootloader (`src/boot/`) is responsible for:
- Initializing the UEFI environment (GOP framebuffer, ACPI, memory map)
- Loading the kernel ELF binary from the EFI system partition
- Setting up identity-mapped page tables (4 GiB, 2 MiB pages)
- Handing control to the kernel with a Multiboot2-compatible boot info struct

## Secure Boot

The bootloader is intended to be signed with a Machine Owner Key (MOK) and eventually submitted to the [rhboot/shim-review](https://github.com/rhboot/shim-review) process for Microsoft signing.

See [TODO-010-Bootloader.md](https://github.com/rizonesoft/impossible-os/blob/main/todo/TODO-010-Bootloader.md) in the main repo for the full Secure Boot roadmap.

## Sync Policy

This repository is automatically synced from `src/boot/` in the private `rizonesoft/impossible-os` repository via GitHub Actions on every push to `main`.

## License

MIT — see [LICENSE](LICENSE)
