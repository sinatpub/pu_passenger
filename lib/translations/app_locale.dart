class AppLocale {
  // login
  static var titleLogin = "Login into your account";
  static var desLogin =
      "Please Input your phone number for login into your account";
  static var phoneNumber = "Phone Number";
  static var enterPhoneNumber = "Enter phone number";

  // otp
  static var otpVertification = "OTP Verification";
  static var desOtpVerification =
      "We have sent verification code to your phone number";
  static var desErrorOTP = "Please make sure enter correct OTP";
  static var didNotGetCode = "Didn't get a code? ";
  static var sendAgain = "Send again";

  // vehicle type
  static var rickshaw = "Rickshaw"; //"រុឺម៉ក";
  static var classicCar = 'Classic car';
  static var miniVan = "Mini Van";
  static var suvCar = "SUV car";
  static var alphard = "Alphard VIP";

  // request booking
  static var whereToGo = 'Where to go';
  static var whereTo = 'Where to?';
  static var chooseYourRide = 'Choose your ride';
  static var refreshed = 'Refreshed';
  static var promoApplied = 'Promo applied: FLY20';
  static var promoTag = 'PROMO';
  static var promoTitle = '20% off airport rides';
  static var promoSubtitle = 'Use code FLY20';
  static var rideWithTrust = 'តារា · Ride with trust';
  static var somethingWentWrong = 'Something went wrong';
  static var selectDestinationToContinue = "Select a destination to continue";
  static var contactingDrivers = "Contacting nearby drivers…";
  static var kmAway = "km away";
  static var destination = "Destination";
  static var searchLocation = 'Search Location';
  static var currentLocation = 'Current Location';
  static var destinationLocation = 'Destination Location';
  static var enterUrDestination = "Enter your destination";
  static var serviceType = "Vehicle Type";
  static var seatCapacity = "Seats";
  static var yes = "Yes";
  static var no = "No";
  static var ok = "Okay";
  static var cancel = 'Cancel';
  static var pleaseTryAgain = "Try again";
  static var driverNotFound = "Driver not found";
  static var driverNotFoundDes = "No driver available. Please try again.";
  static var noResultFound = "No result found";
  static var completed = "Completed";
  static var cancelled = "Cancelled";
  static var noMoreData = "No more data";
  static var ridingHistory = "Riding History";
  static var inVoiceNo = "In voice ID";
  static var method = "Method";

  // socket
  static var waitingDriverArrived = "Waiting Driver Arrive";
  static var driverAcceptedBooking = "Driver Accepted your booking";
  // static var

  // C5 — booking / active ride screen (Screen 9)
  static var driverAccepted = "Driver accepted";
  static var driverArriving = "Driver is arriving";
  static var onTripEnjoy = "On trip · enjoy!";
  // D6 — the 3-step ride timeline's own labels, kept separate from the
  // status-pill copy above (the pill is a sentence, a step is a chip).
  static var stepAccepted = "Accepted";
  static var stepArriving = "Arriving";
  static var stepOnTrip = "On trip";
  static var callDriver = "Call";
  static var safety = "Safety";
  static var safetyComingSoon = "Safety coming soon";
  static var titleCancelBooking = "Cancel booking?";
  static var yesCancel = "Yes, cancel";
  static var keepWaiting = "Keep waiting";
  static var bookingCancelled = "Booking cancelled";

  // detail service in map booking
  static var driverInfo = "Driver Info";
  static var cancelBookingContent =
      "You are currently in the taxi with the driver. Are you sure you want to cancel your booking?";
  static var detailService = "Detail Service";
  static var pricePerKM =
      "Price per km"; // P2: km is the SI unit, and 03 §D7 writes it lowercase
  static var minFee = "Minimum Fare";
  static var normal = "Normal";
  static var khmerCurrency = "៛";

  // Bottom Nav
  static var home = 'Home';
  static var myBooking = "My Booking";
  static var contactUs = 'Contact US';
  static var bookingNow = "Confirm Booking";

  // Dialog booking in progress
  static var bookingInProgress = "Booking in Progress";
  static var bookingInProgressDescription =
      "You already have an ongoing booking";

  // Profile Page
  static var profile = "Account";
  static var seeProfile = "See Your Profile";
  static var setting = 'Setting';
  static var termNCondition = 'Terms & Condition';

  static var logout = 'Logout';
  static var logoutDescription = 'Are you sure you want to log out?';

  // Cancel Booking dialog

  static var weNeedMinute = "We need a few minutes... ";
  static var titleCanceBooking = "Cancel Request booking";
  static var contentCancelBooking = "Are you sure to cancel request booking";
  static var cancelBooking = "Cancel Booking";

  // Calculate Fee
  static var calculateFee = "Calculate Fee";
  // C6 — fee / receipt screen (Screen 10)
  static var tripFare = "Trip fare";
  static var vehicle = "Vehicle";
  static var pickup = "Pickup";
  // Money fails loudly (payload policy): an unparseable fare says so
  // rather than showing a zero the passenger might pay against.
  static var fareUnavailable =
      "Fare unavailable — please ask your driver for the amount.";

  // C7 — rating (Screen 11) and receipt (Screen 12)
  static var rateYourDriver = "Rate your driver";
  static var howWasYourTrip = "How was your trip?";
  static var howWasYourTripWith = "How was your trip with";
  static var submit = "Submit";
  // PDD-02 — no rating endpoint exists; the passenger is told plainly.
  static var ratingPendingBackend =
      "Your rating is saved and will be sent once ratings go live.";
  // N-10 tags. All positive: the spec names no negative tags, and the
  // wording of a complaint about a driver is not invented here.
  static var tagClean = "Clean";
  static var tagOnTime = "On time";
  static var tagFriendly = "Friendly";
  static var tagGoodRoute = "Good route";
  static var thankYou = "Thank you!";
  static var tripCompleteReceiptSent = "Your trip is complete. Receipt sent.";
  static var backToHome = "Back to Home";
  static var bookAgain = "Book again";
  static var paid = "Paid";

  // S1 — history (Screen 13) empty and error states
  static var noCompletedTrips = "No completed trips yet";
  static var noCancelledTrips = "No cancelled trips";
  static var couldNotLoadHistory = "Couldn't load your history";

  // S2 — profile (Screen 15)
  static var savedPlaces = "Saved places";
  static var savedPlacesComingSoon = "Saved places — coming soon";
  static var version = "Version";
  // S2 — contact us (Screen 17)
  static var taarraaPhnomPenh = "Taarraa Taxi · Phnom Penh";

  // S3 — announcements (Screen 18/19)
  static var untitledAnnouncement = "Untitled announcement";
  static var noAnnouncements = "No announcements yet";
  static var couldNotLoadAnnouncements = "Couldn't load announcements";

  // S4 — auth (Screen 1-4)
  static var taarraaTaxiSubtitle = "តារា · Taxi";
  static var tapToAddPhotoRequired = "Tap to add a photo (required)";
  static var fullName = "Full name";
  static var enterFullName = "Enter your full name";

  // P2 — component copy that was hardcoded English
  static var tariff = "Tariff";
  static var minimumFee = "Min fee";
  static var seats = "Seats";
  static var gotIt = "Got it";
  static var unKnown = "Unknown";
  static var distance = "Distance";
  static var duration = "Duration";
  static var dateTime = "Date & Time";
  static var locationPassengerStand = "Current Location Passenger Stand";
  static var totalPrice = "Total Price";

  static var paymentCollection = "Payment Collection";

  static var waitPaymentDriver =
      "Please wait until the driver accepts your payment.";

  static var locationSelected = "Location Selected";
  static var desLocationSelected =
      "Do you want to save the selected destination before going back?";

  // where to go
  static var confirmLocation = "Confirm Location";
  static var confirmNavigation = "Confirm Navigation";

  static var completeProfile = "Complete Profile";

  static var desRegister = "Please fill out the to unlock full access..";

  static var pleaseLoginAgain = "Something went wrong";

  static var desPleaseLoginAgain = "Please login again to continue";

  static var create = "Create";

  static var addressNotFound = "Address not found.";

  static var desAddressNotFound = "Please check your internet connection.";

  static var driver = "Driver";

  static var close = "Close";

  static var driverArrivedLocation = "Driver Arrive Your Location";

  static var noVehicleAvailable = "No vehicle data available";

  static var tarrif = "Tariff";

  static var km = "Km";

  static var confirmDropOff = "Confirm Drop Off";
  static var confirmPickup = "Confirm Pickup";

  static var myLocation = "My Location";

  static var fare = "Fare";

  static var enterAddress = "Enter address name";

  static var emptyLocation = "Empty Location";

  // P-04 (Screen 2) search states
  static var noPlacesMatch = "No places match";
  static var checkSpelling = "Check the spelling";
  static var couldntSearch = "Couldn't search right now";
  static var retry = "Retry";

  // P-05 (Screen 3) pickup
  static var pinnedLocation = "Pinned location";
  static var setPickup = "Set pickup";
  static var setDestination = "Set destination";
  static var searchForPlace = "Search for a place";
  static var addNoteForDriver = "Add a note for driver";
  static var noteHint = "e.g. near the blue gate";
  static var resolvingAddress = "Resolving address...";
  static var weDontOperateHere = "We don't operate here yet";
  static var driversCantStopHere = "Drivers can't stop here";

  static var setLocationMap = "Set location on the map";

  static var next = "Next";

  static var updateAvailable = "Update Available";
  static var newVersion = "A new version";
  static var updateDescription =
      "of the app is available.\nPlease update to enjoy the latest features and improvement";

  static var whatNew = "What's new:";

  static var updateNow = "Update Now";

  static var later = "Later";

  static var waitingDriverAccepted = "Waiting Driver Accept your Request";

  static var onGoing = "onGoing";

  static var startRide = "Start Ride";

  static var passenger = "Passenger";

  static var historyDetail = 'History Detail';

  static var rideComplete = "Ride Completed";
  static var rideCompleteDescription =
      "Your ride and payment have been successfully completed. We hope you had a great trip.";

  static var driverStartRide = "Driver start riding";

  static var pendingPayment = "Pending Payment";

  static var skip = "SKIP";
  static var or = "Or";

  static var vehicleType = "Vehicle Type";

  static var price = "Price";

  static var error = "Error";

  static var cancelBookingFailed =
      "We couldn’t cancel your booking. Please try again.";

  static var announcement = "Announcement";

  static var announcementDetail = "Announcement Detail";

  static var releaseDate = "Release Date";

  static var confirmCancellation = "Confirm Cancellation";

  static var conformCancelDes = "Are you sure you want to cancel this booking?";

  static var done = "Done";

  static var paymentDone = "Payment Successful";

  static var paymentDoneDesc =
      "Your ride and payment have been completed successfully.";

  static var locationRequired = "Location Required";
  static var locationPermanentlyDisabled =
      'Location is permanently disabled. Please enable it in settings to use this feature.';
  static var openSetting = 'Open Setting';

  static var bookARide = "Book a Ride";

  static var driverLocation = "Driver Location";

  static var back = "Back";

  static var language = "Language";

  static var refresh = "Refresh";

  static var clearDestination = "Clear Destination";
}
