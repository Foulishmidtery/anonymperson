# Anonymperson

**Anonymperson** adalah skrip otomatisasi untuk meningkatkan privasi dan anonimitas di Kali Linux 2025.1. Proyek ini mengintegrasikan **ProtonVPN Free**, **Tor**, **IPFS**, dan **Pi-hole** untuk menyediakan lapisan perlindungan terhadap pelacakan, iklan, dan pengintaian online. Dengan fitur seperti rotasi server VPN, pergantian identitas Tor, pemblokiran iklan via Pi-hole, dan pengelolaan file terdesentralisasi melalui IPFS, Anonymperson cocok untuk pengguna yang ingin menjaga privasi mereka.

**Catatan Hukum**: Penggunaan alat ini harus mematuhi hukum setempat terkait VPN, Tor, perubahan alamat MAC, dan modifikasi hostname. Pastikan Anda memahami implikasi hukum sebelum menggunakan Anonymperson.

---

## Features

- **ProtonVPN Free**: Terhubung ke server VPN gratis untuk menyembunyikan alamat IP Anda.
- **Tor**: Menggunakan jaringan Tor untuk anonimitas tambahan melalui SOCKS5 proxy (127.0.0.1:9050).
- **Pi-hole**: Memblokir iklan dan pelacak di seluruh jaringan menggunakan server DNS lokal (tanpa kata sandi web).
- **IPFS**: Berbagi dan mengambil file secara terdesentralisasi dengan daemon IPFS.
- **Dynamic Rotation**: Rotasi otomatis server VPN dan sirkuit Tor untuk meningkatkan anonimitas.
- **MAC Address Spoofing**: Mengubah alamat MAC untuk menghindari pelacakan perangkat.
- **Hostname Randomization**: Mengubah hostname sementara untuk mengurangi identifikasi sistem.
- **Cache Cleaning**: Menghapus cache sistem menggunakan BleachBit.
- **I2P Support**: Integrasi dengan jaringan I2P untuk anonimitas tambahan.
- **Privoxy**: Proxy HTTP yang bekerja dengan Tor untuk lalu lintas web yang lebih aman.
- **Nyx**: Memantau status Tor secara real-time.

---

## Prerequisites

