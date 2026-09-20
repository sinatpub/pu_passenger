# 02 — Design System

All values below are extracted directly from `taarraa-ui-prototype.html` `:root` variables and component styles. This is the single source of truth.

---

## Colors

### CSS Variables (Prototype)

```css
--brand:      #FF4500;
--brand-dark: #CC3700;
--brand-light:#FFA84C;
--brand-50:   #FFF4ED;
--brand-100:  #FFE4D3;

--ink:   #191C24;
--sub:   #6B7588;
--muted: #9AA0B4;
--line:  #EBEBF0;
--bg:    #F6F6F7;
--card:  #fff;

--green:    #0EAF6B;
--green-bg: #E6F8EF;
--red:      #D32F2F;
--red-bg:   #FDECEC;
--amber:    #B97A00;
--amber-bg: #FFF4D6;
--blue:     #2F6BFF;
--navy:     #232838;
```

### Semantic Color Tokens (Flutter)

```
Primary:
  primary         = #FF4500   (--brand — brand color, CTAs, active states)
  primaryDark     = #CC3700   (--brand-dark — pressed, text on brand bg)
  primaryLight    = #FFA84C   (--brand-light — secondary brand accent)
  primaryBg       = #FFF4ED   (--brand-50 — subtle brand backgrounds, active pill bg)
  primaryBorder   = #FFE4D3   (--brand-100 — focus rings, spinner track, badge bg)

Surface:
  background      = #F6F6F7   (--bg — scaffold background)
  surface         = #FFFFFF   (--card — cards, sheets, panels)

Text:
  textPrimary     = #191C24   (--ink — headings, primary content)
  textSecondary   = #6B7588   (--sub — descriptions, body text)
  textMuted       = #9AA0B4   (--muted — captions, disabled text, tab inactive)

Border:
  border          = #EBEBF0   (--line — field borders, dividers, card separators)

State:
  success         = #0EAF6B   (--green — completed badges, paid status)
  successBg       = #E6F8EF   (--green-bg — success badge background)
  error           = #D32F2F   (--red — errors, destructive actions, cancelled)
  errorBg         = #FDECEC   (--red-bg — error badge background, danger-ghost bg)
  warning         = #B97A00   (--amber — pending, waiting)
  warningBg       = #FFF4D6   (--amber-bg — warning badge background)
  info            = #2F6BFF   (--blue — informational)

Dark:
  dark            = #232838   (--navy — dark buttons, status pill, plate badge, promo bg)

Disabled:
  disabledBg      = #D8DBE3   (disabled button background)
  disabledText    = #FFFFFF   (disabled button text)

Overlay:
  overlay         = rgba(15,17,25,0.5)   (backdrop for sheets, dialogs)

Feedback:
  toastBg         = #232838   (--navy — toast background)
  toastIcon       = #7CFFB2   (mint check icon in toast)
```

### Old → New Token Mapping

| Old Token (`AppColors`) | New Token | Notes |
|---|---|---|
| `main` | `primary` | Same value |
| `red` | `primaryDark` | Same value, semantic rename |
| `lighter` | `primaryLight` | Same value, semantic rename |
| `subtitle` | Remove | Was hintColor; use `textMuted` |
| `dark1` | `textPrimary` | Semantic rename |
| `dark2` | `textSecondary` | Semantic rename |
| `dark3` | `textMuted` | Semantic rename |
| `dark4` | `textMuted` (context) | Used for disabled text |
| `light1` | `border` | Semantic rename |
| `light2` | `border` | Same as light1 |
| `light3` | `background` | Semantic rename |
| `light4` | `background` | Same as light3 |
| — | `primaryBg` | NEW — brand-50 |
| — | `primaryBorder` | NEW — brand-100 |
| — | `dark` | NEW — navy |
| — | `success` | Changed from #10CF7C to #0EAF6B |
| — | `warning` | Changed from #F59E0B to #B97A00 |

---

## Typography

### Font System

**Primary:** KantumruyPro (variable weight, Khmer + Latin)
**Weights used:** ExtraBold (800), Bold (700), Regular (400)

### Type Scale (Prototype)

