# 04 — Component Specification

All specs below match the CSS definitions in `taarraa-ui-prototype.html`. Prototype is the single source of truth.

---

## 1. TaPrimaryButton (`.btn`)

**Purpose:** Primary call-to-action

### Props
| Prop | Type | Default | Required |
|---|---|---|---|
| `label` | `String` | — | Yes |
| `onTap` | `VoidCallback?` | — | No |
| `isLoading` | `bool` | `false` | No |
| `isEnabled` | `bool` | `true` | No |
| `variant` | `ButtonVariant` | `primary` | No |
| `size` | `ButtonSize` | `large` | No |

### Variants
```
ButtonVariant:
  primary        — bg: #FF4500, shadow: 0 6px 16px rgba(255,69,0,.35), text: white
  dark           — bg: #232838, shadow: 0 6px 16px rgba(35,40,56,.3), text: white
  ghost          — bg: white, border: 1px solid #EBEBF0, shadow: shadowSm, text: #191C24
  dangerGhost    — bg: #FDECEC, text: #D32F2F, shadow: none

ButtonSize:
  large          — height: 52px, fontSize: 16, fontWeight: 700, borderRadius: 16px
  small          — height: 44px, fontSize: 14, fontWeight: 700, borderRadius: 12px
```

### Disabled State
```
bg: #D8DBE3, text: white, shadow: none, cursor: not-allowed
```

### Press Animation
```
scale(0.97) — 100ms
```

---

## 2. TaIconButton (`.icon-btn`)

**Purpose:** Round-square icon button

### Props
| Prop | Type | Default | Required |
|---|---|---|---|
| `icon` | `Widget` | — | Yes |
| `onTap` | `VoidCallback?` | — | No |
| `size` | `double` | `42` | No |
| `showDot` | `bool` | `false` | No |

### Spec
```
Shape:      borderRadius: 12px
Background: white
Shadow:     shadowSm
Size:       42×42
Color:      #191C24

Dot:        position: absolute, top: 9, right: 10
            width: 9, height: 9, borderRadius: 99
            bg: #FF4500, border: 2px solid white
```

### Press Animation
```
scale(0.97) — 100ms
```

---

## 3. TaTextField (`.field`)

**Purpose:** Styled text input

### Props
| Prop | Type | Default | Required |
|---|---|---|---|
| `hint` | `String?` | — | No |
| `controller` | `TextEditingController?` | — | No |
| `prefix` | `Widget?` | — | No |
| `suffix` | `Widget?` | — | No |
| `obscureText` | `bool` | `false` | No |
| `keyboardType` | `TextInputType?` | `TextInputType.text` | No |
| `inputFormatters` | `List<TextInputFormatter>?` | — | No |
| `onChanged` | `ValueChanged<String>?` | — | No |
| `errorText` | `String?` | — | No |

### Spec
```
Container:
  display: flex, align: center, gap: 10px
  bg: white
  border: 1.5px solid #EBEBF0
  borderRadius: 14px
  padding: 0 14px
  height: 54px
  shadow: shadowSm

Focus:
  border: 1.5px solid #FF4500

Input:
  border: none, outline: none, bg: none, flex: 1
  fontSize: 15, color: #191C24

Prefix:
  fontWeight: 700, fontSize: 15
  borderRight: 1px solid #EBEBF0
  paddingRight: 10px

Error:
  color: #D32F2F, fontSize: 13, marginTop: 6px, minHeight: 18px
```

---

## 4. TaOTPField (`.otp`)

**Purpose:** Single digit OTP input

### Props
| Prop | Type | Default | Required |
|---|---|---|---|
| `count` | `int` | `4` | No |
| `onComplete` | `ValueChanged<String>?` | — | No |

### Spec
```
Row of count inputs, gap: 12px

Each input:
  width: 100% (of flex), height: 64px
  textAlign: center
  fontSize: 26, fontWeight: 800
  border: 1.5px solid #EBEBF0
  borderRadius: 14px
  bg: white
  shadow: shadowSm

Focus:
  border: 1.5px solid #FF4500
  boxShadow: 0 0 0 3px #FFE4D3  (brand-100 ring)

Auto-advance: on input, focus next box
Auto-back: on backspace empty, focus previous box
```

---

## 5. TaSearchCard (`.where`)

**Purpose:** Tappable search bar (Home screen)

