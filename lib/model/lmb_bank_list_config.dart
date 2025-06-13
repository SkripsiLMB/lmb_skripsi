class LmbBankListConfig {
  final List<String> bankNameList;

  const LmbBankListConfig({
    required this.bankNameList
  });

  factory LmbBankListConfig.fromJson(List<dynamic> json) {
    return LmbBankListConfig(
      bankNameList: List<String>.from(json),
    );
  }
}