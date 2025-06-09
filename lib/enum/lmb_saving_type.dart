enum LmbSavingType {
  mandatory,
  principal,
  voluntary;

  String get label {
    switch (this) {
      case LmbSavingType.mandatory:
        return "Mandatory Saving";
      case LmbSavingType.principal:
        return "Principal Saving";
      case LmbSavingType.voluntary:
        return "Voluntary Saving";
    }
  }

  static LmbSavingType fromString(String value) {
    return LmbSavingType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => LmbSavingType.mandatory,
    );
  }

  static LmbSavingType fromLabel(String value) {
    return LmbSavingType.values.firstWhere(
      (e) => e.label == value,
      orElse: () => LmbSavingType.mandatory,
    );
  }
}