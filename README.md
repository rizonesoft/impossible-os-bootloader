# Impossible OS — Bootloader

> The public UEFI bootloader component of [Impossible OS](https://github.com/rizonesoft/impossible-os) — a custom x86-64 operating system built from scratch.

This repository is public to support Secure Boot signing, community audit, and the Microsoft shim-review process.

---

## What is this?

This repository contains the UEFI bootloader for Impossible OS.

The bootloader (`src/boot/`) is responsible for:

- Initialising the UEFI environment (GOP framebuffer, ACPI, memory map)
- Loading the kernel ELF binary from the EFI system partition
- Setting up identity-mapped page tables (4 GiB, 2 MiB pages)
- Handing control to the kernel with a Multiboot2-compatible boot info struct

---

## Secure Boot

### Current Status

The bootloader is signed with a **Machine Owner Key (MOK)** while we work through the Microsoft shim-review process. Users who want Secure Boot enabled during this period can enroll the MOK manually at first boot (one-time prompt in your UEFI firmware).

> **We have applied for Microsoft shim signing.** Once approved, no MOK enrollment will be required — our shim will be trusted by all UEFI firmware out of the box.

### Signing Roadmap

| Stage | Status | Description |
|-------|--------|-------------|
| MOK key pair generation | ✅ Done | RSA-2048 key, 10-year validity |
| Sign bootloader with MOK | ✅ Done | `sbsign` integrated into build pipeline |
| Interim: pre-signed shim (Ubuntu/Fedora) | 🔄 Active | Users see a one-time MOK enrollment prompt |
| **Microsoft shim-review submission** | **🟡 Submitted** | https://github.com/rhboot/shim-review |
| Microsoft-signed shim | ⏳ Pending | ~2–4 week review; eliminates MOK enrollment for end users |

### Understanding the Keys

There are two separate keys involved in Secure Boot:

**1. Our MOK (Machine Owner Key)**
Generated with a 10-year validity (`-days 3650`). This is the key we use to sign
`BOOTX64.EFI`. Users who enroll it once never need to enroll it again.

**2. Microsoft UEFI CA Key** *(the key that signs our shim)*

| Key | Expires | Status |
|-----|---------|--------|
| Microsoft UEFI CA 2011 | ~June 2026 | ⚠️ Expiring soon |
| Microsoft UEFI CA 2023 | ~2075 | ✅ Replacement — now issued to new shims |

We applied at the right time: shims submitted now are signed with the **2023 CA**, which
is valid for decades. The 2011 CA expiry does not affect us.

**Caveat:** Older firmware (pre-2022) may not yet have the 2023 CA enrolled. Those users
will need a BIOS/firmware update from their OEM before our shim-signed builds are trusted.
Disabling Secure Boot is the simplest workaround while waiting for OEM firmware updates.

### Secure Boot by User Type

| User | Recommended approach |
|------|---------------------|
| Enthusiast / developer | Disable Secure Boot — simplest, no restrictions |
| Tech-savvy, Secure Boot on | Enroll MOK once at first boot — then works forever |
| General user (future) | Microsoft-signed shim — zero friction once approved |
| Enterprise / kiosk | Microsoft-signed shim required — pending approval |

> **Short answer:** For Impossible OS today, disabling Secure Boot is fine.
> MOK enrollment works for users who must keep it on. The shim-review application
> starts the clock for full, friction-free Secure Boot support.

### First Boot (MOK Enrollment) — Current Interim Process

Until Microsoft signing is approved, follow these steps on first boot with Secure Boot enabled:

1. At the MokManager screen, select **Enroll MOK**
2. Select **Continue** → **Yes** → enter the enrollment password
3. Select **Reboot**
4. From next boot onwards, Impossible OS boots silently with Secure Boot ✅

### What Must Be Public for Shim Review

| Component | Public? | Reason |
|-----------|---------|--------|
| This bootloader source (`src/boot/`) | ✅ Yes | Microsoft audits the signed binary |
| Shim fork | ✅ Yes | Required by shim-review process |
| Kernel source | ❌ No | UEFI/shim never sees the kernel |
| Rest of Impossible OS | ❌ No | Unrelated to Secure Boot |

---

## Sync Policy

This repository is **automatically synced** from `src/boot/` in the private
`rizonesoft/impossible-os` repository via GitHub Actions on every push to `main`.
Do not submit pull requests here — file issues or contributions on the main repo instead.

---

## Building

The bootloader is built as part of the full OS build system. For reference, the bootloader
is compiled as a PE/COFF UEFI application (`BOOTX64.EFI`) using the UEFI GNU-EFI toolchain.

```bash
# From the main repo (private):
bash scripts/build.sh clean
```

---

## License

MIT — see [LICENSE](LICENSE)
