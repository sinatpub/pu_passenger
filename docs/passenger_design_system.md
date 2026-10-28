# PU Taxi — Passenger App UI Design System

> Extracted from the Flutter source under `lib/` (verified, not inferred from screenshots).
> Analysis date: 2026-10-13. No code was modified to produce this report.

---

## 1. Summary of the Design Language

The passenger app is built on an internal design-token system named **"Taarraa"**
(prefixed `Ta`), introduced in roadmap phase F1/F2. It is a **light-only,
mobile-first, Khmer+Latin** system:

- **Single accent brand colour** `#FF4500` (orange-red "PU Taxi") on a neutral
  grey/white canvas, with a **navy** `#232838` used for secondary/dark surfaces
  (status pill, plate badge, FAB, toast, promo gradient anchor).
- **One type family**: the variable font `KantumruyPro`, 12 named roles.
- **Rounded, card-heavy, flat-to-soft-shadow** surfaces; pill/stadium shapes for
  chips, badges, status pills and the segmented control.
- **Presentational component library** (`lib/presentation/widgets/ta_*.dart`)
  that takes pre-formatted strings and exposes variants (button, badge, avatar…).
- **No Material `AppBar`** is used anywhere (0 occurrences); screen headers are
  custom `Row`s of `TaIconButton` + `Text`.
- **No dark theme** exists (`TaTheme.lightTheme` is the only theme; no
  `darkTheme`, `ThemeMode`, or `Brightness.dark` anywhere in `lib/`).

The token files are the *declared* source of truth. In practice many components
and screens either hardcode primitives or embed local `TextStyle`s — see
§7 "Inconsistencies".

---

## 2. Theme, Colours & Source

### 2.1 Theme wiring

| Item | Detail | Source |
|---|---|---|
| Theme builder | `TaTheme.lightTheme` | `lib/core/theme/ta_theme.dart:11` |
| Applied at | `GetMaterialApp(theme: TaTheme.lightTheme)` | `lib/app/root_main.dart:34` |
| Brightness | `Brightness.light` only | `ta_theme.dart:13` |
| Colour scheme | `ColorScheme.light(...)` | `ta_theme.dart:14-23` |
| Default font family | `fontFamily: 'KantumruyPro'` | `ta_theme.dart:28` |
| Text scale clamp | `TextScaler` clamped `1.0 → 1.3` | `lib/app/root_main.dart:48-51` |
| Material 3 | `useMaterial3: true` | `ta_theme.dart:31` |
| `Theme.of(context)` reads | only **2** in the whole app | — |

### 2.2 Palette (source of truth)

All semantic colours live in `lib/core/theme/ta_colors.dart` (`abstract final class TaColors`).
The comment there states the values were extracted verbatim from
`docs/taarraa-ui-prototype.html` and `docs/ux-redesign/02-design-system.md`.

| Token | HEX | Role / usage |
|---|---|---|
| `primary` | `#FF4500` | Brand, CTAs, active tab, focus ring, links |
| `primaryDark` | `#CC3700` | Pressed brand, text on brand backgrounds |
| `primaryLight` | `#FFA84C` | Secondary brand accent, empty-state icon |
| `primaryBg` | `#FFF4ED` | Subtle brand backgrounds, selected chip/vehicle fill |
| `primaryBorder` | `#FFE4D3` | Focus rings, spinner track, badge tints |
| `background` | `#F6F6F7` | Scaffold background |
| `surface` | `#FFFFFF` | Cards, sheets, fields, nav bar |
| `textPrimary` | `#191C24` | Headings, primary content |
| `textSecondary` | `#6B7588` | Body, descriptions, inactive tab |
| `textMuted` | `#9AA0B4` | Captions, placeholders, disabled text |
| `border` | `#EBEBF0` | Field borders, dividers, separators |
| `success` | `#0EAF6B` | Completed/paid states |
| `successBg` | `#E6F8EF` | Success badge / receipt check background |
| `error` | `#D32F2F` | Errors, destructive actions, cancellations |
| `errorBg` | `#FDECEC` | Error badge, danger-ghost button background |
| `warning` | `#B97A00` | Pending/waiting |
| `warningBg` | `#FFF4D6` | Warning badge / waiting banner background |
| `info` | `#2F6BFF` | Informational (declared; direct use is rare) |
| `dark` | `#232838` | Dark buttons, status pill, plate badge, promo/FAB |
| `disabledBg` | `#D8DBE3` | Disabled button fill (also grab handle) |
| `disabledText` | `#FFFFFF` | Disabled button label |
| `overlay` | `rgba(15,17,25,0.5)` | Sheet/dialog barrier (`Color.fromRGBO`) |
| `toastBg` | `#232838` | Toast fill |
| `toastIcon` | `#7CFFB2` | Mint check icon in toast |

