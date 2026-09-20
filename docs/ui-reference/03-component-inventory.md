# 03 — Component Inventory

> Compiled from the HTML/CSS/JS. **CONFIRMED** = found in the prototype as described. The
> key is *reused vs. one-off*: components marked "reused" are defined once and used on multiple
> screens; "one-off" components are styled per-screen. Named component classes below are the
> prototype's own CSS class names; use them to trace definitions to `lib/` (see 07).

## 1. Shared / reused components

| # | Component (CSS) | Styles (verbatim reference) | Behaviour (JS) | Consumers | Confidence |
| --- | --- | --- | --- | --- | --- |
| C01 | `.btn` · primary CTA | `display:flex;align-items:center;justify-content:center;gap:8px;width:100%;height:52px;border-radius:var(--r-l);background:var(--brand);color:#fff;font-size:16px;font-weight:700;box-shadow:0 6px 16px rgba(255,69,0,.35)` | `<button>`; `:disabled` → `background:#D8DBE3;color:#fff;box-shadow:none;cursor:not-allowed`; variants `.dark` (navy `--navy` shadow `0 6px 16px rgba(35,40,56,.3)`), `.ghost` (white bg, ink text, line border), `.danger-ghost` (white + red), `.sm` (height:44px; font-size:14px; border-radius:12px) | Login Next, Register Create, Map Book Now, Booking Cancel (`.btn.danger-ghost`), Call/Safety (`.btn.sm.dark` / `.btn.sm`), Receipt primary/ghost, fee `.simPay`, dialog `Yes, cancel`, tariff "Got it", Contact "Call" buttons (`.btn.sm`) | CONFIRMED |
| C02 | `.link` · inline text action | `border:none;background:none;color:var(--brand);font-size:14px;font-weight:700;cursor:pointer;text-transform:inherit;` | `:hover` underline | splash "Skip →", OTP "Send again", OTP "New here?", login phone "change number?" (n/a) | CONFIRMED |
| C03 | `.icon-btn` · square icon button | `width:42px;height:42px;border-radius:12px;background:#fff;box-shadow:var(--sh-sm);display:inline-flex;align-items:center;justify-content:center;position:relative;color:var(--ink)` | optional `.dot` (6px brand dot at top-right, `#ff4500`) — used for bell; prototype demo uses it as a pseudo-"unread" cue | back buttons, home bell (with `.dot`), home refresh, OTP back, map-top back | CONFIRMED |
| C04 | `.field` · labelled input | `display:flex;align-items:center;gap:10px;background:#fff;border:1.5px solid var(--line);border-radius:14px;padding:0 14px;height:54px;box-shadow:var(--sh-sm);` `:focus-within{border-color:var(--brand)}`; label `.lbl` (13px/600/--sub, margin `18px 0 8px`); optional `.prefix` (left-addon, `border-right:1px solid var(--line)`, padding-right 10px) | `input{flex:1;height:100%;min-width:0;border:none;outline:none;background:none}` | Login phone (`+855` prefix), OTP (×4 `.otp`), Register name, Map note (`.note-field`), Search | CONFIRMED |
| C05 | `.badge` · status pill | `display:inline-flex;align-items:center;gap:4px;padding:5px 10px;border-radius:99px;font-size:12px;font-weight:700` (base bg `#fff`); variants `.green` (bg `--green-bg`, color `--green`), `.red` (bg `--red-bg`, color `--red`), `.amber` (bg `--amber-bg`, color `--amber`), `.orange` (bg `--brand-50`, color `--brand`) | — (static) | Home promo badge, History hcard status (`green`/`red`), Fee `payBox` (`amber` → `green` when paid) | CONFIRMED |
| C06 | `.seg` · segmented control | container `display:flex;background:#E8EAF0;border-radius:99px;padding:3px;gap:2px;` each option `padding:6px 14px;border:none;background:none;border-radius:99px;font-size:13px;font-weight:700;color:var(--sub);cursor:pointer;` `.on{background:#fff;color:var(--ink);box-shadow:var(--sh-sm)}` | toggles `on` class; changes app language | Login lang, Register lang, Profile lang | CONFIRMED |
| C07 | `.steps` · progress indicator (3 bars) | `display:flex;gap:6px;` each step `width:26px;height:5px;border-radius:99px;background:var(#DCDDE5)`; `.on{background:var(--brand)}` | highlights on auth progression | Login (1), OTP (2), Register (3) | CONFIRMED |
| C08 | `.tabs` · 2-option filter (History) | same pill container as `.seg` (track `#E8EAF0`, `border-radius:14px;padding:4px`) | `setHistTab(0/1)` re-renders list | History Complete/Cancelled | CONFIRMED |
| C09 | `.chip` · selectable tag | `border:1.5px solid var(--line);background:#fff;border-radius:99px;padding:9px 16px;font-size:13px;font-weight:700;color:var(--sub);` `.on{border-color:var(--brand);color:var(--brand-dark);background:var(--brand-50)}` | toggles `on` class | Rating tone tags | CONFIRMED |
| C10 | `.card` · surface | `background:var(--card);border-radius:var(--r-l);box-shadow:var(--sh-md);padding:16px;` (`.card.slim` → radius 14px) | — | Search empty, Fee feeBody, Receipt, HDetail body, Terms, NewsDetail | CONFIRMED |
| C11 | `.kv` · key-value row | `display:flex;justify-content:space-between;font-size:14px;padding:7px 0;` `+ b{color:var(--ink)}` | — | Tariff sheet, Fee, Receipt, HDetail | CONFIRMED |
| C12 | `.addr-row` · start/end with dot markers | `display:flex;gap:12px;align-items:center;font-size:13px;` with `.dot-pickup` (10px navy circle) and `.dot-dest` (10px brand circle), both with a `--line` halo ring | — | Map sheet, Fee, Receipt | CONFIRMED |
| C13 | `.prow` · row nav item | `display:flex;align-items:center;gap:12px;background:#fff;border-radius:14px;box-shadow:var(--sh-sm);padding:15px;width:100%;font-size:15px;font-weight:600;margin-bottom:8px;text-align:left;` icon slot `.ic.sm` in tinted circle; chevron `.ic` right; `.danger` variant (`color:var(--red)`) | `onclick` navigation / `toast()` | Profile menu, Contact rows | CONFIRMED |
| C14 | `.ic` · icon wrapper | `width:22px;height:22px;display:grid;place-items:center;color:currentColor;` size/colour remaps `.ic.sm` (16px), `.ic.lg` (28px), `.ic.fill` (filled strokes), `.ic.muted` | uses sprite `<use>` | every icon | CONFIRMED |
| C15 | `.davatar` · circular avatar | `width:52px;height:52px;border-radius:99px;display:grid;place-items:center;color:#fff;font-size:18px;font-weight:800;background:linear-gradient(135deg,var(--blue),#7A5CFF);` inline overrides for profile (`linear-gradient(135deg,#FF6A00,#B73CFF)`) | initials from name | Driver card, Fee, Rating (72px override), Profile head (52px/64px inline) | CONFIRMED |
| C16 | `.havatar` · history avatar | `width:44px;height:44px;border-radius:99px;background:linear-gradient(135deg,#FF6A00,#B73CFF);color:#fff;font-size:16px;font-weight:800` | — | History hcard | CONFIRMED |
| C17 | `.vimg` · vehicle art | `width:84px;height:52px;display:block;` (map variations to 72×44, tariff to 48×30) | `vSVG('van')` inline SVG art | Home vehList (`.veh`), Map `.veh-mini`, `.tarif` | CONFIRMED |
| C18 | `.appbar` · header bar | `display:flex;align-items:center;gap:12px;margin-bottom:14px;` h2 `17px/700` | static | Search, Fee, History, News, NewsDetail, Terms, Contact (Profile uses `.toprow`) | CONFIRMED |