| Role | CSS Class | Size | Weight | Line Height | Usage |
|---|---|---|---|---|---|
| Display | `.splash-name` | 30 | 800 | 1.2 | Splash brand name |
| Heading | `h1` | 24 | 800 | 1.25 | Screen titles |
| Title | `h2` | 17 | 700 | 1.3 | Section titles, AppBar |
| Body | input/body | 15 | 400 | 1.5 | Primary body text, inputs |
| Caption | `.tiny` / small | 13 | 400 | 1.4 | Subtitles, descriptions |
| Label | `.lbl` | 13 | 600 | 1.3 | Form labels |
| Button | `.btn` | 16 | 700 | 1.2 | Button text |
| Link | `.link` | 14 | 700 | 1.3 | Text links |
| Badge | `.badge` | 12 | 700 | 1.3 | Status badges, tags |
| Tab | tabbar text | 11 | 600 | 1.3 | Bottom nav labels |
| Tab segment | `.seg button` | 13 | 700 | 1.3 | Segmented control labels |
| Price | `.pr` / `.amt` | 14-16 | 800 | 1.3 | Prices, amounts |
| Timer | `.timer` | 14 | 800 | 1.3 | OTP timer countdown |
| Small | `.tiny` | 12 | 400 | 1.3 | Footnotes, timestamps |

### Flutter Text Style Mapping

| Token Name | Size | Weight | Usage |
|---|---|---|---|
| `displayLarge` | 30 | 800 | Splash brand name |
| `headlineLarge` | 24 | 800 | Screen titles (h1) |
| `headlineMedium` | 17 | 700 | Section titles (h2), AppBar |
| `titleLarge` | 16 | 700 | Button text, prices |
| `titleMedium` | 15 | 700 | Secondary titles |
| `bodyLarge` | 15 | 400 | Primary body text, inputs |
| `bodyMedium` | 13 | 400 | Subtitles, descriptions |
| `bodySmall` | 12 | 400 | Footnotes, timestamps |
| `labelLarge` | 14 | 700 | Links, secondary actions |
| `labelMedium` | 13 | 600 | Form labels |
| `labelSmall` | 12 | 700 | Badges, tags, OTP timer |
| `overline` | 11 | 600 | Tab bar labels |

### Old → New Token Mapping

| Old Token (`ThemeConstands`) | New Token |
|---|---|
| `font28SemiBold` | `headlineLarge` (24/800) |
| `font20SemiBold` | `headlineMedium` (17/700) |
| `font18SemiBold` | `titleMedium` (15/700) |
| `font16SemiBold` | `titleLarge` (16/700) |
| `font16Regular` | `bodyLarge` (15/400) |
| `font14SemiBold` | `labelMedium` (13/600) |
| `font14Regular` | `bodyMedium` (13/400) |
| `font12SemiBold` | `labelSmall` (12/700) |
| `font12Regular` | `bodySmall` (12/400) |
| `font10SemiBold` | **REMOVE** (was mislabeled 14pt) |
| `font10Regular` | `overline` (11/600) |

---

## Spacing

### Scale (4px base grid)

```
space2  = 2px
space4  = 4px     (tab label vertical gap, badge inner padding)
space6  = 6px     (micro gaps, grab handle margin)
space8  = 8px     (card internal gaps, segment gap)
space10 = 10px    (icon-btn gap, row gap)
space12 = 12px    (card padding, sheet grab handle, section gaps)
space14 = 14px    (field border-radius, sheet top-radius, dialog padding)
space16 = 16px    (card padding, screen horizontal padding, section padding)
space18 = 18px    (splash subtitle margin)
space20 = 20px    (sheet bottom padding)
space22 = 22px    (dialog border-radius, sheet border-radius, tab bar radius)
space24 = 24px    (sheet bottom padding, large section gaps)
space32 = 32px    (splash loading bar margin, fee body padding)
space34 = 34px    (status bar height)
space44 = 44px    (grab handle width)
space48 = 48px    (between major sections, splash load bar margin)
```

### Prototype Spacing Usage

| Prototype Pattern | Spacing | Context |
|---|---|---|
| `.screen` padding | `46px top, 20px sides, 20px bottom` | Screen insets |
| `.card` padding | `16px` | Card internal |
| `.field` padding | `0 14px` | Input fields |
| `.btn` padding | `0` (uses height) | Buttons (52px height) |
| `.sheet` padding | `12px top (grab), 20px sides, 26px bottom` | Bottom sheets |
| `.dialog` padding | `22px` | Dialogs |
| `.prow` padding | `15px` | Profile rows |
| `.hcard` padding | `14px` | History cards |
| `.place` padding | `13px 14px` | Search results |
| `.status-pill` padding | `10px 18px` | Booking status |
| Auth screen horizontal | `20px` (from `.screen` padding) | Auth forms |

---

## Shape (Corner Radius)

### Tokens