ColorScheme mapping (`ta_theme.dart:14-23`): `primary→primary`, `secondary→primaryLight`,
`error→error`, `surface→surface`, `onPrimary→white`, `onSecondary→black`,
`onSurface→black`, `onError→white`.

### 2.3 Gradients (inventoried, all hardcoded in components)

| Gradient | Stops | Component | Source |
|---|---|---|---|
| Total box | `#FF6A00 → #E63E00` (TL→BR) | `TaTotalBox` | `ta_total_box.dart:24` |
| Promo banner | `#232838 → #3A2C28 → #572C12` (stops 0/0.7/1.0) | `TaPromoBanner` | `ta_promo_banner.dart:33` |
| Driver avatar | `#2F6BFF → #7A5CFF` | `TaAvatar(driver)` | `ta_avatar.dart:44` |
| Other avatars | `#FF6A00 → #B73CFF` | `TaAvatar(history/profile)` | `ta_avatar.dart:45` |
| Skeleton sheen | `#EDEEF2 → #F7F7FA → #EDEEF2` | `TaSkeleton` `ShaderMask` | `ta_skeleton.dart:70-72` |
| Announcement fallback | `primaryBorder → #D8E6FF` | `AnnouncementImageFallback` | `announcement_detail/view.dart:166-170` |

### 2.4 Opacity usage

22 combined `withOpacity` / `withValues` / `withAlpha` calls exist. Representative
patterns: primary shadow `alpha 0.35`, dark shadow `alpha 0.30`, splash glow
`alpha 0.40`, loading overlay `Colors.white.withValues(alpha: 0.94)`, promo
subtitle `white alpha 0.75`.

---

## 3. Typography

### 3.1 Font families

| Family | Declared in `pubspec.yaml` | Referenced in Dart | Notes |
|---|---|---|---|
| `KantumruyPro` (variable) | yes (`fontVariation wght`, Khmer+Latin) | **yes** — `TaTextStyles._family`, `TaTheme.fontFamily` | The only family actually used |
| `KhmerMoul` (`moul_regular.ttf`) | yes | no | Declared, unused |
| `TimesNewRomance` | yes | no | Declared, unused |
| `KantumruyPro-SemiBold` | yes | no | Declared, unused (weight comes from the variable font) |
| `KantumruyPro-Regular` | yes | no | Declared, unused |

`TaTextStyles` drives weights explicitly via `fontVariations: [FontVariation('wght', N)]`.

### 3.2 Type scale (`lib/core/theme/ta_text_styles.dart`, `abstract final class TaTextStyles`)

| Token | Family | Size | Weight | Line height | Documented usage |
|---|---|---|---|---|---|
| `displayLarge` | KantumruyPro | 30 | w800 | 1.2 | Splash name, OTP title, fare amount |
| `headlineLarge` | KantumruyPro | 24 | w800 | 1.25 | Screen titles |
| `headlineMedium` | KantumruyPro | 17 | w700 | 1.3 | Section titles, sheet titles |
| `titleLarge` | KantumruyPro | 16 | w700 | 1.2 | Buttons, prices, header titles |
| `titleMedium` | KantumruyPro | 15 | w700 | 1.3 | Secondary titles |
| `bodyLarge` | KantumruyPro | 15 | w400 | 1.5 | Primary body/input |
| `bodyMedium` | KantumruyPro | 13 | w400 | 1.4 | Subtitles, descriptions |
| `bodySmall` | KantumruyPro | 12 | w400 | 1.3 | Footnotes, timestamps |
| `labelLarge` | KantumruyPro | 14 | w700 | 1.3 | Links, secondary actions |
| `labelMedium` | KantumruyPro | 13 | w600 | 1.3 | Form labels |
| `labelSmall` | KantumruyPro | 12 | w700 | 1.3 | Badges, tags |
| `overline` | KantumruyPro | 11 | w600 | 1.3 | Tab bar labels |

`TaTextStyles.textTheme` maps these onto a Material `TextTheme`
(header/body/label slots) and is installed via `TaTheme.textTheme`.

### 3.3 Typography usage & inconsistency

Token usage across `lib/` (count of `TaTextStyles.<role>` references):

