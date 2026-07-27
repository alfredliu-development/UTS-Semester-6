"""
seed_data.py — Isi database 'uas' dengan sample data lengkap.

Cara pakai:
    python seed_data.py

⚠️  Script ini MENGHAPUS dan MENGISI ULANG semua tabel.
    Password semua akun sample: password123
"""
import os, sys, hashlib, datetime

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
import django
django.setup()

from api.models import AccountUas, Customer, Product, Order, OrderItem

def sha256(text):
    return hashlib.sha256(text.encode()).hexdigest()

HASHED_PW = sha256('password123')

print("=" * 55)
print("  SEED DATA — Sales Take Order (Django)")
print("=" * 55)

# ── Accounts ─────────────────────────────────────────────────────────────────
print("\n→ Mengisi account_uas ...", end=' ')
AccountUas.objects.all().delete()
accounts = AccountUas.objects.bulk_create([
    AccountUas(username='sales01', email='sales01@gmail.com', password=HASHED_PW, full_name='Budi Santoso',    role='sales'),
    AccountUas(username='sales02', email='sales02@gmail.com', password=HASHED_PW, full_name='Siti Rahayu',     role='sales'),
    AccountUas(username='admin01', email='admin@example.com', password=HASHED_PW, full_name='Admin Utama',     role='admin'),
    AccountUas(username='sales03', email='sales03@gmail.com', password=HASHED_PW, full_name='Dani Prasetyo',   role='sales'),
    AccountUas(username='sales04', email='sales04@gmail.com', password=HASHED_PW, full_name='Rina Kurniawati', role='sales'),
])
print(f'{len(accounts)} akun.')

# ── Customers ─────────────────────────────────────────────────────────────────
print("→ Mengisi customers ...", end=' ')
Customer.objects.all().delete()
customers = Customer.objects.bulk_create([
    Customer(name='Toko Maju Jaya',          address='Jl. Sudirman No. 12, Jakarta',     phone='081234567890', is_visited=True,  notes='Toko besar, pesan tiap minggu'),
    Customer(name='Warung Bu Sri',            address='Jl. Melati No. 5, Bogor',          phone='082345678901', is_visited=True,  notes='Langganan tetap'),
    Customer(name='Minimarket Sejahtera',     address='Jl. Pahlawan No. 33, Depok',       phone='083456789012', is_visited=False, notes=None),
    Customer(name='Toko Sumber Rezeki',       address='Jl. Raya Bekasi Km. 20',           phone='084567890123', is_visited=True,  notes='Selalu ambil produk minuman'),
    Customer(name='Warung Pak Joko',          address='Jl. Diponegoro No. 7, Tangerang',  phone='085678901234', is_visited=False, notes=None),
    Customer(name='Toko Berkah Abadi',        address='Jl. Ahmad Yani No. 15, Bandung',   phone='086789012345', is_visited=True,  notes='Suka diskon bundling'),
    Customer(name='Supermarket Harapan',      address='Jl. Gatot Subroto No. 88, Bekasi', phone='087890123456', is_visited=False, notes=None),
    Customer(name='Toko Cahaya Baru',         address='Jl. Veteran No. 22, Bogor',        phone='088901234567', is_visited=True,  notes='Pesan rutin 2x seminggu'),
    Customer(name='Warung Ibu Dewi',          address='Jl. Kebon Jeruk No. 3, Jakarta',   phone='089012345678', is_visited=False, notes=None),
    Customer(name='Toko Indah Selalu',        address='Jl. Pramuka No. 11, Depok',        phone='081122334455', is_visited=True,  notes='Prioritas pengiriman pagi'),
    Customer(name='Minimarket Terang Bulan',  address='Jl. Cempaka No. 9, Tangerang',     phone='081233445566', is_visited=False, notes=None),
    Customer(name='Toko Subur Makmur',        address='Jl. Nusantara No. 17, Bekasi',     phone='081344556677', is_visited=True,  notes=None),
])
print(f'{len(customers)} customer.')

