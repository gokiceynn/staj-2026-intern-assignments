/**
 * Frontend domain tipleri (elle bakım).
 * Backend istek modelleri için otomatik tipler: `src/types/openapi.ts` / `npm run generate:types`
 */
export type ApiResponse<T> = {
  data: T | null;
  isSuccess: boolean;
  message: string;
  code: number;
  errors: Record<string, string[]> | null;
  timestamp: string;
};

export type UserRole = "Customer" | "Seller" | "Admin";

export type User = {
  id: string;
  email: string;
  firstName: string;
  lastName: string;
  phoneNumber: string;
  role: UserRole;
  photoId?: string | null;
  photoUrl?: string | null;
  createdAt: string;
};

export type AuthTokens = {
  accessToken: string;
  accessTokenExpiresAt: string;
  refreshToken: string;
  refreshTokenExpiresAt: string;
};

export type LoginData = AuthTokens & { account: User };

export type OtpSession = {
  sessionId: string;
  expiresAt: string;
};

export type Address = {
  id: string;
  title: string;
  addressLine: string;
  city: string;
  district: string;
  zipCode: string;
  phoneNumber: string;
};

export type CategoryRef = {
  id: string;
  name: string;
};

export type Category = CategoryRef & {
  slug: string;
  iconId: string | null;
  iconUrl: string | null;
  parentCategoryId: string | null;
  productCount: number;
  children: Category[];
};

export type ProductListItem = {
  id: string;
  title: string;
  brand?: string;
  description: string;
  price: number;
  originalPrice?: number | null;
  stock: number;
  photoId: string;
  photoUrl: string;
  rating: number;
  reviewCount?: number;
  freeShipping?: boolean;
  seller?: string;
  isFlashDeal?: boolean;
  isFeatured?: boolean;
  category: CategoryRef;
};

export type ProductDetail = {
  id: string;
  title: string;
  description: string;
  price: number;
  stock: number;
  photoId: string;
  photoUrl: string;
  rating: number;
  features: Record<string, string>;
  categoryId: string;
};

export type Paginated<T> = {
  items: T[];
  pageIndex: number;
  pageSize: number;
  totalCount: number;
  totalPages: number;
};

export type CartItem = {
  productId: string;
  productTitle: string;
  sellerId?: string;
  sellerName?: string;
  price: number;
  quantity: number;
  totalPrice: number;
  stock?: number;
  photoId: string;
  photoUrl: string;
};

export type Cart = {
  items: CartItem[];
  subtotal?: number;
  totalAmount: number;
  currency?: string;
};

export type PaymentCard = {
  cardHolderName: string;
  cardNumber: string;
  expireMonth: number;
  expireYear: number;
  cvv: string;
};

export type OrderItem = {
  productId: string;
  productTitle: string;
  price: number;
  quantity: number;
  photoId: string;
  photoUrl: string;
};

export type ShippingAddress = {
  addressLine: string;
  city: string;
  district: string;
};

export type OrderDetail = {
  orderId: string;
  orderNumber: string;
  totalAmount: number;
  status: string;
  createdAt: string;
  shippingAddress: ShippingAddress;
  items: OrderItem[];
};

export type OrderSummary = {
  orderId: string;
  orderNumber: string;
  totalAmount: number;
  status: string;
  createdAt: string;
  itemCount: number;
};

export type ProductSortBy = "price_asc" | "price_desc" | "rating_desc" | "newest";

export type ProductQueryParams = {
  page?: number;
  size?: number;
  q?: string;
  categoryId?: string;
  minPrice?: number;
  maxPrice?: number;
  sortBy?: ProductSortBy;
  flashDealsOnly?: boolean;
  featuredOnly?: boolean;
};

export type ReviewPhoto = { photoId: string };
export type ReviewUser = { id: string; displayName: string };
export type Review = {
  id: string;
  productId: string;
  user: ReviewUser;
  rating: number;
  comment: string;
  photos: ReviewPhoto[];
  isVerifiedPurchase: boolean;
  createdAt: string;
  updatedAt?: string | null;
};
export type ReviewSummary = {
  averageRating: number;
  totalReviewCount: number;
  ratingDistribution: Record<string, number>;
};
export type ReviewPage = {
  summary: ReviewSummary;
  reviews: Paginated<Review>;
};

export type StatusItem = { code: string; label: string; color: string | null };
export type StatusGroup = { key: string; items: StatusItem[] };

export type PhotoUploadResult = { photoId: string; uploadedAt: string };

export type SellerProfile = {
  id: string;
  storeName: string;
  description: string;
  logoId: string | null;
  taxNumber: string;
  taxOffice: string;
  rating: number;
  isActive: boolean;
  createdAt: string;
};

export type SellerDashboard = {
  productCount: number;
  activeProductCount: number;
  lowStockProductCount: number;
  totalOrderCount: number;
  paidPackageCount: number;
  preparingPackageCount: number;
  shippedPackageCount: number;
  deliveredPackageCount: number;
  cancelledPackageCount: number;
  grossSalesAmount: number;
  currency: string;
};

export type SellerProductCard = {
  product: ProductListItem;
  isActive: boolean;
};

export type SellerProductDetail = {
  id: string;
  title: string;
  description: string;
  price: number;
  stock: number;
  photoId: string | null;
  photoIds: string[];
  categoryId: string;
  features: Record<string, string>;
  isActive: boolean;
};

export type SellerPackageListItem = {
  packageId: string;
  orderId: string;
  orderNumber: string;
  status: string;
  itemCount: number;
  subtotal: number;
  createdAt: string;
};

export type SellerPackageDetail = {
  packageId: string;
  orderId: string;
  orderNumber: string;
  status: string;
  createdAt: string;
  customer: { fullName: string; phoneNumber: string };
  items: OrderItem[];
  shipment: { trackingNumber: string | null; trackingUrl: string | null } | null;
};

export type ShippingCarrier = {
  id: string;
  name: string;
  code: string;
  logoId: string | null;
  flatFee: number;
  estimatedDeliveryDays: number;
  trackingUrlTemplate: string;
  isActive: boolean;
};

export type AdminDashboard = {
  userCount: number;
  customerCount: number;
  sellerCount: number;
  activeProductCount: number;
  orderCount: number;
  grossSalesAmount: number;
  currency: string;
};

export type AdminUserListItem = {
  id: string;
  email: string;
  fullName: string;
  role: string;
  isActive: boolean;
  isEmailVerified: boolean;
  createdAt: string;
};

export type AdminUserDetail = AdminUserListItem & {
  firstName: string;
  lastName: string;
  phoneNumber: string;
  securityVersion: number;
  lastLoginAt: string | null;
};

export type AdminSellerListItem = {
  id: string;
  accountId: string;
  storeName: string;
  email: string;
  rating: number;
  isActive: boolean;
  productCount: number;
};

export type AdminSellerDetail = {
  id: string;
  accountId: string;
  storeName: string;
  description: string;
  taxNumber: string;
  taxOffice: string;
  logoId: string | null;
  rating: number;
  isActive: boolean;
  productCount: number;
  createdAt: string;
};

export type AdminOrderListItem = {
  orderId: string;
  orderNumber: string;
  customerEmail: string;
  totalAmount: number;
  currency: string;
  status: string;
  packageCount: number;
  createdAt: string;
};