### Props
| Prop | Type | Default | Required |
|---|---|---|---|
| `label` | `String` | `"Where to?"` | No |
| `onTap` | `VoidCallback?` | — | No |
| `icon` | `Widget` | `Icon(search)` | No |

### Spec
```
Container:
  display: flex, align: center, gap: 12px
  bg: white
  borderRadius: 16px
  shadow: shadowMd
  padding: 16px
  width: 100%

Text:
  fontSize: 16, fontWeight: 600, color: #6B7588

Icon: color #FF4500

Press:
  border: 1.5px solid #FF4500
```

---

## 6. TaCard (`.card`)

**Purpose:** Generic card container

### Props
| Prop | Type | Default | Required |
|---|---|---|---|
| `child` | `Widget` | — | Yes |
| `onTap` | `VoidCallback?` | — | No |
| `padding` | `EdgeInsets?` | `EdgeInsets.all(16)` | No |
| `margin` | `EdgeInsets?` | — | No |

### Spec
```
Background: white
BorderRadius: 16px
Shadow: shadowMd
Padding: 16px
```

---

## 7. TaSegmentedControl (`.seg`)

**Purpose:** Toggle between 2+ options (language, tabs)

### Props
| Prop | Type | Default | Required |
|---|---|---|---|
| `options` | `List<String>` | — | Yes |
| `selectedIndex` | `int` | — | Yes |
| `onChanged` | `ValueChanged<int>?` | — | No |

### Spec
```
Container:
  display: flex
  bg: #E8EAF0
  borderRadius: 99px
  padding: 3px
  gap: 2px

Button:
  padding: 6px 14px
  borderRadius: 99px
  fontSize: 13, fontWeight: 700
  color: #6B7588

Active button:
  bg: white
  color: #191C24
  shadow: shadowSm
```

---

## 8. TaStepIndicator (`.steps`)

**Purpose:** Progress dots on auth screens

### Props
| Prop | Type | Default | Required |
|---|---|---|---|
| `steps` | `int` | `3` | No |
| `current` | `int` | — | Yes |

### Spec
```
Row, gap: 6px

Each step:
  width: 26px, height: 5px
  borderRadius: 99px
  bg: #DCDDE5

Active step (index <= current):
  bg: #FF4500
```

---

## 9. TaBadge (`.badge`)

**Purpose:** Status label

### Props
| Prop | Type | Default | Required |
|---|---|---|---|
| `label` | `String` | — | Yes |
| `variant` | `BadgeVariant` | `success` | No |

### Variants
```
BadgeVariant:
  success  — bg: #E6F8EF, text: #0EAF6B
  error    — bg: #FDECEC, text: #D32F2F
  warning  — bg: #FFF4D6, text: #B97A00
  brand    — bg: #FFF4ED, text: #CC3700
```

### Spec
```
Container:
  display: inline-flex, align: center, gap: 4px
  fontSize: 12, fontWeight: 700
  padding: 5px 10px
  borderRadius: 99px
```

---

## 10. TaHistoryCard (`.hcard`)

**Purpose:** History list item

### Props
| Prop | `HistoryItem` data | — | Yes |
|---|---|---|---|
| `onTap` | `VoidCallback?` | — | No |
| `isCompleted` | `bool` | `true` | No |

### Spec
```
Button (full width, left-aligned):
  bg: white
  borderRadius: 16px
  shadow: shadowMd
  padding: 14px
  marginBottom: 12px

Row 1 (driver info):
  GradientAvatar(initials, 44px) — gradient: linear-gradient(135deg, #FF6A00, #B73CFF)
  Column:
    Text(invoice, fontWeight: 800)
    Text("driver · date", fontSize: 12, color: #6B7588)
  Text(amount, fontWeight: 800, fontSize: 16) — marginLeft: auto

Badge: Badge(isCompleted ? success : error)

Route summary:
  bg: #F6F6F7, borderRadius: 12px, padding: 10px 12px
  Row: dot-pickup(9px) + from address
  Row: dot-dest(9px) + to address

Meta row:
  fontSize: 12, color: #6B7588
  Row: route icon + "6.1 km" | clock icon + "18 min"
```

---

## 11. TaProfileRow (`.prow`)

**Purpose:** Settings/menu row

