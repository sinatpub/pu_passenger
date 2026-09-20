# 04 — Design Tokens

> All values below are **verbatim** from the prototype's `:root` block and CSS. Every token is
> traceable to (a) the HTML's `:root`, (b) the `s-ds` in-prototype reference screen, or
> (c) hard-coded colours in specific rules. Confidence: CONFIRMED unless noted.

## 1. Colour system — semantic tokens (`:root`, verbatim)

```css
--brand:      #FF4500;   /* primary brand "orange" */
--brand-dark: #CC3700;   /* hover / gradient deep */
--brand-light:#FFA84C;   /* light accent */
--brand-50:   #FFF4ED;   /* tinted surface */
--brand-100:  #FFE4D3;   /* stronger tinted surface */
--ink:        #191C24;   /* body text */
--sub:        #6B7588;   /* secondary text */
--muted:      #9AA0B4;   /* tertiary text */
--line:       #EBEBF0;   /* hairline */
--bg:         #F6F6F7;   /* app background */
--card:       #FFFFFF;

--green:    #0EAF6B;  --green-bg:  #E6F8EF;
--red:      #D32F2F;  --red-bg:    #FDECEC;
--amber:    #B97A00;  --amber-bg:  #FFF4D6;
--blue:     #2F6BFF;  --navy:      #232838;
```

Use pairs (colour + its tinted surface): statuses always ship text+chip pairs; `--blue`/`--navy`
are used for avatars/plates/driver-card and the dark `.btn.dark` and `.status-pill` (the floating
tab bar is white, not navy — see §5).

## 2. Radius scale (`:root`, verbatim)

```css
--r-s: 8px;   --r-m: 12px;   --r-l: 16px;   --r-xl: 20px;
```

Observed contextual assignments: `.btn` = `--r-l` (16px); `.btn.sm` = 12px; cards = 16px;
dialogs = 20px; sheets = 22px top corners; pills = 99px. Fields/OTPs/place-rows/prow = 14px
(hard-coded, between `--r-m` and `--r-l`); `.note-field` = 12px; `.logo-badge` = 28px;
tabbar pill = 22px; `.check-big` = 99px.

## 3. Shadows (`:root`, verbatim)

```css
--sh-sm: 0 2px 6px  rgba(20,22,30,.08);
--sh-md: 0 4px 14px rgba(20,22,30,.10);
--sh-lg: 0 12px 34px rgba(20,22,30,.18);
```

Action shadows (hard-coded): `.btn` `0 6px 16px rgba(255,69,0,.35)`; `.btn.dark` `0 6px 16px
rgba(35,40,56,.3)`; `.total-box` `0 8px 22px rgba(255,69,0,.35)`; `.logo-badge` `0 16px 40px
rgba(255,69,0,.4)`; camera add-on `0 4px 12px rgba(255,69,0,.4)`; `.center-pin` drop-shadow
`0 6px 8px rgba(0,0,0,.3)`; `.bsheet` `0 -8px 30px rgba(0,0,0,.15)`; phone `0 30px 80px
rgba(0,0,0,.5)`.

## 4. Typography

- **Family:** `"Kantumruy Pro", system-ui, -apple-system, "Segoe UI", Roboto, "Noto Sans",
  "Noto Sans Khmer", "Khmer OS Siemreap", "Khmer OS", sans-serif`.
  The prototype does **not** load Kantumruy Pro itself (no `@font-face` / link) — it relies on
  the OS. The Flutter app bundles it (`assets/fonts/KantumruyPro*`, `pubspec.yaml` `fonts:`).
- **Scale (hard-coded, key rules):**

| Role | rule | Layout role |
| --- | --- | --- |
| `.brand` | 24px / 800 / `letter-spacing:2px` | Home wordmark |
| `.splash-name` | 30px / 800 / `letter-spacing:3px` | Splash wordmark |
| h2 (`.appbar`) | 17px / 700 | screen titles |
| `.field input` | 15px | form input |
| `.btn` | 16px / 700 | primary action |
| `.lbl` | 13px / 600 / `--sub` | field label |
| `.link` | 14px / 700 | text link |
| body default | 16px | body |
| `.kv`/`.prow` | 14px / f600 | rows |
| `.t1` | 11px / 700 / uppercase / `letter-spacing:.5px` | card eyebrows |
| `.badge` | 12px / 700 | status pill |
| `.tiny` | 12px | captions |
| `.otp` | 26px / 800 | OTP digits |
| `.plate` | letter-spacing:1px, mono-feel | licence plate |