## 2. Screen-specific components (one-off)

> These are defined per-screen in the CSS and exist only there.

| ID | Component (CSS) | Used on | DOM/CSS reference | Confidence |
| --- | --- | --- | --- | --- |
| U01 | `.splash-logo`, `.logo-badge`, `.splash-name`, `.splash-sub`, `.splash-load` | `s-splash` | `.logo-badge` = 96px orange-radial gradient (brand), shadow `0 16px 40px rgba(255,69,0,.4)`, `font-size:34px`; `.splash-name` 30px/800/`letter-spacing:3px`; `.splash-load` = 44px rounded bar with progress (`.fill` 46%) | CONFIRMED |
| U02 | `.phone-field` (`.field.slim`) | `s-login`, `s-otp` | 54px labelled phone entry with `+855` `.prefix` | CONFIRMED |
| U03 | `.otp` + `.otp-row` | `s-otp` | 4 inputs, `width:64px;height:64px;font-size:26px;font-weight:800;border:1.5px solid var(--line);border-radius:14px;text-align:center;` focus `border-color:var(--brand)`; auto-advance | CONFIRMED |
| U04 | `.avatar-pick` + `.cam` | `s-register` | 120px white circle (`background:#fff;box-shadow:var(--sh-md);margin:22px auto 6px`; muted user icon), `+ .cam` = 38px circular camera badge `background:var(--brand);color:#fff;box-shadow:0 4px 12px rgba(255,69,0,.4)` bottom-right | CONFIRMED |
| U05 | `.home-head` + `.hbtns` + `.brand` + `.brand-km` | `s-home` | header with logo (28px), `.brand` 24px/800 `letter-spacing:2px`, `.brand-km` Khmer 13px, bell `.icon-btn` with `.dot`, `.lang-mini` mini lang pill | CONFIRMED |
| U06 | `.promo` | `s-home` | dark `promoCard` banner: `background:linear-gradient(135deg,#232838,#3a2c28,#572c12)` radius `var(--r-l)` padding 16, white + amber text, `.ic` chevron, "FLY20" code | CONFIRMED |
| U07 | `.sec-row` + `.refresh` | `s-home` | small row listing ride options + a `.icon-btn` refresh; `#secRow` re-renders per vehicle (`seats`, `min`, `perKm`) | CONFIRMED |
| U08 | `.veh` + `.veh.mini` | `s-home` → `s-map` | vehicle row: vimg + label VEHICLE, `.meter` seat/price, price `+ b`, `#vehList`; on map → `.veh-mini` dropdown (selected) | CONFIRMED |
| U09 | `.where` | `s-home`, `s-map` | "Where to?" tap card `background:#fff` `border:1.5px solid transparent` radius `--r-l` `box-shadow:var(--sh-md)` padding 16, `:active{border-color:var(--brand)}`, `.ic` brand arrow | CONFIRMED |
| U10 | `.skel` skeleton | `s-home` | shimmer card `background:linear-gradient(90deg,#EDEEF2,#F7F7FA,#EDEEF2)` animated 1.1s ease infinite | CONFIRMED |
| U11 | `.place` search row | `s-search` | result tile (icon pin + name + sub + `.km` 12px badge), `.empty` state card | CONFIRMED |
| U12 | `.status-pill` (`.pulse`) | `s-booking` | navy pill `background:var(--navy)` white, `border-radius:99px`, pulse ring animation | CONFIRMED |
| U13 | `.timeline` + `.tstep` | `s-booking` | horizontal 3-step progress: `.tstep{flex:1;text-align:center;font-size:11px;font-weight:700;color:var(--muted)}` with 26px `.td` circles (`#E7E8EE` → brand) connected by 2px `#E7E8EE` lines; `.on{color:var(--brand-dark)}` + `.on .td{background:var(--brand);box-shadow:0 4px 10px rgba(255,69,0,.4)}` | CONFIRMED |
| U14 | `.driverCard` | `s-booking`, `s-fee` | driver avatar + name + plate + "RWE-320" mono letter-spacing + link "View driver profile" hover | CONFIRMED |
| U15 | `.total-box` | `s-fee` | orange gradient (brand→dark) rounded box, huge total `b` 28px | CONFIRMED |
| U16 | `.payBox` | `s-fee` | `.badge` inside `.card` bottom row, flips from amber "Waiting" to green "Payment confirmed ✓" | CONFIRMED |
| U17 | `.stars` + `.star` | `s-rating` | 5 star buttons, `font-size:44px`, unlit `#DCDDE5`, lit `.lit{color:#F5A623}` | CONFIRMED |
| U18 | `.check-big` | `s-receipt` | 96px circle `background:var(--green-bg);color:var(--green);font-size:40px;margin:30px auto 16px;animation:pop2 .5s` (light-green surface + green check) | CONFIRMED |
| U19 | `.hcard` + `.hroute` + `.hmeta` | `s-history` | trip card (havatar + `.vr` vimg + INV no + date + `.badge` status + km/time amt), `:hover` translate | CONFIRMED |
| U20 | `.news` | `s-news` | announcement card with `.ne-img` (gradient 3-tile `.img-ph`) | CONFIRMED |
| U21 | `.term` | `s-terms` | numbered pink/navy icon + title + body, `border-top:1px solid var(--line)` | CONFIRMED |
| U22 | `.prow` variant rows | `s-profile`, `s-contact` | `.prow.danger` logout; rows: bell "Announcements", pin "Saved places (soon)", doc "Terms", mail "Contact us" | CONFIRMED |
| U23 | `.prof-head` | `s-profile` | avatar + name + phone, buttons row (`.btn.sm` "Edit" ghost) | CONFIRMED |
| U24 | `.mapwrap` / `.mapBook` / `.minimap` | `s-map`/`s-booking`/`s-search`+`s-hdetail` | map containers (mapMain full, mapBook full, minimap 170px / 200px) | CONFIRMED |
| U25 | `.bsheet` / `.grab` | `s-map`, `s-booking` | persistent bottom sheet: white, `border-radius:22px 22px 0 0`, `box-shadow:0 -8px 30px rgba(0,0,0,.15)`, padding `10px 20px 24px`, max-height 72%; `.grab` = `width:44px;height:5px;border-radius:99px;background:#D8DBE3;margin:0 auto 14px` | CONFIRMED |
| U26 | `.bookov` + `#bookOv` | overlay on `s-map` | full-screen white overlay (rgba(255,255,255,.94)) with spinner (`.spinner`), car-bounce (`.car-bounce`), "Contacting nearby drivers…" + Cancel | CONFIRMED |
| U27 | `.link` "Book again" | `s-receipt` | primary variant | CONFIRMED |
| U28 | `.timer` | `s-otp` | 0:30 countdown pill: `font-weight:800;color:var(--brand);background:var(--brand-50);padding:4px 12px;border-radius:99px;font-variant-numeric:tabular-nums`; hidden + swap to resend link at 0 | CONFIRMED |

