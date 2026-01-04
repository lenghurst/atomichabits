/// Exception for social contract violations (e.g. spam, blocking)
class SocialContractException implements Exception {
  final String message;
  const SocialContractException(this.message);
  @override
  String toString() => message;
}
