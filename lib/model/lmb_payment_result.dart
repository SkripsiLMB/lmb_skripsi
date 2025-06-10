class LmbPaymentResult {
  final bool success;
  final String? qrCodeUrl;
  final String? qrString;
  final String? transactionId;

  LmbPaymentResult({
    required this.success,
    this.qrCodeUrl,
    this.qrString,
    this.transactionId,
  });
}