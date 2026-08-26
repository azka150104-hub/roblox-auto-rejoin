#!/data/data/com.termux/files/usr/bin/bash
# Installer awal untuk Roblox Auto Rejoin for Termux.
# Jalankan dengan: bash install.sh

set -euo pipefail

printf '\n[1/5] Meminta akses penyimpanan Android...\n'
termux-setup-storage

printf '\n[2/5] Memperbarui repository dan paket Termux...\n'
pkg update -y
pkg upgrade -y

printf '\n[3/5] Memasang dependensi...\n'
# git ditambahkan agar repository dapat dipasang/diperbarui dari GitHub.
pkg install -y lua53 tsu python figlet android-tools sqlite git rust clang

printf '\n[4/5] Memasang paket Python...\n'
pip install pyfiglet rich curl_cffi requests pycryptodome cryptography numpy Pillow

printf '\n[5/5] Selesai. Jalankan aplikasi dengan:\n'
printf 'lua5.3 roblox-auto-rejoin.lua\n\n'