### Props
| Prop | Type | Default | Required |
|---|---|---|---|
| `icon` | `Widget` | — | Yes |
| `label` | `String` | — | Yes |
| `trailing` | `Widget?` | `Icon(chevron_right)` | No |
| `onTap` | `VoidCallback?` | — | No |
| `isDanger` | `bool` | `false` | No |

### Spec
```
Container:
  display: flex, align: center, gap: 12px
  bg: white
  borderRadius: 14px
  shadow: shadowSm
  padding: 15px
  width: 100%
  marginBottom: 8px
  fontSize: 15, fontWeight: 600

Leading icon: color #FF4500
Trailing icon: color #9AA0B4

Danger variant:
  color: #D32F2F
  Leading icon: color #D32F2F
  No trailing icon
```

---

## 12. TaAvatar (`.davatar` / `.havatar` / `.avatar-pick`)

**Purpose:** Circular avatar with initials or image

### Variants
```
Driver (davatar):
  size: 52px
  bg: linear-gradient(135deg, #2F6BFF, #7A5CFF)
  text: white, fontWeight: 800, fontSize: 18

History (havatar):
  size: 44px
  bg: linear-gradient(135deg, #FF6A00, #B73CFF)
  text: white, fontWeight: 800

Profile (prof-head):
  size: 48px (inside prof-head)
  bg: linear-gradient(135deg, #FF6A00, #B73CFF)

Register (avatar-pick):
  size: 120px
  bg: white, shadow: shadowMd
  color: #9AA0B4 (placeholder icon)
  Camera button: 38px circle, bg: #FF4500, white icon, shadow: 0 4px 12px rgba(255,69,0,.4)
```

---

## 13. TaTimeline (`.timeline` / `.tstep`)

**Purpose:** Ride progress stepper (Booking screen)

### Props
| Prop | Type | Default | Required |
|---|---|---|---|
| `steps` | `List<String>` | `["Accepted", "Arriving", "On trip"]` | No |
| `currentStep` | `int` | — | Yes |

### Spec
```
Row, full width

Each step:
  flex: 1, textAlign: center

  Step circle (`.td`):
    width: 26, height: 26
    borderRadius: 99px
    bg (inactive): #E7E8EE, text: white
    bg (active): #FF4500, shadow: 0 4px 10px rgba(255,69,0,.4), text: white
    Contains: step number (or check icon if completed)

  Connecting line (before each step except first):
    position: absolute, top: 13px, left: -50%
    width: 100%, height: 2px
    bg (inactive): #E7E8EE
    bg (active): #FF4500

  Label below circle:
    fontSize: 11, fontWeight: 700
    color (inactive): #9AA0B4
    color (active): #CC3700
```

---

## 14. TaStatusPill (`.status-pill`)

**Purpose:** Active ride status indicator

### Props
| Prop | Type | Default | Required |
|---|---|---|---|
| `text` | `String` | — | Yes |
| `isPulsing` | `bool` | `true` | No |

### Spec
```
Container:
  bg: #232838
  color: white
  fontSize: 13, fontWeight: 700
  padding: 10px 18px
  borderRadius: 99px
  shadow: shadowLg
  display: flex, gap: 8px, align: center
  whiteSpace: nowrap

Pulse dot:
  width: 9, height: 9, borderRadius: 99
  bg: #4ADE80
  animation: pulse 1.2s infinite
```

---

## 15. TaDriverCard (`.driver`)

**Purpose:** Driver info row

### Props
| Prop | Type | Default | Required |
|---|---|---|---|
| `name` | `String` | — | Yes |
| `rating` | `String?` | — | No |
| `vehicleInfo` | `String` | — | Yes |
| `plateNumber` | `String?` | — | No |
| `initials` | `String` | — | Yes |

### Spec
```
Container:
  bg: #F6F6F7
  borderRadius: 14px
  padding: 12px
  display: flex, gap: 12px, align: center

DriverAvatar (52px)

Name row:
  Text(name, fontWeight: 800, fontSize: 15)
  If rating: Star icon (filled, #F5A623, 15px) + Text(rating, fontSize: 13)
Text(vehicleInfo, fontSize: 12, color: #6B7588)

Plate badge (if present):
  marginLeft: auto
  bg: #232838, color: white
  fontWeight: 800, fontSize: 13
  padding: 7px 12px, borderRadius: 9px, letterSpacing: 1px
```

