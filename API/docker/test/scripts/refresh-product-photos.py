#!/usr/bin/env python3
"""Tüm ürün fotoğraflarını kategoriye uygun Unsplash görselleriyle günceller."""

from __future__ import annotations

import json
import os
import subprocess
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path

API = "http://127.0.0.1:5082/api/v1"
ROOT = Path(__file__).resolve().parents[4]
PRODUCTS_JSON = ROOT / "Mobile" / "assets" / "data" / "products.json"

SELLER_EMAIL = "seller@vbshop.local"
SELLER_PASSWORD = "DevSellerPass123!"

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

# Ürün id → kategoriye uygun Unsplash görseli (600x600 crop)
PRODUCT_IMAGES: dict[str, str] = {
    "p01": "https://images.unsplash.com/photo-1511707171634-5f897ff02aa4?w=600&h=600&fit=crop",
    "p02": "https://images.unsplash.com/photo-1610945265064-0e34e5519bbf?w=600&h=600&fit=crop",
    "p03": "https://images.unsplash.com/photo-1496181133106-5bcef4bb4fe9?w=600&h=600&fit=crop",
    "p04": "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=600&h=600&fit=crop",
    "p05": "https://images.unsplash.com/photo-1598327275664-5b8174bbeff1?w=600&h=600&fit=crop",
    "p06": "https://images.unsplash.com/photo-1593359679098-018ecc36902f?w=600&h=600&fit=crop",
    "p07": "https://images.unsplash.com/photo-1606220945770-b5b6c2c55bf1?w=600&h=600&fit=crop",
    "p08": "https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=600&h=600&fit=crop",
    "p09": "https://images.unsplash.com/photo-1542272604-787c3835535d?w=600&h=600&fit=crop",
    "p10": "https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600&h=600&fit=crop",
    "p11": "https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=600&h=600&fit=crop",
    "p12": "https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=600&h=600&fit=crop",
    "p13": "https://images.unsplash.com/photo-1558317838-0b9bba6841a6?w=600&h=600&fit=crop",
    "p14": "https://images.unsplash.com/photo-1631049302634-4110f1b76969?w=600&h=600&fit=crop",
    "p15": "https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=600&h=600&fit=crop",
    "p16": "https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=600&h=600&fit=crop",
    "p17": "https://images.unsplash.com/photo-1541643600914-78b084683601?w=600&h=600&fit=crop",
    "p18": "https://images.unsplash.com/photo-1556228578-0d235b4a4dff?w=600&h=600&fit=crop",
    "p19": "https://images.unsplash.com/photo-1447933601403-0c6688de566e?w=600&h=600&fit=crop",
    "p20": "https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=600&h=600&fit=crop",
    "p21": "https://images.unsplash.com/photo-1606313564200-e75d5e30476c?w=600&h=600&fit=crop",
    "p22": "https://images.unsplash.com/photo-1576678927484-cc907957088c?w=600&h=600&fit=crop",
    "p23": "https://images.unsplash.com/photo-1601925260368-ae2f83cf8b7f?w=600&h=600&fit=crop",
    "p24": "https://images.unsplash.com/photo-1478131143081-80f7f84b84e7?w=600&h=600&fit=crop",
    "p25": "https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=600&h=600&fit=crop",
    "p26": "https://images.unsplash.com/photo-1512820790803-83ca734da794?w=600&h=600&fit=crop",
    "p27": "https://images.unsplash.com/photo-1587731554731-1dff8998cd5c?w=600&h=600&fit=crop",
    "p28": "https://images.unsplash.com/photo-1515488042361-ee00e926ddd0?w=600&h=600&fit=crop",
    "p29": "https://images.unsplash.com/photo-1584464491033-06628f3a6b7b?w=600&h=600&fit=crop",
    "p30": "https://images.unsplash.com/photo-151548876427-f376ba17606a?w=600&h=600&fit=crop",
}


def log(msg: str) -> None:
    print(msg, flush=True)


def http_json(method: str, url: str, body: dict | None = None, token: str | None = None) -> dict:
    data = None if body is None else json.dumps(body).encode()
    req = urllib.request.Request(url, data=data, method=method)
    req.add_header("Content-Type", "application/json")
    if token:
        req.add_header("Authorization", f"Bearer {token}")
    with urllib.request.urlopen(req, timeout=120) as resp:
        return json.load(resp)


def login() -> str:
    payload = http_json(
        "POST",
        f"{API}/auth/login",
        {"email": SELLER_EMAIL, "password": SELLER_PASSWORD},
    )
    if not payload.get("isSuccess"):
        raise RuntimeError(f"Giriş başarısız: {payload.get('message')}")
    return payload["data"]["accessToken"]


