# Roblox Auto Rejoin for Termux

Menu Lua 5.3 untuk Termux yang membuka deep link Roblox ke Place ID yang dipilih. Tidak memakai executor, injection, atau bypass Roblox.

## Isi repository

- `roblox-auto-rejoin.lua` — menu utama.
- `install.sh` — instalasi Termux satu kali.

## Instalasi dari GitHub

```sh
pkg install -y git
git clone https://github.com/azka150104-hub/roblox-auto-rejoin.git
cd roblox-auto-rejoin
bash install.sh
lua5.3 roblox-auto-rejoin.lua
```

Saat aplikasi terbuka:

1. Pilih `1) Setup Termux & Dependencies` bila dependensi belum dipasang atau ingin menjalankan pengecekan ulang.
2. Pilih `2) Setup / Edit Configuration`, lalu masukkan Place ID atau URL game Roblox.
3. Pilih `3) Join Game Now` untuk membuka game.

## Memperbarui dari GitHub

```sh
cd roblox-auto-rejoin
git pull
lua5.3 roblox-auto-rejoin.lua
```

## Catatan

- Beri izin penyimpanan ketika `termux-setup-storage` meminta izin Android.
- `tsu` ikut dipasang sesuai daftar dependensi, tetapi aplikasi ini tidak membutuhkan root.
- Auto-rejoin berbasis timer hanya mengirim kembali deep link game. Termux tidak dapat mendeteksi disconnect di dalam aplikasi Roblox.
- Hentikan mode monitor atau timer dengan `Ctrl+C`.
- Pada perangkat root, menu `9) Root Window Grid` dapat mencoba menata task Roblox
  yang sudah terbuka ke dalam grid. Dukungan resize tetap bergantung pada ROM dan
  pengaturan freeform/multi-window Android.