`titleLarge 18 · bodySmall 28 · bodyMedium 26 · labelLarge 12 · displayLarge 9 · titleMedium 9 · headlineMedium 4 · headlineLarge 2 · bodyLarge 1 · labelMedium 1 · labelSmall 0 · overline 0`

- **`labelSmall` and `overline` are defined but never used.**
- **104 raw `fontSize:` values** and **90 raw `TextStyle(` literals** exist outside the
  theme, reproducing the scale by hand. Observed raw sizes and counts:
  `13 (20) · 12 (16) · 17 (14) · 15 (14) · 14 (11) · 11 (8) · 16 (5) · 36 (2) · 30 (2) · 26 (2) · 18 (2) · 40 · 28 · 24 · 22 · 20 · 18.0`.
- Off-scale sizes introduced ad-hoc: **40** (`calculate_fee_screen.dart:149`),
  **36** (`receipt/view.dart:143`), **28** (`ta_total_box.dart:48`), **26** (OTP boxes),
  **22** (`home/view.dart:119`), **20**, **18** (dialogs) — none are tokens.
- Common inline `TextStyle`s duplicate roles, e.g. `fontSize: 15, fontWeight: w700`
  (`ta_address_row.dart:64`, `map_bottom_sheet.dart:338`), `fontSize: 17, w700`
  (`ta_minimax_sheet.dart:79`, `ta_dialog` is 18/w700 at `ta_dialog.dart:107`).

---

## 4. Spacing, Radius, Elevation, Icons

### 4.1 Spacing

**Scale** — `lib/core/theme/ta_spacing.dart` (`abstract final class TaSpacing`):
`space2, space4, space6, space8, space10, space12, space14, space16, space18, space20, space22, space24, space32, space34, space44, space48` (4 px base grid).

> ⚠️ **`TaSpacing` has ZERO references in the entire `lib/` tree.** The scale is
> declared and documented but not applied by any screen or component. All spacing
> is written as literal `EdgeInsets` / `SizedBox` values.

**De-facto spacing conventions (literal):**

| Context | Value | Examples |
|---|---|---|
| Screen horizontal padding | `20` | login `fromLTRB(20,26,20,20)`; otp/receipt/profile/calculate_fee |
| Screen top padding | `26` | auth/fee/receipt/profile headers |
| Screen top padding (home) | `12` | `home/view.dart:41` |
| Home/history list padding | `fromLTRB(20,4/12,20,24)` | `home/view.dart:41`, `history_tab.dart:44` |
| Bottom sheet content | `fromLTRB(20,0,20,26)` | `ta_bottom_sheet.dart:35` |
| Card internal padding | `16` | `TaCard` default `EdgeInsets.all(16)` |
| Field horizontal padding | `14` | `ta_text_field.dart:72` |
| Dialog padding | `22` | `ta_dialog.dart:92` |
| Profile row padding | `15` | `ta_profile_row.dart:31` |
| Search result padding | `13 x 14` | `ta_search_result.dart:33` |
| Status pill padding | `10 x 18` | `ta_status_pill.dart:62` |
| Grab handle | `44 x 5` | `ta_bottom_sheet.dart:53-54` |

### 4.2 ScreenUtil / responsive helpers

- **No** `flutter_screenutil` and **no `.w` / `.h` / `.sp` / `.r`** usages exist (0).
- A **custom diagonal-scaling extension `.d`** exists:
  - `int.d` and `double.d` in `lib/core/utils/app_ext.dart:29-43` — scale factor
    `deviceDiagonal * (value / 1000)`, based on `lib/core/utils/screen_util.dart`
    (`ScreenUtilHelper`, singleton, `Get.width`/`Get.height`, fallback 375×812).
  - **86 usages**, all confined to the map/booking flow:
    `map_bottom_sheet.dart`, `booking_sheet.dart`, `booking_map_screen.dart`,
    `map_screen/view.dart`, `map_screen/logic.dart`, `booking_map_screen/logic.dart`,
    `shared/map_drag/view.dart`, `search_panel.dart`, `search_view.dart`,
    `pin_confirm_sheet.dart`, `app/logic.dart`.
  - Every other screen uses fixed logical pixels. This is a **split responsive model**.

### 4.3 Corner radius

**Tokens** — `lib/core/theme/ta_radius.dart` (`abstract final class TaRadius`):
`radiusSm 8 · radiusMd 12 · radiusLg 16 · radiusXl 20 · radiusXxl 22 · radiusFull 99`.

