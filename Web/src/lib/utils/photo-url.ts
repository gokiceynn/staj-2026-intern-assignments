/** API v1.3 photoId döner; photoUrl istemci tarafında üretilir. */
const PUBLIC_API =
  process.env.NEXT_PUBLIC_API_BASE_URL ?? "http://localhost:5082/api/v1";

export function photoUrlFromId(photoId?: string | null): string {
  if (!photoId) return "/placeholder-product.svg";
  return `${PUBLIC_API}/photos/${encodeURIComponent(photoId)}`;
}

export function withPhotoUrl<T extends { photoId?: string | null; photoUrl?: string | null }>(
  item: T,
): T & { photoUrl: string } {
  return { ...item, photoUrl: item.photoUrl ?? photoUrlFromId(item.photoId) };
}

export function withPhotoUrls<T extends { photoId?: string | null; photoUrl?: string | null }>(
  items: T[],
): Array<T & { photoUrl: string }> {
  return items.map(withPhotoUrl);
}
