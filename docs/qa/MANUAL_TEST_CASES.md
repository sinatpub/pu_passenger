# PU Taxi Passenger: manual test cases (real device)

Test cases for the passenger app on a real phone, against the real backend.
Written on 2026-10-07 for the app at commit `101507e` (branch `dev`).

- [How to use this file](#how-to-use-this-file)
- [1. Setup](#1-setup)
- [2. Known gaps: do not report these](#2-known-gaps-do-not-report-these)
- [3. Test cases](#3-test-cases)
- [4. Result summary](#4-result-summary)
- [5. Bug report template](#5-bug-report-template)

## How to use this file

- Run the sections in order. Later sections need the account and the trip that earlier ones create.
- Each case has numbered steps, then the expected results as a checklist. Tick a box when the app does what the line says.
- A case passes only when every box is ticked. Anything else is a bug: write it up with the [template](#5-bug-report-template) and note the case ID.
- Cases marked **(2 devices)** need the driver app on a second phone or emulator, signed in and online.
- Cases marked **(debug build)** only work in a debug build or a test APK (see Build and install).
- Labels are given in English. Switch the app to English in case B-01 before following the steps; section R repeats the main flow in Khmer.

## 1. Setup

### Devices

| Item | Need |
|---|---|
| Passenger phone | A real Android or iOS phone with a SIM or Wi-Fi, GPS on, Google Play services (Android) |
| Driver device | A second phone or an emulator with the driver app, signed in as an approved driver and **online** |
| Position | Both devices in the same area. The driver must be near enough for the backend to offer them the ride |
| Network | Wi-Fi and mobile data both available on the passenger phone, so you can switch between them |

### Build and install

Debug build, straight onto the connected phone:

```bash
fvm flutter run --dart-define-from-file=dart_defines.json
```

Release build (Android):

```bash
fvm flutter build apk --release --dart-define-from-file=dart_defines.json
```

Test APK: a release build that also has the **Debug login** button, for
signing in as the test account on a real phone. It carries that account's
phone and password, so it is for testers only and must never be published.

```bash
fvm flutter build apk --release --dart-define-from-file=dart_defines.json --dart-define=DEBUG_LOGIN_IN_RELEASE=true --dart-define=DEMO_INVITE=true
```

- Do **not** add `USE_MOCK_DATA=true`. A red **MOCK** tab on the left edge of the screen means the mock backend is on; these cases are for the real one.
- `dart_defines.json` must hold the two Google keys. Without them the map and the place search do not work.

### Accounts

| Account | Where it comes from |
|---|---|
| Passenger, existing | A phone number already registered on the backend. In a debug build or a test APK, the **Debug login** button signs in as the account set in `dart_defines.json` |
| Passenger, new | A phone number that has never signed in, and that can receive the SMS code |
| Driver | The test driver account from the backend developer |

Do not write passwords or codes into bug reports.

### Before you start

- [ ] Uninstall any older copy of the passenger app, so no old session is on the phone.
- [ ] Note the phone model, OS version, and the build (debug or release, commit).
- [ ] Driver app is signed in, approved, and online.

## 2. Known gaps: do not report these

These are known and not yet built or fixed. Skip them when they show up.

| What you see | Why |
|---|---|
| No route line on the map, and no "N min" arrival time on the ride screen | Google refuses the route request for the current key (`REQUEST_DENIED`). Needs a change in Google Cloud console |
| The rating is not saved on the server | The backend has no rating endpoint. The rating shows on the Thank you page for this session only |
| The **PROMO** banner on Home only shows a toast | Demo content, no promo system behind it |
| After a failed load, Home keeps its grey placeholder rows and shows only a short message | No error state on Home yet. Tap the refresh button |
| The driver marker moves in steps, up to a minute apart | The driver's position comes with the booking refresh, not as a live stream |
| **Saved places** shows "coming soon" | Not built |
| **Add a note for driver** is not seen by the driver | The note is kept on the phone and not sent |
| **My invite QR**, **Invite rewards** and the **Ride credit** card show code `PS4N7Q`, $2.07 and the same two people for every account | Sample data: the backend has no invite routes yet. Nobody is really invited or credited. A release build without `DEMO_INVITE=true` has no invite at all (D47) |
| No **Use ride credit** on the booking sheet | Sample credit cannot pay a driver. It works on the mock build |
| Seat counts and "~N min" on the vehicle list are fixed per vehicle kind | The backend sends neither |
| A trip booked before 2026-10-07 shows no pickup address on the fare page, receipt, or history | It was saved without one. The ride screen looks one up; the other pages show what the server has |
| Terms and conditions text mentions "rickshaw" | Legal text not yet revised |

## 3. Test cases

### A. Install and first launch

#### A-01 · First launch

1. Install the app and open it.

- [ ] The splash screen shows the PU Taxi mark, then the Login page opens.
- [ ] The app is in Khmer.
- [ ] No red **MOCK** tab is on the screen.
- [ ] The app name under the icon on the phone's home screen is "PU Taxi".

#### A-02 · Launch with no network

1. Turn on airplane mode.
2. Open the app.

- [ ] The app reaches the Login page and does not freeze or close.

#### A-03 · Launch after a sign-in

Run after section C.

1. Close the app completely (swipe it away).
2. Open it again.

- [ ] Home opens without asking for the phone number again.

### B. Language

#### B-01 · Switch to English

1. On the Login page, tap **EN** in the language switch at the top right.

- [ ] All text on the page changes to English at once.
- [ ] The switch shows **EN** as selected.

#### B-02 · Language is remembered

1. With English selected, close the app completely and open it again.

- [ ] The app opens in English.

#### B-03 · Switch on every page that has the switch

1. Sign in (section C), then tap the switch on Home, and on the Account tab.

- [ ] Each page changes language at once, including the tab bar labels.
- [ ] The choice made on one page shows on the others.

### C. Sign in

#### C-01 · Empty number

1. On Login, leave the phone field empty and tap **Next**.

- [ ] The field shakes.
- [ ] A message says why. Report it if there is none.
- [ ] The app stays on Login. No code is sent.

#### C-02 · Number too short

1. Type `1234567` (seven digits) and tap **Next**.

- [ ] The field shakes and a message says the number is not valid.
- [ ] The app stays on Login.

#### C-03 · Only digits are accepted

1. Try to type letters and symbols into the phone field.
2. Type more than 12 digits.

- [ ] Letters and symbols do not appear.
- [ ] Typing stops at 12 digits.
- [ ] Digits are shown in groups, and `+855` stays in front.

#### C-04 · Valid number sends a code

1. Type the existing passenger's number and tap **Next**.

- [ ] A loading indicator shows, then the OTP page opens.
- [ ] An SMS with a 4-digit code arrives on that number.
- [ ] A countdown runs under the code boxes. **Send again** cannot be tapped until it reaches zero.

#### C-05 · Wrong code

1. On the OTP page, type a wrong 4-digit code.

- [ ] A dialog says to check the code. The boxes show the error state.
- [ ] After closing the dialog you can type again.

#### C-06 · Right code

1. Type the code from the SMS.

- [ ] Home opens.
- [ ] The Account tab shows this passenger's name and phone number.

#### C-07 · Send again

1. Sign out, start sign-in again, and on the OTP page wait for the countdown to end.
2. Tap **Send again**.

- [ ] A new SMS arrives.
- [ ] The countdown starts again.
- [ ] The new code signs you in.

#### C-08 · Back from OTP

1. On the OTP page, tap the back arrow at the top left.

- [ ] Login opens with the number still in the field.

#### C-09 · Debug login (debug build or test APK)

1. On Login, tap **Debug login** under **Next**.

- [ ] The line under the button names the account it signs in as.
- [ ] Home opens without an SMS code.
- [ ] In a release build this button is not there.

### D. Sign up

#### D-01 · New number opens Complete Profile

1. Sign in with a number that has never been used, and enter the SMS code.

- [ ] The **Complete Profile** page opens, not Home.
- [ ] The step indicator shows the third step.

#### D-02 · Photo and name

1. Tap the photo circle and choose a photo from the camera or the gallery.
2. Type a full name.
3. Tap **Create**.

- [ ] The phone asks for camera or photo permission the first time.
- [ ] The chosen photo shows in the circle.
- [ ] Home opens after **Create**.
- [ ] The Account tab shows the name, the number, and the photo.

#### D-03 · Create without a photo

1. On Complete Profile, type a name but add no photo. Tap **Create**.

- [ ] The caption under the photo circle says the photo is optional.
- [ ] **Create** is live as soon as a name is typed.
- [ ] Home opens after **Create**.
- [ ] The Account tab shows the name and the number, and initials in place of a photo.

#### D-04 · Back from Complete Profile

1. Tap the back arrow.

- [ ] The app goes back without closing or freezing.

### E. Session

#### E-01 · Stay signed in

1. Sign in. Close the app completely. Open it again. Repeat three times.

- [ ] Home opens every time.
- [ ] You are never sent to Login.

#### E-02 · Log out

1. Account tab, tap **Logout**, then confirm.

- [ ] A dialog asks to confirm before anything happens.
- [ ] Login opens.

#### E-03 · Logged out means logged out

1. After E-02, close the app completely and open it again.

- [ ] Login opens, not Home.

#### E-04 · Sign in as someone else

1. After logging out of passenger X, sign in as passenger Y.
2. Open Account, then My Booking.

- [ ] Account shows Y's name and number.
- [ ] My Booking shows Y's trips, not X's.

#### E-05 · Cancel the logout

1. Tap **Logout**, then choose the "no" answer.

- [ ] The dialog closes and you are still signed in.

### F. Home

#### F-01 · Vehicle list loads

1. Open Home.

- [ ] Grey placeholder rows show first, then the list.
- [ ] The list shows the vehicle types of the backend (today: Moto, Tuktuk, Car).
- [ ] Each row has a drawing of the right vehicle, the name, seats, a price per km, a "from" price, and a wait time.
- [ ] Prices are in dollars with cents, for example `$0.30/km` and `from $0.50`.
- [ ] Moto shows "1 Seat", not "1 Seats".

#### F-02 · Refresh

1. Tap the round refresh button at the right of **Choose your ride**.

- [ ] The placeholder rows show briefly and the list comes back.

#### F-03 · Home with no network

1. Turn on airplane mode. Tap refresh.

- [ ] A message says something went wrong.
- [ ] The app does not close.

1. Turn airplane mode off and tap refresh.

- [ ] The list loads again.

#### F-04 · Tab bar

1. Tap **Home**, **My Booking**, **Account** in turn.

- [ ] Each tab opens its page and is shown as selected.
- [ ] The tab bar stays at the bottom of the screen on all three.

#### F-05 · Open the map from a vehicle

1. Tap **Tuktuk**.

- [ ] The map page opens with Tuktuk already selected.

#### F-06 · Update prompt

Only when the backend lists a newer version than the installed one.

1. Open Home.

- [ ] A dialog offers the update, with a way to go to the store.
- [ ] Note whether it can be dismissed.

### G. Permissions and location

#### G-01 · Location permission asked

1. With a fresh install, sign in and reach Home.

- [ ] The phone asks for location permission.

#### G-02 · Allow

1. Choose "While using the app".
2. Tap a vehicle.

- [ ] The map centres on where you are.
- [ ] The pickup row shows the address of that spot, without repeated or empty parts.

#### G-03 · Deny

1. Fresh install. Deny location. Tap a vehicle.

- [ ] The map opens and the app does not close.
- [ ] You can still set a pickup by moving the map.

#### G-04 · Deny for good

1. Deny location twice (Android), or turn it off in the phone's settings.
2. Open Home.

- [ ] A dialog explains location is needed and offers **Open Setting**.
- [ ] **Open Setting** opens this app's page in the phone's settings.

#### G-05 · GPS off

1. Turn off the phone's location service. Open the map page.

- [ ] The app does not close.
- [ ] The pickup follows the pin, so a pickup can still be set by moving the map.

#### G-06 · Notification permission

1. Fresh install on Android 13 or later, or iOS. Reach Home.

- [ ] The phone asks to allow notifications.
- [ ] The app works the same whichever answer you give.

### H. Map: pickup, drop-off, vehicle

#### H-01 · Map page layout

1. Tap a vehicle on Home.

- [ ] The back button is at the top left.
- [ ] The current-location button is at the right, above the sheet.
- [ ] The sheet shows the pickup row, **Add drop-off (optional)**, the vehicle chips, and the **Book** button.
- [ ] Driver markers of the selected vehicle type show on the map when drivers are near.

#### H-02 · Move the pickup

1. Drag the map so the pin sits on another street. Let go.

- [ ] The pickup address in the sheet changes to the new spot within a few seconds.
- [ ] Dragging again quickly never leaves the address of an earlier spot on screen.

#### H-03 · Back to my position

1. After H-02, tap the current-location button.

- [ ] The map returns to where you are, and the pickup address follows.

#### H-04 · Change vehicle

1. Tap each vehicle chip in turn.

- [ ] The chip is shown as selected.
- [ ] The line under the chips changes to that vehicle's seats and wait time.
- [ ] The button changes to **Book {vehicle}**.
- [ ] The driver markers change to drivers of that type, with the right marker (a moto for Moto, a tuk tuk for Tuktuk, a car for Car).

#### H-05 · Tariff

1. Tap **Tariff**.

- [ ] A sheet shows the minimum fee, the price per km, and the seats of the selected vehicle, in dollars.
- [ ] **Got it** closes it.

#### H-06 · Add a drop-off from the map

1. Tap **Add drop-off (optional)**.
2. Move the map to the destination. Tap **Confirm Drop Off**.

- [ ] A map opens with a pin and the address of the pin.
- [ ] Back on the booking map, the drop-off row shows that address.
- [ ] A fare shows on each vehicle chip and on the button, for example **Book Moto · $1.70**.
- [ ] Pickup and drop-off markers match the dots in the route card (dark round for pickup, orange square for drop-off).

#### H-07 · Add a drop-off by search

1. Tap **Add drop-off (optional)**, then the search field.
2. Type two letters.
3. Type a place name, for example `Aeon Mall`.
4. Tap a result.

- [ ] With two letters a hint says to type at least three.
- [ ] Results appear after three or more letters.
- [ ] Tapping a result moves the pin there.
- [ ] A name with no match shows "No places match".
- [ ] The X in the search field clears it.

#### H-08 · Clear the drop-off

1. With a drop-off set, tap the X on the drop-off row.

- [ ] The drop-off is removed and the row says **Add drop-off (optional)** again.
- [ ] The fares go back to "from $…".

#### H-09 · Fare estimate looks right

1. Set a drop-off a few km away. Open **Tariff** for the selected vehicle.

- [ ] Estimate = minimum fee for the first km + price per km for each further km, to the cent. For a route under 1 km it is the minimum fee.

#### H-10 · Leave the map

1. Tap the back button, or use the phone's back gesture.

- [ ] Home opens. Nothing is booked.

### I. Booking request

#### I-01 · Book without a drop-off (2 devices)

1. Driver online. On the passenger map, with no drop-off, tap **Book {vehicle}**.

- [ ] An overlay shows a spinner, "Contacting nearby drivers…", the vehicle name, and **Cancel**.
- [ ] The driver app receives the request within a few seconds, with the passenger's name.

#### I-02 · Driver accepts (2 devices)

1. After I-01, accept on the driver app.

- [ ] The passenger moves to the ride screen within about 5 seconds.

#### I-03 · Book right after the map opens (2 devices)

1. Open the map and tap **Book** as fast as you can, before the pickup address appears.
2. Let the driver accept.

- [ ] The ride screen shows a pickup address, not `---` and not "Pinned location".

#### I-04 · Cancel while searching

1. Tap **Book**, then **Cancel** on the overlay.

- [ ] The overlay closes and the map is usable again.
- [ ] You can book again straight away.
- [ ] Note what the driver app shows. The request should go away, or say it was cancelled.

#### I-05 · Double tap on Book

1. Tap **Book** twice quickly.

- [ ] Only one request reaches the driver.

#### I-06 · Book with no network

1. Turn on airplane mode. Tap **Book**.

- [ ] A dialog says "Couldn't book your ride" with **Try again** and **Close**.
- [ ] **Close** returns to the map with pickup and drop-off unchanged.

1. Turn airplane mode off. Tap **Book**, and in the dialog tap **Try again** if it shows.

- [ ] The request goes out.

#### I-07 · Book with a drop-off (2 devices)

1. Set a drop-off. Tap **Book**. Driver accepts.

- [ ] The driver app shows the drop-off.
- [ ] The passenger's ride screen shows both addresses.

### J. Active ride

All cases in this section are **(2 devices)**. Start from an accepted booking.

#### J-01 · Driver on the way

- [ ] The headline says the driver is on the way.
- [ ] The first of three progress bars is filled.
- [ ] The driver card shows the driver's name, the car (maker, model, colour), and the plate number.
- [ ] The trip card shows the pickup address. With no drop-off it says "No drop-off · fare by meter".
- [ ] **Call driver** and **Cancel Booking** are shown.
- [ ] The map shows the driver marker and the pickup marker.

#### J-02 · Driver marker moves

1. Move the driver device, or wait while the driver drives.

- [ ] The driver marker on the passenger map moves to the new spot within about a minute, and points the way the driver is heading.

#### J-03 · Recenter

1. Drag the map away. Tap the recenter button at the right, above the sheet.

- [ ] The map returns to show the driver and the pickup.

#### J-04 · Call driver

1. Tap **Call driver**.

- [ ] The phone's dialler opens with the driver's number. The call is not placed until you press call.
- [ ] Coming back to the app shows the ride screen unchanged.

#### J-05 · Driver arrives

1. On the driver app, mark arrival.

- [ ] The passenger's headline changes to say the driver has arrived, within a few seconds.
- [ ] The line under it says "Meet at {pickup}".
- [ ] The second progress bar is filled.
- [ ] **Cancel Booking** is still shown.

#### J-06 · Trip starts

1. On the driver app, start the trip.

- [ ] The headline changes to say the trip is under way.
- [ ] All three progress bars are filled.
- [ ] The line under the headline says "To {drop-off}", or "Fare by meter" with no drop-off.
- [ ] **Cancel Booking** is no longer shown.

#### J-07 · Pickup address when the booking has none

Only if a trip shows no pickup address.

- [ ] The trip card shows an address looked up from the pickup point, a moment after the screen opens.

#### J-08 · Leave and come back during the ride

1. During the ride, press the phone's home button. Wait 30 seconds. Open the app again.

- [ ] The ride screen shows the current stage, not an earlier one.

#### J-09 · Kill and reopen during the ride

1. During the ride, close the app completely. Open it again.

- [ ] Home shows briefly, then the ride screen opens on its own at the current stage.

#### J-10 · Back gesture during the ride

1. Use the phone's back gesture on the ride screen.

- [ ] Note what happens. The passenger must not lose the ride: if the app leaves the ride screen, reopening Home must bring it back.

### K. Cancelling

#### K-01 · Passenger cancels before pickup (2 devices)

1. With an accepted booking, tap **Cancel Booking**.
2. Choose **Keep waiting**.
3. Tap **Cancel Booking** again and choose **Yes, cancel**.

- [ ] A dialog asks "Cancel booking?" before anything happens.
- [ ] **Keep waiting** closes the dialog and the ride goes on.
- [ ] **Yes, cancel** ends the ride and returns to Home.
- [ ] The driver app shows the passenger cancelled.
- [ ] The trip appears under My Booking, **Cancelled**, with no fare.

#### K-02 · Driver cancels (2 devices)

1. With an accepted booking, cancel on the driver app.

- [ ] The passenger sees a dialog "Your driver cancelled", with **Book again** and **Close**.
- [ ] **Close** returns to Home.

#### K-03 · Book again after the driver cancelled (2 devices)

1. Repeat K-02 and tap **Book again**.

- [ ] The map opens with the same vehicle and the same drop-off as the cancelled booking.

#### K-04 · A new booking after a cancel (2 devices)

1. After K-01, book again and let the driver accept.

- [ ] The second booking works the same as the first.

### L. Fare and payment

All cases in this section are **(2 devices)**.

#### L-01 · Trip ends

1. On the driver app, end the trip.

- [ ] The passenger moves to the fare page within a few seconds.
- [ ] The amount is large, in dollars with cents.
- [ ] The card shows pickup, drop-off (or "No drop-off · fare by meter"), distance, duration, and date and time.
- [ ] A banner says the app is waiting for the driver to confirm payment.

#### L-02 · Amount matches the driver

- [ ] The amount on the passenger's fare page is the amount the driver app asks to collect.

#### L-03 · Driver confirms payment

1. On the driver app, confirm the payment.

- [ ] The passenger moves to the Thank you page, and the rating dialog opens over it.

#### L-04 · Reopen on the fare page

1. On the fare page, before the driver confirms, close the app completely and open it.

- [ ] The fare page opens again on its own, with the same amount.

#### L-05 · Fare page with no network

1. On the fare page, turn on airplane mode, then off after 20 seconds.

- [ ] The app does not close.
- [ ] After the network returns, the page still moves on when the driver confirms.

### M. Rating and receipt

#### M-01 · Rate the driver

1. In the rating dialog, tap a star.
2. Tap some of the tags.
3. Tap **Submit**.

- [ ] **Submit** cannot be used before a star is chosen.
- [ ] Tags can be turned on and off.
- [ ] The dialog closes and the Thank you page shows the rating you gave.

#### M-02 · Skip the rating

1. On another trip, tap **Skip** in the rating dialog.

- [ ] The dialog closes. The Thank you page shows no rating.

#### M-03 · Thank you page content

- [ ] "Thank you!" and "Your trip is complete" show at the top.
- [ ] The amount and "Paid" show, with the payment method when the trip has one.
- [ ] The card shows pickup, drop-off, invoice number, and date and time.
- [ ] Long addresses wrap inside the card and do not run off the screen.

#### M-04 · Automatic return to Home

1. On the Thank you page, do not touch the screen.

- [ ] The **Back to Home** button counts down from 60 seconds.
- [ ] At zero, Home opens on its own.

#### M-05 · Back to Home

1. On another trip, tap **Back to Home** before the countdown ends.

- [ ] Home opens at once.
- [ ] No ride screen or fare page comes back afterwards.

#### M-06 · Book again from the receipt

1. On the Thank you page, tap **Book again**.

- [ ] The map opens with the same vehicle, and the same drop-off if the trip had one.

### N. History

#### N-01 · Completed tab

1. Open **My Booking**.

- [ ] Placeholder cards show first, then the list.
- [ ] The trip just taken is at the top.
- [ ] Each card shows the date and time, the fare, the vehicle and driver, pickup and drop-off, and distance and time.
- [ ] The card shows the drawing of the right vehicle.
- [ ] Fares are in dollars with cents.

#### N-02 · Cancelled tab

1. Tap **Cancelled**.

- [ ] Cancelled trips show, without a fare and without distance.

#### N-03 · Empty tab

With an account that has no trips of that kind.

- [ ] The tab shows "No completed trips yet" or "No cancelled trips", not an endless loader.

#### N-04 · Pull to refresh

1. Pull the list down.

- [ ] The list reloads.

#### N-05 · Long list

With an account that has more trips than fit on one page.

1. Scroll to the bottom.

- [ ] More trips load, then "No more data" shows at the end.
- [ ] No trip appears twice.

#### N-06 · History with no network

1. Turn on airplane mode. Open **My Booking**, or pull to refresh.

- [ ] An error state shows with a retry button, not an endless loader.
- [ ] With the network back, retry loads the list.

#### N-07 · Trip details

1. Tap a completed trip.

- [ ] **Trip details** opens with a map of the pickup and drop-off.
- [ ] A trip with no drop-off shows only the pickup on the map, not a line to an empty spot.
- [ ] The page shows amount, Paid, driver, car, plate, addresses, date, distance, duration, and invoice.
- [ ] A cancelled trip says "Cancelled" and "No fare was charged".

#### N-08 · Book again from details

1. On Trip details, tap **Book again**.

- [ ] The map opens with that trip's vehicle and drop-off.

### O. Account

#### O-01 · Profile card

1. Open the **Account** tab.

- [ ] The card shows the name and the phone number with the country code.
- [ ] With no photo, the avatar shows the initials.

#### O-02 · Announcements

1. Tap **Announcement**.
2. Tap one, if there are any.

- [ ] The list loads, or says "No announcements yet".
- [ ] An announcement opens with its title, date, and text.
- [ ] The back button returns to the list.

#### O-03 · Terms

1. Tap **Terms & Condition**.

- [ ] The text opens and scrolls. Back returns to Account.

#### O-04 · Contact

1. Tap **Contact US**.
2. Tap the phone number, then go back and tap the email address.

- [ ] The page shows the PU Taxi mark.
- [ ] The phone number opens the dialler.
- [ ] The email address opens the mail app.

#### O-05 · Saved places

1. Tap **Saved places**.

- [ ] A short message says it is coming soon. Nothing else happens.

#### O-06 · Version

- [ ] The version at the bottom of the Account page matches the build under test.

#### O-07 · Account with no network

1. Turn on airplane mode. Open the Account tab.

- [ ] The card shows an error with **Retry**, and the menu rows still work.

### P. Network and interruptions

#### P-01 · Wi-Fi to mobile data during a ride (2 devices)

1. During a ride on Wi-Fi, turn Wi-Fi off so the phone uses mobile data.
2. Change the stage on the driver app.

- [ ] The passenger's screen follows the new stage within about a minute.

#### P-02 · Network lost while searching (2 devices)

1. Tap **Book**. During the search, turn on airplane mode.
2. Let the driver accept. Turn airplane mode off.

- [ ] Within about 10 seconds of the network returning, the ride screen opens.

#### P-03 · Network lost during a ride (2 devices)

1. During a ride, turn on airplane mode for one minute. On the driver app, mark arrival and start the trip. Turn airplane mode off.

- [ ] The passenger's screen catches up to the current stage. It does not show a stage that has passed.

#### P-04 · Phone locked during a ride (2 devices)

1. During a ride, lock the phone for two minutes. On the driver app, end the trip. Unlock.

- [ ] The fare page opens.

#### P-05 · Incoming call during a ride (2 devices)

1. During a ride, receive a phone call and end it.

- [ ] The ride screen is unchanged and still follows the driver.

#### P-06 · App in the background while searching (2 devices)

1. Tap **Book**. Press the phone's home button. Let the driver accept. Open the app.

- [ ] The ride screen opens.

#### P-07 · Slow network

1. Use a weak signal, or limit the speed in the phone's developer options.
2. Open Home, the map, and My Booking.

- [ ] Each page shows a loader or placeholders while it waits, then its content. None stays blank.

#### P-08 · Push notifications (2 devices)

1. Put the app in the background. On the driver app, accept, arrive, start, and end a trip.

- [ ] Note which of these steps brings a notification on the passenger phone, and what tapping it opens.

### Q. Device and display

#### Q-01 · Large text

1. Set the phone's font size to the largest. Open Login, Home, the map sheet, the ride screen, the fare page, and My Booking.

- [ ] No text is cut off or runs under another element.
- [ ] Every button can still be reached.

#### Q-02 · Small screen

On the smallest phone you have.

- [ ] The map sheet, the ride sheet, and the Thank you page fit, or scroll. Nothing is hidden behind the tab bar or the phone's navigation bar.

#### Q-03 · Keyboard

1. Open the phone field on Login, the name field on Complete Profile, and the place search.

- [ ] The keyboard does not cover the field being typed in or its button.
- [ ] The phone field shows a number keyboard.

#### Q-04 · Rotate the phone

1. With rotation allowed on the phone, turn it sideways on Home and on the ride screen.

- [ ] Note what happens: the app either stays upright, or turns without broken layout. Report a broken layout.

#### Q-05 · Dark mode

1. Turn on the phone's dark mode. Open the app.

- [ ] The app stays in its light look, and all text is readable.

#### Q-06 · Long use

1. Take three trips one after another without closing the app.

- [ ] Each trip works the same as the first.
- [ ] The app does not slow down or close.

### R. Khmer

#### R-01 · Main flow in Khmer (2 devices)

1. Switch to **ខ្មែរ**. Run I-01, I-02, J-05, J-06, L-01, L-03, M-01, M-04.

- [ ] Every label, headline, button, and dialog is in Khmer.
- [ ] No Khmer text is cut off, and no vowel or subscript is clipped at the top or bottom of a line.
- [ ] Amounts still read `$1.70`.

#### R-02 · Other pages in Khmer

1. In Khmer, open My Booking, Trip details, Account, Announcement, Terms, Contact.

- [ ] All fixed text is in Khmer. Text that comes from the server (names, addresses, announcements) shows as the server sends it.

#### R-03 · Wording check

For a Khmer speaker.

- [ ] Note any Khmer wording that is wrong, unnatural, or inconsistent, with the page and the English label it stands for.

## 4. Result summary

| Field | Value |
|---|---|
| Tester | |
| Date | |
| Passenger phone and OS | |
| Driver device | |
| Build (debug or release, commit) | |
| Backend | |

| Section | Cases | Passed | Failed | Not run |
|---|---|---|---|---|
| A. Install and first launch | 3 | | | |
| B. Language | 3 | | | |
| C. Sign in | 9 | | | |
| D. Sign up | 4 | | | |
| E. Session | 5 | | | |
| F. Home | 6 | | | |
| G. Permissions and location | 6 | | | |
| H. Map | 10 | | | |
| I. Booking request | 7 | | | |
| J. Active ride | 10 | | | |
| K. Cancelling | 4 | | | |
| L. Fare and payment | 5 | | | |
| M. Rating and receipt | 6 | | | |
| N. History | 8 | | | |
| O. Account | 7 | | | |
| P. Network and interruptions | 8 | | | |
| Q. Device and display | 6 | | | |
| R. Khmer | 3 | | | |
| **Total** | **110** | | | |

## 5. Bug report template

```text
Case ID:
Title:            what went wrong, in one line
Phone and OS:
Build:            debug or release, commit
Language:         EN or Khmer
Network:          Wi-Fi, mobile data, or none

Steps:
1.
2.

Expected:
Actual:

How often:        every time, sometimes, once
Screenshot or video:
Log line, if a debug build:   for example "[ApiClient] GET /… could not read the response: …"
```

In a debug build, two log lines help most:

- `[ApiClient] <method> <path>: could not read the response: <reason>` — the app got an answer it could not read.
- `[api] <status> <method> <path>` followed by a `curl` line — the request and the server's answer. It holds the sign-in token, so do not paste it into a public place.
