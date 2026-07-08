# Sakura Beauty - Flutter Android App

A complete Japanese skincare e-commerce Android app built from scratch using Flutter/Dart, converted from the [Sakura Beauty web application](https://envy-enhance-fixed5.vercel.app).

## 📱 Features

- **26 Screens**: Home, Products, Product Detail, Cart, Checkout, Orders, Tracking, Wishlist, Profile, Addresses, Auth, Admin Dashboard, Blog, Compare, Gift Cards, Loyalty, Referrals, Subscriptions, Pre-orders, Email Preferences, Search, Settings
- **Full E-Commerce Flow**: Browse → Cart → Checkout → Orders → Track
- **Admin Dashboard**: Sales analytics, order management, user management
- **Auth**: Clerk authentication (Email, Google OAuth)
- **Japanese-Inspired Design**: Sakura pink theme with Material 3
- **Responsive UI**: Bottom navigation, card-based layouts, skeleton loading
- **State Management**: Riverpod
- **Networking**: Dio HTTP client with auth interceptors

## 🏗 Architecture

```
lib/
├── main.dart                          # App entry point
├── app.dart                           # MaterialApp with routing & theme
├── core/
│   ├── api/                           # API client & service classes
│   │   ├── api_client.dart            # Dio client with interceptors
│   │   ├── product_service.dart       # Products API
│   │   ├── category_service.dart      # Categories API
│   │   ├── cart_service.dart          # Cart API
│   │   ├── order_service.dart         # Orders API
│   │   ├── user_service.dart          # Users API
│   │   └── extra_services.dart        # Reviews, Wishlist, Coupons, Admin
│   ├── models/                        # Data models (mirrors OpenAPI)
│   │   ├── product.dart
│   │   ├── category.dart
│   │   ├── cart.dart
│   │   ├── order.dart
│   │   ├── user.dart
│   │   ├── blog.dart
│   │   ├── coupon.dart
│   │   ├── wishlist.dart
│   │   ├── address.dart
│   │   └── dashboard.dart
│   ├── providers/                     # Riverpod providers
│   │   ├── app_providers.dart         # Cart, Wishlist, Search, Theme
│   │   └── auth_provider.dart         # Authentication
│   ├── routes/
│   │   └── app_router.dart            # GoRouter configuration
│   ├── theme/
│   │   └── app_theme.dart             # Japanese-inspired design system
│   └── utils/
│       ├── api_constants.dart
│       └── logger.dart
├── features/                          # Feature-based UI modules
│   ├── home/                          # Home with carousel, categories
│   ├── products/                      # Product listing + detail
│   ├── cart/                          # Cart with swipe-to-delete
│   ├── checkout/                      # Checkout with address, payment, coupon
│   ├── orders/                        # Order list, detail, tracking
│   ├── wishlist/                      # Wishlist grid
│   ├── auth/                          # Sign in / Sign up
│   ├── profile/                       # Profile + addresses CRUD
│   ├── admin/                         # Admin dashboard + stats
│   ├── blog/                          # Blog list + article
│   ├── compare/                       # Product comparison
│   ├── giftcards/                     # Gift card purchase
│   ├── loyalty/                       # Loyalty points + rewards
│   ├── referral/                      # Referral program
│   ├── subscriptions/                 # Subscription management
│   ├── preorder/                      # Pre-order products
│   ├── email_prefs/                   # Email notification preferences
│   ├── search/                        # Product search
│   └── settings/                      # App settings
└── shared/
    └── widgets/                       # Reusable UI components
        ├── app_scaffold.dart          # Main scaffold with bottom nav
        ├── product_card.dart          # Product card (grid + list)
        ├── common_widgets.dart        # AppBar, SectionHeader, EmptyState, Price
        └── skeletons.dart             # Shimmer loading skeletons
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK >= 3.16.0
- Android SDK
- JDK 17

### Setup

1. **Clone the repository**
```bash
cd sakura_beauty_app
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Configure environment**
Create a `.env` file (or use `--dart-define`):
```bash
# .env
CLERK_PUBLISHABLE_KEY=pk_test_your_key_here
API_BASE_URL=https://envy-enhance-fixed5.vercel.app
```

4. **Run the app**
```bash
flutter run --dart-define=CLERK_PUBLISHABLE_KEY=pk_test_xxx \
            --dart-define=API_BASE_URL=https://envy-enhance-fixed5.vercel.app
```

5. **Build APK**
```bash
flutter build apk --release \
  --dart-define=CLERK_PUBLISHABLE_KEY=pk_test_xxx \
  --dart-define=API_BASE_URL=https://envy-enhance-fixed5.vercel.app
```

## 🔌 API Connection

The app connects to the existing Sakura Beauty backend API:
- **Base URL**: `https://envy-enhance-fixed5.vercel.app/api`
- **Auth**: Clerk JWT tokens via `Authorization: Bearer <token>` header
- **Endpoints**: 40+ REST endpoints (products, categories, cart, orders, reviews, wishlist, coupons, users, admin)

## 📦 Dependencies

| Package | Purpose |
|---------|---------|
| `flutter_riverpod` | State management |
| `go_router` | Navigation & routing |
| `dio` | HTTP client |
| `clerk_flutter` | Authentication |
| `cached_network_image` | Image caching |
| `shimmer` | Loading skeletons |
| `carousel_slider` | Hero banners |
| `flutter_rating_bar` | Star ratings |
| `flutter_slidable` | Swipe actions |
| `google_fonts` | Typography |
| `flutter_stripe` | Payment processing |

## 🎨 Design System

- **Primary**: `#E8A0BF` (Sakura Pink)
- **Secondary**: `#F3C5D5` (Light Pink)
- **Accent**: `#C86B85` (Rose)
- **Background**: `#FFF5F5` (Sakura White)
- **Text**: `#3D3D3D` (Charcoal)
- **Success**: `#6BA368` (Green)
- **Error**: `#D35D6E` (Red)
- **Font**: Noto Sans JP

## 📄 License

MIT
