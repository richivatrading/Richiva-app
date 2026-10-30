# Richiva Fashion: developer handoff

> **This is a design prototype built in React + Vite + Tailwind inside Figma Make. It is not the production Flutter app.** The production target is Flutter/Dart (Android and iOS). Nothing here is Flutter code. Vite/React are only the prototyping vehicle. All data is stored in the browser (`localStorage`, key `richiva.proto.v3`). The server is authoritative for money, stock, vouchers, loyalty, offers and payments in production.

## 1. Screen inventory and navigation map

| Group | Route | Screen |
|---|---|---|
| Entry | `/onboarding` | Onboarding (3 slides, skip) |
| Discovery | `/` | Home: hero, category arc, new arrivals, promo, featured, collections, recently viewed, Gold Points preview |
| | `/categories` | Categories + subcategories |
| | `/shop/:slug?sub=` | Listing (subcategory chips, filter/sort sheet) |
| | `/collections/:id` | Collection |
| | `/search?filters=1` | Search + filter/sort sheet |
| | `/size-guide?p=` | Size guide (cm/in, find my size) |
| | `/custom` | Custom garment builder (7 steps, saved locally, not an order) |
| Product | `/product/:id` | Detail: gallery, variants, stock, delivery/returns, Add to Bag, Try On, Make an Offer (sheet) |
| | `/product/:id/reviews` | Reviews (verified-purchase only; none seeded) |
| | `/try-on?p=` | Try-on (camera preview, 3-minute active timer) |
| Bag/checkout | `/wishlist`, `/bag` | Wishlist, Bag (+ voucher input) |
| | `/checkout/address` → `/checkout/shipping` → `/checkout/payment` → `/checkout/review` → `/order/:id/result` | Checkout journey |
| Rewards | `/vouchers`, `/loyalty`, `/referrals` | Voucher centre, Gold Points, referral |
| Auth | `/login`, `/register`, `/verify`, `/forgot-password` | Auth (OTP demo code `123456`) |
| Orders | `/orders`, `/orders/:id`, `/orders/:id/track`, `/orders/:id/cancel`, `/orders/:id/return`, `/returns` | Order management |
| Account | `/account`, `/addresses`, `/notifications`, `/notifications/settings` | Account hub |
| Support | `/support`, `/support/chat`, `/support/ai` | FAQ, demo chat, AI (unavailable) |
| QA | `/states` | State gallery |

Bottom nav (Home, Search, Wishlist, Bag, Account) is hidden on onboarding, try-on, auth, checkout and order result.

## 2. Design tokens

**Colour** (logo-derived dark neutrals + restrained metallic gold for loyalty only)

| Token | Hex | Use |
|---|---|---|
| void | #0d0c0b | App backdrop outside the frame |
| canvas | #151412 | Screen background |
| soft | #1f1d1b | Cards, inputs |
| raised | #2a2724 | Elevated, toggles |
| line | #36322e | Dividers, outlines |
| ink | #f2eee8 | Foreground text, primary pill fill |
| muted | #9d968d | Secondary text |
| gold 100/300/500/700 | #f3e3b0 / #d9b45c / #b8923a / #7d611f | Gold Points surfaces/text only |

Contrast: ink on canvas ≈ 15:1, muted on canvas ≈ 6:1, canvas on ink pill ≈ 15:1. Status is never colour-only (labels/icons accompany).

**Typography**: Poppins throughout. Display 28–44/600, titles 18–24/600, body 13–14/400, labels 10–12 uppercase tracking, tabular numerals for prices.

**Spacing/shape**: 4-pt grid; screen padding 20; card padding 16–20; radii 16 (inputs/small), 24–28 (cards), full pills; primary controls ≥ 44–52 px high.

**Icons**: lucide, 1.5 stroke, 14–22 px. In Flutter use Material Symbols (rounded, weight 300) or Lucide Flutter.

## 3. Motion
Small feedback 120–200 ms, sheets/transitions 180–350 ms, hero entrance ≤ 600 ms. Easing: ease-out. No perpetual animation except spinners for loading. `MotionConfig reducedMotion="user"` disables transforms when the OS asks. Flutter: honour `MediaQuery.disableAnimations`.

## 4. Responsive behaviour
Single column max 480 px, centred with border on a darker backdrop for wider screens. Checked at 360, 390, 430 px widths: no horizontal overflow. Safe-area insets respected for header, bottom nav and sticky bars. Flutter: `SafeArea`, `LayoutBuilder` + max-width constraint on tablets.

## 5. Components → Flutter mapping

| Prototype | Flutter |
|---|---|
| `PageShell` | `Scaffold` + `SliverAppBar`/`AppBar` |
| `BottomNav` | `NavigationBar` inside `StatefulShellRoute` (GoRouter) |
| `Sheet` (focus trap, Esc) | `showModalBottomSheet(isScrollControlled: true)` |
| `ProductCard` | custom `StatelessWidget` in `SliverGrid` |
| Gallery (scroll-snap) | `PageView` + indicators |
| `Field` | `TextFormField` + `InputDecoration` |
| `Steps` | custom stepper/`LinearProgressIndicator` |
| `Notice`, `StatusPill` | `Container` + `Text`/`Chip` |
| Skeleton | `shimmer`-style `AnimatedContainer` (restrained) |
| Toast | `SnackBar` |
| Store (localStorage) | Riverpod `Notifier`s + repository interfaces (local mock impl → HTTP impl) |
| `ActiveTimer` | `Stopwatch` driven by `WidgetsBindingObserver` (pause on `paused`/`inactive`) |
| Camera preview | `camera` package `CameraPreview`; `TryOnProvider` interface for the renderer |
| Payments | provider SDK/redirect behind `PaymentRepository`; confirm via server webhook |

