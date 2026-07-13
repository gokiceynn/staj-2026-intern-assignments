import type { FavoritesRepository } from "@/features/favorites/repositories/favorites-repository";

const STORAGE_KEY = "vbshop_favorites";

export class LocalFavoritesRepository implements FavoritesRepository {
  private read(): string[] {
    if (typeof window === "undefined") return [];
    try {
      const raw = localStorage.getItem(STORAGE_KEY);
      if (!raw) return [];
      const parsed = JSON.parse(raw) as unknown;
      return Array.isArray(parsed)
        ? parsed.filter((id): id is string => typeof id === "string")
        : [];
    } catch {
      return [];
    }
  }

  private write(ids: string[]): void {
    if (typeof window === "undefined") return;
    localStorage.setItem(STORAGE_KEY, JSON.stringify(ids));
  }

  getAll(): string[] {
    return this.read();
  }

  add(productId: string): void {
    const ids = this.read();
    if (!ids.includes(productId)) {
      this.write([...ids, productId]);
    }
  }

  remove(productId: string): void {
    this.write(this.read().filter((id) => id !== productId));
  }

  has(productId: string): boolean {
    return this.read().includes(productId);
  }

  clear(): void {
    if (typeof window === "undefined") return;
    localStorage.removeItem(STORAGE_KEY);
  }
}

export function getFavoritesRepository(): FavoritesRepository | null {
  if (process.env.NODE_ENV === "development") {
    return new LocalFavoritesRepository();
  }
  return null;
}