---

## 16. TaTotalBox (`.total-box`)

**Purpose:** Trip fare total display

### Props
| Prop | Type | Default | Required |
|---|---|---|---|
| `amount` | `String` | — | Yes |
| `label` | `String` | `"Total · Cash"` | No |

### Spec
```
Container:
  bg: linear-gradient(135deg, #FF6A00, #E63E00)
  borderRadius: 16px
  color: white
  padding: 16px
  display: flex, justify: between, align: center
  shadow: 0 8px 22px rgba(255,69,0,.35)

Label: opacity: .85, fontSize: 13
Amount: fontWeight: 800, fontSize: 28
```

---

## 17. TaStarRating (`.stars`)

**Purpose:** 5-star rating input

### Props
| Prop | Type | Default | Required |
|---|---|---|---|
| `rating` | `int` | `0` | Yes |
| `onChanged` | `ValueChanged<int>?` | — | No |

### Spec
```
Row, gap: 10px, justify: center

Each star:
  width: 44, height: 44
  color (unlit): #DCDDE5
  color (lit): #F5A623
  animation (on select): pop3 (scale 1.3) 250ms
```

---

## 18. TaChip (`.chip`)

**Purpose:** Selectable tag (Rating screen)

### Props
| Prop | Type | Default | Required |
|---|---|---|---|
| `label` | `String` | — | Yes |
| `isSelected` | `bool` | `false` | No |
| `onTap` | `VoidCallback?` | — | No |

### Spec
```
Container:
  border: 1.5px solid #EBEBF0
  bg: white
  borderRadius: 99px
  padding: 9px 16px
  fontSize: 13, fontWeight: 700
  color: #6B7588

Selected:
  border: 1.5px solid #FF4500
  color: #CC3700
  bg: #FFF4ED
```

---

## 19. TaPromoBanner (`.promo`)

**Purpose:** Promotional banner on Home

### Props
| Prop | Type | Default | Required |
|---|---|---|---|
| `tag` | `String` | `"PROMO"` | No |
| `title` | `String` | — | Yes |
| `subtitle` | `String` | — | Yes |
| `onTap` | `VoidCallback?` | — | No |

### Spec
```
Container:
  bg: linear-gradient(120deg, #232838, #3a2c28 70%, #572c12)
  color: white
  borderRadius: 16px
  padding: 14px 16px
  display: flex, align: center, gap: 12px
  shadow: shadowMd

Tag pill:
  bg: #FF4500
  fontSize: 11, fontWeight: 800
  padding: 4px 10px, borderRadius: 99px

Title: fontWeight: 800, fontSize: 15
Subtitle: opacity: .75

Trailing: chevron icon, opacity: .6
```

---

## 20. TaVehicleRow (`.veh` / `.veh-mini`)

**Purpose:** Vehicle selection row

### Props
| Prop | Type | Default | Required |
|---|---|---|---|
| `vehicle` | `VehicleData` | — | Yes |
| `isSelected` | `bool` | `false` | No |
| `onTap` | `VoidCallback?` | — | No |
| `compact` | `bool` | `false` | No |

### Full Row (`.veh`)
```
Container:
  bg: white
  borderRadius: 16px
  shadow: shadowMd
  padding: 12px 14px
  display: flex, gap: 12px, align: center
  marginBottom: 10px
  border: 1.5px solid transparent

Selected:
  borderColor: #FF4500
  bg: #FFF4ED

Vehicle art: 84×52, SVG

Info:
  Text(name, fontWeight: 800, fontSize: 15)
  Text("3 seats · $0.45/km", fontSize: 12, color: #6B7588)

Right:
  Text("from $1.00", fontWeight: 800, color: #CC3700)
  ETA row: clock icon (sm) + "3 min", fontSize: 12, color: #6B7588
```

### Compact Row (`.veh-mini`)
```
Same layout but:
  Vehicle art: 72×44
  Name: fontWeight: 800
  Seats/eta: "3 seats · ~3 min"
  Trailing: Tariff pill button instead of price
```

---

## 21. TaStatRow (`.stat3`)

**Purpose:** Distance/duration/fare metrics

### Props
| Prop | Type | Default | Required |
|---|---|---|---|
| `items` | `List<StatItem>` | — | Yes |

