"""
setup_db.py — Buat database 'uas' dan semua tabel via Django migrations.

Cara pakai (jalankan sekali sebelum start server):
    python setup_db.py

Pastikan XAMPP MySQL sudah aktif!
"""
import os
import sys

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')

import django
django.setup()

import mysql.connector

print("=" * 55)
print("  SETUP DATABASE — Sales Take Order (Django)")
print("=" * 55)

# 1. Buat database jika belum ada
print("\n[1/3] Membuat database 'uas' di MySQL...")
try:
    conn = mysql.connector.connect(host='localhost', user='root', password='')
    cur  = conn.cursor()
    cur.execute("CREATE DATABASE IF NOT EXISTS uas CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;")
    conn.commit()
    conn.close()
    print("✅ Database 'uas' siap.")
except Exception as e:
    print(f"❌ Gagal membuat database: {e}")
    print("   Pastikan XAMPP MySQL sudah aktif!")
    sys.exit(1)

# 2. Jalankan migrate
print("\n[2/3] Menjalankan Django migrations...")
from django.core.management import call_command
try:
    call_command('migrate', '--run-syncdb', verbosity=0)
    print("✅ Semua tabel berhasil dibuat.")
except Exception as e:
    print(f"❌ Migrations gagal: {e}")
    sys.exit(1)

# 3. Cek tabel
print("\n[3/3] Memverifikasi tabel...")
from api.models import AccountUas, Customer, Product, Order, OrderItem
tables = {
    'account_uas':  AccountUas,
    'customers':    Customer,
    'products':     Product,
    'orders':       Order,
    'order_items':  OrderItem,
}
for name, model in tables.items():
    try:
        count = model.objects.count()
        print(f"   ✅  {name:<15} ({count} baris)")
    except Exception as e:
        print(f"   ❌  {name}: {e}")

print("\n" + "=" * 55)
print("  ✅ Setup selesai! Jalankan server:")
print("     python manage.py runserver 0.0.0.0:8080")
print("=" * 55)