| Token | Value | Prototype Usage |
|---|---|---|
| `radiusSm` | 8px | `.skel` (8px), tab active pill (14px), `.steps i` (99px) |
| `radiusMd` | 12px | `.icon-btn` (12px), `.hroute` (12px), `.note-field` (12px) |
| `radiusLg` | 16px | `.btn` (16px), `.card` (16px), `.place` (14px), `.promo` (16px) |
| `radiusXl` | 20px | `.dialog` (20px) |
| `radiusXxl` | 22px | `.sheet` (22px), `.tabbar` (22px) |
| `radiusFull` | 99px | `.badge`, `.seg`, `.tabbar` btn (14px inner), `.avatar-pick`, `.grab` |

### Component Radius Mapping

| Component | Radius | Token |
|---|---|---|
| Primary button `.btn` | 16px | `radiusLg` |
| Ghost button `.btn.ghost` | 16px | `radiusLg` |
| Danger ghost `.btn.danger-ghost` | 16px | `radiusLg` |
| Small button `.btn.sm` | 12px | `radiusMd` |
| Card `.card` | 16px | `radiusLg` |
| History card `.hcard` | 16px | `radiusLg` |
| Search result `.place` | 14px | — |
| Input field `.field` | 14px | — |
| OTP input `.otp` | 14px | — |
| Toast | 14px | — |
| Profile row `.prow` | 14px | — |
| Dialog `.dialog` | 20px | `radiusXl` |
| Bottom sheet `.sheet` | 22px | `radiusXxl` |
| Tab bar `.tabbar` | 22px | `radiusXxl` |
| Segmented `.seg` | 99px | `radiusFull` |
| Badge `.badge` | 99px | `radiusFull` |
| Avatar `.avatar-pick` | 99px | `radiusFull` |
| Status pill `.status-pill` | 99px | `radiusFull` |
| Grab handle `.grab` | 99px | `radiusFull` |
| Timer pill `.timer` | 99px | `radiusFull` |
| Brand logo badge `.logo-badge` | 28px | — |
| Total box `.total-box` | 16px | `radiusLg` |
| Promo `.promo` | 16px | `radiusLg` |
| Note field `.note-field` | 12px | `radiusMd` |
| Vehicle row `.veh` | 16px | `radiusLg` |
| Stat row `.stat3` | 14px | — |
| Notification dot | 99px | `radiusFull` |
| Bottom nav active pill | 14px | — |
| Bottom nav outer | 22px | `radiusXxl` |
| Splash loader `.splash-load` | 99px | `radiusFull` |
| Avatar camera btn `.cam` | 99px | `radiusFull` |

---

## Elevation / Shadows

### Tokens

```
shadowSm  = 0 2px 6px  rgba(20,22,30,0.08)
shadowMd  = 0 4px 14px rgba(20,22,30,0.10)
shadowLg  = 0 12px 34px rgba(20,22,30,0.18)
```

### Component Shadow Mapping

| Component | Shadow |
|---|---|
| `.card` | `shadowMd` |
| `.hcard` | `shadowMd` |
| `.veh` | `shadowMd` |
| `.field` | `shadowSm` |
| `.otp` | `shadowSm` |
| `.icon-btn` | `shadowSm` |
| `.prow` | `shadowSm` |
| `.place` | `shadowSm` |
| `.promo` | `shadowMd` |
| `.tabbar` | `shadowLg` |
| `.toast` | `shadowLg` |
| `.sheet` | Custom: `0 -8px 30px rgba(0,0,0,0.15)` |
| `.logo-badge` | `0 16px 40px rgba(255,69,0,0.4)` |
| `.btn` (primary) | `0 6px 16px rgba(255,69,0,0.35)` |
| `.btn.dark` | `0 6px 16px rgba(35,40,56,0.3)` |
| `.plate` | None (flat) |
| `.status-pill` | `shadowLg` |
| `.dialog` | None (uses animation) |
| `.total-box` | `0 8px 22px rgba(255,69,0,0.35)` |
| `.timer` | None |
| `.badge` | None |
| `.seg` | None |
| `.steps` | None |
| `.stat3` | None (flat bg container) |
| `.driver` | None (flat bg container) |
| `.davatar` | None |
| `.center-pin` | `drop-shadow(0 6px 8px rgba(0,0,0,0.3))` |
| `.fab` | `shadowMd` |
| `.chip` | None |
| `.stars button` | None |
| `.splash-load` | None |

---

## Icons

### SVG Icon Sprite (Prototype)

The prototype defines 28 SVG symbols used throughout. These map to the following in Flutter:

