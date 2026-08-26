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
4. Pilih `10) Auto Detect Roblox Apps (60 sec delay)` untuk mendeteksi package
   Roblox/clone yang namanya memuat `roblox` atau `mercy`, lalu membukanya satu per satu.
   Anda bisa memilih agar layout Auto Grid tersimpan diterapkan setelah semua aplikasi dibuka.
5. Pilih `14) Auto Grid Settings (Layout)` untuk menyimpan tata letak seperti `2x2`,
   `3x2`, atau `3x3`. Pengaturan ini dipakai oleh menu `10` dan
   `11) Auto Grid Open App Windows`, sehingga layout tidak perlu diketik berulang kali.
   Bila package Roblox tidak ditemukan pada task, skrip mencoba task aplikasi pengguna yang
   sedang terlihat (memerlukan root/freeform ROM).
6. Pilih `12) Detect Roblox Apps (Scan Only)` bila hanya ingin melihat daftar package
   Roblox/clone yang terdeteksi tanpa membuka aplikasinya.
7. Pilih `13) Detect Visible App Tasks (Scan Only)` untuk memeriksa task yang akan
   dipakai fallback Auto Grid tanpa mengubah posisi jendela.

## Memperbarui dari GitHub

```sh
cd roblox-auto-rejoin
git pull
lua5.3 roblox-auto-rejoin.lua
```

## Catatan

- Beri izin penyimpanan ketika `termux-setup-storage` meminta izin Android.
- `tsu` ikut dipasang sesuai daftar dependensi, tetapi aplikasi ini tidak membutuhkan root.
- Paket Python berat seperti `cryptography` tidak dipasang karena tidak diperlukan skrip ini
  dan dapat lama di-compile pada Termux.
- Auto-rejoin berbasis timer hanya mengirim kembali deep link game. Termux tidak dapat mendeteksi disconnect di dalam aplikasi Roblox.
- Hentikan mode monitor atau timer dengan `Ctrl+C`.
- Pada perangkat root, menu `9) Root Window Grid` dapat mencoba menata task Roblox
  yang sudah terbuka ke dalam grid. Dukungan resize tetap bergantung pada ROM dan
  pengaturan freeform/multi-window Android.
- Jika hasil grid masih saling menimpa, window manager/freeform pihak ketiga pada perangkat
  kemungkinan mengambil alih ukuran jendela setelah skrip mengaturnya. Coba tutup atau nonaktifkan
  mode auto-resize pada window manager tersebut sebelum menjalankan menu `11`.
