import 'package:lmb_skripsi/enum/lmb_saving_type.dart';
import 'package:lmb_skripsi/model/lmb_saving/lmb_saving.dart';

class VoluntarySaving extends LmbSaving {
  VoluntarySaving({required int totalAmount})
      : super(totalAmount, LmbSavingType.voluntary);

  factory VoluntarySaving.fromJson(Map<String, dynamic> json) {
    return VoluntarySaving(
      totalAmount: json['total_amount'] ?? 0,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'total_amount': totalAmount,
    };
  }
}