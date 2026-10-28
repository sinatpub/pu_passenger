# Design System Inventory (as-implemented)

> Documents the actual tokens and reusable components in the code, including
> inconsistent and duplicated implementations. Detail cross-references the
> fuller `docs/passenger_design_system.md`; this file is the audit-oriented
> inventory. All claims **[SRC]**.

---

## 1. Theme wiring

| Item | Value / location |
|---|---|
| Theme object | `TaTheme.lightTheme` — `lib/core/theme/ta_theme.dart:11` |
| Applied | `GetMaterialApp(theme: TaTheme.lightTheme)` — `lib/app/root_main.dart:34` |
| Brightness | `Brightness.light` only (`ta_theme.dart:13`); **no dark theme** (0 hits for `darkTheme`/`ThemeMode`/`Brightness.dark`) |
| ColorScheme | `ColorScheme.light(primary: primary, secondary: primaryLight, error: error, surface: surface, onPrimary: white, onSecondary: black, onSurface: black, onError: white)` — `ta_theme.dart:14-23` |
| Scaffold bg | `TaColors.background` (`ta_theme.dart:27`) |
| Font family | `'KantumruyPro'` (`ta_theme.dart:28`) |
| Hint color | `TaColors.textMuted` (`ta_theme.dart:29`) |
| `useMaterial3` | `true` (`ta_theme.dart:31`) |
| Text scaling | clamped 1.0–1.3 — `lib/app/root_main.dart:48-51` |
| Direct `Theme.of(context)` reads | **2** in the whole app |

## 2. Color tokens — `lib/core/theme/ta_colors.dart`

`abstract final class TaColors`:

| Token | HEX | Role |
|---|---|---|
| `primary` | `#FF4500` | brand, CTA, active, focus |
| `primaryDark` | `#CC3700` | pressed brand, price text |
| `primaryLight` | `#FFA84C` | secondary accent, empty icon |
| `primaryBg` | `#FFF4ED` | selected fills, timer pill |
| `primaryBorder` | `#FFE4D3` | focus/glow, spinner track |
| `background` | `#F6F6F7` | scaffold |
| `surface` | `#FFFFFF` | cards/fields/sheets |
| `textPrimary` | `#191C24` | headings/body |
| `textSecondary` | `#6B7588` | descriptions/labels |
| `textMuted` | `#9AA0B4` | hints/captions |
| `border` | `#EBEBF0` | borders/dividers |
| `success` | `#0EAF6B` / `successBg` `#E6F8EF` | success states |
| `error` | `#D32F2F` / `errorBg` `#FDECEC` | errors |
| `warning` | `#B97A00` / `warningBg` `#FFF4D6` | pending |
| `info` | `#2F6BFF` | informational (rarely used) |
| `dark` | `#232838` | navy buttons/pills |
| `disabledBg` | `#D8DBE3` / `disabledText` `#FFFFFF` | disabled |
| `overlay` | `rgba(15,17,25,0.5)` | barriers |
| `toastBg` | `#232838` / `toastIcon` `#7CFFB2` | toast |

## 3. Typography — `lib/core/theme/ta_text_styles.dart`

`abstract final class TaTextStyles`, family `KantumruyPro`, weights via
`fontVariations: [FontVariation('wght', N)]`:

| Role | Size / Weight / Height |
|---|---|
| `displayLarge` | 30 / w800 / 1.2 |
| `headlineLarge` | 24 / w800 / 1.25 |
| `headlineMedium` | 17 / w700 / 1.3 |
| `titleLarge` | 16 / w700 / 1.2 |
| `titleMedium` | 15 / w700 / 1.3 |
| `bodyLarge` | 15 / w400 / 1.5 |
| `bodyMedium` | 13 / w400 / 1.4 |
| `bodySmall` | 12 / w400 / 1.3 |
| `labelLarge` | 14 / w700 / 1.3 |
| `labelMedium` | 13 / w600 / 1.3 |
| `labelSmall` | 12 / w700 / 1.3 — **0 usages** |
| `overline` | 11 / w600 / 1.3 — **0 usages** |

`TaTextStyles.textTheme` is installed on the theme; only 1 direct reference to
`TaTextStyles.textTheme`.

**Font families declared in `pubspec.yaml:166-181`:** `KhmerMoul`,
`TimesNewRomance`, `KantumruyPro`, `KantumruyPro-SemiBold`,
`KantumruyPro-Regular`. **Only `KantumruyPro` is referenced in Dart**; the other
four are dead config.

