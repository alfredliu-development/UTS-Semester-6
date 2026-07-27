"""
Django settings — Sales Take Order Backend
Database: MySQL XAMPP  (host=localhost, user=root, password='', db=uas)
"""

from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent

SECRET_KEY = 'django-sales-take-order-secret-key-2024'

DEBUG = True

# Allow Android emulator, physical device (LAN), and localhost
ALLOWED_HOSTS = ['*']

# ─── Installed Apps ───────────────────────────────────────────────────────────
INSTALLED_APPS = [
    'django.contrib.contenttypes',
    'django.contrib.auth',            # dibutuhkan DRF
    'django.contrib.staticfiles',
    'rest_framework',
    'corsheaders',
    'api',
]

# ─── Middleware ───────────────────────────────────────────────────────────────
MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',          # CORS — must be first
    'django.middleware.common.CommonMiddleware',
]

# ─── CORS ─────────────────────────────────────────────────────────────────────
CORS_ALLOW_ALL_ORIGINS = True                         # Allow Flutter dari mana saja

# ─── URL ──────────────────────────────────────────────────────────────────────
ROOT_URLCONF = 'config.urls'

# ─── Database: MySQL XAMPP ────────────────────────────────────────────────────
DATABASES = {
    'default': {
        'ENGINE':   'django.db.backends.mysql',
        'NAME':     'uas',
        'USER':     'root',
        'PASSWORD': '',
        'HOST':     'localhost',
        'PORT':     '3306',
        'OPTIONS': {
            'charset': 'utf8mb4',
            'init_command': "SET sql_mode='STRICT_TRANS_TABLES'",
        },
    }
}

# ─── DRF ──────────────────────────────────────────────────────────────────────
REST_FRAMEWORK = {
    'DEFAULT_RENDERER_CLASSES': [
        'rest_framework.renderers.JSONRenderer',
    ],
    'DEFAULT_PARSER_CLASSES': [
        'rest_framework.parsers.JSONParser',
    ],
    # Nonaktifkan autentikasi default DRF — API ini pakai custom auth
    'DEFAULT_AUTHENTICATION_CLASSES': [],
    'DEFAULT_PERMISSION_CLASSES': [],
}

# ─── i18n ─────────────────────────────────────────────────────────────────────
LANGUAGE_CODE = 'id-id'
TIME_ZONE = 'Asia/Jakarta'
USE_I18N = False
USE_TZ = False                 # Simpan datetime tanpa timezone ke MySQL

# ─── Static ───────────────────────────────────────────────────────────────────
STATIC_URL = '/static/'

DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'