Only **10** `TaRadius.*` references exist. Many components hardcode radii that
overlap the scale but bypass it: `14` (field, OTP, note field, profile row, search
result, toast, stat row, warning banner, driver card), `9` (plate badge), `10`
(vehicle art placeholder, `getBoxDecoration` default), `3` (route/trip marker),
`28` (splash logo badge), `20` (dialog), `22` (sheets — sometimes via token,
sometimes literal).

### 4.4 Elevation / shadows

**Tokens** — `lib/core/theme/ta_shadow.dart` (`abstract final class TaShadows`),
base shadow colour `rgba(20,22,30,1)`:

| Token | Value |
|---|---|
| `shadowSm` | `0 2 6 rgba(20,22,30,0.08)` |
| `shadowMd` | `0 4 14 rgba(20,22,30,0.10)` |
| `shadowLg` | `0 12 34 rgba(20,22,30,0.18)` |

24 `TaShadows.*` references. Component-specific shadows are hardcoded on top:
primary button `primary alpha .35 / blur 16 / y6` (`ta_button.dart:118-124`), dark
button `dark alpha .30`, total box `primary alpha .35 / blur 22 / y8`, avatar camera
`primary alpha .40 / blur 12 / y4`, splash `primary alpha .40 / blur 40 / y16`,
FAB `dark alpha .30 / blur 14 / y6`. The legacy `getBoxDecoration`
(`lib/core/utils/get_decoration.dart`) uses `rgba(0,0,0,0.15)` and is only called
once (`x_network_image.dart:61`).

### 4.5 Icons

- **Icon system:** Material `Icons.*` for UI glyphs + `flutter_svg` for brand/nav/vehicle art.
- **Nav icons (SVG, tinted):** `assets/nav_icon/home-angle-2-svgrepo-com.svg` (+`home.svg`),
  `book.svg` (+`book_outline.svg`), `profile_fill.svg` (+`profile.svg`) — tinted
  `TaColors.primary` (active) / `TaColors.textSecondary` (inactive), drawn 22×22
  (`bottom_nav/view.dart:44-56`).
- **Tabular icon sizes in use:** `13` (ETA/star inline), `15`, `18`, `20`, `22` (nav,
  profile rows, search), `26` (loading car), `28` (dialog icon, FAB, QR), `30`, `32`,
  `36` (receipt check), `40`, `44` (rating stars), `48`, `56` (register avatar placeholder).
- **`TaIconButton`**: drawn 42×42 (borderRadius `radiusMd`), but **hit target grown to
  48** via `minTapTarget` (`ta_icon_button.dart:38`); icon size = `size * 0.48`.
- Asset catalogue: `lib/core/resources/asset_resource.dart` (`ImageAssets`), with SVG
  icons under `assets/icon/svg/`, vehicle art under `assets/image/svg/`, markers under
  `assets/marker/`, and the brand mark `assets/launcher/launcher_passenger_1024.png`.
- Duplicate/unused assets exist (`logout 1.svg`, `logout-exit-svgrepo-com.svg`,
  `logout-svgrepo-com.svg`; `logo_app.png` not referenced by `ImageAssets`).

### 4.6 Motion

`lib/core/utils/motion.dart` (`abstract final class Motion`): `fast 120ms`,
`medium 200ms`, `base 280ms`, `ambient 1100ms`. Reduced-motion is honoured via
`prefersReducedMotion` / `motionDuration` / `applyAmbientMotion`. Press feedback is
`scale 0.97` at `100ms` in `TaPressable`.

---

## 5. Reusable Component Inventory

All `Ta-` components are exported from the barrel `lib/presentation/widgets/widgets.dart`
and are documented as presentational (pre-formatted strings only).

### 5.1 Buttons

| Component | File | Styling rules |
|---|---|---|
| `TaButton` | `ta_button.dart` | Variants `primary / dark / ghost / dangerGhost`; sizes `large` (52 h, `radiusLg`, 16px) / `small` (44 h, `radiusMd`, 14px); label w700; loading = 22px `CircularProgressIndicator` stroke 2.5; disabled `disabledBg`/`disabledText`; shadow per variant; optional leading `icon` |
| `TaPressable` | `ta_pressable.dart` | Shared press-scale wrapper `scale(0.97)` @100ms, `easeOut` |
| `TaIconButton` | `ta_icon_button.dart` | 42px square, `radiusMd`, `shadowSm`, icon `size*0.48`; `minTapTarget` 48; `.dot()` notification dot; `TaDotBadge` wrapper |
| `TaStepIndicator` | `ta_step_indicator.dart` | 26×5 dots (or expanded segments), active `primary`, inactive `#DCDDE5`, radius 99 |

