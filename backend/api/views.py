"""
api/views.py — Semua endpoint REST API Sales Take Order App.

Endpoint summary:
  GET  /health

  POST /account_uas/login
  POST /account_uas/register
  GET  /account_uas/<id>
  PUT  /account_uas/<id>

  GET  /customers
  GET  /customers/search?q=...
  GET  /customers/<id>
  PUT  /customers/<id>/visit
  GET  /customers/stats/total-visited

  GET  /products
  GET  /products/search?q=...
  GET  /products/<id>
  GET  /products/categories

  GET  /orders
  POST /orders
  GET  /orders/today
  GET  /orders/<id>
  GET  /orders/<id>/items
  PUT  /orders/<id>/status
  GET  /orders/stats/today-total
  GET  /orders/stats/today-count
"""

import datetime
from django.db import transaction
from django.db.models import Q, Sum, Count
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status

from .models import AccountUas, Customer, Product, Order, OrderItem
from .serializers import (
    AccountSerializer, AccountWriteSerializer,
    CustomerSerializer,
    ProductSerializer,
    OrderSerializer, OrderItemSerializer, OrderWriteSerializer,
)


# ══════════════════════════════════════════════════════════════════════════════
# HEALTH
# ══════════════════════════════════════════════════════════════════════════════

@api_view(['GET'])
def health_check(request):
    """Cek koneksi server + database."""
    try:
        AccountUas.objects.exists()   # simple DB ping
        return Response({'status': 'ok', 'message': 'Server dan database terhubung!'})
    except Exception as e:
        return Response({'status': 'error', 'message': str(e)},
                        status=status.HTTP_500_INTERNAL_SERVER_ERROR)


# ══════════════════════════════════════════════════════════════════════════════
# AUTH  —  account_uas
# ══════════════════════════════════════════════════════════════════════════════

@api_view(['POST'])
def login(request):
    """Login: { username, password (SHA-256) } → AccountUas."""
    username = request.data.get('username', '').strip()
    pwd      = request.data.get('password', '')

    if not username or not pwd:
        return Response({'message': 'Username dan password wajib diisi'},
                        status=status.HTTP_400_BAD_REQUEST)

    try:
        user = AccountUas.objects.get(username=username, password=pwd)
        return Response(AccountSerializer(user).data)
    except AccountUas.DoesNotExist:
        return Response({'message': 'Username atau password salah'},
                        status=status.HTTP_401_UNAUTHORIZED)


@api_view(['POST'])
def register(request):
    """Register akun baru."""
    data = request.data

    required = ['username', 'email', 'password', 'full_name']
    if not all(data.get(f, '').strip() for f in required):
        return Response({'message': 'Semua field wajib diisi'},
                        status=status.HTTP_400_BAD_REQUEST)

    if AccountUas.objects.filter(username=data['username'].strip()).exists():
        return Response({'message': 'Username sudah digunakan'},
                        status=status.HTTP_409_CONFLICT)

    if AccountUas.objects.filter(email=data['email'].strip()).exists():
        return Response({'message': 'Email sudah digunakan'},
                        status=status.HTTP_409_CONFLICT)

    user = AccountUas.objects.create(
        username  = data['username'].strip(),
        email     = data['email'].strip(),
        password  = data['password'],
        full_name = data['full_name'].strip(),
        role      = data.get('role', 'sales'),
    )
    return Response(AccountSerializer(user).data, status=status.HTTP_201_CREATED)


