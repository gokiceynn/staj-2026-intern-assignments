"""İngilizce metinleri Google Translate (gtx) ile Türkçeye çevirir."""

from __future__ import annotations

import json
import time
import urllib.error
import urllib.parse
import urllib.request

UA = {"User-Agent": "VBShop-Seed/1.0"}


def translate_to_tr(text: str, retries: int = 3) -> str:
    if not text or not text.strip():
        return text

    q = urllib.parse.quote(text[:4500])
    url = (
        "https://translate.googleapis.com/translate_a/single"
        f"?client=gtx&sl=en&tl=tr&dt=t&q={q}"
    )

    for attempt in range(retries):
        try:
            req = urllib.request.Request(url, headers=UA)
            with urllib.request.urlopen(req, timeout=30) as resp:
                data = json.loads(resp.read().decode())
            return "".join(part[0] for part in data[0] if part and part[0])
        except urllib.error.HTTPError as err:
            if err.code == 429 and attempt < retries - 1:
                time.sleep(2 * (attempt + 1))
                continue
            return text
        except Exception:  # noqa: BLE001
            if attempt < retries - 1:
                time.sleep(1)
                continue
            return text
    return text
