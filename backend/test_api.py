"""Test semua endpoint Django backend."""
import urllib.request
import urllib.error
import json

BASE = "http://localhost:8080"
ok = 0
fail = 0


def get(path):
    try:
        with urllib.request.urlopen(BASE + path) as r:
            return r.status, json.loads(r.read())
    except urllib.error.HTTPError as e:
        return e.code, {}


def post(path, body):
    data = json.dumps(body).encode()
    req = urllib.request.Request(
        BASE + path, data=data,
        headers={"Content-Type": "application/json"}, method="POST"
    )
    try:
        with urllib.request.urlopen(req) as r:
            return r.status, json.loads(r.read())
    except urllib.error.HTTPError as e:
        return e.code, {}


def check(label, s, data, expect=200, key=None):
    global ok, fail
    passed = (s == expect) and (key is None or key in data)
    symbol = "OK" if passed else "FAIL"
    val = ""
    if not passed:
        val = str(data)[:60]
    print(f"  [{symbol}] [{s}] {label}  {val}")
    if passed:
        ok += 1
    else:
        fail += 1


print("=" * 50)
print("  TEST DJANGO BACKEND")
print("=" * 50)

s, d = get("/health")
check("GET /health", s, d, 200, "status")

s, d = get("/customers")
check("GET /customers", s, d, 200)

s, d = get("/customers/search?q=Toko")
check("GET /customers/search", s, d, 200)

s, d = get("/customers/stats/total-visited")
check("GET /customers/stats/total-visited", s, d, 200, "count")

s, d = get("/customers/1")
check("GET /customers/1", s, d, 200, "name")

s, d = get("/products")
check("GET /products", s, d, 200)

s, d = get("/products/search?q=Indomie")
check("GET /products/search", s, d, 200)

s, d = get("/products/categories")
check("GET /products/categories", s, d, 200)

s, d = get("/products/1")
check("GET /products/1", s, d, 200, "name")

s, d = get("/orders")
check("GET /orders", s, d, 200)

s, d = get("/orders/today")
check("GET /orders/today", s, d, 200)

s, d = get("/orders/stats/today-total")
check("GET /orders/stats/today-total", s, d, 200, "total")

s, d = get("/orders/stats/today-count")
check("GET /orders/stats/today-count", s, d, 200, "count")

s, d = get("/orders/1")
check("GET /orders/1", s, d, 200, "id")

s, d = get("/orders/1/items")
check("GET /orders/1/items", s, d, 200)

s, d = post("/account_uas/login", {
    "username": "sales01",
    "password": "ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f"
})
check("POST /account_uas/login", s, d, 200, "id")

s, d = get("/account_uas/1")
check("GET /account_uas/1", s, d, 200, "username")

print("=" * 50)
print(f"  PASSED: {ok}  FAILED: {fail}  TOTAL: {ok + fail}")
print("=" * 50)