Buttons have no dedicated "outlined" or "text" variants — those are expressed as
`ghost` (white + border) and `dangerGhost` (error tint).

### 5.2 Inputs & forms

| Component | File | Styling rules |
|---|---|---|
| `TaTextField` | `ta_text_field.dart` | 54 h, radius 14, border 1.5 (`primary` focused / `border` idle); bold prefix + vertical rule; 15px text; hint `textMuted`; error caption 13px `error` with reserved 18px min-height |
| `TaOtpField` | `ta_otp_field.dart` | N boxes, 64 h, radius 14, focus glow `primaryBorder`; digit 26 w800; auto-advance |
| `TaNoteField` | `ta_note_field.dart` | `background` fill, radius 12, 13px text, leading `description_outlined` |
| OTP screen | `otp/view.dart:34-48` | Uses `Pinput` (not `TaOtpField`) restyled to the same tokens (58×64, radius 14, 26/w800) |
| `TaSearchCard` | `ta_search_card.dart` | Tappable "Where to?" bar, radius 16, `shadowMd`, primary search icon, 16px w600 `textSecondary` |
| `TaSearchResult` | `ta_search_result.dart` | radius 14, `shadowSm`, location pin, optional distance pill (`primaryBg`, `primaryDark`) |

### 5.3 Surfaces, sheets, dialogs, feedback

| Component | File | Styling rules |
|---|---|---|
| `TaCard` | `ta_card.dart` | `surface`, radius `radiusLg` (16), `shadowMd`, default padding 16 |
| `TaBottomSheet.show` | `ta_bottom_sheet.dart` | Modal, 22px top radius, `overlay` barrier, max 82% height, grab handle, content padding `20/0/20/26` |
| `gShowModalBottomSheet` / `xShowModalBottomSheet` | `g_showmodal_bottom.dart`, `x_showmodal_bottom.dart` | Legacy re-skinned draggable sheets (22px radius, `TaGrabHandle`, token animation) |
| `TaDialog` / `TaDialogCard` | `ta_dialog.dart` | Centered white card, radius 20, padding 22, `overlay` barrier, scale `pop` curve `(0.2,0.9,0.3,1.2)`; `TaDialogIcon` (56px circle, warning/error tones) |
| `TaToast` | `ta_toast.dart` | Navy pill (`toastBg`), radius 14, mint check, auto-dismiss 2400ms, bottom 100, `shadowLg` |
| `showCustomSnackBar` | `custom_snackbar_widget.dart` | `toastification` white pill, radius 18, `error` hairline border (0.1 width) |
| `showErrorCustomDialog` / `showGetXErrorCustomDialog` / `showYesNoCustomDialog` | `error_dialog_widget.dart`, `yesno_dialog_widget.dart` | Compose `TaDialog` + `TaButton` |

### 5.4 Navigation & layout chrome

| Component | File | Styling rules |
|---|---|---|
| `TaBottomNav` / `TaNavItem` | `ta_bottom_nav.dart` | White bar, top hairline `border`, `SafeArea(bottom)`, active `primary` / inactive `textSecondary`, 28×3 indicator, label 12 w600, 22px icons, press scale 0.97 |
| Screen headers | screens | Custom `Row` with `TaIconButton(arrow_back_ios_new)` + `titleLarge` — **no Material `AppBar`** anywhere |
| `TaSegment` | `ta_segment.dart` | Stadium track `#E8EAF0`, selected white pill `shadowSm`, label 13 w700 |
| `TaChip` | `ta_chip.dart` | Pill 99, selected `primaryBg`/`primary` border 1.5, label 13 w700 |
| `TaBadge` | `ta_badge.dart` | Pill, 12 w700, variants success/error/warning/brand |
| `TaStatusPill` | `ta_status_pill.dart` | Navy pill `dark`, `shadowLg`, pulsing `#4ADE80` dot, 13 w700 white |
| `InviteFab` | `invite/widgets/invite_fab.dart` | 56px circle `dark`, `qr_code_2`, `dark alpha .30` shadow |
| `TaBottomNav` items | `bottom_nav/view.dart` | Home / MyBooking / Profile |

### 5.5 Domain display components

