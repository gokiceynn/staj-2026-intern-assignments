import type { User } from "@/types/api";

type AccountPayload = User | { account: User };

/** GET/PUT /account/me yanıtını düz User nesnesine çevirir. */
export function normalizeAccountPayload(data: AccountPayload): User {
  if (
    data &&
    typeof data === "object" &&
    "account" in data &&
    data.account &&
    typeof data.account === "object"
  ) {
    return data.account;
  }

  return data as User;
}