@api_view(['GET', 'PUT'])
def user_detail(request, user_id):
    """GET/PUT /account_uas/<id>."""
    try:
        user = AccountUas.objects.get(pk=user_id)
    except AccountUas.DoesNotExist:
        return Response({'message': 'Akun tidak ditemukan'},
                        status=status.HTTP_404_NOT_FOUND)

    if request.method == 'GET':
        return Response(AccountSerializer(user).data)

    # PUT — update full_name dan username
    data = request.data
    if not data.get('full_name', '').strip() or not data.get('username', '').strip():
        return Response({'message': 'full_name dan username wajib diisi'},
                        status=status.HTTP_400_BAD_REQUEST)

    # Cek username duplikat (selain diri sendiri)
    if AccountUas.objects.filter(username=data['username'].strip()).exclude(pk=user_id).exists():
        return Response({'message': 'Username sudah digunakan akun lain'},
                        status=status.HTTP_409_CONFLICT)

    user.full_name = data['full_name'].strip()
    user.username  = data['username'].strip()
    user.save()
    return Response({'message': 'Akun berhasil diperbarui'})


# ══════════════════════════════════════════════════════════════════════════════
# CUSTOMERS
# ══════════════════════════════════════════════════════════════════════════════

@api_view(['GET'])
def customer_list(request):
    """GET /customers — semua customer A-Z."""
    qs = Customer.objects.all()
    return Response(CustomerSerializer(qs, many=True).data)


@api_view(['GET'])
def customer_search(request):
    """GET /customers/search?q=... — cari by nama/alamat/telp."""
    q = request.query_params.get('q', '').strip()
    qs = Customer.objects.filter(
        Q(name__icontains=q) | Q(address__icontains=q) | Q(phone__icontains=q)
    )
    return Response(CustomerSerializer(qs, many=True).data)


@api_view(['GET'])
def customer_detail(request, cust_id):
    """GET /customers/<id>."""
    try:
        customer = Customer.objects.get(pk=cust_id)
        return Response(CustomerSerializer(customer).data)
    except Customer.DoesNotExist:
        return Response({'message': 'Customer tidak ditemukan'},
                        status=status.HTTP_404_NOT_FOUND)


@api_view(['PUT'])
def customer_visit(request, cust_id):
    """PUT /customers/<id>/visit — update is_visited."""
    if 'is_visited' not in request.data:
        return Response({'message': 'Field is_visited wajib diisi'},
                        status=status.HTTP_400_BAD_REQUEST)
    try:
        customer = Customer.objects.get(pk=cust_id)
        customer.is_visited = bool(request.data['is_visited'])
        customer.save()
        return Response({'message': 'Status kunjungan berhasil diperbarui'})
    except Customer.DoesNotExist:
        return Response({'message': 'Customer tidak ditemukan'},
                        status=status.HTTP_404_NOT_FOUND)


@api_view(['GET'])
def customer_total_visited(request):
    """GET /customers/stats/total-visited."""
    count = Customer.objects.filter(is_visited=True).count()
    return Response({'count': count})


# ══════════════════════════════════════════════════════════════════════════════
# PRODUCTS
# ══════════════════════════════════════════════════════════════════════════════

@api_view(['GET'])
def product_list(request):
    """GET /products  (optional ?category=xxx)."""
    category = request.query_params.get('category', '').strip()
    qs = Product.objects.all()
    if category and category.lower() != 'semua':
        qs = qs.filter(category=category)
    return Response(ProductSerializer(qs, many=True).data)


@api_view(['GET'])
def product_search(request):
    """GET /products/search?q=..."""
    q = request.query_params.get('q', '').strip()
    qs = Product.objects.filter(
        Q(name__icontains=q) | Q(category__icontains=q)
    )
    return Response(ProductSerializer(qs, many=True).data)


@api_view(['GET'])
def product_detail(request, product_id):
    """GET /products/<id>."""
    try:
        product = Product.objects.get(pk=product_id)
        return Response(ProductSerializer(product).data)
    except Product.DoesNotExist:
        return Response({'message': 'Produk tidak ditemukan'},
                        status=status.HTTP_404_NOT_FOUND)


@api_view(['GET'])
def product_categories(request):
    """GET /products/categories — daftar kategori unik."""
    cats = (Product.objects
            .values_list('category', flat=True)
            .distinct()
            .order_by('category'))
    return Response(list(cats))