| Component | File | Styling rules |
|---|---|---|
| `TaAddressRow` | `ta_address_row.dart` | Pickup (`dark` dot) / destination (`primary` dot) row, label 11 w700 ls 0.5 `textMuted` |
| `TaTripCard` / `TaTripRows` | `ta_trip_card.dart` | Bordered surface radius 16; uses `TaTextStyles.labelLarge` |
| `TaKVRow` | `ta_kv_row.dart` | Label 14 `textSecondary`, value 14 w700 (default colour) |
| `TaHistoryCard` | `ta_history_card.dart` | `surface`, radius 16, `border`, 14 w800 date, 16 w800 fare, vehicle art 52×32 |
| `TaDriverCard` | `ta_driver_card.dart` | `background`/`surface`+border, radius 14/16; name 15 w800; **star `#F5A623`**; plate navy radius 9, 13 w800 ls 1 |
| `TaVehicleRow` / `VehicleData` | `ta_vehicle_row.dart` | Selected `primaryBg`+`primary` border 1.5, radius 16, `shadowMd`; name 15 w800; price `primaryDark`; compact variant 14 |
| `TaTotalBox` | `ta_total_box.dart` | Orange gradient, radius 16, 28 w800 amount |
| `TaPromoBanner` | `ta_promo_banner.dart` | Dark gradient, radius 16, PROMO tag pill, 15 w800 title |
| `TaStarRating` | `ta_star_rating.dart` | 5×44px stars `#F5A623`/`#DCDDE5`, pop `scale 1.3` @250ms `easeOutBack` |
| `TaTimeline` / `ConnectorLine` | `ta_timeline.dart` | 26px steps `primary`/`#E7E8EE`, label 11 w700 |
| `TaStatRow` / `StatItem` | `ta_stat_row.dart` | `background` radius 14, value 16 w800, label 11 `textSecondary` |
| `TaProfileRow` | `ta_profile_row.dart` | `surface`, radius 14, `shadowSm`, padding 15, icon 22 `primary`/`error`, label 15 w600, chevron `textMuted` |
| `TaAvatar` / `TaAvatarVariant` | `ta_avatar.dart` | driver 52 / history 44 / profile 48 / register 120; gradients (see §2.3); initials w800; camera FAB 38 |
| `TaMinMaxSheet` | `ta_minimax_sheet.dart` | "Tariff" pill (`primaryBg`) + sheet with KV rows |
| `TaCenterPin` | `ta_center_pin.dart` | Map centre pin (`current_marker.svg`), 46/52 tip offset, lift `-0.4` @200ms |

### 5.6 Loading, empty & error states

| Component | File | Styling rules |
|---|---|---|
| `TaSkeleton` / `TaSkeletonCard` | `ta_skeleton.dart` | Shimmer `#EDEEF2 → #F7F7FA` @1100ms; card radius 16, `shadowSm` |
| `LoadingShimmer` | `loading_shimmer.dart` | Legacy shimmer; same colours `#EDEEF2`/`#F7F7FA` (duplicate of `TaSkeleton`) |
| `CardBoardShimmer` | `card_board_shimmer_widget.dart` | Another shimmer; colours `#D9D9D9`/`#EDEEF2`/`#F7F7FA` (duplicate) |
| `TaLoadingOverlay` | `ta_loading_overlay.dart` | Near-opaque white (0.94), 64px brand spinner stroke 5, bouncing car, cancel `dangerGhost` |
| `LoadingWidget` | `loading_widget.dart` | Full-screen white 0.94 + brand spinner (no text/cancel) |
| `CenterLoading` | `center_loading.dart` | Centered `CircularProgressIndicator(color: primary)` |
| `EmptyData` | `empty_data.dart` | 72px `primaryBg` circle + `inbox_outlined` `primaryLight`, message `bodyMedium` `textSecondary` |
| `HistoryEmptyState` / `HistoryErrorState` | `history/widgets/history_tab.dart` | Muted icon + retry `ghost` button |
| `FeeLoadingView` / `FeeErrorView` | `calculate_fee_screen.dart` | Shaped skeletons / `receipt_long_outlined` + retry |
| `InviteLoadError` | `my_qr_sheet.dart` | `wifi_off` + retry |
| `ErrorDialog` helpers | `error_dialog_widget.dart`, `yesno_dialog_widget.dart` | `TaDialog` + `TaButton` |

> **Toasts/Snackbars** use two parallel systems: the custom `TaToast`
> (Overlay-based) and `showCustomSnackBar` (toastification). A third legacy
> global is `flutter_easyloading` (37 refs) whose config in `main.dart:53-64`
> is **off-brand** (yellow/green/blue), see §7.

---

## 6. Layout & Responsive Rules

