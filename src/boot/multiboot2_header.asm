; =============================================================================
; Multiboot2 Header — Required for GRUB to recognize the kernel
; =============================================================================

section .multiboot2
align 8

MULTIBOOT2_MAGIC    equ 0xE85250D6      ; Multiboot2 magic number
ARCHITECTURE        equ 0               ; 0 = i386 (32-bit protected mode entry)
HEADER_LENGTH       equ multiboot2_header_end - multiboot2_header_start
CHECKSUM            equ -(MULTIBOOT2_MAGIC + ARCHITECTURE + HEADER_LENGTH)

multiboot2_header_start:
    dd MULTIBOOT2_MAGIC
    dd ARCHITECTURE
    dd HEADER_LENGTH
    dd CHECKSUM

    ; --- Framebuffer tag (request GOP framebuffer) ---
    align 8
    dw 5                        ; type = framebuffer tag
    dw 0                        ; flags (not optional)
    dd 20                       ; size of this tag
    dd 1280                     ; preferred width
    dd 720                      ; preferred height
    dd 32                       ; preferred bpp

    ; --- EFI amd64 entry address tag (type 9) ---
    ; Tells GRUB to enter kernel in 64-bit long mode on UEFI systems.
    ; Without this, GRUB must switch 64→32 bit which fails on Hyper-V.
    align 8
    extern _start_efi64
    dw 9                        ; type = EFI amd64 entry address
    dw 0                        ; flags (not optional)
    dd 12                       ; size of this tag
    dd _start_efi64             ; 64-bit entry point address

    ; --- End tag ---
    align 8
    dw 0                        ; type = end tag
    dw 0                        ; flags
    dd 8                        ; size
multiboot2_header_end:
