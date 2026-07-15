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
  description: string;
  price: number;
  stock: number;
  photoId: string;
  photoUrl: string;
  rating: number;
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
};
