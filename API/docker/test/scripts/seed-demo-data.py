#!/usr/bin/env python3
"""VBShop demo verisi: kategoriler + satıcı kaydı + ürünler.

Kullanım:
  python3 API/docker/test/scripts/seed-demo-data.py

Gereksinimler: docker stack ayakta (API :5082, Mailpit :8026, MySQL konteyneri).
"""

from __future__ import annotations

import base64
import json
import re
import subprocess
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path

API = "http://127.0.0.1:5082/api/v1"
MAILPIT = "http://127.0.0.1:8026/api/v1"
MYSQL_CONTAINER = "ecommerce-test-mysql-1"
MYSQL_USER = "ecommerce_app"
MYSQL_PASS = "change-me"
MYSQL_DB = "ecommerce"

ROOT = Path(__file__).resolve().parents[4]
PRODUCTS_JSON = ROOT / "Mobile" / "assets" / "data" / "products.json"

SELLER = {
    "email": "seller@vbshop.local",
    "password": "DevSellerPass123!",
    "passwordConfirm": "DevSellerPass123!",
    "firstName": "VBShop",
    "lastName": "Satıcı",
    "phoneNumber": "+905551112233",
    "storeName": "VBShop Mağaza",
    "taxNumber": "1234567890",
    "taxOffice": "Kadıköy",
}

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

MOBILE_TO_API_CATEGORY = {
    "elektronik": "cat_elektronik",
    "moda": "cat_moda",
    "ev-yasam": "cat_ev_yasam",
    "kozmetik": "cat_kozmetik",
    "supermarket": "cat_supermarket",
    "spor": "cat_spor",
    "kitap": "cat_kitap",
    "anne-bebek": "cat_anne_bebek",
}


def placeholder_jpeg() -> bytes:
    return base64.b64decode(
        "/9j/4AAQSkZJRgABAQEASABIAAD/2wBDAP//////////////////////////////////////////////////////////////////////////////////////2wBDAf//////////////////////////////////////////////////////////////////////////////////////wAARCAABAAEDASIAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAX/xAAUEAEAAAAAAAAAAAAAAAAAAAAA/8QAFQEBAQAAAAAAAAAAAAAAAAAAAAX/xAAUEQEAAAAAAAAAAAAAAAAAAAAA/9oADAMBAAIRAxEAPwCwAA//2Q=="
    )


def download_image(url: str) -> bytes:
    try:
        return http_bytes(url)
    except urllib.error.HTTPError as err:
        if err.code == 429:
            time.sleep(1.5)
            try:
                return http_bytes(url)
            except Exception:  # noqa: BLE001
                return placeholder_jpeg()
        return placeholder_jpeg()
    except Exception:  # noqa: BLE001
        return placeholder_jpeg()


def list_existing_titles(token: str) -> set[str]:
    titles: set[str] = set()
    page = 1
    while True:
        req = urllib.request.Request(
            f"{API}/seller/products?page={page}&size=50",
            headers={"Authorization": f"Bearer {token}"},
        )
        with urllib.request.urlopen(req, timeout=30) as resp:
            payload = json.load(resp)
        items = payload.get("data", {}).get("page", {}).get("items", [])
        if not items and isinstance(payload.get("data"), dict):
            items = payload["data"].get("items", [])
        if not items:
            break
        for item in items:
            product = item.get("product", item)
            title = product.get("title")
            if title:
                titles.add(title)
        total_pages = (
            payload.get("data", {})
            .get("page", payload.get("data", {}))
            .get("totalPages", page)
        )
        if page >= total_pages:
            break
        page += 1
    return titles


def log(msg: str) -> None:
    print(msg, flush=True)


def http_json(method: str, url: str, body: dict | None = None, token: str | None = None) -> dict:
    data = None if body is None else json.dumps(body).encode()
    req = urllib.request.Request(url, data=data, method=method)
    req.add_header("Content-Type", "application/json")
    if token:
        req.add_header("Authorization", f"Bearer {token}")
    with urllib.request.urlopen(req, timeout=60) as resp:
        return json.load(resp)


def http_bytes(url: str) -> bytes:
    with urllib.request.urlopen(url, timeout=60) as resp:
        return resp.read()


def upload_photo(token: str, image_bytes: bytes, filename: str = "product.jpg") -> str:
    boundary = "----VBShopSeedBoundary7MA4YWxk"
    body = (
        f"--{boundary}\r\n"
        f'Content-Disposition: form-data; name="file"; filename="{filename}"\r\n'
        f"Content-Type: image/jpeg\r\n\r\n"
    ).encode() + image_bytes + f"\r\n--{boundary}--\r\n".encode()

    req = urllib.request.Request(
        f"{API}/photos",
        data=body,
        method="POST",
        headers={
            "Content-Type": f"multipart/form-data; boundary={boundary}",
            "Authorization": f"Bearer {token}",
        },
    )
    with urllib.request.urlopen(req, timeout=120) as resp:
        payload = json.load(resp)
    if not payload.get("isSuccess"):
        raise RuntimeError(f"Photo upload failed: {payload}")
    return payload["data"]["photoId"]


