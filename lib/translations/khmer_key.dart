import 'app_locale.dart';

get khmerKey => {
      // login
      AppLocale.titleLogin: "ចូលប្រើប្រាស់ប្រពន្ធ័",
      AppLocale.desLogin: "សូមធ្វើការបញ្ចូលលេខទូរសព្ទ ដើម្បីប្រើប្រាស់ប្រពន្ធ័",
      AppLocale.phoneNumber: "លេខទូរសព្ទ",
      AppLocale.enterPhoneNumber: 'បញ្ចូលលេខទូរសព្ទ័',
      // otp
      AppLocale.otpVertification: "ផ្ទៀងផ្ទាត់ លេខកូដ",
      AppLocale.desOtpVerification:
          "យើងបានផ្ញើលេខកូដផ្ទៀងផ្ទាត់ទៅកាន់លេខទូរស័ព្ទរបស់អ្នក",
      AppLocale.desErrorOTP: "សូមប្រាកដថាបញ្ចូល OTP ត្រឹមត្រូវ។",
      AppLocale.didNotGetCode: "មិនបានទទួលលេខកូដ",
      AppLocale.sendAgain: "សូមផ្ញើរម្តងទៀត",

      AppLocale.completeProfile: "បំពេញប្រវត្តិរូប",
      AppLocale.desRegister: "សូមបំពេញប្រវត្តិរូប ដើម្បីប្រើប្រាស់",

      AppLocale.driverAcceptedBooking: "អ្នកបើកបរបានទទួលយកការកក់របស់អ្នក",
      // request booking map
      AppLocale.whereToGo: "ស្វែងរកទីតាំង",
      AppLocale.currentLocation: "ទីតាំងបច្ចុប្បន្ន",
      AppLocale.destinationLocation: "គោលដៅ",
      AppLocale.enterUrDestination: "បញ្ចូលទីតាំងគោលដៅ",
      AppLocale.serviceType: "ប្រភេទយានយន្ដ",
      AppLocale.seatCapacity: "ចំនួនកៅអី",
      AppLocale.pleaseTryAgain: "សូមព្យាយាមម្ដងទៀត",
      AppLocale.driverNotFound: "មិនមានអ្នកបើកបរនៅជិតទីនេះ",
      AppLocale.close: "បិទ",

      // detail service map booking
      AppLocale.driverInfo: "ពត៍មានអ្នកបើក",
      AppLocale.detailService: "ពត៍មានសេវា",
      AppLocale.pricePerKM: "តម្លៃក្នុង ១គីឡូ",
      AppLocale.minFee: "តម្លៃអប្បបរមា",
      AppLocale.normal: "តម្លៃធម្មតា",
      AppLocale.khmerCurrency: "៛",
      AppLocale.bookingNow: "កក់ឥឡូវនេះ",

      AppLocale.yes: "បាទ/ចាស",
      AppLocale.no: "ទេ",
      AppLocale.cancel: "បោះបង់",

      // Vehicle type
      AppLocale.rickshaw: "RICKSHAW",
      AppLocale.classicCar: "CLASSIC Car",
      AppLocale.miniVan: "MINI VAN",
      AppLocale.suvCar: "SUV Car",
      AppLocale.alphard: "ALPARD",
      AppLocale.passenger: "អ្នកដំណើរ",
      AppLocale.historyDetail: "ពត៍មានលម្អិត",
      AppLocale.driverStartRide: "អ្នកបើកបរចេញដំណើរ",
      // Dialog booking in progress
      AppLocale.bookingInProgress: "ការកក់កំពុងដំណើរការ",
      AppLocale.bookingInProgressDescription:
          "អ្នកមានការកក់រួចហើយ, សូមរង់ចាំបន្តិច",
      AppLocale.noResultFound: "រកមិនឃើញលទ្ធផល",

      AppLocale.completed: "បានបញ្ចប់",
      AppLocale.cancelled: "បោះបង់",
      AppLocale.noMoreData: "មិនមានទិន្នន័យទៀតទេ",
      AppLocale.ridingHistory: "ប្រវត្តិធ្វើដំណើរ",
      AppLocale.inVoiceNo: "លេខវិក្កយបត្រ",
      AppLocale.method: "បង់តាមរយ៖ ",

      // Bottom Nav
      AppLocale.home: "ទំព័រដើម",
      AppLocale.myBooking: "កំណត់ត្រា",
      AppLocale.profile: 'ប្រវត្តិរូប',
      AppLocale.seeProfile: 'មើលរូបភាព',
      AppLocale.setting: "ការកំណត់",
      AppLocale.termNCondition: "លក្ខខណ្ឌ",
      AppLocale.contactUs: "ទំនាក់ទំនង ជំនួយ",
      AppLocale.logout: "ចាកចេញ",
      AppLocale.logoutDescription: 'តើអ្នកប្រាកដថាចង់ចេញ?',
      // Cancel Booking dialog
      AppLocale.weNeedMinute: "សូមរង់ចាំបន្ទិច...",
      AppLocale.titleCanceBooking: "បោះបង់ការកក់",
      AppLocale.contentCancelBooking: "តើអ្នកប្រាកដថាបោះបង់ការកក់មែនទេ?",
      AppLocale.cancelBooking: "បោះបង់",
      AppLocale.cancelBookingContent:
          "បច្ចុប្បន្នអ្នកកំពុងជិះតាក់ស៊ីជាមួយអ្នកបើកបរ។ តើអ្នកប្រាកដថាចង់លុបចោលការកក់របស់អ្នកមែនទេ?",

      // Calculate Fee
      AppLocale.calculateFee: "គណនាថ្លៃឈ្នួល",
      AppLocale.unKnown: "មិនស្គាល់",
      AppLocale.paymentCollection: "ការប្រមូលការទូទាត់",
      AppLocale.distance: "ចម្ងាយ",
      AppLocale.duration: "រយៈពេល",
      AppLocale.dateTime: "កាលបរិច្ឆេទ",
      AppLocale.locationPassengerStand: "ទីតាំងអ្នកដំណើរ",
      AppLocale.totalPrice: "តម្លៃសរុប",

      AppLocale.waitPaymentDriver:
          "សូមរង់ចាំរហូតដល់អ្នកបើកបរទទួលបានការបង់ប្រាក់របស់អ្នក",

      // where to go
      AppLocale.confirmLocation: "យល់ព្រម",
      AppLocale.confirmNavigation: "បញ្ជាក់ទីតាំង",
      AppLocale.desLocationSelected: "តើអ្នកចង់រក្សាទុកគោលដៅដែលបានជ្រើសដែរឬទេ?",
      AppLocale.pleaseLoginAgain: "ប្រពន្ធ័មានបញ្ហា",
      AppLocale.desPleaseLoginAgain: "សូមធ្វើការ ចុះឈ្មោះម្ដងទៀត",
      AppLocale.create: "បង្កើត",
      AppLocale.addressNotFound: "រកមិនឃើញទីតាំងរបស់អ្នកទេ",
      AppLocale.desAddressNotFound: "សូមពិនិត្យមើលអ៊ីនធឺណិតរបស់អ្នក",
      AppLocale.driver: "អ្នកបើកបរ",
      AppLocale.driverArrivedLocation: "អ្នកបើកបរមកដល់ទីតាំងរបស់អ្នក",
      AppLocale.noVehicleAvailable: 'មិនមានទិន្នន័យយានយន្តទេ',
      AppLocale.tarrif: "ពន្ធ",
      AppLocale.km: "គីឡូ",
      AppLocale.confirmDropOff: "ទទួលយកទីតាំង",
      AppLocale.confirmPickup: "ទទួលយកទីតាំងទទួល",
      AppLocale.myLocation: "ទីតាំងបច្ចុប្បន្ន",
      AppLocale.fare: 'ចំណាយអស់',
      AppLocale.enterAddress: "បញ្ចូលឈ្មោះអាសយដ្ឋាន",
      AppLocale.emptyLocation: "ទីតាំងទទេ",
      AppLocale.setLocationMap: 'កំណត់ទីតាំងនៅលើផែនទី',
      AppLocale.next: "បន្ទាប់",
      AppLocale.updateAvailable: "ការអាប់ដេតថ្មី",
      AppLocale.newVersion: "មានកំណែថ្មី",
      AppLocale.updateDescription:
          "នៃកម្មវិធី។\nសូមអាប់ដេត ដើម្បីរីករាយជាមួយមុខងារ និងការកែលម្អចុងក្រោយបំផុត។",
      AppLocale.whatNew: "មុខងារថ្មី",
      AppLocale.updateNow: "អាប់ដេតឥឡូវ",
      AppLocale.later: "រំលង",
      AppLocale.waitingDriverAccepted: "រង់ចាំអ្នកបើកបរទទួលយកសំណើរបស់អ្នក",
      AppLocale.onGoing: "កំពុងធ្វើដំណើរ",
      AppLocale.driverNotFoundDes: "សូមព្យាយាមម្តងទៀត",
      AppLocale.pendingPayment: "រង់ចាំការទូទាត់",
      AppLocale.skip: "រំលង",
      AppLocale.or: "ឬ",
      AppLocale.vehicleType: "ប្រភេទយានយន្ដ",
      AppLocale.error: "កំហុស",
      AppLocale.cancelBookingFailed:
          "យើងមិនអាចលុបចោលការកក់របស់អ្នកបានទេ។ សូមព្យាយាមម្តងទៀត។",
      AppLocale.announcement: "សេចក្តីប្រកាស",
      AppLocale.announcementDetail: "សេចក្តីប្រកាសលម្អិត",
      AppLocale.releaseDate: "កាលបរិច្ឆេទចេញផ្សាយ",
      AppLocale.confirmCancellation: "បញ្ជាក់ការលុបចោល",
      AppLocale.conformCancelDes: "តើអ្នកប្រាកដថាចង់លុបចោលការកក់នេះមែនទេ?",
      AppLocale.rideComplete: "ការជិះបានបញ្ចប់",
      AppLocale.rideCompleteDescription:
          "ការធ្វើដំណើរ និងការទូទាត់របស់អ្នកបានបញ្ចប់ដោយជោគជ័យ។ យើងសង្ឃឹមថាអ្នកបានរីករាយជាមួយការធ្វើដំណើររបស់អ្នក។",
      AppLocale.done: 'រួចរាល់',
      AppLocale.paymentDone: "ការទូទាត់រួចរាល់",
      AppLocale.paymentDoneDesc:
          "ការធ្វើដំណើរ និងការទូទាត់របស់អ្នកបានបញ្ចប់ដោយជោគជ័យ។",
      AppLocale.locationRequired: "តម្រូវការទីតាំង",
      AppLocale.locationPermanentlyDisabled:
          "មុខងារ Location ត្រូវបានបិទជាអចិន្ត្រៃយ៍។ សូមបើកវានៅក្នុងការកំណត់ (Settings) ដើម្បីប្រើមុខងារនេះ។",
      AppLocale.openSetting: "បើកការកំណត់",
      AppLocale.bookARide: "កក់ការធ្វើដំណើរ",
      AppLocale.driverLocation: "ទីតាំងអ្នកបើកបរ",
      AppLocale.back: "ត្រឡប់"
    };
