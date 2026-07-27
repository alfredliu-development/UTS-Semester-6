from django.urls import path
from . import views

urlpatterns = [

    # ── Health ──────────────────────────────────────────────────────────────
    path('health', views.health_check),

    # ── Auth ────────────────────────────────────────────────────────────────
    path('account_uas/login',           views.login),
    path('account_uas/register',        views.register),
    path('account_uas/<int:user_id>',   views.user_detail),

    # ── Customers ───────────────────────────────────────────────────────────
    # PENTING: route static (search, stats) harus di atas route dinamis (<id>)
    path('customers/search',                    views.customer_search),
    path('customers/stats/total-visited',       views.customer_total_visited),
    path('customers/<int:cust_id>/visit',        views.customer_visit),
    path('customers/<int:cust_id>',              views.customer_detail),
    path('customers',                            views.customer_list),

    # ── Products ────────────────────────────────────────────────────────────
    path('products/search',                      views.product_search),
    path('products/categories',                  views.product_categories),
    path('products/<int:product_id>',            views.product_detail),
    path('products',                             views.product_list),

    # ── Orders ──────────────────────────────────────────────────────────────
    path('orders/today',                         views.order_today),
    path('orders/stats/today-total',             views.order_today_total),
    path('orders/stats/today-count',             views.order_today_count),
    path('orders/<int:order_id>/items',          views.order_items),
    path('orders/<int:order_id>/status',         views.order_status),
    path('orders/<int:order_id>',                views.order_detail),
    path('orders',                               views.order_list),
]
