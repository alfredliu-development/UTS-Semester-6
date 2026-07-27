# 🚀 Backend Django REST Framework — Sales Take Order

Backend REST API menggunakan **Django 4.2 + Django REST Framework**  
Database: **MySQL XAMPP** (host=localhost, user=root, password='', db=uas)

---

## 📋 Requirements

- Python 3.10+
- XAMPP (MySQL aktif)

---

## ⚡ Quick Start

### 1. Install dependencies
```cmd
cd backend
pip install -r requirements.txt
```

### 2. Setup database (buat DB + tabel)
```cmd
python setup_db.py
```

### 3. Isi sample data (opsional tapi direkomendasikan)
```cmd
python seed_data.py
```

### 4. Jalankan server
```cmd
python manage.py runserver 0.0.0.0:8080
```

Test: buka `http://localhost:8080/health`

---

## 📡 API Endpoints

| Method | URL | Deskripsi |
|--------|-----|-----------|
| GET  | `/health` | Cek koneksi server + DB |
| POST | `/account_uas/login` | Login |
| POST | `/account_uas/register` | Register |
| GET/PUT | `/account_uas/<id>` | Get / Update akun |
| GET  | `/customers` | Semua customer |
| GET  | `/customers/search?q=` | Cari customer |
| GET  | `/customers/<id>` | Detail customer |
| PUT  | `/customers/<id>/visit` | Update kunjungan |
| GET  | `/customers/stats/total-visited` | Total dikunjungi |
| GET  | `/products` | Semua produk |
| GET  | `/products?category=` | Filter kategori |
| GET  | `/products/search?q=` | Cari produk |
| GET  | `/products/<id>` | Detail produk |
| GET  | `/products/categories` | Daftar kategori |
| GET  | `/orders` | Semua order |
| GET  | `/orders?customer_id=` | Order by customer |
| POST | `/orders` | Buat order baru |
| GET  | `/orders/today` | Order hari ini |
| GET  | `/orders/<id>` | Detail order |
| GET  | `/orders/<id>/items` | Items dari order |
| PUT  | `/orders/<id>/status` | Update status |
| GET  | `/orders/stats/today-total` | Total nilai hari ini |
| GET  | `/orders/stats/today-count` | Jumlah order hari ini |

---

## 🔑 Login Sample

| username | password |
|----------|----------|
| sales01  | password123 |
| sales02  | password123 |
| admin01  | password123 |

> Password dikirim sebagai **SHA-256 hash** dari Flutter.

---

## 🔧 Flutter baseUrl

Edit `lib/core/constants/app_constants.dart`:

```dart
// Android Emulator
static const String baseUrl = 'http://10.0.2.2:8080';

// Device Fisik (ganti dengan IP komputer LAN Anda)
static const String baseUrl = 'http://192.168.0.101:8080';
```