- **Sistem Operasi**: Kali Linux 2025.1 (64-bit).
- **Akses Root**: Skrip harus dijalankan sebagai root (`sudo`).
- **Koneksi Internet**: Diperlukan untuk mengunduh dependensi dan konfigurasi.
- **Akun ProtonVPN Free**: Daftar di [ProtonVPN](https://protonvpn.com/free-vpn) untuk mendapatkan kredensial.
- **Ruang Disk**: Minimal 5 GB untuk Docker, IPFS, dan dependensi lainnya.
- **Git**: Untuk mengkloning repositori (`sudo apt install git`).

---

## Installation

Ikuti langkah-langkah berikut untuk menginstal Anonymperson di Kali Linux 2025.1.

### 1. Clone Repository
Kloning repositori ke direktori pilihan Anda (misalnya, `~/Downloads`):
```bash
mkdir -p ~/Downloads
cd ~/Downloads
git clone https://github.com/Foulishmidtery/anonymperson.git
cd anonymperson
```

### 2. Run Setup Script
Jalankan `setup_anonymperson.sh` untuk membuat struktur direktori proyek (default: `/home/$USER/anonymperson`), menyalin file, mengatur izin, dan menginstal dependensi:
```bash
sudo chmod +x setup_anonymperson.sh
sudo ./setup_anonymperson.sh
```

Skrip akan:
- Membuat direktori proyek di `/home/$USER/anonymperson` (atau lokasi kustom jika `ANONYMPERSON_DEST` diatur, misalnya, `export ANONYMPERSON_DEST=/opt/anonymperson`).
- Menyalin file utama (`INSTALL.sh`, `anonymperson`, dll.) dan file konfigurasi (`torrc`, `privoxy.config`, dll.).
- Mengatur izin file.
- Menjalankan `INSTALL.sh` untuk menginstal dependensi (`tor`, `privoxy`, `openvpn`, `macchanger`, `nyx`, `curl`, `bleachbit`, `docker.io`, dll.), menyiapkan Pi-hole sebagai container Docker tanpa kata sandi web, serta menginstal I2P, ProtonVPN CLI, dan IPFS.

Untuk menggunakan lokasi kustom:
```bash
export ANONYMPERSON_DEST=/opt/anonymperson
sudo ./setup_anonymperson.sh
```

### 3. Update ProtonVPN Credentials
Skrip `setup_anonymperson.sh` membuat file kredensial placeholder. Edit file untuk menambahkan kredensial ProtonVPN Anda:
```bash
sudo nano /etc/anonymperson/protonvpn_credentials.conf
```
Ganti placeholder dengan kredensial Anda:
```bash
PROTONVPN_USERNAME="your_actual_username"
PROTONVPN_PASSWORD="your_actual_password"
```
Simpan dan atur izin:
```bash
sudo chmod 600 /etc/anonymperson/protonvpn_credentials.conf
```

### 4. Verify Configuration Files
Pastikan direktori `configs/` di direktori proyek (misalnya, `/home/$USER/anonymperson/configs/`) berisi file berikut:
- `torrc`: Konfigurasi Tor dengan minimal:
  ```bash
  SocksPort 9050
  DataDirectory /var/lib/tor
  ```
- `privoxy.config`: Konfigurasi Privoxy dengan:
  ```bash
  forward-socks5 / 127.0.0.1:9050 .
  listen-address 127.0.0.1:8118
  ```
- `us-free-22.protonvpn.tcp.ovpn`: File konfigurasi OpenVPN dari ProtonVPN Free (unduh dari [ProtonVPN Dashboard](https://account.protonvpn.com), pilih server gratis, TCP).
- `ipfs_config`: Konfigurasi IPFS (dihasilkan oleh `ipfs init` atau gunakan default).

Jika file tidak ada, lihat bagian **Configuration Files** di bawah untuk membuatnya.

### 5. Verify Installation
Pindah ke direktori proyek:
```bash
cd ~/anonymperson
```
Periksa status layanan:
```bash
sudo systemctl status tor
sudo systemctl status privoxy
docker ps  # Pastikan container pihole berjalan
ipfs --version
protonvpn-cli --version
```

---

## Usage

Jalankan perintah berikut dengan `sudo` dari direktori proyek (misalnya, `/home/$USER/anonymperson`) untuk mengelola anonimitas:

### Basic Commands
- **Aktifkan Anonimitas**:
  ```bash
  sudo anonymperson anON
  ```
  Mengaktifkan ProtonVPN, Tor, Privoxy, IPFS, Pi-hole, perubahan MAC, hostname acak, dan rotasi dinamis.

- **Nonaktifkan Anonimitas**:
  ```bash
  sudo anonymperson anOFF
  ```
  Menghentikan semua layanan, mengembalikan MAC dan hostname ke default.

- **Periksa Status**:
  ```bash
  sudo anonymperson status
  ```
  Menampilkan status Tor, Privoxy, IPFS, Pi-hole, dan VPN.

- **Periksa IP Publik**:
  ```bash
  sudo anonymperson status_ip
  ```
  Menampilkan alamat IP publik saat ini.

### Advanced Commands
- **VPN**:
  ```bash
  sudo anonymperson start_vpn    # Mulai ProtonVPN
  sudo anonymperson stop_vpn     # Hentikan ProtonVPN
  sudo anonymperson status_vpn   # Periksa status VPN
  sudo anonymperson dynamic_vpn  # Aktifkan rotasi server VPN
  ```

- **Tor**:
  ```bash
  sudo anonymperson start_tor    # Mulai Tor
  sudo anonymperson stop_tor     # Hentikan Tor
  sudo anonymperson status_tor   # Periksa status Tor
  sudo anonymperson change       # Ganti identitas Tor
  sudo anonymperson dynamic      # Aktifkan rotasi sirkuit Tor
  ```

- **Pi-hole**:
  ```bash
  sudo anonymperson start_pihole  # Mulai Pi-hole
  sudo anonymperson stop_pihole   # Hentikan Pi-hole
  sudo anonymperson status_pihole # Periksa status Pi-hole
  ```
  Akses dashboard Pi-hole di `http://localhost/admin` (tanpa kata sandi).

- **IPFS**:
  ```bash
  sudo anonymperson start_ipfs         # Mulai daemon IPFS
  sudo anonymperson stop_ipfs          # Hentikan daemon IPFS
  sudo anonymperson status_ipfs        # Periksa status IPFS
  sudo anonymperson share_ipfs <file>  # Bagikan file via IPFS
  sudo anonymperson get_ipfs <hash>    # Ambil file dari IPFS
  ```

- **I2P**:
  ```bash
  sudo anonymperson start_i2p    # Mulai I2P
  sudo anonymperson stop_i2p     # Hentikan I2P
  sudo anonymperson status_i2p   # Periksa status I2P
  ```

- **Privoxy**:
  ```bash
  sudo anonymperson start_privoxy   # Mulai Privoxy
  sudo anonymperson stop_privoxy    # Hentikan Privoxy
  sudo anonymperson status_privoxy  # Periksa status Privoxy
  ```

- **MAC Address**:
  ```bash
  sudo anonymperson start_mac    # Ubah MAC address
  sudo anonymperson stop_mac     # Kembalikan MAC address
  sudo anonymperson status_mac   # Periksa MAC address
  ```

- **Hostname**:
  ```bash
  sudo anonymperson change_hostname   # Ubah hostname
  sudo anonymperson restore_hostname  # Kembalikan hostname ke 'kali'
  sudo anonymperson status_hostname   # Periksa hostname
  ```

- **Cache Cleaning**:
  ```bash
  sudo anonymperson wipe  # Hapus cache sistem
  ```

- **Nyx (Tor Monitoring)**:
  ```bash
  sudo anonymperson start_nyx  # Buka monitor Tor
  ```

- **Help**:
  ```bash
  sudo anonymperson --help
  ```
  Menampilkan daftar semua perintah.

---

## Configuration Files

Jika file konfigurasi di `configs/` tidak tersedia, buat dengan konten berikut:

- **torrc**:
  ```bash
  SocksPort 9050
  DataDirectory /var/lib/tor
  ```

- **privoxy.config**:
  ```bash
  forward-socks5 / 127.0.0.1:9050 .
  listen-address 127.0.0.1:8118
  ```

- **us-free-22.protonvpn.tcp.ovpn**:
  - Unduh dari akun ProtonVPN Free di [ProtonVPN Dashboard](https://account.protonvpn.com).
  - Pilih server gratis (misalnya, US-Free#22) dan unduh file `.ovpn` untuk TCP.
  - Salin ke `configs/us-free-22.protonvpn.tcp.ovpn`.

- **ipfs_config**:
  - Jalankan `ipfs init` untuk menghasilkan konfigurasi default:
    ```bash
    ipfs init
    cp ~/.ipfs/config configs/ipfs_config
    ```
  - Contoh konten (dis簡化):
    ```json
    {
      "Identity": {
        "PeerID": "..."
      },
      "Datastore": {
        "StorageMax": "10GB"
      },
      "Addresses": {
        "Swarm": ["/ip4/0.0.0.0/tcp/4001"],
        "API": "/ip4/127.0.0.1/tcp/5001",
        "Gateway": "/ip4/127.0.0.1/tcp/8080"
      }
    }
    ```

---

## Security Notes

- **ProtonVPN Credentials**: Kredensial disimpan di `/etc/anonymperson/protonvpn_credentials.conf` dengan izin ketat (`chmod 600`). Jangan bagikan file ini.
- **Pi-hole Web Interface**: Tanpa kata sandi, dashboard Pi-hole (`http://localhost/admin`) dapat diakses oleh siapa saja di jaringan lokal. Jika server Anda terpapar ke internet, tambahkan kata sandi dengan mengedit `INSTALL.sh`:
  ```bash
  -e WEBPASSWORD="secure_password" \
  ```
  atau batasi akses dengan firewall:
  ```bash
  sudo ufw allow 80
  sudo ufw allow 443
  sudo ufw allow 53
  ```

- **DNS Leaks**: Pi-hole diatur sebagai server DNS lokal (`127.0.0.1`). Uji kebocoran DNS:
  ```bash
  nslookup flurry.com
  ```
  Respons `0.0.0.0` menunjukkan Pi-hole memblokir domain iklan.

- **Isolated Environment**: Jalankan Anonymperson di mesin virtual atau container untuk keamanan tambahan.

---

## Troubleshooting

- **Pi-hole Tidak Berjalan**:
  Periksa log:
  ```bash
  docker logs pihole
  ```
  Pastikan port 53, 80, dan 443 tidak digunakan:
  ```bash
  sudo ss -tuln | grep ':53\|:80\|:443'
  ```
  Hentikan layanan yang berkonflik:
  ```bash
  sudo systemctl stop <service_name>
  ```

- **ProtonVPN Gagal**:
  Verifikasi kredensial di `/etc/anonymperson/protonvpn_credentials.conf`. Periksa status:
  ```bash
  protonvpn-cli status
  ```
  Perbarui file `us-free-22.protonvpn.tcp.ovpn` dari akun ProtonVPN Anda.

- **Tor atau Privoxy Gagal**:
  Periksa log:
  ```bash
  journalctl -u tor
  journalctl -u privoxy
  ```

- **IPFS Tidak Berfungsi**:
  Pastikan daemon berjalan:
  ```bash
  ipfs daemon --offline
  ```

- **Konflik Port**:
  Nonaktifkan layanan seperti `dnsmasq`:
  ```bash
  sudo systemctl disable dnsmasq
  sudo systemctl stop dnsmasq
  ```

- **Setup Gagal**:
  Periksa log kesalahan:
  ```bash
  cat ~/anonymperson/install_error.log
  ```
  Laporkan masalah di [GitHub Issues](https://github.com/Foulishmidtery/anonymperson/issues).

---

## Contributing

Kontribusi sangat diterima! Untuk berkontribusi:
1. Fork repositori ini.
2. Buat branch untuk fitur atau perbaikan:
   ```bash
   git checkout -b feature/your-feature
   ```
3. Commit perubahan Anda:
   ```bash
   git commit -m "Add your feature"
   ```
4. Push ke branch Anda:
   ```bash
   git push origin feature/your-feature
   ```
5. Buat Pull Request di GitHub.

---

## License

Proyek ini dilisensikan di bawah [MIT License](LICENSE).

---

## Acknowledgments

- Terinspirasi dari [anonym8](https://github.com/HiroshiManRise/anonym8).
- Menggunakan layanan gratis dari [ProtonVPN](https://protonvpn.com).
- Didukung oleh proyek open-source seperti [Tor](https://www.torproject.org), [Pi-hole](https://pi-hole.net), dan [IPFS](https://ipfs.io).

---

**Kontak**: Untuk pertanyaan, buka issue di [GitHub](https://github.com/Foulishmidtery/anonymperson) atau hubungi pengelola repositori.