import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../config/network/api.state.dart';
import '../config/utils/pretty.dio.dart';
import '../data/Model/SendMoneyModel.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});
  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  String? _scannedUserId;
  final _amountController = TextEditingController();
  bool _isLoading = false;
  final primaryColor = const Color(0xFF006970);
  final primaryDark = const Color(0xFF004C52);
  final primaryLight = const Color(0xFF3399A0);
  final backgroundLight = const Color(0xFFF5FAFA);
  late final MobileScannerController controller;
  @override
  void initState() {
    super.initState();
    controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }
  void _sendMoney() async {
    if (_scannedUserId == null || _scannedUserId!.isEmpty) {
      Fluttertoast.showToast(msg: "No user ID scanned");
      return;
    }

    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      Fluttertoast.showToast(msg: "Please enter amount");
      return;
    }

    final amount = int.tryParse(amountText);
    if (amount == null || amount <= 0) {
      Fluttertoast.showToast(msg: "Please enter a valid amount greater than 0");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final body = SendMoneyBodyModel(
        userId: _scannedUserId!,
        amount: amount,
      );

      final service = APIStateNetwork(callPrettyDio());
      final response = await service.sendWalletMoney(body);

      if (response.error == false) {
        Fluttertoast.showToast(
          msg: response.message ?? "Money sent successfully! ✓",
          backgroundColor: Colors.green.shade700,
          textColor: Colors.white,
          fontSize: 16,
        );

        setState(() {
          _scannedUserId = null;
          _amountController.clear();
        });
        controller.start();
      } else {
        Fluttertoast.showToast(
          msg: response.message ?? "Failed to send money",
          backgroundColor: Colors.red.shade700,
          textColor: Colors.white,
        );
      }
    } catch (e, stackTrace) {
      log("Send money error: $e\n$stackTrace");
      Fluttertoast.showToast(
        msg: "Something went wrong. Please try again.",
        backgroundColor: Colors.red.shade700,
        textColor: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        title: const Text("Scan & Send Money"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              controller.torchEnabled ? Icons.flash_on : Icons.flash_off,
            ),
            onPressed: () => controller.toggleTorch(),
            tooltip: "Toggle Flash",
          ),
        ],
      ),
      body: Column(
        children: [

          // Camera Area - 60% approx
          Expanded(
            flex: 5,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Subtle gradient background
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [backgroundLight, Colors.white],
                    ),
                  ),
                ),

                // Scanner frame
                Center(
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: _scannedUserId == null
                            ? primaryColor
                            : Colors.green.shade600,
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.25),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: MobileScanner(
                        controller: controller,
                        fit: BoxFit.cover,
                        onDetect: (capture) {
                          final List<Barcode> barcodes = capture.barcodes;
                          for (final barcode in barcodes) {
                            final String? code = barcode.rawValue;
                            if (code != null && code.trim().isNotEmpty) {
                              controller.stop();
                              setState(() {
                                _scannedUserId = code.trim();
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: primaryColor,
                                  content: Text(
                                    "Scanned → $_scannedUserId",
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  duration: const Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                              break;
                            }
                          }
                        },
                      ),
                    ),
                  ),
                ),

                // Scanning overlay hint when not scanned
                if (_scannedUserId == null)
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.qr_code_scanner_rounded,
                          size: 64,
                          color: Colors.white70,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Align QR code in frame",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            shadows: const [
                              Shadow(
                                blurRadius: 8,
                                color: Colors.black45,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Input & Action Area
          Expanded(
            flex: 4,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 16,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _scannedUserId == null
                            ? "Scan recipient's QR code"
                            : "Recipient ready",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _scannedUserId == null
                              ? Colors.grey.shade800
                              : primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      if (_scannedUserId != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "ID: $_scannedUserId",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      const SizedBox(height: 28),

                      if (_scannedUserId != null) ...[
                        TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          autofocus: true,
                          decoration: InputDecoration(
                            labelText: "Amount (₹)",
                            labelStyle: TextStyle(color: primaryColor),
                            prefixIcon: Icon(
                              Icons.currency_rupee_rounded,
                              color: primaryColor,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: primaryColor, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                        ),
                        const SizedBox(height: 32),

                        SizedBox(
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _sendMoney,
                            icon: _isLoading
                                ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.8,
                              ),
                            )
                                : const Icon(Icons.send_rounded, size: 22),
                            label: Text(
                              _isLoading ? "Sending..." : "Send Money",
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 2,
                              shadowColor: primaryColor.withOpacity(0.4),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        TextButton(
                          onPressed: () {
                            setState(() {
                              _scannedUserId = null;
                              _amountController.clear();
                            });
                            controller.start();
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: primaryLight,
                          ),
                          child: const Text(
                            "Scan another QR code",
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
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
    _amountController.dispose();
    super.dispose();
  }
}