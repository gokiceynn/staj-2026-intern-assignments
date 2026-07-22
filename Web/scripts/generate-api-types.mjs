#!/usr/bin/env node
/**
 * Backend OpenAPI şemasından TypeScript tiplerini üretir.
 * API çalışmıyorsa openapi/openapi.snapshot.json kullanılır.
 */
import { execSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const webRoot = path.join(__dirname, "..");
const snapshotPath = path.join(webRoot, "openapi/openapi.snapshot.json");
const outputPath = path.join(webRoot, "src/types/api.generated.ts");
const openapiUrl =
  process.env.OPENAPI_URL ??
  "http://127.0.0.1:5082/swagger/v1/swagger.json";

async function refreshSnapshot() {
  try {
    const response = await fetch(openapiUrl, { signal: AbortSignal.timeout(5000) });
    if (!response.ok) {
      console.warn(
        `[generate:types] OpenAPI indirilemedi (${response.status}). Snapshot korunuyor.`,
      );
      return;
    }

    const body = await response.text();
    fs.mkdirSync(path.dirname(snapshotPath), { recursive: true });
    fs.writeFileSync(snapshotPath, body, "utf8");
    console.log(`[generate:types] OpenAPI güncellendi: ${openapiUrl}`);
  } catch {
    console.warn(
      `[generate:types] OpenAPI'e ulaşılamadı. Mevcut snapshot kullanılacak: ${snapshotPath}`,
    );
  }
}

function ensureSnapshotExists() {
  if (!fs.existsSync(snapshotPath)) {
    console.error(
      `[generate:types] Snapshot bulunamadı: ${snapshotPath}\n` +
        "Backend'i başlatın veya OPENAPI_URL ile tekrar deneyin.",
    );
    process.exit(1);
  }
}

async function main() {
  await refreshSnapshot();
  ensureSnapshotExists();

  execSync(
    `npx openapi-typescript "${snapshotPath}" -o "${outputPath}"`,
    { cwd: webRoot, stdio: "inherit" },
  );

  console.log(`[generate:types] Yazıldı: ${path.relative(webRoot, outputPath)}`);
}

main();
