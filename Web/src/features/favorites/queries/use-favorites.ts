"use client";

import { useCallback, useSyncExternalStore } from "react";
import { getFavoritesRepository } from "@/features/favorites/repositories/local-favorites-repository";

const listeners = new Set<() => void>();

function subscribe(listener: () => void) {
  listeners.add(listener);
  return () => listeners.delete(listener);
}

function notify() {
  listeners.forEach((l) => l());
}

function getSnapshot(): string[] {
  const repo = getFavoritesRepository();
  return repo?.getAll() ?? [];
}

export function useFavorites() {
  const ids = useSyncExternalStore(subscribe, getSnapshot, () => []);

  const repo = getFavoritesRepository();
  const isDevOnly = process.env.NODE_ENV === "development";

  const add = useCallback(
    (productId: string) => {
      if (!repo) return;
      repo.add(productId);
      notify();
    },
    [repo],
  );

  const remove = useCallback(
    (productId: string) => {
      if (!repo) return;
      repo.remove(productId);
      notify();
    },
    [repo],
  );

  const toggle = useCallback(
    (productId: string) => {
      if (!repo) return;
      if (repo.has(productId)) {
        repo.remove(productId);
      } else {
        repo.add(productId);
      }
      notify();
    },
    [repo],
  );

  const has = useCallback(
    (productId: string) => ids.includes(productId),
    [ids],
  );

  return { ids, add, remove, toggle, has, isDevOnly, isAvailable: Boolean(repo) };
}