### Spec
```
Container:
  bg: #F6F6F7
  borderRadius: 14px
  padding: 12px 0
  display: flex

Each item:
  flex: 1, textAlign: center
  + borderLeft (except first): 1px solid #EBEBF0

  Value: fontWeight: 800, fontSize: 16
  Label: fontSize: 11, color: #6B7588
```

---

## 22. TaAddressRow (`.addr-row` + `.dot-pickup` + `.dot-dest`)

**Purpose:** Pickup/destination display

### Spec
```
Row, gap: 12px, align: flex-start, padding: 8px 0

Dot (pickup): 12×12, borderRadius: 99, bg: #232838, boxShadow: 0 0 0 4px #E3E5EC
Dot (dest):   12×12, borderRadius: 99, bg: #FF4500, boxShadow: 0 0 0 4px #FFE4D3

Label: fontSize: 11, fontWeight: 700, color: #9AA0B4, textTransform: uppercase, letterSpacing: .5px
Name:  fontSize: 15, fontWeight: 700
Sub:   fontSize: 12, color: #6B7588
```

---

## 23. TaKVRow (`.kv`)

**Purpose:** Key-value pair display

### Spec
```
Row, justify: space-between, fontSize: 14, padding: 7px 0

Label: color: #6B7588
Value: fontWeight: 700
```

---

## 24. TaNoteField (`.note-field`)

**Purpose:** Optional driver note input

### Spec
```
Container:
  display: flex, align: center, gap: 8px
  bg: #F6F6F7
  borderRadius: 12px
  padding: 10px 12px
  fontSize: 13, color: #6B7588

Input:
  border: none, bg: none, outline: none, flex: 1
  fontSize: 13, minWidth: 0
```

---

## 25. TaSearchResult (`.place`)

**Purpose:** Search result item

### Spec
```
Container:
  display: flex, gap: 12px, align: center
  bg: white
  borderRadius: 14px
  shadow: shadowSm
  padding: 13px 14px
  marginBottom: 8px
  width: 100%
  textAlign: left

Pin icon: color #FF4500
Name: fontWeight: 700, fontSize: 14
Keyword: fontSize: 12, color: #6B7588
Distance badge: marginLeft: auto, fontSize: 12, fontWeight: 800, color: #CC3700, bg: #FFF4ED, padding: 4px 10px, borderRadius: 99px
```

---

## 26. TaDialog (`.dialog`)

**Purpose:** Modal dialog

### Spec
```
Container:
  position: absolute, left: 24, right: 24, top: 50%, transform: translateY(-50%)
  bg: white
  borderRadius: 20px
  padding: 22px
  textAlign: center
  animation: pop 250ms cubic-bezier(.2,.9,.3,1.2)

Title: margin: 0 0 8px, fontSize: 18
Body:  fontSize: 14, color: #6B7588, marginBottom: 16px

Actions (`.drow`):
  display: flex, gap: 10px
  Full-width buttons side by side
```

---

## 27. TaBottomSheet (`.sheet`)

**Purpose:** Bottom sheet

### Spec
```
Container:
  position: absolute, left: 0, right: 0, bottom: 0
  bg: white
  borderRadius: 22px 22px 0 0
  padding: 12px 20px 26px
  maxHeight: 82%
  overflow-y: auto
  animation: up 300ms cubic-bezier(.2,.9,.3,1)

Grab handle:
  width: 44px, height: 5px
  borderRadius: 99px
  bg: #D8DBE3
  margin: 0 auto 14px

Backdrop:
  position: absolute, inset: 0
  bg: rgba(15,17,25,.5)
  animation: fade 200ms
```

---

## 28. TaToast (`#toast`)

**Purpose:** Temporary feedback toast

### Spec
```
Container:
  position: absolute, left: 20, right: 20, bottom: 100px
  bg: #232838
  color: white
  fontSize: 14, fontWeight: 600
  padding: 13px 16px
  borderRadius: 14px
  shadow: shadowLg
  display: flex, gap: 10px, align: center
  opacity: 0, transform: translateY(12px), transition: .25s

Visible:
  opacity: 1, transform: none

Icon: color #7CFFB2 (mint check)
Duration: 2400ms
No swipe-to-dismiss
No type variants (always check icon)
```

---

## 29. TaSkeleton (`.skel`)

**Purpose:** Loading placeholder