- **Semantic type roles** (documented on the `s-ds` reference screen): Heading 24/ExtraBold ·
  Title 17/Bold · Body 15/Regular · Caption 13/Regular. (Maps to `lib/core/theme/text_styles.dart`.)

## 5. Surface / spacing scale

- **Spacing (observed & on `s-ds`):** 4 / 8 / 12 / 16 / 24 / 32 / 48 (px).
- **Screen padding:** `.screen { padding:46px 20px 20px }`; `.tabbed { padding-bottom:96px }`
  (leaves room for the floating tab bar).
- **Cards/sheets:** `.card` padding 16px; `.bsheet` padding `12px 20px 24px`; `.dialog` padding 22px.
- **Floating tab bar:** `position:absolute; inset-inline:12px; bottom:12px; background:#fff;
  border-radius:22px; box-shadow:var(--sh-lg); padding:8px;` — three equal tabs (11px/600/`--muted`,
  `border-radius:14px`, icon + label stacked); active tab = brand text + `--brand-50` background.

## 6. Hard-coded colours (beyond `:root`)

| Value | Where |
| --- | --- |
| `#20232e` | page background (behind the phone) |
| `#000` | phone bezel |
| `#F5A623` | starred (:not unlit) rating star |
| `#DCDDE5` | unlit steps/stars, seg.on shadow base |
| `#E8EAF0` | `.seg` / `.tabs` track |
| `#D8DBE3` | disabled `.btn`, `.grab`, ghost pill on dark surfaces |
| `#7CFFB2` | toast success icon (mint) |
| `#4ADE80` | `.status-pill` pulse ring (green) |
| `#D8E6FF` | news image-placeholder gradient end |
| `linear-gradient(135deg,#FF6A00,#FF4500 60%,#E63E00)` | `.logo-badge` |
| `linear-gradient(135deg,#FF6A00,#E63E00)` | `.total-box` |
| `linear-gradient(120deg,#232838,#3a2c28 70%,#572c12)` | `.promo` banner |
| `linear-gradient(90deg,#EDEEF2,#F7F7FA,#EDEEF2)` | `.skel` shimmer |
| `linear-gradient(135deg,var(--blue),#7A5CFF)` | `.davatar` default |
| `linear-gradient(135deg,#FF6A00,#B73CFF)` | `.havatar` / profile `.davatar` override |
| `rgba(15,17,25,.5)` | sheet/dialog backdrop |
| `rgba(255,255,255,.94)` | booking overlay |
| map SVG fills | blocks `#EDF1F4`, parks `#CDE7C3`/`#D8EFCE`, river `#BED9E9`, `map-bg` `#E6EBF0`, roads `#D4DBE2`/`#fff`, pin `#FF4500`/`#fff` halo |
| demo nav colours | panel sidebar `#262b3a`/`#dfe3ee`/`#9aa3bd`/`#8b93ad`/`#cfd5e8`/`#313752` (prototype chrome) |

## 7. Deprecated / out-of-scope tokens (relative to prototype)

- **No dark palette is defined** in the passenger prototype (`--navy` is a surface accent, not a theme).
  The current app's dark theme (see `docs/reverse-engineering/04-design-tokens.md`) is **out of
  the prototype's scope**; baseline target = light-only (see `roadmap.md` F1 → C) unless a task
  explicitly requests dark mode.

## 8. Token → Flutter mapping source

- Produce `TaColor`/`TaRadius`/`TaShadow`/`TaTextStyle` ThemeExtension classes per F1
  (`lib/core/theme/ta_*.dart`), names mapped 1:1 from this file (e.g. `--brand` → `TaColors.brand`,
  `--r-l` → `TaRadius.l`, `--sh-md` → `TaShadows.md`). Full wiring details are in
  `07-flutter-mapping.md`.