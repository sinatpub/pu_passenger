import 'dart:io';

import 'package:com.tara.passenger/presentation/screens/invite/widgets/invite_code_field.dart';

class RegisterState {
  String passengerName ='';
  String phoneNumber ='';
  File? profileImage;

  /// D40: the invite code as typed, upper case. Empty means no inviter.
  String inviteCode = '';
  InviteCodeStatus inviteStatus = InviteCodeStatus.idle;

  /// Who [inviteCode] belongs to, once the server has said so.
  String? inviterName;
}
