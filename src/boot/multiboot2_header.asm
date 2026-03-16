; =============================================================================
; Multiboot2 Header — Required for GRUB to recognize the kernel
;
; Tags:
;   - Framebuffer tag (type 5): request 1280x720x32 GOP framebuffer
;   - EFI boot services tag (type 7): keep UEFI boot services alive
;     (REQUIRED for type 9 to be honored by GRUB)
;   - EFI amd64 entry address tag (type 9): enter kernel in 64-bit mode
;     (prevents 64→32 mode switch that hangs on Hyper-V)
; =============================================================================

section .multiboot2
align 8

MULTIBOOT2_MAGIC    equ 0xE85250D6      ; Multiboot2 magic number
ARCHITECTURE        equ 0               ; 0 = i386 (32-bit protected mode entry)
HEADER_LENGTH       equ multiboot2_header_end - multiboot2_header_start
CHECKSUM            equ -(MULTIBOOT2_MAGIC + ARCHITECTURE + HEADER_LENGTH)

OPTIONAL_FLAG       equ 1               ; flags bit 0 = optional tag

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

    ; --- EFI boot services tag (type 7) ---
    ; Tells GRUB to NOT call ExitBootServices before entering the kernel.
    ; This is REQUIRED for the EFI amd64 entry tag (type 9) to work.
    ; Without this tag, GRUB ignores type 9 and uses the 32-bit _start.
    ; Marked optional so BIOS/legacy GRUB ignores it gracefully.
    align 8
    dw 7                        ; type = EFI boot services tag
    dw OPTIONAL_FLAG            ; flags (optional — ignored by non-EFI GRUB)
    dd 8                        ; size of this tag

    ; --- EFI amd64 entry address tag (type 9) ---
    ; Tells GRUB to enter kernel at _start_efi64 in 64-bit long mode.
    ; Only honored when EFI boot services tag (type 7) is also present.
    ; Marked optional so BIOS/legacy GRUB ignores it.
    align 8
    extern _start_efi64
    dw 9                        ; type = EFI amd64 entry address
    dw OPTIONAL_FLAG            ; flags (optional — ignored by non-EFI GRUB)
    dd 12                       ; size of this tag
    dd _start_efi64             ; 64-bit entry point address

    ; --- End tag ---
    align 8
    dw 0                        ; type = end tag
    dw 0                        ; flags
    dd 8                        ; size
multiboot2_header_end:
