import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../config/network/api.state.dart';
import '../config/utils/pretty.dio.dart';
import '../data/Model/CreateOrderBodyModel.dart';


class AddMoneyToWalletPage extends StatefulWidget {
  const AddMoneyToWalletPage({super.key});

  @override
  State<AddMoneyToWalletPage> createState() => _AddMoneyToWalletPageState();
}

class _AddMoneyToWalletPageState extends State<AddMoneyToWalletPage> {
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late Razorpay _razorpay;
  bool _isLoading = false;
  String? _createdOrderId;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    _amountController.dispose();
    super.dispose();
  }

  // ────────────────────────────────────────────────
  // Create order on your backend
  // ────────────────────────────────────────────────
  // Future<void> _createOrder(int amountInPaise) async {
  //   setState(() => _isLoading = true);
  //
  //   try {
  //     final service = APIStateNetwork(callPrettyDio());
  //     final response = await service.createOrder(
  //
  //       CreateOrderModel(
  //         amount: amountInPaise,
  //         currency: "INR",
  //       ),
  //
  //     );
  //
  //     // IMPORTANT: Adjust according to your actual response model
  //     // Assuming response has field like response.orderId or response.data['orderId']
  //     // setState(() {
  //     //   _createdOrderId = response.orderId; // ← change to correct field name!
  //     // });
  //
  //     Fluttertoast.showToast(
  //       msg: "Order created successfully!",
  //       backgroundColor: Colors.green,
  //     );
  //
  //     _openCheckout(amountInPaise);
  //
  //   } catch (e) {
  //     Fluttertoast.showToast(
  //       msg: "Order creation failed: ${e.toString().split('\n').first}",
  //       toastLength: Toast.LENGTH_LONG,
  //       backgroundColor: Colors.red,
  //     );
  //   } finally {
  //     setState(() => _isLoading = false);
  //   }
  // }

  Future<void> _createOrder(int amountInPaise) async {
    setState(() => _isLoading = true);

    try {
      final service = APIStateNetwork(callPrettyDio());
      final response = await service.createOrder(
        CreateOrderModel(
          amount: amountInPaise,
          currency: "INR",
        ),
      );

      if (response.error == true || response.data?.razorpayOrder?.id == null) {
        throw Exception(response.message ?? "Order creation failed");
      }

      setState(() {
        _createdOrderId = response.data!.razorpayOrder!.id!;
      });

      Fluttertoast.showToast(
        msg: "Order created successfully!",
        backgroundColor: Colors.green,
      );

      _openCheckout(amountInPaise);

    } catch (e) {
      Fluttertoast.showToast(
        msg: "Order creation failed: ${e.toString().split('\n').first}",
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.red,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }


  void _openCheckout(int amountInPaise) {
    if (_createdOrderId == null || _createdOrderId!.isEmpty) {
      Fluttertoast.showToast(msg: "No order ID available");
      return;
    }

    var options = {
      'key': 'rzp_test_S3KH88gvOeaAOh', // ← YOUR KEY (test/live)
      'amount': amountInPaise,            // in paise
      'name': 'WeLoads',
      'description': 'Wallet Top-up',
      'order_id': _createdOrderId,
      'prefill': {
        'contact': '9876543210',          // ← can fetch from user profile
        'email': 'user@weloads.com',
      },
      'external': {
        'wallets': ['paytm', 'amazonpay'], // optional
      },
      'theme': {
        'color': '#006970',               // your brand color
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      Fluttertoast.showToast(msg: "Checkout error: $e");
    }
  }

  // ────────────────────────────────────────────────
  // Payment Handlers
  // ────────────────────────────────────────────────
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    Fluttertoast.showToast(
      msg: "Payment Successful! 🎉\nPayment ID: ${response.paymentId}",
      toastLength: Toast.LENGTH_LONG,
    );

    // MUST DO: Verify on backend
    _verifyAndAddToWallet(
      paymentId: response.paymentId!,
      orderId: response.orderId!,
      signature: response.signature!,
      amount: int.parse(_amountController.text.trim()),
    );

    // Clear field & order id after success
    _amountController.clear();
    setState(() => _createdOrderId = null);

    // Optional: Navigate back or show success screen
    // Navigator.pop(context, true);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(
      msg: "Payment Failed\nCode: ${response.code}\n${response.message}",
      toastLength: Toast.LENGTH_LONG,
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(msg: "Opened ${response.walletName}");
  }

  Future<void> _verifyAndAddToWallet({
    required String paymentId,
    required String orderId,
    required String signature,
    required int amount,
  }) async {

    // TODO: Call your backend verify + add to wallet API
    // Example payload:
    // {
    //   "paymentId": paymentId,
    //   "orderId": orderId,
    //   "signature": signature,
    //   "amount": amount,
    // }
    // After successful verification → update wallet balance in UI / via provider / bloc

    Fluttertoast.showToast(msg: "Wallet updated! Balance refreshed soon.");

  }

  void _proceedToPay() {
    if (!_formKey.currentState!.validate()) return;
    final amountText = _amountController.text.trim();
    final amount = int.tryParse(amountText);
    if (amount == null || amount < 10) {
      Fluttertoast.showToast(msg: "Enter valid amount (min ₹10)");
      return;
    }
    final amountInPaise = amount;
    _createOrder(amountInPaise);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF006970);

    return Scaffold(

      appBar: AppBar(
        title: const Text("Add Money to Wallet"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body:
      SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 30),

                Text(
                  "Enter Amount",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    prefixText: "₹ ",
                    labelText: "Amount",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryColor, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Enter amount";
                    final n = int.tryParse(value);
                    if (n == null || n < 10) return "Minimum ₹10";
                    return null;
                  },
                ),

                const SizedBox(height: 40),

                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  ElevatedButton(
                    onPressed: _proceedToPay,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Add Money via Razorpay",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),

                const SizedBox(height: 24),

                const Text(
                  "100% secure payment powered by Razorpay",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ),

    );
  }
}