### Spec
```
Container:
  bg: white
  borderRadius: 16px
  shadow: shadowSm
  padding: 14px
  marginBottom: 10px
  display: flex, gap: 12px

Inner skeletons:
  bg: linear-gradient(90deg, #EDEEF2, #F7F7FA, #EDEEF2)
  background-size: 200% 100%
  animation: sh 1.1s infinite

Shape variants:
  Rectangle: borderRadius: 8px
  Circle:    borderRadius: 99px
```

---

## 30. TaLoadingOverlay (`.bookov`)

**Purpose:** Full-screen booking loading

### Spec
```
Container:
  position: absolute, inset: 0
  bg: rgba(255,255,255,.94)
  zIndex: 20
  display: flex, flexDirection: column, align: center, justify: center
  padding: 32px, textAlign: center

Spinner:
  width: 64, height: 64, borderRadius: 99
  border: 5px solid #FFE4D3
  borderTopColor: #FF4500
  animation: spin .8s linear infinite

Car bounce:
  marginTop: 14
  animation: bnc 1s infinite ease-in-out
  color: #FF4500

Title: marginTop: 10
Subtitle: color: #6B7588, fontSize: 12, margin: 6px 0 22px
Cancel button: dangerGhost, maxWidth: 220
```

---

## 31. TaBottomNav (`.tabbar`)

**Purpose:** Floating pill navigation

### Spec
```
Container:
  position: absolute, left: 12, right: 12, bottom: 12
  bg: white
  borderRadius: 22px
  shadow: shadowLg
  display: flex
  padding: 8px
  zIndex: 55

Tab button:
  flex: 1
  display: flex, flexDirection: column, align: center, gap: 3px
  padding: 8px 0
  fontSize: 11, fontWeight: 600
  color: #9AA0B4
  borderRadius: 14px

Active tab:
  color: #FF4500
  bg: #FFF4ED
  borderRadius: 14px
```

---

## 32. TaMinMaxSheet (`.tarif-btn` / tariff sheet)

**Purpose:** Vehicle tariff detail bottom sheet

### Trigger Button
```
Tariff pill:
  marginLeft: auto
  fontSize: 13, fontWeight: 800
  color: #FF4500
  bg: #FFF4ED
  padding: 9px 16px, borderRadius: 99px
```

### Sheet Content
```
Title: "Vehicle Name · Tariff"
KV rows: Min fee, Price per km, Seats
Button: "Got it" (primary, full width)
```

---

## Component File Structure

All new components in `lib/presentation/widgets/`:

```
lib/presentation/widgets/
├── ta_button.dart           (primary, ghost, danger-ghost, dark, sm)
├── ta_icon_button.dart      (square, dot indicator)
├── ta_text_field.dart       (with prefix, error)
├── ta_otp_field.dart        (4-digit input)
├── ta_search_card.dart      (home "Where to?")
├── ta_card.dart             (generic card)
├── ta_segment.dart          (language toggle, tabs)
├── ta_step_indicator.dart   (auth progress dots)
├── ta_badge.dart            (success, error, warning, brand)
├── ta_history_card.dart     (hcard with havatar, route, meta)
├── ta_profile_row.dart      (prow with danger variant)
├── ta_avatar.dart           (driver, history, profile, register)
├── ta_timeline.dart         (ride progress stepper)
├── ta_status_pill.dart      (booking status)
├── ta_driver_card.dart      (driver info + plate)
├── ta_total_box.dart        (orange gradient total)
├── ta_star_rating.dart      (5-star input)
├── ta_chip.dart             (selectable tag)
├── ta_promo_banner.dart     (home promo)
├── ta_vehicle_row.dart      (full and compact variants)
├── ta_stat_row.dart         (distance/duration/fare)
├── ta_address_row.dart      (pickup/dest with dots)
├── ta_kv_row.dart           (key-value pair)
├── ta_note_field.dart       (driver note)
├── ta_search_result.dart    (place card)
├── ta_dialog.dart           (centered popup)
├── ta_bottom_sheet.dart     (grab handle, backdrop)
├── ta_toast.dart            (navy, mint icon)
├── ta_skeleton.dart         (shimmer loading)
├── ta_loading_overlay.dart  (booking spinner + car)
├── ta_bottom_nav.dart       (floating pill)
├── ta_minimax_sheet.dart    (tariff detail)
└── widgets.dart             (barrel export)
```