| Symbol ID | SVG Description | Flutter Icon | Usage |
|---|---|---|---|
| `i-home` | Home angle | Custom SVG | Tab bar Home |
| `i-cal` | Calendar | `Icons.calendar_today` | Tab bar My Booking |
| `i-user` | Person | `Icons.person` | Tab bar Profile |
| `i-bell` | Bell | `Icons.notifications` | Home bell button |
| `i-back` | Chevron left | `Icons.chevron_left` | Back buttons |
| `i-search` | Magnifying glass | `Icons.search` | Search fields |
| `i-phone` | Phone | `Icons.phone` | Contact, call driver |
| `i-star` | Star | `Icons.star` | Rating, splash logo |
| `i-x` | Close X | `Icons.close` | Close, clear dest |
| `i-locate` | Crosshair | `Icons.my_location` | FAB, location pill |
| `i-shield` | Shield + check | `Icons.shield` | Safety button |
| `i-chev` | Chevron right | `Icons.chevron_right` | List item trailing |
| `i-pin` | Map pin | `Icons.location_on` | Search results, places |
| `i-car` | Car | `Icons.directions_car` | Booking overlay |
| `i-clock` | Clock | `Icons.access_time` | ETA, duration |
| `i-route` | Route dots | `Icons.route` | History distance |
| `i-check` | Checkmark | `Icons.check` | Toast, timeline, receipt |
| `i-globe` | Globe | `Icons.language` | Language toggle |
| `i-out` | Logout | `Icons.logout` | Logout |
| `i-doc` | Document | `Icons.description` | Terms, note field |
| `i-mail` | Email | `Icons.email` | Contact email |
| `i-cam` | Camera | `Icons.camera_alt` | Avatar upload |
| `i-refresh` | Refresh | `Icons.refresh` | Home refresh button |
| `i-info` | Info circle | `Icons.info` | Info |
| `i-grid` | 4-grid | `Icons.grid_view` | Prototype FAB |
| `i-wallet` | Wallet | `Icons.account_balance_wallet` | Payment |
| `i-send` | Send arrow | `Icons.send` | Send |

### Asset SVG Icons (Existing)

| Asset | Usage |
|---|---|
| `assets/nav_icon/home-angle-2-svgrepo-com.svg` | Home active |
| `assets/nav_icon/home.svg` | Home inactive |
| `assets/nav_icon/book.svg` | My Booking active |
| `assets/nav_icon/book_outline.svg` | My Booking inactive |
| `assets/nav_icon/profile.svg` | Profile inactive |
| `assets/nav_icon/profile_fill.svg` | Profile active |

---

## Animations

### Micro-interactions

| Animation | CSS | Duration | Curve | Usage |
|---|---|---|---|---|
| Button press | `scale(.97)` | 100ms | default | All buttons |
| Screen enter | `fadeUp` | 280ms | ease | Screen transitions |
| Sheet open | `up` | 300ms | cubic-bezier(.2,.9,.3,1) | Bottom sheets |
| Dialog open | `pop` | 250ms | cubic-bezier(.2,.9,.3,1.2) | Dialogs |
| Toast show | opacity + translateY | 250ms | ease | Toast appear |
| Shake | horizontal translate | 400ms | ease | Validation errors |
| Splash pop | `pop2` (scale .7→1) | 600ms | cubic-bezier(.2,.9,.3,1.2) | Splash logo |
| Skeleton shimmer | background-position | 1100ms | infinite | Loading skeletons |
| Loading bar | translateX -100%→300% | 1000ms | infinite | Splash loader |
| Pulse dot | opacity 1→0.35 | 1200ms | infinite | Booking status |
| Star pop | `pop3` (scale 1.3) | 250ms | ease | Rating star select |
| Fade | opacity 0→1 | 200ms | ease | Backdrop |

### Keyframe Definitions

```css
fadeUp { from { opacity:0; transform:translateY(10px) } to { opacity:1; transform:none } }
up { from { transform:translateY(60px); opacity:0 } }
pop { from { transform:translateY(-50%) scale(.9); opacity:0 } }
pop2 { from { transform:scale(.7); opacity:0 } }
pop3 { 50% { transform:scale(1.3) } }
shake { 0%,100%{transform:none} 25%{translateX(-7px)} 50%{translateX(7px)} 75%{translateX(-4px)} }
sh { to { background-position:-200% 0 } }
load { 0%{translateX(-100%)} 100%{translateX(300%)} }
spin { to { transform:rotate(360deg) } }
bnc { 50%{transform:translateY(-8px)} }
pl { 50%{opacity:.35} }
```

---

## Responsive Layout

**Approach:** Phone-only (400px prototype frame). The `.d` extension in the existing codebase is kept.

**Breakpoints (prototype only):**
```css
@media(max-width:900px) { .panel { display:none } }   /* hide sidebar */
@media(max-width:480px) { phone { width:100vw; height:100dvh; border-radius:0 } }  /* full screen */
```

No tablet/desktop layout. The app targets phones in the Cambodia market.
