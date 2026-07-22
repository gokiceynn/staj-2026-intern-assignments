#!/usr/bin/env node
/**
 * Yerel Lighthouse denetimi.
 * Önce production sunucusu: npm run build && npm run start
 * Sonra: npm run lighthouse
 */
import { execSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const webRoot = path.join(__dirname, "..");
const baseUrl = (process.env.LIGHTHOUSE_URL ?? "http://localhost:3000").replace(
  /\/$/,
  "",
);
const pages = ["/", "/products", "/login"];
const outDir = path.join(webRoot, "lighthouse-reports");

function slug(route) {
  if (route === "/") return "home";
  return route.replace(/^\//, "").replace(/\//g, "-");
}

async function probe(url) {
  try {
    const res = await fetch(url, { signal: AbortSignal.timeout(3000) });
    return res.ok;
  } catch {
    return false;
  }
}

async function main() {
  const alive = await probe(baseUrl);
  if (!alive) {
    console.error(
      `[lighthouse] ${baseUrl} yanıt vermiyor.\n` +
        "Önce: npm run build && npm run start",
    );
    process.exit(1);
  }

  fs.mkdirSync(outDir, { recursive: true });

  for (const route of pages) {
    const url = `${baseUrl}${route}`;
    const outputBase = path.join(outDir, slug(route));
    console.log(`[lighthouse] ${url}`);

    execSync(
      [
        "npx lighthouse",
        `"${url}"`,
        "--quiet",
        "--output html",
        "--output json",
        `--output-path "${outputBase}"`,
        '--chrome-flags="--headless --no-sandbox"',
        "--only-categories=performance,accessibility,best-practices,seo",
      ].join(" "),
      { cwd: webRoot, stdio: "inherit" },
    );
  }

  console.log(`[lighthouse] Raporlar: ${outDir}`);
}

main();
