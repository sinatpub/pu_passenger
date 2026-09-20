# Phase 3 — Design Tokens

## 1. Colors

### Primary Palette (`lib/core/theme/colors.dart` — `AppColors`)

| Token | Hex | Usage |
|---|---|---|
| `main` | `#FF4500` | Primary brand color, buttons, accents, cursor |
| `red` | `#FF1100` | Intense red variant |
| `darker` | `#CC3700` | Dark primary variant |
| `lighter` | `#FFA84C` | Light primary variant |
| `subtitle` | `#FFA07A` | HintColor in theme |
| `error` | `#D32F2F` | Error states, error borders |
| `info` | `#1976D2` | Informational states |
| `success` | `#10CF7C` | Success states, "Completed" badge |

### Neutrals

| Token | Hex | Usage |
|---|---|---|
| `dark1` | `rgb(0,0,0)` | Drag handle, primary text |
| `dark2` | `#6B7588` | Hint text, secondary text |
| `dark3` | `#8F90A6` | Tertiary text |
| `dark4` | `#C7C9D9` | Quaternary text |
| `light1` | `#E2E2E5` | Borders, dividers |
| `light2` | `#EBEBF0` | Subtle backgrounds |
| `light3` | `#F6F6F7` | Card backgrounds, upload card |
| `light4` | `#FAFAFC` | Scaffold background |

### Material 3 ColorScheme Mapping (`lib/core/theme/app_theme.dart`)

| Scheme Key | Token |
|---|---|
| `primary` | `AppColors.main` |
| `secondary` | `AppColors.lighter` |
| `error` | `AppColors.error` |
| `surface` | `AppColors.light3` |
| `onPrimary` | `Colors.white` |
| `onSecondary` | `Colors.black` |
| `onSurface` | `Colors.black` |
| `onError` | `Colors.white` |

### Hard-Coded Colors in Components

| Component | Color | Location |
|---|---|---|
| Vehicle card background | `AppColors.main.withOpacity(0.8)` | `home/view.dart` |
| Vehicle card center (VIP) | `AppColors.main` | `home/view.dart` |
| "Booking Now" button | `AppColors.main` | `fbtn_widget.dart` |
| Error dialog button | `Colors.red` | `error_dialog_widget.dart` |
| Yes dialog button | `Colors.red` | `yesno_dialog_widget.dart` |
| Loading overlay | `Colors.grey.withOpacity(.3)` | `loading_widget.dart` |
| Snack border | `Colors.red[200]` | `custom_snackbar_widget.dart` |
| Status "Completed" | `AppColors.success` | `history_card_widget.dart` |
| Status "Cancelled" | `AppColors.error` | `history_card_widget.dart` |
| Total price section | `AppColors.main` bg | `calculate_fee_screen.dart` |
| Text field shadow | `rgba(0,0,0,0.25)` offset (0,2) blur 5 | `text_field_decoration.dart` |
| DecoratedInputBorder shadow | `rgba(96,96,96,0.17)` offset (0,4) blur 14 | `decorated_input_border.dart` |

---

## 2. Typography

### Font Families

| Family | Files | Usage |
|---|---|---|
| `KantumruyPro` | `fonts/KantumruyPro-VariableFont_wght.ttf` | **Primary UI font** — all text |
| `KantumruyPro-Regular` | `fonts/KantumruyPro-Regular.ttf` | Regular weight text |
| `KantumruyPro-SemiBold` | `fonts/KantumruyPro-SemiBold.ttf` | Bold headings |
| `KhmerMoul` | `fonts/moul_regular.ttf` | "តារា" brand text on Home |
| `TimesNewRomance` | `fonts/timesNewRomance.ttf` | Invoice text (if used) |

**Note:** `fontFamilyFallback: ['KantumruyPro']` is set in `ThemeConstands`.

### AppTextStyles (Global)

| Style | Size | Weight | Color |
|---|---|---|---|
| `heading` | 24 | Bold | Black |
| `body` | 16 | Normal | Black |
| `bodyDark` | 16 | Normal | White |

### ThemeConstands (Named Styles)

All use `KantumruyPro` family:

