#!/usr/bin/env python3
"""DummyJSON'dan gerçek ürün fotoğraflarıyla ~100 ürün yükler.

Kullanım:
  python3 API/docker/test/scripts/seed-from-dummyjson.py

Kaynak: https://dummyjson.com/products (demo amaçlı, ücretsiz)
"""

from __future__ import annotations

import importlib.util
import json
import os
import subprocess
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path

_SCRIPT_DIR = Path(__file__).resolve().parent
_spec = importlib.util.spec_from_file_location("tr_translate", _SCRIPT_DIR / "tr_translate.py")
_tr_mod = importlib.util.module_from_spec(_spec)
assert _spec.loader is not None
_spec.loader.exec_module(_tr_mod)
translate_to_tr = _tr_mod.translate_to_tr

API = "http://127.0.0.1:5082/api/v1"
DUMMYJSON = "https://dummyjson.com/products"
MYSQL_CONTAINER = "ecommerce-test-mysql-1"
MYSQL_USER = "ecommerce_app"
MYSQL_PASS = "change-me"
MYSQL_DB = "ecommerce"
ROOT = Path(__file__).resolve().parents[4]

SELLER_EMAIL = "seller@vbshop.local"
SELLER_PASSWORD = "DevSellerPass123!"
MAX_TOTAL = int(os.environ.get("MAX_PRODUCTS", "100"))
MAX_PER_CATEGORY = int(os.environ.get("MAX_PER_CATEGORY", "14"))
TRY_RATE = float(os.environ.get("TRY_RATE", "35"))

CATEGORIES = [
    ("cat_elektronik", "Elektronik", "elektronik", 1),
    ("cat_moda", "Moda", "moda", 2),
    ("cat_ev_yasam", "Ev & Yaşam", "ev-yasam", 3),
    ("cat_kozmetik", "Kozmetik", "kozmetik", 4),
    ("cat_supermarket", "Süpermarket", "supermarket", 5),
    ("cat_spor", "Spor & Outdoor", "spor", 6),
    ("cat_kitap", "Kitap & Hobi", "kitap", 7),
    ("cat_anne_bebek", "Anne & Bebek", "anne-bebek", 8),
]

DUMMY_TO_VB = {
    "smartphones": "cat_elektronik",
    "laptops": "cat_elektronik",
    "tablets": "cat_elektronik",
    "mobile-accessories": "cat_elektronik",
    "mens-shirts": "cat_moda",
    "mens-shoes": "cat_moda",
    "mens-watches": "cat_moda",
    "womens-dresses": "cat_moda",
    "womens-shoes": "cat_moda",
    "womens-bags": "cat_moda",
    "womens-watches": "cat_moda",
    "sunglasses": "cat_moda",
    "tops": "cat_moda",
    "furniture": "cat_ev_yasam",
    "home-decoration": "cat_ev_yasam",
    "kitchen-accessories": "cat_ev_yasam",
    "beauty": "cat_kozmetik",
    "fragrances": "cat_kozmetik",
    "skin-care": "cat_kozmetik",
    "groceries": "cat_supermarket",
    "sports-accessories": "cat_spor",
    "motorcycle": "cat_spor",
    "vehicle": "cat_spor",
}

UA = {"User-Agent": "VBShop-Seed/1.0"}


def log(msg: str) -> None:
    print(msg, flush=True)


def http_json(method: str, url: str, body: dict | None = None, token: str | None = None) -> dict:
    data = None if body is None else json.dumps(body).encode()
    req = urllib.request.Request(url, data=data, method=method, headers={**UA, "Content-Type": "application/json"})
    if token:
        req.add_header("Authorization", f"Bearer {token}")
    with urllib.request.urlopen(req, timeout=120) as resp:
        return json.load(resp)


def http_bytes(url: str) -> bytes:
    req = urllib.request.Request(url, headers=UA)
    with urllib.request.urlopen(req, timeout=120) as resp:
        return resp.read()


