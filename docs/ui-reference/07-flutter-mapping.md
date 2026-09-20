# 07 — Flutter Mapping Reference

> **Conceptual mapping only.** This documents how the prototype *would* map onto Flutter widgets
> and the existing `pu_passenger` architecture. It does **not** describe any unreferenced app code;
> every destination maps to an existing file via its live path (`lib/core/…`, `lib/presentation/…`).
> Naming follows the token/primitive kit in `docs/ux-redesign/02-design-system.md` (`Ta*`).

## 1. Token mapping (from 04 → lib/core/theme)

| Prototype token | Flutter target (F1 `lib/core/theme/ta_*.dart`) | Notes |
| --- | --- | --- |
| `--brand` | `TaColors.brand` (#FF4500) | primary CTA + accent |
| `--brand-dark` | `TaColors.brandDark` | gradient deep / pressed |
| `--brand-light` | `TaColors.brandLight` | accent gradient |
| `--brand-50`/`--brand-100` | `TaColors.brandSurf` variants | chips, dots, badge bg |
| `--ink/--sub/--muted` | `TaColors.ink/sub/muted` | text |
| `--line/--bg/--card` | `TaColors.line/bg/card` | surfaces |
| `--green/--red/--amber` + `-bg` | `TaColors.status.*` | status badges |
| `--blue`/`--navy` | `TaColors.blue/navy` | avatars, tabbar |
| `--r-s…--r-xl` | `TaRadius.s…xl` | cards 16, dialog 20, sheet 22, pill 99 |
| `--sh-sm…--sh-lg` + action shadows | `TaShadows.sm…lg` + `.brandFocus` | btn shadow, total-box, tabbar |
| type roles (Heading/Title/Body/Caption) | `TaTextStyles.*` | see 04 (§4 role table) |

## 2. Global scaffold mapping

| Prototype | Flutter | Note |
| --- | --- | --- |
| `.stage`/`.phone` | page chrome (home, map) | device outer frame not app UI |
| `.statusbar` | `MediaQuery` system padding | prototype draws it; Flutter does it for real |
| `s-*` screens | `Screen.page` GetX pages (`lib/presentation/screens/*/view/*` etc.) | live names in `roadmap.md` |
| `.tabbar` (floating pill) | `bottom_nav` (3 tabs, brand-pill) — already in app | verify pill styling per C1 |
| `#toast` | `TaToast` / GetX snackbar | navy pill + green check, 2.4s |
| `#sheetRoot`/`#dialogRoot` | repo `showModalBottomSheet`/`showDialog` wrappers | Escape/backdrop close |

## 3. Auth screens → GetX flows

| Prototype | Flutter (existing) |
| --- | --- |
| `s-login` + phone → OTP | `login` screen → `otp` screen (registration/login split already exists) |
| `s-otp` (4-digit, auto-submit) → Home | `otp` screen (Pinput `length:4` + `onCompleted`; current `otp/view.dart`) |
| `s-register` (name + avatar) → Home | `register` screen — Create disabled unless name & photo (current `register/view.dart`) |
| auth steps indicator | `TaSteps` (3 bars). NOTE: prototype/blueprint use 3 dots/bars — bits differ (`roadmap.md` PDD-04) |
| language `.seg` | existing `lib/translations/` `AppLocale` toggle (Dart maps) |

## 4. Booking spine → map-first booking

| Prototype | Flutter (target widgets) |
| --- | --- |
| map full-bleed + `.center-pin` | map screen using `google_maps_flutter` (already the app's map) |
| `.where` card + search sheet | `s-search` (see C7) |
| `.bsheet` pickup/dest/stats | map-bottom-sheet pattern (new, C7) |
| `.veh-mini` + `.tarif-btn` + tariff `.sheet` | vehicle selection + `TaSheet` tariff card |
| `#bookOv` (contacting → driver found) | booking overlay on the map (existing booking UX, C5/C7) |
| map-top back/"My Location" pill + `.fab` recount | tap-to-return + location FAB (P-04/P-05 work in `map_drag` already updated these widgets) |
| search results `.place` | flutter search result tiles (`search_state` already updated) |
| `.note-field` | `TextField` for driver note (S plug) |
| `.status-pill` + `.timeline` + `.driverCard` | active-ride bottom sheet (booking/view components, "Realtime · five-step"); real socket events in `lib/services/socket_service.dart` |

## 5. Fare / rating / receipt → C-follow-ups

| Prototype | Flutter (target widgets) |
| --- | --- |
| `s-fee` total-box + `.kv` + payBox | fare screen (Q1/Q2 formatting) — **USD `$` is prototype-only; app uses `៛`** (`roadmap.md` PDD-01) |
| `s-rating` stars + chips + note | rating screen (N-10 `rate_driver/rating.dart` already ships) |
| `s-receipt` check-big + card | receipt screen (C-add) |

## 6. History / profile / info screens → C/S follow-ups

| Prototype | Flutter (target widgets) |
| --- | --- |
| `s-history` tabs + hcards | history screen (already exists; align empty/loading) |
| `s-hdetail` | history_detail |
| `s-profile` prof-head + prow rows + logout dialog | profile screen; restore bell/logout handler (`roadmap.md` PDD-03; `profile` view) |
| `s-news` + `s-newsDetail` | announcement(_detail) screens (C-add) |
| `s-terms` | term_condition |
| `s-contact` | contact_us |

## 7. Component → widget mapping (from 03)

| Prototype | Flutter widget proposal | Variants |
| --- | --- | --- |
| `.btn` | `TaButton` | `dark`/`ghost`/`dangerGhost`/`sm`, `disabled` |
| `.link` | `TaTextButton` | `brand` underline |
| `.icon-btn` | `TaIconButton` | `.dot` badge slot |
| `.field` | `TaField` | label–prefix–focus/border-state |
| `.otp` | `TaOtpField` (4-digit wrapper) | arithmetically focused auto-advance |
| `.seg` / `.tabs` | `TaSegmentedButton` (one primitive) | `on` active shadow |
| `.steps` | `TaStepsIndicator` | n-state bars |
| `.badge` | `TaBadge` | green/red/amber/orange |
| `.chip` | `TaChip` | selectable `.on` |
| `.card` | `TaCard` | slim variant |
| `.kv` | `TaKeyValueRow` | — |
| `.addr-row` | `TaAddressRow` | dot-halo pickup/dest |
| `.prow` | `TaProfileRow` | danger variant + chevron |
| `.ic` | sprite `IconData` set | size via `.sm/.lg/.fill` remap |
| `.davatar`/`.havatar`/`.avatar-pick` | `TaAvatar` | size override + camera badge |
| `.vimg` + `vSVG()` | `TaVehicleArt` | tuk/sedan/suv/van/vip |
| `.veh`/`.veh-mini` | `TaVehicleRow` / `TaVehicleMini` | selected state |
| `.where` | `TaWhereCard` | active brand border |
| `.skel` | shimmer widget (already used) | skeleton line |
| `.place` | `TaSearchResultTile` | km badge + empty state |
| `.minimap` / `.mapwrap` | map container wrappers | real maps |
| `.bsheet`/`.grab` | `TaBottomSheet` + grab | max-height 72% |
| `.status-pill`+`.pulse` | `TaStatusPill` | pulse ring |
| `.timeline` | `TaTimeline` | done/active/next |
| `.driverCard` | `TaDriverCard` | plate, call, safety |
| `.total-box`/`.payBox` | `TaTotalBox`/`TaPayBox` | amber→green |
| `.stars` | `TaStarRating` | 5× lit unlit |
| `.check-big` | `TaSuccessCheck` | — |
| `.hcard` | `TaHistCard` | hover/active |
| `.news` | `TaNewsCard` | img-ph slot |
| `.term` | `TaTermRow` | numbered |
| `.tabbar` | `TaBottomNav` (floating pill) | — |

## 8. Behaviour mapping (from 05)

| Prototype behaviour | Flutter target |
| --- | --- |
| Router + auto-advance timers | GetX routing (`lib/routes/app_pages.dart`) + `Timer` in controllers — timers only for *simulated* demo affordances, replaced by socket events in production |
| OTP auto-submit (4 digits) | Pinput length-4 `onCompleted` — already implemented |
| login validation (≥8 digits, shake, vibrate) | `login/logic.dart` validation + `FormField` + optional `HapticFeedback` |
| splash 2.2s auto-advance | `splash_screen` controller timer (already exists) |
| toast inventory (verbatim strings) | `TaToast.success` messages via template keys in `english_key.dart`/`khmer_key.dart` |
| dialog inventory (cancel/logout) | `TaAlertDialog` with danger affirmatives |
| disabled CTA until valid | `TaButton.disabled` driven by controller `Rx` |
| pull-to-refresh | existing home refresh (already wired to socket polling) |
| i18n toggle | `AppLocale` `get `locale`, setLanguage, persistence (already in app) |
| screen transitions fade-up | app-level `PageRouteBuilder` or default transitions (keep consistent) |
| Keyboard Escape | back button / `PopScope` |

## 9. Coverage gaps / risks (be explicit)

| Gap | Reference to decide | Decision owner |
| --- | --- | --- |
| Alert content uses real KV strings; translate & centralize | F1 token string table in ux-redesign 02 | F1 author (you during F1). |
| **Demo affordances** (`Skip ▸`, fee `simPay`, splash `Skip`, "type any 4 digits") | `roadmap.md` `D14` | researcher-facing only; **excluded** from UI — do not port |
| **USD fare display** in prototype | `roadmap.md` `PDD-01` (app displays ៛) | product |
| **Rating via no endpoint** | `PDD-02` (N-10) | product |
| **#2F6BFF route colour** vs real map tiles | P3/G map-render QA | QA (Q1/Q2) |
| **push taker affordance** is not in prototype (bell dot ≠ unread count) | PDD-03 | product |
| **dark theme** not in prototype scope | F1→C baseline light-only | confirm via G0 gate |

## 10. Suggested build order (complete context)

Based on the doc set (01–07) + `roadmap.md`:
1. F1 tokens/theme (`ta_*` in `lib/core/theme`) — 04 → 07 §1.
2. C7 map-first booking (map → search → overlay → trip) — 05 §4/§8; this is the prototype's core.
3. C1 bottom-pill nav restyle — 07 §2.
4. C-add announcement/receipt/tariff = prototype parity screens (04, 06).
5. S/Q/QA after path parity; all PDD-01/02/03 decisions gate the above (see `IMPLEMENTATION_PROGRESS.md`).

> End of passenger UI-reference. Final audit cross-checks: `docs/ux-redesign/01–07`, the HTML at
> `docs/taarraa-ui-prototype.html`, and live `lib/` paths (see `roadmap.md` §"Never change").