| Style Name | Family | Size | Weight |
|---|---|---|---|
| `font10Regular` | KantumruyPro-Regular | 10.0 | Normal |
| `font10SemiBold` | KantumruyPro-SemiBold | **14.0** ⚠️ | SemiBold |
| `font12Regular` | KantumruyPro-Regular | 12.0 | Normal |
| `font12SemiBold` | KantumruyPro-SemiBold | 12.0 | SemiBold |
| `font14Regular` | KantumruyPro-Regular | 14.0 | Normal |
| `font14SemiBold` | KantumruyPro-SemiBold | 14.0 | SemiBold |
| `font16Regular` | KantumruyPro-Regular | 16.0 | Normal |
| `font16SemiBold` | KantumruyPro-SemiBold | 16.0 | SemiBold |
| `font18Regular` | KantumruyPro-Regular | 18.0 | Normal |
| `font18SemiBold` | KantumruyPro-SemiBold | 18.0 | SemiBold |
| `font20Regular` | KantumruyPro-Regular | 20.0 | Normal |
| `font20SemiBold` | KantumruyPro-SemiBold | 20.0 | SemiBold |
| `font22Regular` | KantumruyPro-Regular | 22.0 | Normal |
| `font22SemiBold` | KantumruyPro-SemiBold | 22.0 | SemiBold |
| `font24Regular` | KantumruyPro-Regular | 24.0 | Normal |
| `font24SemiBold` | KantumruyPro-SemiBold | 24.0 | SemiBold |
| `font28Regular` | KantumruyPro-Regular | 28.0 | Normal |
| `font28SemiBold` | KantumruyPro-SemiBold | 28.0 | SemiBold |

**⚠️ Bug:** `font10SemiBold` declares size `14.0`, not `10.0`. The name is misleading.

**Typography Scale:** 10, 12, 14, 16, 18, 20, 22, 24, 28 — each with Regular and SemiBold variants. Two weights only: Normal and SemiBold. No line heights defined.

---

## 3. Spacing

### Diagonal-Based Responsive Sizing

File: `lib/core/utils/app_ext.dart`

The app uses a custom responsive sizing extension `.d`:
```dart
extension ScreenUtilInt on int {
  double get d => this / 1000 * ScreenUtilHelper.instance.deviceDiagonal;
}
extension ScreenUtilDouble on double {
  double get d => this / 1000 * ScreenUtilHelper.instance.deviceDiagonal;
}
```

`deviceDiagonal` = `sqrt(height² + width²)` — typically ~880 on a standard phone.

**Usage in code:** `28..d`, `48..d`, `18..d`, `10..d` etc. — all spacing is relative to screen diagonal.

### No Consistent Spacing Scale

There is **no documented spacing scale**. Values are hard-coded per screen:

| Value Used | Frequency |
|---|---|
| 8 | Padding inside components |
| 10 | Small gaps, image padding |
| 12 | Form field label spacing |
| 16-18 | Medium gaps |
| 28 | Auth screen vertical spacing |
| 32-38 | Large gaps |
| 48 | Major section spacing |

---

## 4. Corner Radius

### Component-Level Values

| Component | Radius | Location |
|---|---|---|
| Vehicle cards | 12 | `home/view.dart` |
| History cards | 12 | `history_card_widget.dart` |
| Announcement cards | 12 | `announcement/view.dart` |
| Text fields | 8-10 | `x_text_field.dart`, `text_field_decoration.dart` |
| Bottom sheets | 18 (top only) | `g_showmodal_bottom.dart`, `x_showmodal_bottom.dart` |
| Upload card | 10 | `card_atta_widget.dart` |
| XButton overlay | 8 | `x_button.dart` |
| FBTNWidget button | `AppConstant.padding02` | `fbtn_widget.dart` |
| Snackbar | 18 | `custom_snackbar_widget.dart` |
| EasyLoading | 18 | `main.dart` |

**No consistent radius scale.** Common values: 8, 10, 12, 18.

---

## 5. Shadows / Elevation

