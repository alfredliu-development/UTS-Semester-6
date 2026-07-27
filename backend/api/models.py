from django.db import models


class AccountUas(models.Model):
    """Tabel: account_uas — akun sales/admin."""
    username  = models.CharField(max_length=50, unique=True)
    email     = models.CharField(max_length=100)
    password  = models.CharField(max_length=255)   # SHA-256 hash dari Flutter
    full_name = models.CharField(max_length=100)
    role      = models.CharField(max_length=20, default='sales')

    class Meta:
        db_table = 'account_uas'

    def __str__(self):
        return self.username


class Customer(models.Model):
    """Tabel: customers."""
    name       = models.CharField(max_length=100)
    address    = models.TextField()
    phone      = models.CharField(max_length=20)
    is_visited = models.BooleanField(default=False)
    notes      = models.TextField(null=True, blank=True)

    class Meta:
        db_table = 'customers'
        ordering = ['name']

    def __str__(self):
        return self.name


class Product(models.Model):
    """Tabel: products."""
    name        = models.CharField(max_length=100)
    category    = models.CharField(max_length=50)
    price       = models.DecimalField(max_digits=10, decimal_places=2)
    stock       = models.IntegerField()
    unit        = models.CharField(max_length=20, default='pcs')
    description = models.TextField(null=True, blank=True)

    class Meta:
        db_table = 'products'
        ordering = ['name']

    def __str__(self):
        return self.name


class Order(models.Model):
    """Tabel: orders."""
    STATUS_CHOICES = [
        ('draft', 'Draft'),
        ('sent',  'Terkirim'),
        ('done',  'Selesai'),
    ]

    customer    = models.ForeignKey(Customer, on_delete=models.RESTRICT,
                                    db_column='customer_id')
    customer_name = models.CharField(max_length=100)
    total_amount  = models.DecimalField(max_digits=10, decimal_places=2)
    status        = models.CharField(max_length=20, choices=STATUS_CHOICES,
                                     default='draft')
    notes         = models.TextField(null=True, blank=True)
    created_at    = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'orders'
        ordering = ['-created_at']

    def __str__(self):
        return f'Order #{self.id} — {self.customer_name}'


class OrderItem(models.Model):
    """Tabel: order_items."""
    order        = models.ForeignKey(Order, on_delete=models.CASCADE,
                                     related_name='items', db_column='order_id')
    product      = models.ForeignKey(Product, on_delete=models.RESTRICT,
                                     db_column='product_id')
    product_name = models.CharField(max_length=100)
    price        = models.DecimalField(max_digits=10, decimal_places=2)
    quantity     = models.IntegerField()
    unit         = models.CharField(max_length=20, default='pcs')

    class Meta:
        db_table = 'order_items'

    def __str__(self):
        return f'{self.product_name} x{self.quantity}'
