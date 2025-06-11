import 'package:lmb_skripsi/enum/lmb_saving_type.dart';
import 'package:lmb_skripsi/model/lmb_saving/lmb_mandatory_saving.dart';
import 'package:lmb_skripsi/model/lmb_saving/lmb_principal_saving.dart';
import 'package:lmb_skripsi/model/lmb_saving/lmb_voluntary_saving.dart';

abstract class LmbSaving {
  final double totalAmount;
  final LmbSavingType type;

  LmbSaving(this.totalAmount, this.type);

  Map<String, dynamic> toJson();
  factory LmbSaving.fromJson(Map<String, dynamic> json) {
    final type = LmbSavingType.fromString(json['type']);
    switch (type) {
      case LmbSavingType.mandatory:
        return LmbMandatorySaving.fromJson(json);
      case LmbSavingType.principal:
        return LmbPrincipalSaving.fromJson(json);
      case LmbSavingType.voluntary:
        return LmbVoluntarySaving.fromJson(json);
    }
  }
}