def seed_categories() -> None:
    log("→ Kategoriler ekleniyor...")
    values = ",\n".join(
        f"('{cid}', '{name}', '{slug}', NULL, NULL, {sort_order}, 1, UTC_TIMESTAMP(6), 0)"
        for cid, name, slug, sort_order in CATEGORIES
    )
    sql = f"""
INSERT IGNORE INTO categories
  (id, name, slug, parent_category_id, icon_photo_id, sort_order, is_active, created_at_utc, version)
VALUES
{values};
"""
    subprocess.run(
        [
            "docker",
            "exec",
            MYSQL_CONTAINER,
            "mysql",
            f"-u{MYSQL_USER}",
            f"-p{MYSQL_PASS}",
            "--default-character-set=utf8mb4",
            MYSQL_DB,
            "-e",
            sql,
        ],
        check=True,
        capture_output=True,
        text=True,
    )
    log(f"  ✓ {len(CATEGORIES)} kategori hazır")
    subprocess.run(
        [
            "docker", "exec", "ecommerce-test-redis-1",
            "redis-cli", "-a", "change-redis-me", "--no-auth-warning",
            "DEL", "catalog:categories:v1",
        ],
        capture_output=True,
    )


def wait_otp(email: str, timeout_sec: int = 45) -> str:
    log("→ Mailpit'ten OTP bekleniyor...")
    deadline = time.time() + timeout_sec
    while time.time() < deadline:
        with urllib.request.urlopen(f"{MAILPIT}/messages", timeout=10) as resp:
            messages = json.load(resp).get("messages", [])
        for msg in messages:
            if email.lower() not in msg.get("To", [{}])[0].get("Address", "").lower():
                continue
            msg_id = msg["ID"]
            with urllib.request.urlopen(f"{MAILPIT}/message/{msg_id}", timeout=10) as resp:
                detail = json.load(resp)
            text = detail.get("Text", "") + detail.get("HTML", "")
            match = re.search(r"\b(\d{6})\b", text)
            if match:
                log(f"  ✓ OTP alındı: {match.group(1)}")
                return match.group(1)
        time.sleep(2)
    raise TimeoutError("OTP e-postası zaman aşımına uğradı. Mailpit'i kontrol edin.")


def register_and_verify_seller() -> str:
    log("→ Satıcı kaydı oluşturuluyor...")
    try:
        reg = http_json("POST", f"{API}/auth/seller/register", SELLER)
    except urllib.error.HTTPError as err:
        if err.code == 409:
            log("  • Satıcı e-postası zaten kayıtlı, giriş deneniyor...")
            login = http_json(
                "POST",
                f"{API}/auth/login",
                {"email": SELLER["email"], "password": SELLER["password"]},
            )
            if login.get("isSuccess"):
                return login["data"]["accessToken"]
        raise

    if not reg.get("isSuccess"):
        raise RuntimeError(f"Seller register failed: {reg}")

    session_id = reg["data"]["sessionId"]
    code = wait_otp(SELLER["email"])

    verify = http_json(
        "POST",
        f"{API}/auth/email/verify",
        {"sessionId": session_id, "code": code},
    )
    if not verify.get("isSuccess"):
        raise RuntimeError(f"Email verify failed: {verify}")

    log("  ✓ Satıcı doğrulandı ve giriş yapıldı")
    return verify["data"]["accessToken"]


def seed_products(token: str) -> None:
    products = json.loads(PRODUCTS_JSON.read_text(encoding="utf-8"))
    existing = list_existing_titles(token)
    pending = [p for p in products if p["name"] not in existing]
    log(f"→ {len(pending)} ürün yükleniyor ({len(existing)} zaten var)...")

    created = 0
    skipped = 0
    for item in pending:
        category_id = MOBILE_TO_API_CATEGORY.get(item["categoryId"])
        if not category_id:
            log(f"  ! Atlandı (kategori yok): {item['name']}")
            skipped += 1
            continue

        image_url = item["images"][0]
        try:
            image_bytes = download_image(image_url)
            photo_id = upload_photo(token, image_bytes, f"{item['id']}.jpg")
            time.sleep(0.5)
        except Exception as exc:  # noqa: BLE001
            log(f"  ! Fotoğraf yüklenemedi ({item['name']}): {exc}")
            skipped += 1
            continue

        body = {
            "title": item["name"],
            "description": item["description"],
            "price": float(item["price"]),
            "stock": int(item["stock"]),
            "categoryId": category_id,
            "photoIds": [photo_id],
            "features": {"Marka": item.get("brand", "VBShop")},
            "isActive": True,
        }

        try:
            result = http_json("POST", f"{API}/seller/products", body, token=token)
        except urllib.error.HTTPError as err:
            detail = err.read().decode()
            log(f"  ! Ürün oluşturulamadı ({item['name']}): {detail}")
            skipped += 1
            continue

        if not result.get("isSuccess"):
            log(f"  ! Ürün oluşturulamadı ({item['name']}): {result}")
            skipped += 1
            continue

        created += 1
        log(f"  ✓ [{created}] {item['name']}")

    log(f"\nTamamlandı: {created} ürün oluşturuldu, {skipped} atlandı.")


def main() -> int:
    if not PRODUCTS_JSON.exists():
        log(f"Ürün dosyası bulunamadı: {PRODUCTS_JSON}")
        return 1

    try:
        health = urllib.request.urlopen(f"{API.replace('/api/v1', '')}/health/ready", timeout=5)
        if health.status != 200:
            raise RuntimeError("API hazır değil")
    except Exception as exc:  # noqa: BLE001
        log(f"API erişilemiyor ({API}): {exc}")
        return 1

    seed_categories()
    token = register_and_verify_seller()
    seed_products(token)

    log("\n--- Satıcı giriş bilgileri ---")
    log(f"E-posta : {SELLER['email']}")
    log(f"Parola  : {SELLER['password']}")
    log("Panel   : http://localhost:3000/seller")
    return 0


if __name__ == "__main__":
    sys.exit(main())