## 3. Icons of note (from the sprite)

| Icon ID (sprite) | Glyph | Colour / role | Used in |
| --- | --- | --- | --- |
| `i-home` | home | currentColor | tabbar Home |
| `i-cal` | calendar | currentColor | tabbar My Booking |
| `i-user` | user | currentColor | tabbar Profile, avatar placeholders |
| `i-bell` | bell | currentColor | home hbtns (with `.dot`), news img-ph |
| `i-back` | arrow-left | currentColor | all `.appbar`/`.map-top` backs |
| `i-search` | magnifier | currentColor | where card, search field, map |
| `i-phone` | phone | currentColor | booking Call, contact rows |
| `i-star` | star | currentColor | logo-badge, rating |
| `i-x` | × | currentColor | destination clear, dialogs |
| `i-locate` | crosshair | currentColor | map "My Location", locate fab |
| `i-shield` | shield | currentColor | booking Safety |
| `i-chev` | chevron-right | currentColor | promo, prow rows |
| `i-pin` | map pin | currentColor | search places, saved-places, contact addr |
| `i-car` | car | currentColor | bookov car-bounce |
| `i-clock` | clock | currentColor | veh eta, hmeta |
| `i-route` | route | currentColor | hmeta |
| `i-check` | ✓ | currentColor | toast, timeline done, check-big |
| `i-globe` | globe | currentColor | *(unused — dead symbol, §4)* |
| `i-out` | logout | currentColor | profile logout |
| `i-doc` | document | currentColor | note-field, terms prow |
| `i-mail` | envelope | currentColor | contact email prow |
| `i-cam` | camera | currentColor | register avatar cam |
| `i-refresh` | refresh | currentColor | home refresh icon-btn |
| `i-info` | info | currentColor | *(unused)* |
| `i-grid` | grid | currentColor | protoFab / jump sheet |
| `i-wallet` | wallet | currentColor | *(unused)* |
| `i-send` | send | currentColor | *(unused)* |

