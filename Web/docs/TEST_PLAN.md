# Test Plan

## Unit tests (Vitest)

| Area | Cases |
|------|-------|
| `parseApiResponse` | success, error, field errors, null data |
| Zod schemas | login, register, card, address forms |
| `formatCurrency` | TRY formatting |
| `buildProductQuery` | URL search params sync |
| `RefreshTokenManager` | single in-flight refresh |

## Component tests

| Component | Cases |
|-----------|-------|
| `ProductCard` | render, link, add to cart callback |
| `LoginForm` | validation errors, submit |
| `CartItem` | quantity change, subtotal |
| `EmptyState` | message, action |

## E2E (Playwright)

1. Browse products on home / products page
2. Search and filter products (URL params)
3. Login flow
4. Product detail navigation
5. Add to cart
6. Checkout multi-step (address → payment → summary)
7. Order success page

## Manual QA checklist

- [ ] Responsive mobile / tablet / desktop
- [ ] Light / dark theme
- [ ] Loading skeletons
- [ ] Empty states
- [ ] API error states
- [ ] 401 → login redirect
- [ ] Token refresh on expired access
- [ ] No sensitive data in console
- [ ] Cart remove disabled (API gap documented)