def mysql_exec(sql: str) -> None:
    subprocess.run(
        [
            "docker", "exec", MYSQL_CONTAINER, "mysql",
            f"-u{MYSQL_USER}", f"-p{MYSQL_PASS}", "--default-character-set=utf8mb4", MYSQL_DB, "-e", sql,
        ],
        check=True,
        capture_output=True,
        text=True,
    )


def clear_rate_limits() -> None:
    result = subprocess.run(
        ["docker", "exec", "ecommerce-test-redis-1", "redis-cli", "-a", "change-redis-me", "--no-auth-warning", "KEYS", "ecommerce:v1:ratelimit:*"],
        capture_output=True, text=True, check=False,
    )
    for key in result.stdout.splitlines():
        if key.strip():
            subprocess.run(
                ["docker", "exec", "ecommerce-test-redis-1", "redis-cli", "-a", "change-redis-me", "--no-auth-warning", "DEL", key.strip()],
                capture_output=True, check=False,
            )


def clear_catalog_cache() -> None:
    subprocess.run(
        ["docker", "exec", "ecommerce-test-redis-1", "redis-cli", "-a", "change-redis-me", "--no-auth-warning", "DEL", "catalog:categories:v1"],
        capture_output=True, check=False,
    )


def seed_categories() -> None:
    values = ",\n".join(
        f"('{cid}', '{name}', '{slug}', NULL, NULL, {order}, 1, UTC_TIMESTAMP(6), 0)"
        for cid, name, slug, order in CATEGORIES
    )
    mysql_exec(f"INSERT IGNORE INTO categories (id,name,slug,parent_category_id,icon_photo_id,sort_order,is_active,created_at_utc,version) VALUES {values};")


def wipe_products() -> None:
    log("→ Mevcut ürünler temizleniyor...")
    mysql_exec("""
SET FOREIGN_KEY_CHECKS=0;
DELETE FROM review_photos;
DELETE FROM reviews;
DELETE FROM cart_items;
DELETE FROM favorites;
DELETE FROM order_items;
DELETE FROM product_photos;
DELETE FROM products;
SET FOREIGN_KEY_CHECKS=1;
""")


def login() -> str:
    payload = http_json("POST", f"{API}/auth/login", {"email": SELLER_EMAIL, "password": SELLER_PASSWORD})
    if not payload.get("isSuccess"):
        raise RuntimeError(payload.get("message", "Giriş başarısız"))
    return payload["data"]["accessToken"]


class Session:
    def __init__(self) -> None:
        self.token = login()
        self.uploads = 0

    def refresh_if_needed(self) -> None:
        if self.uploads > 0 and self.uploads % 18 == 0:
            clear_rate_limits()
            time.sleep(2)
        if self.uploads > 0 and self.uploads % 35 == 0:
            log("  … token yenileniyor")
            self.token = login()

    def mark_upload(self) -> None:
        self.uploads += 1


def fetch_dummyjson_products() -> list[dict]:
    log("→ DummyJSON'dan ürünler çekiliyor...")
    payload = http_json("GET", f"{DUMMYJSON}?limit=200")
    items = payload.get("products", [])
    log(f"  ✓ {len(items)} ürün alındı")
    return items


def pick_products(dummy_items: list[dict]) -> list[dict]:
    """Kategori başına limit ile dengeli seçim."""
    buckets: dict[str, list[dict]] = {cid: [] for cid, *_ in CATEGORIES}
    for item in dummy_items:
        vb_cat = DUMMY_TO_VB.get(item.get("category", ""))
        if not vb_cat or len(buckets[vb_cat]) >= MAX_PER_CATEGORY:
            continue
        buckets[vb_cat].append(item)

    selected: list[dict] = []
    for vb_cat, items in buckets.items():
        for item in items:
            item["_vbCategoryId"] = vb_cat
            selected.append(item)
            if len(selected) >= MAX_TOTAL:
                break
        if len(selected) >= MAX_TOTAL:
            break

    return selected[:MAX_TOTAL]


def content_type_for(url: str, data: bytes) -> tuple[str, str]:
    if url.endswith(".webp") or data[:4] == b"RIFF":
        return "image/webp", "product.webp"
    if data[:3] == b"\xff\xd8\xff":
        return "image/jpeg", "product.jpg"
    return "image/png", "product.png"


