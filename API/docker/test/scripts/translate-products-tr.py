#!/usr/bin/env python3
"""Mevcut satıcı ürünlerinin başlık ve açıklamalarını Türkçeye çevirir."""

from __future__ import annotations

import importlib.util
import json
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path

API = "http://127.0.0.1:5082/api/v1"
SELLER_EMAIL = "seller@vbshop.local"
SELLER_PASSWORD = "DevSellerPass123!"
UA = {"User-Agent": "VBShop-Seed/1.0"}

_SCRIPT_DIR = Path(__file__).resolve().parent
_spec = importlib.util.spec_from_file_location("tr_translate", _SCRIPT_DIR / "tr_translate.py")
_mod = importlib.util.module_from_spec(_spec)
assert _spec.loader is not None
_spec.loader.exec_module(_mod)
translate_to_tr = _mod.translate_to_tr


def log(msg: str) -> None:
    print(msg, flush=True)


def http_json(method: str, url: str, body: dict | None = None, token: str | None = None) -> dict:
    data = None if body is None else json.dumps(body).encode()
    req = urllib.request.Request(url, data=data, method=method, headers={**UA, "Content-Type": "application/json"})
    if token:
        req.add_header("Authorization", f"Bearer {token}")
    with urllib.request.urlopen(req, timeout=120) as resp:
        return json.load(resp)


def login() -> str:
    payload = http_json("POST", f"{API}/auth/login", {"email": SELLER_EMAIL, "password": SELLER_PASSWORD})
    if not payload.get("isSuccess"):
        raise RuntimeError(payload.get("message", "Giriş başarısız"))
    return payload["data"]["accessToken"]


def list_products(token: str) -> list[dict]:
    items: list[dict] = []
    page = 1
    while True:
        payload = http_json("GET", f"{API}/seller/products?page={page}&size=50", token=token)
        page_data = payload["data"].get("page", payload["data"])
        batch = page_data.get("items", [])
        for row in batch:
            items.append(row.get("product", row))
        if page >= page_data.get("totalPages", page):
            break
        page += 1
    return items


def get_detail(token: str, product_id: str) -> dict:
    return http_json("GET", f"{API}/seller/products/{product_id}", token=token)["data"]


def looks_turkish(text: str) -> bool:
    tr_chars = set("ğüşıöçĞÜŞİÖÇ")
    return any(c in text for c in tr_chars)


def main() -> int:
    token = login()
    products = list_products(token)
    log(f"→ {len(products)} ürün Türkçeleştirilecek...")

    ok = 0
    skip = 0
    for i, row in enumerate(products, 1):
        pid = row["id"]
        detail = get_detail(token, pid)
        title = detail["title"]
        desc = detail["description"]

        if looks_turkish(title) and looks_turkish(desc[:80]):
            skip += 1
            continue

        tr_title = translate_to_tr(title)
        time.sleep(0.25)
        tr_desc = translate_to_tr(desc)
        time.sleep(0.25)

        body = {
            "title": tr_title[:240],
            "description": tr_desc[:5000],
            "price": float(detail["price"]),
            "stock": int(detail["stock"]),
            "categoryId": detail["categoryId"],
            "photoIds": detail.get("photoIds") or ([detail["photoId"]] if detail.get("photoId") else []),
            "features": detail.get("features") or {},
            "isActive": detail.get("isActive", True),
        }
        if not body["photoIds"]:
            log(f"  ! Fotoğraf yok, atlandı: {title[:50]}")
            continue

        try:
            result = http_json("PUT", f"{API}/seller/products/{pid}", body, token=token)
            if not result.get("isSuccess"):
                raise RuntimeError(str(result))
            ok += 1
            log(f"  ✓ [{ok}] {tr_title[:55]}")
            time.sleep(0.5)
        except Exception as exc:  # noqa: BLE001
            log(f"  ! {title[:40]}: {exc}")

    log(f"\nTamamlandı: {ok} çevrildi, {skip} zaten Türkçe/atlandı.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
