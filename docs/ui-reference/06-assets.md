# 06 — Assets & Media

> What the prototype actually ships and how it gets drawn. Confidence: CONFIRMED unless noted.
> The whole prototype is self-contained (no external fonts/rasters); every "asset" below is either
> an inline SVG, a CSS gradient/glyph, or a procedural map.

## 1. Icon sprite (inline SVG)

- **Format:** `<svg><symbol id="i-*" viewBox="0 0 24 24">` stroke-based icons
  (`fill:none; stroke:currentColor; stroke-width:2; stroke-linecap/linejoin:round`).
- **Count:** 27 symbols.

| ID | Used | ID | Used | ID | Used |
| --- | --- | --- | --- | --- | --- |
| `i-home` | tabbar | `i-cal` | tabbar My Booking | `i-user` | tabbar Profile |
| `i-bell` | home/news | `i-back` | appbars | `i-search` | where/search/map |
| `i-phone` | Call, contact | `i-star` | logo/rating | `i-x` | dest-clear/dialog |
| `i-locate` | map pill/fab | `i-shield` | Safety | `i-chev` | promo/prow |
| `i-pin` | places/contact | `i-car` | bookov | `i-clock` | veh eta/hmeta |
| `i-route` | hmeta | `i-check` | toast/timeline | `i-cam` | register cam |
| `i-refresh` | home refresh | `i-doc` | note/terms | `i-mail` | contact email |
| `i-out` | logout | `i-grid` | prototype jumps | *(iced: `i-globe`, `i-info`, `i-wallet`, `i-send`)* |

- Dead symbols: `i-globe`, `i-info`, `i-wallet`, `i-send` are declared but never referenced
  (grep-verified §03-4). Do not ship dead icons.

## 2. Vehicle artwork

- **`.vimg` wrapper** (84×52 home / 72×44 map mini / 48×30 tariff) renders `vSVG(vehicleId)` —
  a template-literal inline SVG (96×48 viewBox).
- Vehicle classes: `tuk`, `sedan`, `suv`, `van`, `vip`, each drawn as a flat base + cabin + 2 wheels
  + window path set. Colour comes from the `VEHICLES` data, not the shape: Tuk-Tuk `#F5A623`-amber,
  Classic/sedan `#FF4500`-brand, SUV `#2F6BFF`-blue, Minivan `#7A5CFF`, VIP Alphard `#232838`-navy
  (with an amber `#F5A623` accent strip). Wheels `#232838` with `#C9CDD8` hubs. Bases/per-km in the
  same table: Tuk $1.00/$0.45 · Classic $1.50/$0.60 · SUV $2.00/$0.80 · Minivan $2.50/$0.95 ·
  VIP $4.00/$1.50.

## 3. Maps (procedural SVG, 4 instances)

| Instance | Screen | Size |
| --- | --- | --- |
| `#mapMain` | `s-map` | full-bleed mapwrap |
| `#mapBook` | `s-booking` | full-bleed mapwrap |
| `.minimap` (search) | `s-search` | 170px |
| `.minimap` (hdetail) | `s-hdetail` | 200px |

- **Renderer:** `mapSVG(container, {id})` builds a light-grey grid map: `#E6EBF0` background,
  `#EDF1F4` blocks, `#CDE7C3`/`#D8EFCE` park patches, `#BED9E9` river, `#D4DBE2` roads + white
  road, `#2F6BFF`-tinted route polyline, markers (pickup `#232838` dot + dest `#FF4500` pin).
- **Marker animation:** `moveMarker(el, o, dur=1.2s)` slides the dest marker between two fixed
  anchor coordinates with an ease.

## 4. Avatars

| Component | Rules |
| --- | --- |
| `.davatar` (default driver) | 52px, `linear-gradient(135deg,var(--blue),#7A5CFF)`, 2-char initials white 18/800 |
| profile `.davatar` (inline override) | `linear-gradient(135deg,#FF6A00,#B73CFF)` |
| rating `.davatar` | size override to 72px |
| `.havatar` (history) | 44px, `linear-gradient(135deg,#FF6A00,#B73CFF)`, initials 16/800 |
| `.avatar-pick` (register) | 120px white circle (`box-shadow:var(--sh-md)`) with a muted user icon, plus a 38px circular `.cam` camera badge (`background:var(--brand)`, `box-shadow:0 4px 12px rgba(255,69,0,.4)`) pinned bottom-right |

No raster photo assets; avatars are gradient + initials (real photos would come in via
`image_picker` in production).

## 5. Logo & wordmark

- `.logo-badge` = pure CSS: `linear-gradient(135deg,#FF6A00,#FF4500 60%,#E63E00)`, radius 28px,
  inner star glyph (`.ic`), shadow `0 16px 40px rgba(255,69,0,.4)`, `:active` scale micro-interaction.
  Sizes: 96px on splash, 28px in the home head, 72px (inline `style`) on contact.
- `.splash-name` 30px/800 `letter-spacing:3px`; `.brand` 24px/800 `letter-spacing:2px`.

## 6. Promotional / illustrative art

- `.promo` = CSS gradient banner `linear-gradient(120deg,#232838,#3a2c28 70%,#572c12)` with white/amber
  text, a `.tag` brand chip ("50% OFF"), chevron icon and a large `#FF4500` circle accent; no raster.
- `.img-ph` news placeholder = CSS gradient tile `linear-gradient(120deg,var(--brand-100),#D8E6FF)`
  (120px tall) with a bell icon; not a real user-asset slot.
- `.total-box` = orange CSS gradient box; `.check-big` = green CSS circle + check glyph.

## 7. Fonts

- Family stack includes `Kantumruy Pro` first, then system + Khmer fallbacks —
  **but the prototype never loads it** (no `@font-face`, no CDN link). The Flutter app bundles the
  family in `assets/fonts/` and declares it in `pubspec.yaml` (verified in `lib/`).
- Khmer glyphs fall back to system Khmer fonts in the browser; the app's
  `lib/translations/khmer_key.dart` supplies the strings.

## 8. Audio / video / other media

- **None.** No WebAudio, no `<audio>`, no `<video>`, no raster `img` with real files, no external
  URLs (Cloudflare artifact scripts aside). All interactivity is CSS/JS simulated.

## 9. Non-app assets (excluded)

- Prototype chrome: `.panel`, `#protoFab`, `#curName`, `s-ds` we own as style refs; the
  Cloudflare scripts are artifacts (see 01-§5).

## 10. Consolidation checklist (port into the app)

- [ ] Port the **23 used** stroke icons as Flutter `IconData`/`CustomPaint` (omit 4 dead symbols).
- [ ] Reproduce `vSVG()` vehicle art as a `TaVehicleArt` widget (tuk/sedan/suv/van/vip).
- [ ] Real maps via `google_maps_flutter` (lib already uses it) — replaces `mapSVG()`.
- [ ] Avatars: gradient+initials widget in-app; hook `image_picker` per prototype note.
- [ ] Fonts: keep bundled KantumruyPro (already imported); run khmer_key sync.
- [ ] Ignore `.panel`, FAB, demo "Skip ▸" / "Simulate" buttons, and Cloudflare scripts.