## 4. Dead / unused symbols (sprite inventory)

| Symbol | Evidence |
| --- | --- |
| `i-globe`, `i-info`, `i-wallet`, `i-send` | defined in the `<symbol>` sprite but **never referenced** by any `##i-*` `use` in the HTML/JS (grep `href="#i-globe"` = 0, `i-info` = 0, `i-wallet` = 0, `i-send` = 0) | CONFIRMED |

> The driver prototype exposed a sibling set of symbols; this set (27) is the passenger-specific
> sprite. In the Flutter rewrite, only the *used* 23 are ported (see 07).

## 5. Reuse vs. one-off summary

- **High reuse:** `.btn`, `.field`, `.icon-btn`, `.badge`, `.seg`, `.steps`, `.tabs`, `.chip`,
  `.prow`, `.kv`, `.addr-row`, `.card`, `.link`, `.ic`. These are the primitive kit to rebuild
  in Flutter (07 mapping).
- **Medium (2 screens):** `.appbar`, `.grab`, `.bsheet`, `.veh`/`.veh-mini`, `.vimg`, `.davatar`,
  `.havatar`, `.skel`, `.map` containers, `.pulse`.
- **One-off:** splash kit, OTP kit, register avatar, promo banner, tariff sheet, booking
  timeline, status pill, total-box, payBox, stars, check-big, history card, news card, terms.
- Static panel/demo/splash/skip and prototype-control elements are NOT part of the target kit.

## 6. Notable CSS gotchas (implementation notes)

- `--brand` is used for the primary CTA *and* for the accent of `.total-box` gradient and `.fab`;
  the object-blind classes above inherit the token, so the Flutter theme must expose the same
  base token (F1).
- `.btn[disabled]` grey `#D8DBE3` appears on Login Next/Book Now until valid input; keep the
  disabled state in the Flutter `TaButton`.
- `.seg` vs `.tabs` are visually the same mechanism (pill container + `.on` shadow) with different
  height — implement one `TaSegment` primitive and reuse.
- Icon `.tint1…tint4` wrappers reuse the 24×24 stroke set; base `stroke:none` fill-aware icons
  need `stroke-width:0` overrides in the `.ic.fill` variant.
- The prototype has **no dark theme** and **no drawer**; the app's historical dark theme
  (`docs/ux-redesign/02-design-system.md` §"dark theme") is out of the target scope for the
  passenger baseline (light-only) — revisit only if a dark variant is explicitly requested.