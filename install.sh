#!/data/data/com.termux/files/usr/bin/bash
# Installer awal untuk Roblox Auto Rejoin for Termux.
# Jalankan dengan: bash install.sh

set -euo pipefail

printf '\n[1/4] Meminta akses penyimpanan Android...\n'
termux-setup-storage

printf '\n[2/4] Memperbarui repository dan paket Termux...\n'
pkg update -y
pkg upgrade -y

printf '\n[3/4] Memasang dependensi utama...\n'
# git ditambahkan agar repository dapat dipasang/diperbarui dari GitHub.
pkg install -y lua53 tsu python figlet android-tools sqlite git

printf '\n[4/4] Paket Python tambahan dilewati.\n'
printf 'Tidak diperlukan untuk auto rejoin dan dapat lama di-compile di Termux.\n'
printf 'Jika diperlukan untuk proyek Python Anda sendiri, pasang manual nanti.\n'

printf '\nSelesai. Jalankan aplikasi dengan:\n'
printf 'lua5.3 roblox-auto-rejoin.lua\n\n'