def upload_photo(token: str, image_bytes: bytes, filename: str, content_type: str, retries: int = 4) -> str:
    boundary = "----VBShopDummyJSON"
    body = (
        f"--{boundary}\r\n"
        f'Content-Disposition: form-data; name="file"; filename="{filename}"\r\n'
        f"Content-Type: {content_type}\r\n\r\n"
    ).encode() + image_bytes + f"\r\n--{boundary}--\r\n".encode()

    for attempt in range(retries):
        req = urllib.request.Request(
            f"{API}/photos",
            data=body,
            method="POST",
            headers={
                "Content-Type": f"multipart/form-data; boundary={boundary}",
                "Authorization": f"Bearer {token}",
                **UA,
            },
        )
        try:
            with urllib.request.urlopen(req, timeout=120) as resp:
                payload = json.load(resp)
            if not payload.get("isSuccess"):
                raise RuntimeError(str(payload))
            return payload["data"]["photoId"]
        except urllib.error.HTTPError as err:
            if err.code == 429 and attempt < retries - 1:
                wait = 20 * (attempt + 1)
                log(f"    … rate limit, {wait}s bekleniyor")
                time.sleep(wait)
                continue
            raise
    raise RuntimeError("upload failed")


def try_price(item: dict) -> float:
    if item.get("_mobile"):
        return float(item["price"])
    usd = float(item.get("price") or 1)
    return max(10.0, round(usd * TRY_RATE, 2))


def create_product(session: Session, item: dict) -> str:
    session.refresh_if_needed()
    image_url = item.get("thumbnail") or (item.get("images") or [None])[0]
    if not image_url:
        raise RuntimeError("görsel yok")

    image_bytes = http_bytes(image_url)
    content_type, filename = content_type_for(image_url, image_bytes)
    photo_id = upload_photo(session.token, image_bytes, filename, content_type)
    session.mark_upload()

    brand = item.get("brand") or "VBShop"
    features = {"Marka": str(brand)}
    if item.get("sku"):
        features["SKU"] = str(item["sku"])

    tr_title = translate_to_tr(item["title"])
    tr_desc = translate_to_tr(item.get("description") or item["title"])
    time.sleep(0.3)

    body = {
        "title": tr_title[:240],
        "description": tr_desc[:5000],
        "price": try_price(item),
        "stock": max(1, int(item.get("stock") or 10)),
        "categoryId": item["_vbCategoryId"],
        "photoIds": [photo_id],
        "features": features,
        "isActive": True,
    }
    try:
        result = http_json("POST", f"{API}/seller/products", body, token=session.token)
    except urllib.error.HTTPError as err:
        if err.code == 401:
            session.token = login()
            result = http_json("POST", f"{API}/seller/products", body, token=session.token)
        else:
            raise
    if not result.get("isSuccess"):
        raise RuntimeError(str(result))
    return tr_title


def main() -> int:
    try:
        urllib.request.urlopen(f"{API.replace('/api/v1', '')}/health/ready", timeout=5)
    except Exception as exc:  # noqa: BLE001
        log(f"API hazır değil: {exc}")
        return 1

    seed_categories()
    wipe_products()
    clear_rate_limits()
    clear_catalog_cache()

    token = login()
    session = Session()
    session.token = token
    products = pick_products(fetch_dummyjson_products())
    log(f"→ {len(products)} ürün yüklenecek...")

    ok = 0
    fail = 0
    for i, item in enumerate(products, 1):
        try:
            tr_title = create_product(session, item)
            ok += 1
            log(f"  ✓ [{ok}] {tr_title[:60]}")
            time.sleep(2.5)
        except Exception as exc:  # noqa: BLE001
            fail += 1
            log(f"  ! [{i}] {item.get('title', '?')[:50]}: {exc}")
            time.sleep(3)

    clear_catalog_cache()
    log(f"\nTamamlandı: {ok} ürün yüklendi, {fail} hata.")
    log("Web: http://localhost:3000/products")
    return 0 if ok > 0 else 1


if __name__ == "__main__":
    sys.exit(main())