## 4. Spacing, radius, shadow, motion

- **Spacing** — `lib/core/theme/ta_spacing.dart` (`TaSpacing`): `space2…space48`.
  ⚠️ **0 references in `lib/`.** All spacing is literals. De-facto values:
  screen h-padding `20`, top `26`, card `16`, field `14`, dialog `22`.
- **Radius** — `lib/core/theme/ta_radius.dart` (`TaRadius`): `sm 8, md 12,
  lg 16, xl 20, xxl 22, full 99`. Only **10** `TaRadius.*` references; many
  components hardcode `14`, `9`, `10`, `3`, `28`, `20`, `22`.
- **Shadow** — `lib/core/theme/ta_shadow.dart` (`TaShadows`): `sm 0 2 6
  rgba(20,22,30,.08)`, `md 0 4 14 rgba(20,22,30,.10)`, `lg 0 12 34
  rgba(20,22,30,.18)`. 24 references; component-specific shadows hardcoded on top.
- **Motion** — `lib/core/utils/motion.dart` (`Motion`): `fast 120ms, medium
  200ms, base 280ms, ambient 1100ms` + `prefersReducedMotion()`.
- **Responsive `.d`** — `lib/core/utils/app_ext.dart:29-43` (diagonal scaling);
  86 usages, confined to map/booking screens. No `flutter_screenutil`,
  no `.w/.h/.sp/.r`.

## 5. Reusable component inventory (`lib/presentation/widgets/`)

Barrel: `widgets.dart`. Static counts of `TaColors.` = 378, `TaTextStyles.` = 111,
`TaShadows.` = 24, `TaRadius.` = 10, `TaSpacing.` = 0.

| Component | File | Key styling |
|---|---|---|
| `TaButton` | `ta_button.dart` | variants `primary/dark/ghost/dangerGhost`; sizes `large` (52, r16, 16) / `small` (44, r12, 14); w700; primary shadow `primary@.35 blur16` |
| `TaPressable` | `ta_pressable.dart` | press scale 0.97 @100ms |
| `TaIconButton` | `ta_icon_button.dart` | drawn 42, hit area 48; icon `size*0.48`; `shadowSm`; `.dot()` |
| `TaTextField` | `ta_text_field.dart` | h54, r14, border 1.5; prefix bold + rule; hint/error; error min-height 18 |
| `TaOtpField` | `ta_otp_field.dart` | N boxes — **not used on the OTP screen** (which uses `Pinput`) |
| `TaNoteField` | `ta_note_field.dart` | bg background, r12 |
| `TaCard` | `ta_card.dart` | pad 16, r16 (`radiusLg`), `shadowMd` |
| `TaBottomSheet` | `ta_bottom_sheet.dart` | top r22, `TaGrabHandle` 44×5, barrier `overlay`, pad `20/0/20/26` |
| `TaDialog` / `TaDialogCard` / `TaDialogIcon` | `ta_dialog.dart` | r20, pad 22, scale pop `(0.2,0.9,0.3,1.2)`, 56px icon |
| `TaToast` | `ta_toast.dart` | navy pill, r14, auto 2400ms |
| `TaSegment` | `ta_segment.dart` | track `#E8EAF0`, selected white+`shadowSm`, 13/w700 |
| `TaStepIndicator` | `ta_step_indicator.dart` | 26×5 dots, active `primary`, inactive `#DCDDE5` |
| `TaChip` | `ta_chip.dart` | pill, selected `primaryBg`/`primary` 1.5 |
| `TaBadge` | `ta_badge.dart` | pill, 12/w700, success/error/warning/brand |
| `TaStatusPill` | `ta_status_pill.dart` | navy pill, pulsing `#4ADE80` dot |
| `TaStarRating` | `ta_star_rating.dart` | stars `#F5A623`/`#DCDDE5`, pop 1.3 @250ms |
| `TaAvatar` | `ta_avatar.dart` | driver 52/history 44/profile 48/register 120; gradients |
| `TaBottomNav` / `TaNavItem` | `ta_bottom_nav.dart` | top hairline `border`, active `primary` |
| `TaAddressRow`, `TaKVRow`, `TaTimeline`, `TaStatRow`, `TaProfileRow`, `TaHistoryCard`, `TaTripCard`, `TaDriverCard`, `TaVehicleRow`, `TaTotalBox`, `TaPromoBanner`, `TaSearchCard`, `TaSearchResult`, `TaMinimaxSheet`, `TaCenterPin`, `EmptyData` | respective files | see `docs/passenger_design_system.md` §5 |