## 6. Business rules (all server-authoritative in production)

- **Money**: integer NPR (use minor units in production). Totals = list − offer savings − voucher + shipping.
- **Offers (Make an Offer)**: sample range per product (`minOff`/`maxOff`). Max 2 attempts per product. Demo response rule: off ≤ midpoint accepted; otherwise attempt 1 counteroffer, attempt 2 rejected. Hold 24 h; expired offers cannot be used. An accepted offer links to one product and applies to one unit. Demo mode is labelled.
- **Vouchers**: type (percent/fixed/shipping), min spend, max discount, expiry, `excludeDiscounted` (configurable, not assumed), `oneTime`. One voucher per order. Items at an offer price are not discounted again. Interaction with Gold Points rewards is **to be decided** and shown as such.
- **Gold Points**: virtual, not real gold. Threshold configurable (sample 20,000); unlocks a small NPR discount whose value/rule is not final. Points pending until delivery + 7-day return window; reversed on cancellation.
- **Try-on**: 3-minute allowance counts only while camera live and not user-paused; pauses on user pause, camera stop/loss, permission loss, app background; remaining time persisted. Only a camera preview is implemented; garment rendering requires a provider (unavailable state).
- **Checkout**: COD → `cod-due`; online → `pending` until server-verified `paid`. A gateway redirect is not proof of payment. Duplicate submit locked while placing. Price/stock change requires acknowledgement.
- **Cancellation**: allowed only before `packed`. **Returns/exchanges**: delivered orders within the return window (sample 7 days).
- **Reviews**: only for delivered purchases; marked verified.

## 7. Per-screen specification

Format: purpose · actions · states · backend data · acceptance.

- **Onboarding**: explain the app · Next/Skip/Get started · n/a · `onboarded` flag · shown once; reset from Account.
- **Home**: discovery · open campaign, categories, products, collections, bell, bag, search/filter, Gold Points, vouchers, try-on · loading skeleton / error with retry / empty rails hidden · campaign, categories, collections, featured, recent IDs · all entries navigate; recently viewed from actual views only.
- **Categories / Listing / Search**: browse and filter · subcategory chips, sort, price, size, colour, in-stock, on-offer · loading, empty (no matches, reset), error · catalogue query with filters server-side · filter count shown; sold-out excluded when "In stock only".
- **Product**: decide and buy · select size/colour, qty, Add to Bag, Try On, Make an Offer, wishlist, size guide, reviews · sold out → Notify me; sold-out sizes disabled · product, stock, variants · cannot add sold-out/unselected variants; no fabricated reviews.
- **Make an Offer**: negotiate · slider within range, send, accept counter, offer again · accepted / counter / rejected / expired, attempts left, hold time · offer API · max 2 attempts; expiry blocks use; demo labelled.
- **Bag**: review lines · qty (limited by stock), remove, voucher code, continue · empty, blocked (unavailable), loading, error · cart, pricing quote · totals match checkout.
- **Address / Shipping / Payment / Review**: complete checkout · CRUD addresses (phone `97/98XXXXXXXX`), choose method, choose payment, place order · validation errors, price/stock-change, pay-fail/pending scenarios (demo) · addresses, shipping rates, payment config, order create · place disabled until signed in, no blocked items, acknowledgements; duplicate submit locked.
- **Order result**: confirmed/verifying/failed/pending · retry payment, switch to COD, check status, view order · order id, payment status, delivery summary · never shows "paid" until verified.
- **Orders / Detail / Track**: history and status · tabs, track, cancel, return, write review · empty tabs · orders API · timeline reflects events; status changes in demo are simulated.
- **Cancel / Return / Returns**: self-service · reasons, item selection, exchange size · ineligible explanations · cancellation/return APIs · eligibility rules above.
- **Vouchers**: apply codes · Apply/Remove · applied, ineligible (reason), expired, already used · voucher API · rules text visible.
- **Gold Points**: loyalty dashboard · view only; redeem disabled until server enables · pending/confirmed/reversed · ledger API · disclaimers visible.
- **Auth / OTP / Recovery**: sign in/up · forms, OTP (3 tries, 30 s resend) · validation, lockout · auth API, SMS/email OTP · prototype labelled; no password checked.
- **Notifications / Preferences / Referrals / Reviews / Support / Chat / AI / Size guide / Custom / States**: as listed in the route table; support chat replies are automated demo text; AI page is disabled and says so.

## 8. Backend/integration list (not connected)
Auth + OTP provider, catalogue/stock API, pricing/voucher service, bargaining service, loyalty ledger, payment providers (eSewa, Khalti, card; none confirmed), courier/tracking, push (FCM/APNs), support chat backend, AI service, try-on provider, image CDN for real product photography.

## 9. Accessibility
Labelled inputs with inline errors, `role=dialog` sheets with focus trap/Esc/focus return, radio/switch semantics, `aria-live` for status, 44 px+ targets, reduced motion.