# ══════════════════════════════════════════════════════════════════════════════
# ORDERS
# ══════════════════════════════════════════════════════════════════════════════

def _serialize_orders(qs):
    return OrderSerializer(qs, many=True).data


@api_view(['GET'])
def order_list(request):
    """GET /orders  (optional ?customer_id=xxx)."""
    cust_id = request.query_params.get('customer_id')
    qs = Order.objects.all()
    if cust_id:
        qs = qs.filter(customer_id=cust_id)
    return Response(_serialize_orders(qs))


@api_view(['POST'])
def order_create(request):
    """
    POST /orders
    Body: { "order": {...}, "items": [...] }
    """
    ser = OrderWriteSerializer(data=request.data)
    if not ser.is_valid():
        return Response({'message': str(ser.errors)},
                        status=status.HTTP_400_BAD_REQUEST)

    vdata = ser.validated_data
    order_data = vdata['order']
    items_data = vdata['items']

    if not items_data:
        return Response({'message': 'Order harus memiliki minimal 1 item'},
                        status=status.HTTP_400_BAD_REQUEST)

    try:
        with transaction.atomic():
            order = Order.objects.create(
                customer_id   = order_data['customer_id'],
                customer_name = order_data['customer_name'],
                total_amount  = order_data['total_amount'],
                status        = order_data.get('status', 'draft'),
                notes         = order_data.get('notes'),
            )
            OrderItem.objects.bulk_create([
                OrderItem(
                    order        = order,
                    product_id   = item['product_id'],
                    product_name = item['product_name'],
                    price        = item['price'],
                    quantity     = item['quantity'],
                    unit         = item.get('unit', 'pcs'),
                )
                for item in items_data
            ])
        return Response({'id': order.id, 'message': 'Order berhasil dibuat'},
                        status=status.HTTP_201_CREATED)
    except Exception as e:
        return Response({'message': str(e)},
                        status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['GET'])
def order_today(request):
    """GET /orders/today."""
    today = datetime.date.today()
    qs = Order.objects.filter(created_at__date=today)
    return Response(_serialize_orders(qs))


@api_view(['GET'])
def order_detail(request, order_id):
    """GET /orders/<id>."""
    try:
        order = Order.objects.get(pk=order_id)
        return Response(OrderSerializer(order).data)
    except Order.DoesNotExist:
        return Response({'message': 'Order tidak ditemukan'},
                        status=status.HTTP_404_NOT_FOUND)


@api_view(['GET'])
def order_items(request, order_id):
    """GET /orders/<id>/items."""
    items = OrderItem.objects.filter(order_id=order_id)
    return Response(OrderItemSerializer(items, many=True).data)


@api_view(['PUT'])
def order_status(request, order_id):
    """PUT /orders/<id>/status  body: { "status": "draft|sent|done" }."""
    valid = ['draft', 'sent', 'done']
    new_status = request.data.get('status', '')
    if new_status not in valid:
        return Response({'message': f'Status tidak valid. Pilih: {valid}'},
                        status=status.HTTP_400_BAD_REQUEST)
    try:
        order = Order.objects.get(pk=order_id)
        order.status = new_status
        order.save()
        return Response({'message': 'Status order berhasil diperbarui'})
    except Order.DoesNotExist:
        return Response({'message': 'Order tidak ditemukan'},
                        status=status.HTTP_404_NOT_FOUND)


@api_view(['GET'])
def order_today_total(request):
    """GET /orders/stats/today-total."""
    today  = datetime.date.today()
    result = Order.objects.filter(created_at__date=today).aggregate(
        total=Sum('total_amount')
    )
    return Response({'total': float(result['total'] or 0)})


@api_view(['GET'])
def order_today_count(request):
    """GET /orders/stats/today-count."""
    today = datetime.date.today()
    count = Order.objects.filter(created_at__date=today).count()
    return Response({'count': count})
