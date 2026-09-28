import 'package:flutter/material.dart';

import '../../models/customer_model.dart';
import '../../services/payment_service.dart';

import '../../models/payment_history_ent.dart';

// ---------------------------------------------------------------------------
// Theme colors
// ---------------------------------------------------------------------------

const Color kPaymentBgColor = Color(0xFFF6F3EA);
const Color kPaymentCardColor = Color(0xFFFFFFFF);
const Color kPaymentAccent = Color(0xFF0B7FBF);
const Color kPaymentTextDark = Color(0xFF1D2430);
const Color kPaymentTextMuted = Color(0xFF8A8FA3);

// ---------------------------------------------------------------------------
// Make Payment Screen
// ---------------------------------------------------------------------------

class MakePaymentScreen extends StatefulWidget {
  final CustomerModel customer;

  const MakePaymentScreen({
    super.key,
    required this.customer,
  });

  @override
  State<MakePaymentScreen> createState() => _MakePaymentScreenState();
}

class _MakePaymentScreenState extends State<MakePaymentScreen> {
  // -------------------------------------------------------------------------
  // Static UI data — API abhi implement nahi hai
  // -------------------------------------------------------------------------

  bool _isLoadingBalance = false;
  String? _balanceError;

  bool _isLoadingHistory = false;
  String? _historyError;


  bool _isPaymentLoading = false;

  List<PaymentHistoryEnt> _paymentHistory = [];

  final TextEditingController _amountController =
  TextEditingController();

  final TextEditingController _messageController =
  TextEditingController(text: 'Your:');





  @override
  void initState() {
    super.initState();
    _loadBalance();
    _loadPaymentHistory();
  }