# ── Products ──────────────────────────────────────────────────────────────────
print("→ Mengisi products ...", end=' ')
Product.objects.all().delete()
products = Product.objects.bulk_create([
    # Mie Instan
    Product(name='Indomie Goreng',        category='Mie Instan',       price=3500,  stock=500, unit='pcs',    description='Mie goreng rasa ayam bawang'),
    Product(name='Indomie Kuah Ayam',     category='Mie Instan',       price=3500,  stock=480, unit='pcs',    description='Mie kuah rasa ayam spesial'),
    Product(name='Mie Sedaap Goreng',     category='Mie Instan',       price=3200,  stock=350, unit='pcs',    description='Mie goreng kriuk'),
    Product(name='Supermi Soto',          category='Mie Instan',       price=3000,  stock=400, unit='pcs',    description='Mie kuah rasa soto'),
    Product(name='Pop Mie Ayam',          category='Mie Instan',       price=5500,  stock=200, unit='pcs',    description='Mie cup praktis rasa ayam'),
    # Minuman
    Product(name='Aqua 600ml',            category='Minuman',          price=4000,  stock=300, unit='botol',  description='Air mineral 600ml'),
    Product(name='Aqua 1500ml',           category='Minuman',          price=7500,  stock=200, unit='botol',  description='Air mineral 1.5 liter'),
    Product(name='Teh Botol Sosro 450ml', category='Minuman',          price=6000,  stock=250, unit='botol',  description='Teh manis kemasan botol'),
    Product(name='Coca-Cola 390ml',       category='Minuman',          price=8000,  stock=150, unit='kaleng', description='Minuman bersoda segar'),
    Product(name='Pocari Sweat 500ml',    category='Minuman',          price=10000, stock=120, unit='botol',  description='Minuman isotonik'),
    Product(name='Le Minerale 600ml',     category='Minuman',          price=3500,  stock=320, unit='botol',  description='Air mineral premium'),
    # Snack
    Product(name='Chitato Original 68g',  category='Snack',            price=10000, stock=180, unit='pcs',    description='Keripik kentang gurih'),
    Product(name='Oreo Original 137g',    category='Snack',            price=12000, stock=160, unit='pcs',    description='Biskuit krim vanila'),
    Product(name='Taro Net BBQ 160g',     category='Snack',            price=11000, stock=140, unit='pcs',    description='Keripik talas bumbu BBQ'),
    Product(name='Qtela Tempe 60g',       category='Snack',            price=8000,  stock=200, unit='pcs',    description='Keripik tempe renyah'),
    Product(name='Richeese Ahh 100g',     category='Snack',            price=9000,  stock=175, unit='pcs',    description='Snack keju gurih'),
    # Kebutuhan Rumah
    Product(name='Rinso Anti Noda 1kg',   category='Kebutuhan Rumah',  price=22000, stock=100, unit='pcs',    description='Deterjen bubuk anti noda'),
    Product(name='Sunlight 755ml',        category='Kebutuhan Rumah',  price=18500, stock=120, unit='botol',  description='Sabun cuci piring jeruk'),
    Product(name='So Klin Lantai 1L',     category='Kebutuhan Rumah',  price=20000, stock=90,  unit='botol',  description='Pembersih lantai lavender'),
    Product(name='Lifebuoy Sabun 110g',   category='Kebutuhan Rumah',  price=8500,  stock=200, unit='pcs',    description='Sabun mandi anti bakteri'),
    # Bahan Makanan
    Product(name='Beras Premium 5kg',     category='Bahan Makanan',    price=75000, stock=80,  unit='karung', description='Beras putih pulen premium'),
    Product(name='Minyak Goreng 2L',      category='Bahan Makanan',    price=38000, stock=110, unit='botol',  description='Minyak goreng sawit'),
    Product(name='Gula Pasir 1kg',        category='Bahan Makanan',    price=17000, stock=150, unit='pcs',    description='Gula pasir putih'),
    Product(name='Tepung Terigu 1kg',     category='Bahan Makanan',    price=12500, stock=130, unit='pcs',    description='Tepung terigu serbaguna'),
    Product(name='Kecap Manis ABC 135ml', category='Bahan Makanan',    price=9500,  stock=200, unit='botol',  description='Kecap manis legendaris'),
])
print(f'{len(products)} produk.')

# ── Orders + Items ────────────────────────────────────────────────────────────
print("→ Mengisi orders & order_items ...", end=' ')
OrderItem.objects.all().delete()
Order.objects.all().delete()

today     = datetime.datetime.now()
yesterday = today - datetime.timedelta(days=1)

sample_orders = [
    (customers[0],  'done',  'Selesai pengiriman',  today,      [(products[0],5),(products[1],3),(products[5],12)]),
    (customers[1],  'sent',  'Dalam perjalanan',    today,      [(products[2],2),(products[6],4)]),
    (customers[2],  'draft', None,                  today,      [(products[3],1),(products[4],6),(products[7],2)]),
    (customers[0],  'done',  'Order kemarin',       yesterday,  [(products[0],10),(products[5],8)]),
    (customers[3],  'done',  'Langganan mingguan',  yesterday,  [(products[1],4),(products[8],3),(products[9],5)]),
    (customers[4],  'sent',  'Butuh invoice',       yesterday,  [(products[2],7),(products[3],2)]),
]

total_orders = 0
total_items  = 0
for cust, st, notes, created, item_list in sample_orders:
    total_amount = sum(float(p.price) * q for p, q in item_list)
    order = Order.objects.create(
        customer      = cust,
        customer_name = cust.name,
        total_amount  = total_amount,
        status        = st,
        notes         = notes,
        created_at    = created,
    )
    OrderItem.objects.bulk_create([
        OrderItem(order=order, product=p, product_name=p.name,
                  price=p.price, quantity=q, unit=p.unit)
        for p, q in item_list
    ])
    total_orders += 1
    total_items  += len(item_list)

print(f'{total_orders} order, {total_items} items.')

print("\n" + "=" * 55)
print("  ✅ Seed data selesai!")
print()
print("  Login sample:")
print("   username: sales01   password: password123")
print("   username: sales02   password: password123")
print("   username: admin01   password: password123")
print("=" * 55)
