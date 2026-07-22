/** Mobil ile aynı mock katalog (varsayılan: true). API için `NEXT_PUBLIC_USE_MOCK=false` */
export function isMockCatalogEnabled() {
  return process.env.NEXT_PUBLIC_USE_MOCK !== "false";
}
