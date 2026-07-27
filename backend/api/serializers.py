from rest_framework import serializers
from .models import AccountUas, Customer, Product, Order, OrderItem


# ─── Account ──────────────────────────────────────────────────────────────────

class AccountSerializer(serializers.ModelSerializer):
    class Meta:
        model  = AccountUas
        fields = ['id', 'username', 'email', 'full_name', 'role']
        # password TIDAK disertakan di response (keamanan)


class AccountWriteSerializer(serializers.ModelSerializer):
    """Untuk register — menerima password dari request."""
    class Meta:
        model  = AccountUas
        fields = ['id', 'username', 'email', 'password', 'full_name', 'role']
        extra_kwargs = {'password': {'write_only': True}}


# ─── Customer ─────────────────────────────────────────────────────────────────

class CustomerSerializer(serializers.ModelSerializer):
    class Meta:
        model  = Customer
        fields = ['id', 'name', 'address', 'phone', 'is_visited', 'notes']


# ─── Product ──────────────────────────────────────────────────────────────────

class ProductSerializer(serializers.ModelSerializer):
    price = serializers.FloatField()   # Kirim sebagai float, bukan string Decimal

    class Meta:
        model  = Product
        fields = ['id', 'name', 'category', 'price', 'stock', 'unit', 'description']


# ─── Order Item ───────────────────────────────────────────────────────────────

class OrderItemSerializer(serializers.ModelSerializer):
    price = serializers.FloatField()

    class Meta:
        model  = OrderItem
        fields = ['id', 'order_id', 'product_id', 'product_name', 'price',
                  'quantity', 'unit']


class OrderItemWriteSerializer(serializers.Serializer):
    """Untuk menerima item saat create order (tidak perlu order_id dulu)."""
    product_id   = serializers.IntegerField()
    product_name = serializers.CharField(max_length=100)
    price        = serializers.FloatField()
    quantity     = serializers.IntegerField(min_value=1)
    unit         = serializers.CharField(max_length=20, default='pcs')


# ─── Order ────────────────────────────────────────────────────────────────────

class OrderSerializer(serializers.ModelSerializer):
    total_amount = serializers.FloatField()
    created_at   = serializers.DateTimeField(format='%Y-%m-%dT%H:%M:%S')

    class Meta:
        model  = Order
        fields = ['id', 'customer_id', 'customer_name', 'total_amount',
                  'status', 'notes', 'created_at']


class OrderWriteSerializer(serializers.Serializer):
    """Untuk create order — menerima nested order + items."""

    class _OrderBodySerializer(serializers.Serializer):
        customer_id   = serializers.IntegerField()
        customer_name = serializers.CharField(max_length=100)
        total_amount  = serializers.FloatField()
        status        = serializers.ChoiceField(
            choices=['draft', 'sent', 'done'], default='draft'
        )
        notes         = serializers.CharField(allow_blank=True, allow_null=True,
                                              required=False)

    order = _OrderBodySerializer()
    items = OrderItemWriteSerializer(many=True)