- **Base model:** phone-only. Prototype target 400px wide; no tablet/desktop layout.
- **Screen scaffold:** `Scaffold(backgroundColor: TaColors.background)` +
  `SafeArea` (24 refs). Most screens are `SafeArea(bottom: false)` inside the
  bottom-nav shell, then a `SingleChildScrollView`/`ListView` with
  `fromLTRB(20, 26, 20, …)`.
- **Keyboard handling:** `KeyboardDismisser` wraps the whole app
  (`root_main.dart:19-23`, dismiss on tap and downward pan). Sheet content adds
  `MediaQuery.viewInsetsOf` bottom padding (`ride_credit_row.dart:164`;
  map sheet measures its own `maxHeight`, `map_bottom_sheet.dart:56-70`).
- **Text scaling:** OS scale respected but clamped `1.0–1.3` (`root_main.dart:48-51`).
- **`TaTextStyles` does not scale with the `.d` extension.** Only map/booking
  geometry uses `.d`; this creates two sizing systems in one app.
- **Transitions:** `GetMaterialApp` default `Transition.cupertino`, 500ms
  (`root_main.dart:29-30`).
- **Montserrat/Inter/etc.:** none — one family only.

---

## 7. Inconsistencies, Duplicates & Hardcoded Values

### 7.1 Tokens defined but unused

| Token file | Status |
|---|---|
| `ta_spacing.dart` (`TaSpacing`) | **0 references** — scale declared but never applied |
| `TaTextStyles.labelSmall` | 0 references |
| `TaTextStyles.overline` | 0 references |
| `KhmerMoul`, `TimesNewRomance`, `KantumruyPro-SemiBold`, `KantumruyPro-Regular` | Declared in `pubspec.yaml`, not referenced in code |
| `TaColors.info` | Declared, rarely referenced directly |

### 7.2 Hardcoded colours that should be tokens

| Value | Where | Should map to |
|---|---|---|
| `#E8EAF0` | `ta_segment.dart:35` (segment track) | nearest `border`/`disabledBg` |
| `#E7E8EE` | `ta_timeline.dart:62,113` | neutral step |
| `#DCDDE5` | `ta_star_rating.dart:63`, `ta_step_indicator.dart:41` | inactive dot/star |
| `#EDEEF2`, `#F7F7FA` | `ta_skeleton.dart`, `loading_shimmer.dart`, `card_board_shimmer_widget.dart` | skeleton sheen (3 copies) |
| `#D9D9D9` | `card_board_shimmer_widget.dart:15` | skeleton base |
| `#F5A623` | `ta_driver_card.dart:62`, `ta_star_rating.dart:63` | **rating gold — not a token** |
| `#E3E5EC` | `ta_address_row.dart:38` | pickup dot halo |
| `#4ADE80` | `ta_status_pill.dart:79` | online green (differs from `success #0EAF6B`) |
| `#E4E5EB` | `splash_screen/view.dart:143` | loader track |
| `#7A5200` | `calculate_fee/widgets/fee_waiting_banner.dart:30` | darker warning text for contrast |
| `#FF6A00`, `#E63E00` | `ta_total_box.dart:24` | orange gradient |
| `#232838`,`#3A2C28`,`#572C12` | `ta_promo_banner.dart:33` | promo gradient |
| `#2F6BFF`,`#7A5CFF`,`#FF6A00`,`#B73CFF` | `ta_avatar.dart:44-45` | avatar gradients |
| `#D8E6FF` | `announcement_detail/view.dart:167` | fallback gradient |
| `Colors.black87` | `app/logic.dart:247` | should be `textPrimary` |
| `Colors.blue` | `google_map_logic.dart:300` (polyline default) | map polyline |
| `Colors.yellow/green/blue` | `main.dart:59-64` (EasyLoading global config) | **entirely off-brand** |
| `Colors.black` | `invite/scan_view.dart:53` (scanner background) | intentional (camera) |

### 7.3 Duplicated / parallel systems

- **Three shimmer implementations** with overlapping colours: `TaSkeleton`
  (token-adjacent), `LoadingShimmer`, `CardBoardShimmer`.
- **Two modal-sheet helpers** (`gShowModalBottomSheet`, `xShowModalBottomSheet`)
  plus `TaBottomSheet` — all three re-implement the same 22px/`TaGrabHandle` chrome.
- **Two toast systems**: `TaToast` vs `showCustomSnackBar` (toastification).
- **Two full-screen loaders**: `TaLoadingOverlay` vs `LoadingWidget`.
- **Two OTP renderers**: `TaOtpField` (unused on the OTP screen) vs `Pinput` in
  `otp/view.dart`.
