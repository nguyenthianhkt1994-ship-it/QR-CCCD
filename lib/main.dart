import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'cccd_model.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: CCCDScannerHome(),
  ));
}

class CCCDScannerHome extends StatefulWidget {
  const CCCDScannerHome({super.key});

  @override
  State<CCCDScannerHome> createState() => _CCCDScannerHomeState();
}

class _CCCDScannerHomeState extends State<CCCDScannerHome> {
  final MobileScannerController controller = MobileScannerController();
  bool isScanning = true;

  void _onDetect(BarcodeCapture capture) {
    if (!isScanning) return;

    for (final barcode in capture.barcodes) {
      final String? rawValue = barcode.rawValue;
      if (rawValue != null && rawValue.contains('|')) {
        try {
          final data = CCCDData.fromQRString(rawValue);
          setState(() => isScanning = false);
          controller.stop();
          HapticFeedback.mediumImpact();
          _showResultSheet(data);
          break;
        } catch (e) {}
      }
    }
  }

  void _showResultSheet(CCCDData data) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "THÔNG TIN CĂN CƯỚC",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => _resumeScanning(),
                  ),
                ],
              ),
              const Divider(height: 20),
              _buildInfoRow(Icons.badge_outlined, "Số CCCD", data.cccdNumber, highlight: true),
              _buildInfoRow(Icons.credit_card, "Số CMND cũ", data.oldCmndNumber),
              _buildInfoRow(Icons.person_outline, "Họ và tên", data.fullName),
              _buildInfoRow(Icons.calendar_today_outlined, "Ngày sinh", data.dateOfBirth),
              _buildInfoRow(Icons.transgender_outlined, "Giới tính", data.gender),
              _buildInfoRow(Icons.location_on_outlined, "Nơi thường trú", data.permanentAddress),
              _buildInfoRow(Icons.date_range_outlined, "Ngày cấp", data.issueDate),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        final copyText = "Số CCCD: ${data.cccdNumber}\nSố CMND cũ: ${data.oldCmndNumber}\nHọ và tên: ${data.fullName}\nNgày sinh: ${data.dateOfBirth}\nGiới tính: ${data.gender}\nNơi thường trú: ${data.permanentAddress}\nNgày cấp: ${data.issueDate}";
                        Clipboard.setData(ClipboardData(text: copyText));
                        Fluttertoast.showToast(msg: "Đã sao chép toàn bộ thông tin!");
                      },
                      icon: const Icon(Icons.copy, size: 18),
                      label: const Text("Sao chép"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _resumeScanning(),
                      icon: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 18),
                      label: const Text("Quét tiếp", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _resumeScanning() {
    Navigator.of(context).pop();
    setState(() => isScanning = true);
    controller.start();
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.blueGrey),
          const SizedBox(width: 8),
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black54, fontSize: 13)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: highlight ? FontWeight.bold : FontWeight.w500,
                color: highlight ? Colors.redAccent : Colors.black87,
                fontSize: highlight ? 15 : 13.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Quét QR CCCD", style: TextStyle(fontSize: 16, color: Colors.white)),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on, color: Colors.white),
            onPressed: () => controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch_outlined, color: Colors.white),
            onPressed: () => controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          MobileScanner(
            controller: controller,
            onDetect: _onDetect,
          ),
          Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.cyanAccent, width: 2.5),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const Positioned(
            bottom: 60,
            child: Text(
              "Đặt mã QR trên thẻ CCCD vào khung",
              style: TextStyle(color: Colors.white, backgroundColor: Colors.black54, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
