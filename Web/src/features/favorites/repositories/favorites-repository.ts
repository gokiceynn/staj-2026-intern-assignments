export interface FavoritesRepository {
  getAll(): string[];
  add(productId: string): void;
  remove(productId: string): void;
  has(productId: string): boolean;
  clear(): void;
}