| Component | Shadow | Location |
|---|---|---|
| Text fields | `BoxShadow(color: rgba(0,0,0,0.25), offset: (0,2), blur: 5)` | `text_field_decoration.dart` |
| DecoratedInputBorder | `BoxShadow(color: rgba(96,96,96,0.17), offset: (0,4), blur: 14)` | `decorated_input_border.dart` |
| History cards | `BoxShadow(color: rgba(0,0,0,0.05), offset: (0,4), blur: 10)` | `history_card_widget.dart` |
| Map appbar buttons | `BoxShadow(color: rgba(0,0,0,0.3), offset: (0,2), blur: 6)` | `map_appbar.dart` |
| FBTNWidget | `elevation: 0.5` | `fbtn_widget.dart` |
| Theme cardTheme | `elevation: 0` | `app_theme.dart` |
| Theme appBarTheme | `elevation: 0` | `app_theme.dart` |

---

## 6. Theme Configuration

File: `lib/core/theme/app_theme.dart`

```dart
ThemeData.light().copyWith(
  primaryColor: AppColors.main,
  primaryColorLight: AppColors.lighter,
  primaryColorDark: AppColors.darker,
  scaffoldBackgroundColor: AppColors.light4,
  fontFamily: "KantumruyPro",
  hintColor: AppColors.subtitle,
  colorScheme: ColorScheme.light(
    primary: AppColors.main,
    secondary: AppColors.lighter,
    error: AppColors.error,
    surface: AppColors.light3,
    onPrimary: Colors.white,
    onSecondary: Colors.black,
    onSurface: Colors.black,
    onError: Colors.white,
  ),
  cardTheme: CardTheme(elevation: 0),
  appBarTheme: AppBarTheme(elevation: 0),
  useMaterial3: true,
)
```

### Additional Theme Config in Root

File: `lib/app/root_main.dart`

- Route transitions: `Transition.cupertino`, 500ms
- Text scale: clamped to `1.0–1.3` (accessibility)
- Builder applies: `EasyLoading.init()`, `MediaQuery` text scale override

---

## 7. Layout Patterns

### Responsive Sizing

- **Custom:** `.d` extension (diagonal-based) used for padding/margins
- **No flutter_screenutil** or other responsive framework
- **No fixed layout constants file**

### Common Layout Patterns

| Pattern | Values | Usage |
|---|---|---|
| Screen horizontal margin | 16-24 | Auth screens, forms |
| Card padding | 16 | History, announcements |
| Section spacing | 28-48 | Auth screens |
| Button height | 38 | FBTNWidget |
| Avatar sizes | 80 (profile), 140 (upload), 160 (register) | Various |
| Icon sizes | 20-30 | Map, nav |

---

## 8. Light/Dark Theme

**The app only implements a light theme.** No dark theme or theme switching is present.

`ThemeData.light()` is the only theme configured in `AppTheme.lightTheme`.

---

## 9. Icon System

- **Navigation:** SVG icons from `assets/nav_icon/` (home, book, profile — outline and filled variants)
- **Map:** SVG markers from `assets/marker/` (passenger, driver, destination, vehicle types)
- **UI:** Mix of Material Icons (`Icons.home`, `Icons.person`, `Icons.event`) and SVG assets
- **Flutter Icons:** CupertinoIcons used in Profile screen (doc_text, person_crop_circle_fill)
- **No icon font** beyond Material and Cupertino defaults

---

## 10. Design Token Issues and Inconsistencies

### Confirmed Issues

1. **`font10SemiBold` mislabeled:** Named "10" but size is `14.0` (`text_styles.dart:29-30`)
2. **No spacing scale:** Values scattered across screens with no central definition
3. **No radius scale:** Corner radii vary per component (8, 10, 12, 18)
4. **Shadow inconsistency:** Multiple different shadow specs across components
5. **Hard-coded colors in widgets:** Many components define their own colors instead of using `AppColors`
6. **No dark theme:** Only light theme implemented
7. **Typography:** Only 2 weights (Normal, SemiBold) — no Medium, Bold, or Light
8. **Line heights:** Not defined in any text style
9. **`.d` extension:** Non-standard responsive approach — not intuitive for developers
10. **Mixed font families:** `KhmerMoul` and `TimesNewRomance` used in specific spots alongside `KantumruyPro`
