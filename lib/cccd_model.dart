class CCCDData {
  final String cccdNumber;
  final String oldCmndNumber;
  final String fullName;
  final String dateOfBirth;
  final String gender;
  final String permanentAddress;
  final String issueDate;

  CCCDData({
    required this.cccdNumber,
    required this.oldCmndNumber,
    required this.fullName,
    required this.dateOfBirth,
    required this.gender,
    required this.permanentAddress,
    required this.issueDate,
  });

  static String _formatDate(String input) {
    if (input.length == 8) {
      return "${input.substring(0, 2)}/${input.substring(2, 4)}/${input.substring(4, 8)}";
    }
    return input;
  }

  factory CCCDData.fromQRString(String raw) {
    final parts = raw.split('|');
    if (parts.length < 7) {
      throw const FormatException("Mã QR không đúng định dạng CCCD");
    }

    return CCCDData(
      cccdNumber: parts[0].trim(),
      oldCmndNumber: parts[1].trim().isEmpty ? "Không có" : parts[1].trim(),
      fullName: parts[2].trim(),
      dateOfBirth: _formatDate(parts[3].trim()),
      gender: parts[4].trim(),
      permanentAddress: parts[5].trim(),
      issueDate: _formatDate(parts[6].trim()),
    );
  }
}