Legacy/parallel widgets still present: `loading_widget.dart`, `center_loading.dart`,
`custom_animated_loading.dart`, `loading_shimmer.dart`, `card_board_shimmer_widget.dart`,
`g_showmodal_bottom.dart`, `x_showmodal_bottom.dart`, `custom_snackbar_widget.dart`,
`error_dialog_widget.dart`, `yesno_dialog_widget.dart`, `shake_widget.dart`,
`x_network_image.dart`.

## 6. Duplication & inconsistency register (audit-critical)

| ID | Issue | Evidence |
|---|---|---|
| DS-01 | `TaSpacing` unused — literal spacing everywhere | 0 refs to `TaSpacing.`; 104 raw `fontSize:` values |
| DS-02 | `labelSmall`, `overline` unused | 0 refs each |
| DS-03 | 4 unused font families | `pubspec.yaml:166-181` vs 0 Dart refs |
| DS-04 | 3 shimmer systems | `ta_skeleton.dart`, `loading_shimmer.dart`, `card_board_shimmer_widget.dart` share `#EDEEF2/#F7F7FA` |
| DS-05 | 3 sheet helpers + direct `showModalBottomSheet` | `ta_bottom_sheet`, `x_showmodal_bottom`, `g_showmodal_bottom` |
| DS-06 | 2 toast systems | `TaToast` vs `toastification` `showCustomSnackBar` |
| DS-07 | 2+ full-screen loaders | `TaLoadingOverlay`, `LoadingWidget`, `CenterLoading`, `EasyLoading` |
| DS-08 | 2 OTP renderers | `TaOtpField` (unused) vs `Pinput` in `otp/view.dart` |
| DS-09 | Rating gold `#F5A623` not tokenized | `ta_driver_card.dart:62`, `ta_star_rating.dart:63` |
| DS-10 | Online green `#4ADE80` ≠ `success #0EAF6B` | `ta_status_pill.dart:79` |
| DS-11 | Neutral hexes not tokenized | `#E8EAF0`, `#E7E8EE`, `#DCDDE5`, `#E4E5EB`, `#E3E5EC` |
| DS-12 | Off-brand global `EasyLoading` config | `main.dart:53-64` (`Colors.yellow/green/blue`) |
| DS-13 | `TaKVRow` value has no explicit color | `ta_kv_row.dart:33` |
| DS-14 | Radius literals bypass scale | `14` repeated across ~8 components; sheets sometimes `22` literal |
| DS-15 | `.d` responsive used only in map/booking | `app_ext.dart`; 86 refs in 11 map/booking files only |

## 7. Asset inventory (`lib/core/resources/asset_resource.dart`, `assets/`)

- **Brand:** `assets/launcher/launcher_passenger_1024.png` (`ImageAssets.brandMark`), `assets/image/company_logo.png`, `assets/logo_app.png` (unused by `ImageAssets`).
- **Nav (SVG, tinted):** `assets/nav_icon/{home-angle-2-svgrepo-com,home,book,book_outline,profile,profile_fill}.svg`.
- **UI icons (SVG):** `assets/icon/svg/{bxs_map,current_location,date_time,humbleicons_dashboard,logout 1,logout-exit-svgrepo-com,logout-svgrepo-com,map_out,payment_out,time_out,typcn_pin-outline,where_to_go}.svg` (three duplicate logout icons).
- **Vehicle art (SVG):** `assets/image/svg/vehicle_{classic,mini_van,moto,suv,tuk_tuk,vip}.svg`.
- **Markers (PNG/SVG):** `assets/marker/*` (car, classic, moto, mini, suv, rickshaw, passenger, current_marker.svg, destination_icon.png).
- **Maps:** `assets/image/png/map_placeholder.png`, `assets/image/svg/no_image.svg`.
- **Flags:** `assets/image/country/*`.
- **Sound:** `assets/sounds/booking_sound.wav` (booking notification).

## 8. Design-system risk summary

1. **Token drift:** the palette/type/radius/motion are tokenized, but spacing is
   not used at all, and neutral/status/rating colors are hardcoded — a redesign
   that only swaps tokens will not reach every surface.
2. **Multiple parallel primitives** for the same job (loaders, toasts, sheets,
   OTP) will make a PassApp-style visual refresh inconsistent unless consolidated
   first.
3. **`.d` split model:** only the map/booking flow scales to screen size; the
   rest is fixed logical pixels — a responsiveness risk for larger phones.