def clear_upload_rate_limit() -> None:
    subprocess.run(
        [
            "docker", "exec", "ecommerce-test-redis-1",
            "redis-cli", "-a", "change-redis-me", "--no-auth-warning",
            "KEYS", "ecommerce:v1:ratelimit:upload:*",
        ],
        capture_output=True,
        text=True,
        check=False,
    )
    result = subprocess.run(
        [
            "docker", "exec", "ecommerce-test-redis-1",
            "redis-cli", "-a", "change-redis-me", "--no-auth-warning",
            "KEYS", "ecommerce:v1:ratelimit:upload:*",
        ],
        capture_output=True,
        text=True,
        check=False,
    )
    for key in result.stdout.splitlines():
        if key.strip():
            subprocess.run(
                [
                    "docker", "exec", "ecommerce-test-redis-1",
                    "redis-cli", "-a", "change-redis-me", "--no-auth-warning",
                    "DEL", key.strip(),
                ],
                capture_output=True,
            )


def upload_photo(token: str, image_bytes: bytes, filename: str, retries: int = 3) -> str:
    boundary = "----VBShopPhotoRefresh"
    body = (
        f"--{boundary}\r\n"
        f'Content-Disposition: form-data; name="file"; filename="{filename}"\r\n'
        f"Content-Type: image/jpeg\r\n\r\n"
    ).encode() + image_bytes + f"\r\n--{boundary}--\r\n".encode()

    for attempt in range(retries):
        req = urllib.request.Request(
            f"{API}/photos",
            data=body,
            method="POST",
            headers={
                "Content-Type": f"multipart/form-data; boundary={boundary}",
                "Authorization": f"Bearer {token}",
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
                time.sleep(15 * (attempt + 1))
                continue
            raise
    raise RuntimeError("upload failed")


def download(url: str, seed: str) -> bytes:
    req = urllib.request.Request(url, headers={"User-Agent": "VBShop-Seed/1.0"})
    try:
        with urllib.request.urlopen(req, timeout=120) as resp:
            return resp.read()
    except urllib.error.HTTPError as err:
        if err.code in (404, 403, 429):
            fallback = f"https://picsum.photos/seed/vbshop-{seed}/600/600"
            time.sleep(1)
            with urllib.request.urlopen(
                urllib.request.Request(fallback, headers={"User-Agent": "VBShop-Seed/1.0"}),
                timeout=120,
            ) as resp:
                return resp.read()
        raise


def list_seller_products(token: str) -> list[dict]:
    items: list[dict] = []
    page = 1
    while True:
        payload = http_json("GET", f"{API}/seller/products?page={page}&size=50", token=token)
        data = payload["data"]
        page_data = data.get("page", data)
        batch = page_data.get("items", [])
        for row in batch:
            product = row.get("product", row)
            items.append(product)
        total_pages = page_data.get("totalPages", page)
        if page >= total_pages:
            break
        page += 1
    return items


def get_product_detail(token: str, product_id: str) -> dict:
    payload = http_json("GET", f"{API}/seller/products/{product_id}", token=token)
    return payload["data"]


def main() -> int:
    mock_products = json.loads(PRODUCTS_JSON.read_text(encoding="utf-8"))
    by_title = {p["name"]: p for p in mock_products}

    log("→ Satıcı girişi...")
    if os.environ.get("TARGET_IDS"):
        log("→ Hedef mod: yalnızca eksik ürünler")
        time.sleep(30)
    token = login()

    api_products = list_seller_products(token)
    log(f"→ {len(api_products)} ürünün fotoğrafları güncelleniyor...")

    updated = 0
    target_ids = {x.strip() for x in os.environ.get("TARGET_IDS", "").split(",") if x.strip()}

    for product in api_products:
        title = product["title"]
        mock = by_title.get(title)
        if not mock:
            log(f"  ! Eşleşme yok: {title}")
            continue
        if target_ids and mock["id"] not in target_ids:
            continue

        image_url = PRODUCT_IMAGES.get(mock["id"]) or mock["images"][0]
        try:
            image_bytes = download(image_url, mock["id"])
            photo_id = upload_photo(token, image_bytes, f"{mock['id']}.jpg")
            detail = get_product_detail(token, product["id"])
            body = {
                "title": detail["title"],
                "description": detail["description"],
                "price": float(detail["price"]),
                "stock": int(detail["stock"]),
                "categoryId": detail["categoryId"],
                "photoIds": [photo_id],
                "features": detail.get("features") or {"Marka": mock.get("brand", "VBShop")},
                "isActive": detail.get("isActive", True),
            }
            result = http_json("PUT", f"{API}/seller/products/{product['id']}", body, token=token)
            if not result.get("isSuccess"):
                raise RuntimeError(str(result))
            updated += 1
            log(f"  ✓ [{updated}] {title}")
            time.sleep(2)
        except Exception as exc:  # noqa: BLE001
            log(f"  ! Hata ({title}): {exc}")
            time.sleep(2)

    log(f"\nTamamlandı: {updated}/{len(api_products)} ürün güncellendi.")
    return 0 if updated == len(api_products) else 1


if __name__ == "__main__":
    sys.exit(main())
