import 'package:lmb_skripsi/enum/lmb_saving_type.dart';
import 'package:lmb_skripsi/model/lmb_saving/lmb_saving.dart';

class MandatorySaving extends LmbSaving {
  final bool isPaid;

  MandatorySaving({
    required int totalAmount,
    required this.isPaid,
  }) : super(totalAmount, LmbSavingType.mandatory);

  factory MandatorySaving.fromJson(Map<String, dynamic> json) {
    return MandatorySaving(
      totalAmount: json['total_amount'] ?? 0,
      isPaid: json['is_paid'] ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'total_amount': totalAmount,
      'is_paid': isPaid,
    };
  }
}