  Future<void> _loadPaymentHistory() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _isLoadingHistory = true;
      _historyError = null;
    });

    try {
      final distCode =
          widget.customer.custcode?.toString().trim() ?? '';

      if (distCode.isEmpty) {
        throw Exception('Customer code not found.');
      }

      final history =
      await PaymentService.getPaymentHistory(
        distCode: distCode,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _paymentHistory = history;
        _historyError = null;
      });
    } catch (e) {
      debugPrint('PGHISTORY ERROR: $e');

      if (!mounted) {
        return;
      }

      setState(() {
        _historyError = _cleanErrorMessage(e);
      });
    } finally {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingHistory = false;
      });
    }
  }

  Future<void> _loadBalance() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _isLoadingBalance = true;
      _balanceError = null;
    });

    try {
      final distCode = widget.customer.custcode?.toString().trim() ?? '';

      if (distCode.isEmpty) {
        throw Exception('Customer code not found.');
      }

      final balanceResponse = await PaymentService.getBalance(
        distCode: distCode,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _balanceError = null;

        if (balanceResponse.msg.trim().isNotEmpty) {
          _messageController.text = balanceResponse.msg;
        } else {
          _messageController.text = '';
        }

        if (balanceResponse.drcr.trim() == 'D') {
          _amountController.text = balanceResponse.balance;
        } else {
          _amountController.text = '0';
        }
      });
    } catch (e) {
      debugPrint('GET BALANCE ERROR: $e');

      if (!mounted) {
        return;
      }

      setState(() {
        _balanceError = _cleanErrorMessage(e);
      });
    } finally {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingBalance = false;
      });
    }
  }

  String _cleanErrorMessage(Object error) {
    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.substring('Exception: '.length);
    }

    return message.isNotEmpty
        ? message
        : 'Something went wrong. Please try again.';
  }




  @override
  void dispose() {
    _amountController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // Reset
  // -------------------------------------------------------------------------

  void _resetPayment() {
    setState(() {
      _amountController.text = '0';
      _messageController.text = 'Your:';
    });
  }

  // -------------------------------------------------------------------------
  // Pay Now
  // -------------------------------------------------------------------------

  Future<void> _submitPayment() async {
    final amount = _amountController.text.trim();

    // ========================================================
    // AMOUNT VALIDATION
    // ========================================================

    if (amount.isEmpty) {
      _showValidationPopup('Please enter amount.');
      return;
    }

    if (amount == '0') {
      _showValidationPopup('Please enter a valid amount.');
      return;
    }

    // ========================================================
    // DISTRIBUTOR CODE VALIDATION
    // ========================================================

    final distCode =
        widget.customer.custcode?.toString().trim() ?? '';

    if (distCode.isEmpty) {
      _showValidationPopup('Distributor code not found.');
      return;
    }

    // ========================================================
    // START LOADER
    // ========================================================

    if (mounted) {
      setState(() {
        _isPaymentLoading = true;
      });
    }

    try {
      // ======================================================
      // GET PG TOKEN API
      // ======================================================

      final paymentToken =
      await PaymentService.getPaymentToken(
        amount: amount,
        distCode: distCode,
      );

      if (!mounted) {
        return;
      }

      // ======================================================
      // RESPONSE RECEIVED
      // STOP LOADER
      // ======================================================

      setState(() {
        _isPaymentLoading = false;
      });

      // ======================================================
      // HTTP 200 + STATUS FAIL
      // ======================================================

      if (paymentToken.status.toLowerCase() != 'success') {
        _showValidationPopup(
          paymentToken.msg.isNotEmpty
              ? paymentToken.msg
              : 'Payment failed.',
        );
        return;
      }

      // ======================================================
      // HTTP 200 + STATUS SUCCESS
      // ======================================================

      debugPrint('========================================');
      debugPrint('GET PG TOKEN SUCCESS');
      debugPrint('ORDER ID: ${paymentToken.orderId}');
      debugPrint('MID: ${paymentToken.mid}');
      debugPrint(
        'TOKEN RECEIVED: ${paymentToken.token.isNotEmpty}',
      );
      debugPrint('========================================');

      // ======================================================
      // START PAYTM SDK
      // ======================================================

      final paytmResponse =
      await PaymentService.startPaytmTransaction(
        paymentToken: paymentToken,
        amount: amount,
      );

      debugPrint('========================================');
      debugPrint('PAYTM SDK RESPONSE');
      debugPrint('$paytmResponse');
      debugPrint('========================================');

    } catch (e) {
      // ======================================================
      // NON-200 / EMPTY RESPONSE / API EXCEPTION
      // ======================================================

      if (!mounted) {
        return;
      }

      setState(() {
        _isPaymentLoading = false;
      });

      await _showPaymentErrorPopup(
        e.toString().replaceFirst(
          'Exception: ',
          '',
        ),
      );
    }
  }

  void _showValidationPopup(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 35),
          child: Container(
            padding: const EdgeInsets.fromLTRB(
              24,
              24,
              24,
              18,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ==================================================
                // INFO ICON
                // ==================================================

                Container(
                  width: 58,
                  height: 58,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEAF7FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFF0C447C),
                    size: 32,
                  ),
                ),

                const SizedBox(height: 16),

                // ==================================================
                // TITLE
                // ==================================================

                const Text(
                  'Payment',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0C447C),
                  ),
                ),

                const SizedBox(height: 10),

                // ==================================================
                // MESSAGE
                // ==================================================

                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.4,
                    color: Color(0xFF555555),
                  ),
                ),

                const SizedBox(height: 22),

                // ==================================================
                // OK BUTTON
                // ==================================================

                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0C447C),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showPaymentErrorPopup(String message) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 30),
          child: Container(
            padding: const EdgeInsets.fromLTRB(
              24,
              26,
              24,
              20,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ==================================================
                // ERROR ICON
                // ==================================================

                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFEEEE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline_rounded,
                    color: Color(0xFFD32F2F),
                    size: 36,
                  ),
                ),

                const SizedBox(height: 18),

                // ==================================================
                // TITLE
                // ==================================================

                const Text(
                  'Payment Failed',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0C447C),
                  ),
                ),

                const SizedBox(height: 10),

                // ==================================================
                // ERROR MESSAGE
                // ==================================================

                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14.5,
                    height: 1.45,
                    color: Color(0xFF555555),
                  ),
                ),

                const SizedBox(height: 24),

                // ==================================================
                // RETRY BUTTON
                // ==================================================

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      // Close error popup
                      Navigator.of(dialogContext).pop();

                      if (!mounted) {
                        return;
                      }

                      // Same API call again.
                      // _submitPayment() starts/stops loader itself.
                      await _submitPayment();
                    },
                    icon: const Icon(
                      Icons.refresh_rounded,
                      size: 21,
                    ),
                    label: const Text(
                      'Retry',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0C447C),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // ==================================================
                // CANCEL BUTTON
                // ==================================================

                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF0C447C),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPaymentBgColor,
      body: Stack(
        children: [
          // =====================================================
          // EXISTING PAYMENT SCREEN
          // =====================================================
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),

                Expanded(
                  child: _isLoadingBalance
                      ? const Center(
                    child: CircularProgressIndicator(
                      color: kPaymentAccent,
                    ),
                  )
                      : _balanceError != null
                      ? _buildPaymentErrorPage()
                      : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      6,
                      20,
                      20,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 420,
                        ),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.stretch,
                          children: [
                            // Customer
                            _buildCustomerCard(),

                            const SizedBox(height: 16),

                            // Message
                            _buildMessageCard(),

                            const SizedBox(height: 16),

                            // Amount
                            _buildAmountCard(),

                            const SizedBox(height: 16),

                            // History
                            _buildHistoryCard(),

                            const SizedBox(height: 20),

                            // Bottom buttons
                            _buildBottomButtons(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // =====================================================
          // PAYMENT LOADER
          // =====================================================
          if (_isPaymentLoading)
            Positioned.fill(
              child: AbsorbPointer(
                absorbing: true,
                child: Container(
                  color: Colors.black54,
                  child: Center(
                    child: Container(
                      width: 220,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 24,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 42,
                            height: 42,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor:
                              AlwaysStoppedAnimation<Color>(
                                Color(0xFF0C447C),
                              ),
                            ),
                          ),
                          SizedBox(height: 18),
                          Text(
                            'Processing Payment...',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0C447C),
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Please wait',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF666666),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Header
  // -------------------------------------------------------------------------

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        14,
        20,
        12,
      ),
      child: Row(
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: kPaymentTextDark,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Make Payment',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: kPaymentTextDark,
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Customer Card
  // -------------------------------------------------------------------------

  Widget _buildCustomerCard() {
    final customer = widget.customer;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kPaymentCardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: kPaymentAccent.withOpacity(0.25),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: kPaymentAccent.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: kPaymentAccent.withOpacity(0.10),
            ),
            child: const Icon(
              Icons.person_rounded,
              size: 26,
              color: kPaymentAccent,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer.custname,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: kPaymentTextDark,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Code: ${customer.custcode}',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.black.withOpacity(0.55),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Message Card
  //
  // Java:
  // TextView tv_msg
  // -------------------------------------------------------------------------

  Widget _buildMessageCard() {
    return _sectionCard(
      title: 'MESSAGE',
      child: TextField(
        controller: _messageController,
        readOnly: true,
        maxLines: null,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: kPaymentTextDark,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Amount Card
  //
  // Java:
  // TextInputLayout
  // TextInputEditText -> et_amount
  // -------------------------------------------------------------------------

  Widget _buildAmountCard() {
    return _sectionCard(
      title: 'AMOUNT',
      child: TextField(
        controller: _amountController,
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
        ),
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: kPaymentTextDark,
        ),
        decoration: InputDecoration(
          prefixText: '₹ ',
          prefixStyle: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: kPaymentAccent,
          ),
          hintText: '0.00',
          hintStyle: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: kPaymentTextMuted.withOpacity(0.5),
          ),
          suffixIcon: Transform.translate(
            offset: const Offset(0, -14),
            child: IconButton(
              icon: const Icon(
                Icons.clear_rounded,
                size: 20,
                color: kPaymentTextMuted,
              ),
              onPressed: () {
                _amountController.clear();
              },
            ),
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }


  Widget _buildPaymentErrorPage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 72,
              width: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.redAccent.withOpacity(0.10),
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                color: Colors.redAccent,
                size: 38,
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'Unable to load payment information',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: kPaymentTextDark,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              _balanceError ??
                  'Something went wrong. Please try again.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: kPaymentTextMuted,
              ),
            ),

            const SizedBox(height: 22),

            SizedBox(
              height: 46,
              child: ElevatedButton.icon(
                onPressed: _isLoadingBalance
                    ? null
                    : _loadBalance,
                icon: const Icon(
                  Icons.refresh_rounded,
                  size: 20,
                ),
                label: const Text(
                  'Retry',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPaymentAccent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // History Card

  // -------------------------------------------------------------------------
  Widget _buildHistoryCard() {
    return _sectionCard(
      title: 'PAYMENT HISTORY',
      child: _isLoadingHistory
          ? const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: CircularProgressIndicator(
            color: kPaymentAccent,
          ),
        ),
      )
          : _historyError != null
          ? _buildHistoryError()
          : _paymentHistory.isEmpty
          ? const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'No payment history',
          style: TextStyle(
            fontSize: 14,
            color: kPaymentTextMuted,
          ),
        ),
      )
          : Column(
        children: [
          for (
          int i = 0;
          i < _paymentHistory.length;
          i++
          ) ...[
            if (i > 0)
              Divider(
                height: 20,
                color: Colors.grey.withOpacity(0.20),
              ),
            _historyRow(
              _paymentHistory[i],
              i,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHistoryError() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            color: Colors.redAccent,
            size: 34,
          ),
          const SizedBox(height: 10),
          const Text(
            'Unable to load payment history',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: kPaymentTextDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _historyError ??
                'Something went wrong. Please try again.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: kPaymentTextMuted,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 40,
            child: ElevatedButton.icon(
              onPressed: _isLoadingHistory
                  ? null
                  : _loadPaymentHistory,
              icon: const Icon(
                Icons.refresh_rounded,
                size: 18,
              ),
              label: const Text(
                'Retry',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPaymentAccent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _historyRow(
      PaymentHistoryEnt row,
      int index,
      ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: index % 2 == 1
            ? const Color(0xFFF5F8FA)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE3EAF0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ------------------------------------------------------
          // DATE + AMOUNT
          // ------------------------------------------------------
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 16,
                      color: kPaymentAccent,
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        row.txndate.isNotEmpty
                            ? row.txndate
                            : '-',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: kPaymentTextMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              if (row.txnamount.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF7FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '₹${row.txnamount}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: kPaymentAccent,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // ------------------------------------------------------
          // GATEWAY RESPONSE
          // ------------------------------------------------------
          if (row.respmsg.isNotEmpty)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.check_circle_outline_rounded,
                  size: 18,
                  color: Colors.green,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    row.respmsg,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: kPaymentTextDark,
                    ),
                  ),
                ),
              ],
            ),

          // ------------------------------------------------------
          // ERP MESSAGE
          // ------------------------------------------------------
          if (row.erpmsg.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 9,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 17,
                    color: Color(0xFFB7791F),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      row.erpmsg,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.35,
                        color: Color(0xFF6B5A32),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Bottom Buttons
  //
  // Java:
  // btn_reset
  // btn_submit
  // -------------------------------------------------------------------------

  Widget _buildBottomButtons() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _resetPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF757575),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Reset',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _submitPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPaymentAccent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Pay Now',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // Shared Section Card
  // -------------------------------------------------------------------------

  Widget _sectionCard({
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kPaymentCardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: kPaymentAccent.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
              color: kPaymentTextMuted,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}