- **Two avatar gradients** and **two FAB-like dark circles** (`InviteFab`, plate badge).

### 7.4 Typography inconsistencies

- 104 raw `fontSize:` + 90 raw `TextStyle(` literals outside the theme.
- Sizes `18, 20, 22, 28, 36, 40` are used that have no token counterpart.
- `TaKVRow` value text has **no explicit colour** (`ta_kv_row.dart:33`), so it
  falls back to the ambient `DefaultTextStyle` — the only display row without a
  token colour.
- `ta_theme.dart` sets `textTheme` but individual widgets rarely consume it,
  so most text bypasses the theme.

### 7.5 Shape/geometry inconsistencies

- Timers/toasts/fields repeat hardcoded radii (`14`) instead of `radiusMd`.
- Sheet radius is `TaRadius.radiusXxl` in `map_bottom_sheet.dart:76` but literal
  `22` in `ta_bottom_sheet.dart:20`, `booking_sheet.dart:73`, `g/x showmodal`.
- The `.d` diagonal scaling is applied only in map/booking screens; the rest of
  the app ignores it, so the same physical gap can render at different sizes.

### 7.6 Theme gaps

- **No dark theme** and no `ThemeMode` — the app can only be light.
- **No Material `AppBar` theme** because no `AppBar` is used; headers are custom.
- `ColorScheme` maps `onSurface`/`onSecondary` to `Colors.black`, which is not a
  token.

---

## 8. Source Map (design decision → implementation)

| Design decision | Implementation file / symbol |
|---|---|
| Colour palette | `lib/core/theme/ta_colors.dart` → `TaColors` |
| Theme assembly / ColorScheme | `lib/core/theme/ta_theme.dart` → `TaTheme.lightTheme` |
| Theme applied to app | `lib/app/root_main.dart:34` |
| Type scale | `lib/core/theme/ta_text_styles.dart` → `TaTextStyles` |
| Base font family | `ta_theme.dart:28`, `ta_text_styles.dart:12` |
| Spacing scale (declared, unused) | `lib/core/theme/ta_spacing.dart` → `TaSpacing` |
| Corner radius scale | `lib/core/theme/ta_radius.dart` → `TaRadius` |
| Elevation scale | `lib/core/theme/ta_shadow.dart` → `TaShadows` |
| Motion tokens / reduced motion | `lib/core/utils/motion.dart` → `Motion`, `prefersReducedMotion` |
| Diagonal scaling `.d` | `lib/core/utils/app_ext.dart:29-43`, `lib/core/utils/screen_util.dart` |
| Legacy decoration helper | `lib/core/utils/get_decoration.dart` → `getBoxDecoration` |
| Asset paths | `lib/core/resources/asset_resource.dart` → `ImageAssets` |
| Component barrel | `lib/presentation/widgets/widgets.dart` |
| Button system | `lib/presentation/widgets/ta_button.dart` |
| Press animation | `lib/presentation/widgets/ta_pressable.dart` |
| Inputs | `ta_text_field.dart`, `ta_otp_field.dart`, `ta_note_field.dart` |
| Cards / sheets / dialogs / toast | `ta_card.dart`, `ta_bottom_sheet.dart`, `ta_dialog.dart`, `ta_toast.dart` |
| Navigation | `ta_bottom_nav.dart`, `lib/presentation/screens/bottom_nav/view.dart` |
| Loading / empty / error | `ta_skeleton.dart`, `ta_loading_overlay.dart`, `loading_widget.dart`, `empty_data.dart` |
| Global Easyloading config (off-brand) | `lib/main.dart:53-64` |
| Text-scale clamp | `lib/app/root_main.dart:48-51` |
| Transition | `lib/app/root_main.dart:29-30` |
| Screen padding convention | e.g. `login/view.dart:45`, `otp/view.dart:57`, `receipt/view.dart:56` |

---

## 9. Open Items ("Needs verification")

- Whether the variable font's `wght` axis actually renders w600/w700/w800 on all
  platforms (the code sets both `fontWeight` and `fontVariations`; the source
  comment at `ta_text_styles.dart:8-10` flags this as unverified in P3).
- Contrast of `TaColors.warning` on `warningBg` is documented as 3.3:1 and
  worked around with `#7A5200` in `fee_waiting_banner.dart:28-30`; a full
  contrast audit of all token pairings was not performed.
- Exact rendered form of the three declared-but-unused font families (not found
  in code; presumed dead config).
