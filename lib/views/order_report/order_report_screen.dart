
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../models/customer_model.dart';
import '../../models/order_report_model.dart';
import '../../services/order_report_service.dart';

class OrderReportScreen extends StatefulWidget {
final CustomerModel customer;

const OrderReportScreen({
super.key,
required this.customer,
});

@override
State<OrderReportScreen> createState() => _OrderReportScreenState();
}

class _OrderReportScreenState extends State<OrderReportScreen> {
// ==========================================================
// COLORS
// ==========================================================

static const Color deepBlue = Color(0xFF0C447C);
static const Color accentBlue = Color(0xFF0B7FBF);
static const Color lightBlue = Color(0xFFEAF7FF);
static const Color cream = Color(0xFFFAF4E6);

// ==========================================================
// FORM STATE
// ==========================================================

String? _selectedShift;

DateTime _selectedDate = DateTime.now();

final GlobalKey _shiftFieldKey = GlobalKey();

// ==========================================================
// REPORT STATE
// ==========================================================

OrderReportModel? _report;

bool _isLoading = false;

bool _hasError = false;

String _errorMessage = 'Something went wrong from server';

// ==========================================================
// DATE
// ==========================================================

Future<void> _pickDate() async {
final picked = await showDatePicker(
context: context,
initialDate: _selectedDate,
firstDate: DateTime(2020),
lastDate: DateTime(2100),
);

if (picked != null) {
setState(() {
_selectedDate = picked;
});
}
}

// ==========================================================
// SHIFT SELECTION
// ==========================================================

Future<void> _showShiftSelection() async {
final renderObject =
_shiftFieldKey.currentContext?.findRenderObject();

if (renderObject is! RenderBox) {
return;
}

final offset = renderObject.localToGlobal(Offset.zero);
final size = renderObject.size;

final overlayObject =
Overlay.of(context).context.findRenderObject();

if (overlayObject is! RenderBox) {
return;
}

final selected = await showMenu<String>(
context: context,
color: Colors.white,
elevation: 8,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(18),
),
position: RelativeRect.fromRect(
Rect.fromLTWH(
offset.dx,
offset.dy + size.height + 6,
size.width,
0,
),
Offset.zero & overlayObject.size,
),
constraints: BoxConstraints(
minWidth: size.width,
maxWidth: size.width,
),
items: [
PopupMenuItem<String>(
value: 'Morning Shift',
padding: EdgeInsets.zero,
child: _ShiftMenuRow(
title: 'Morning Shift',
icon: Icons.wb_sunny_rounded,
color: const Color(0xFFE5A51B),
selected: _selectedShift == 'Morning Shift',
),
),
PopupMenuItem<String>(
value: 'Evening Shift',
padding: EdgeInsets.zero,
child: _ShiftMenuRow(
title: 'Evening Shift',
icon: Icons.nightlight_round,
color: const Color(0xFF7C5CD6),
selected: _selectedShift == 'Evening Shift',
),
),
],
);

if (selected != null) {
setState(() {
_selectedShift = selected;
});
}
}

// ==========================================================
// RESET
// ==========================================================

void _resetForm() {
setState(() {
_selectedShift = null;
_selectedDate = DateTime.now();

_report = null;
_hasError = false;
_errorMessage = 'Something went wrong from server';
});
}

// ==========================================================
// SUBMIT
// ==========================================================

Future<void> _submit() async {
// --------------------------------------------------------
// SHIFT VALIDATION
// --------------------------------------------------------

if (_selectedShift == null) {
_showShiftRequiredPopup();
return;
}

await _loadReport();
}

// ==========================================================
// LOAD REPORT
// ==========================================================

  void _showNoOrderBottomSheet(String message) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return SafeArea(
          top: false,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              24,
              8,
              24,
              12,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top handle
                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD8E0E5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 10),

                // Emoji
                const Text(
                  '📦',
                  style: TextStyle(
                    fontSize: 38,
                  ),
                ),

                const SizedBox(height: 4),

                // Order Information
                const Text(
                  'Order Information',
                  style: TextStyle(
                    color: deepBlue,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 4),

                // Message
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF687781),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 12),

                // OK Button
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
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


  Future<void> _loadReport() async {
    if (_selectedShift == null) {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = 'Something went wrong from server';
    });

    // --------------------------------------------------------
    // Morning Shift -> M
    // Evening Shift -> E
    // --------------------------------------------------------

    final shiftCode =
    _selectedShift == 'Morning Shift' ? 'M' : 'E';

    final orderDate = _formatDate(_selectedDate);

    try {
      final report = await OrderReportService.syncReport(
        customer: widget.customer,
        orderDate: orderDate,
        shift: shiftCode,
      );

      if (!mounted) {
        return;
      }

      // ------------------------------------------------------
      // API FAILURE
      // ------------------------------------------------------

      if (report == null) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage =
          'Unable to get order report.\nPlease try again.';
        });

        return;
      }

      // ------------------------------------------------------
      // NO ORDER FOUND
      // ------------------------------------------------------

      final message = report.msg
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();

      if (message.toLowerCase() == 'no order found') {
        setState(() {
          _isLoading = false;
          _hasError = false;
          _report = null;
        });

        _showNoOrderBottomSheet(message);

        return;
      }

      // ------------------------------------------------------
      // API SUCCESS
      // ------------------------------------------------------

      setState(() {
        _isLoading = false;
        _hasError = false;
        _report = report;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage =
        'Unable to get order report.\nPlease try again.';
      });
    }
  }

// ==========================================================
// SHIFT REQUIRED POPUP
// ==========================================================

void _showShiftRequiredPopup() {
showDialog<void>(
context: context,
barrierDismissible: true,
builder: (context) {
return Dialog(
backgroundColor: Colors.transparent,
insetPadding: const EdgeInsets.symmetric(
horizontal: 28,
),
child: ClipRRect(
borderRadius: BorderRadius.circular(24),
child: BackdropFilter(
filter: ImageFilter.blur(
sigmaX: 8,
sigmaY: 8,
),
child: Container(
padding: const EdgeInsets.all(22),
decoration: BoxDecoration(
color: Colors.white.withOpacity(0.96),
borderRadius: BorderRadius.circular(24),
),
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
Container(
width: 58,
height: 58,
decoration: BoxDecoration(
color: const Color(0xFFFFF4D6),
borderRadius: BorderRadius.circular(18),
),
child: const Icon(
Icons.access_time_rounded,
color: Color(0xFFE5A51B),
size: 30,
),
),
const SizedBox(height: 15),
const Text(
'Shift Required',
textAlign: TextAlign.center,
style: TextStyle(
color: deepBlue,
fontSize: 19,
fontWeight: FontWeight.w700,
),
),
const SizedBox(height: 8),
const Text(
'Please select a shift before submitting the order report.',
textAlign: TextAlign.center,
style: TextStyle(
color: Color(0xFF687781),
fontSize: 14,
height: 1.4,
),
),
const SizedBox(height: 20),
SizedBox(
width: double.infinity,
height: 46,
child: ElevatedButton(
onPressed: () {
Navigator.pop(context);
},
style: ElevatedButton.styleFrom(
backgroundColor: accentBlue,
foregroundColor: Colors.white,
elevation: 0,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(13),
),
),
child: const Text(
'OK',
style: TextStyle(
fontWeight: FontWeight.w700,
),
),
),
),
],
),
),
),
),
);
},
);
}

// ==========================================================
// DATE FORMAT
// ==========================================================

String _formatDate(DateTime date) {
return '${date.day.toString().padLeft(2, '0')}-'
'${date.month.toString().padLeft(2, '0')}-'
'${date.year}';
}

// ==========================================================
// ORDER STATUS
// ==========================================================

String _getOrderStatus(String status) {
if (status == '1') {
return 'Order is approved';
}

if (status == '2') {
return 'Order cancelled';
}

return 'Order not approved';
}

// ==========================================================
// ORDER STATUS ICON
// ==========================================================

IconData _getOrderStatusIcon(String status) {
if (status == '1') {
return Icons.check_circle_rounded;
}

if (status == '2') {
return Icons.cancel_rounded;
}

return Icons.info_rounded;
}

// ==========================================================
// BUILD
// ==========================================================

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: cream,
body: SafeArea(
child: Column(
children: [
// ==================================================
// HEADER
// ==================================================

_buildHeader(),

// ==================================================
// BODY
// ==================================================

Expanded(
child: _isLoading
? _buildLoadingState()
    : _hasError
? _buildErrorState()
    : SingleChildScrollView(
physics: const BouncingScrollPhysics(),
padding: const EdgeInsets.fromLTRB(
16,
18,
16,
30,
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
// ==================================
// CUSTOMER
// ==================================

_buildCustomerCard(),

const SizedBox(height: 18),

// ==================================
// FILTER
// ==================================

_buildFilterCard(),

const SizedBox(height: 18),

// ==================================
// ACTION BUTTONS
// ==================================

_buildActionButtons(),

// ==================================
// REPORT
// ==================================

if (_report != null) ...[
const SizedBox(height: 22),

_buildOrderSummary(),

const SizedBox(height: 18),

..._buildProductSections(),

if (_report!.imgurl.trim().isNotEmpty)
...[
const SizedBox(height: 18),
_buildImageSection(),
],
],
],
),
),
),
],
),
),
);
}

// ==========================================================
// HEADER
// ==========================================================

Widget _buildHeader() {
return Container(
width: double.infinity,
padding: const EdgeInsets.fromLTRB(
8,
10,
16,
14,
),
decoration: const BoxDecoration(
borderRadius: BorderRadius.only(
bottomLeft: Radius.circular(24),
bottomRight: Radius.circular(24),
),
),
child: SizedBox(
height: 44,
child: Stack(
alignment: Alignment.center,
children: [
// ==================================================
// BACK
// ==================================================

Align(
alignment: Alignment.centerLeft,
child: GestureDetector(
onTap: () {
Navigator.pop(context);
},
child: const Padding(
padding: EdgeInsets.only(
left: 38,
top: 8,
bottom: 8,
right: 8,
),
child: Text(
'<',
style: TextStyle(
color: Colors.black,
fontSize: 34,
fontWeight: FontWeight.w400,
height: 1,
),
),
),
),
),

// ==================================================
// CENTER TITLE
// ==================================================

Align(
alignment: Alignment.center,
child: Padding(
padding: const EdgeInsets.only(
right: 35,
),
child: const Text(
'Order Report',
style: TextStyle(
color: Colors.black,
fontSize: 28,
fontWeight: FontWeight.w700,
),
),
),
),
],
),
),
);
}

// ==========================================================
// LOADING STATE
// ==========================================================

Widget _buildLoadingState() {
return Center(
child: SingleChildScrollView(
physics: const BouncingScrollPhysics(),
padding: const EdgeInsets.all(24),
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Container(
width: 78,
height: 78,
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(24),
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(0.06),
blurRadius: 18,
offset: const Offset(0, 7),
),
],
),
child: const Padding(
padding: EdgeInsets.all(23),
child: CircularProgressIndicator(
strokeWidth: 3,
color: accentBlue,
),
),
),
const SizedBox(height: 20),
const Text(
'Getting Order Report...',
style: TextStyle(
color: deepBlue,
fontSize: 17,
fontWeight: FontWeight.w700,
),
),
const SizedBox(height: 7),
Text(
'${widget.customer.custname}\n'
'${_selectedShift ?? ''} • '
'${_formatDate(_selectedDate)}',
textAlign: TextAlign.center,
style: const TextStyle(
color: Color(0xFF75838D),
fontSize: 13,
height: 1.45,
),
),
],
),
),
);
}

// ==========================================================
// ERROR STATE
// ==========================================================

Widget _buildErrorState() {
return Center(
child: SingleChildScrollView(
physics: const BouncingScrollPhysics(),
padding: const EdgeInsets.all(24),
child: Container(
width: double.infinity,
constraints: const BoxConstraints(
maxWidth: 420,
),
padding: const EdgeInsets.all(24),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(24),
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(0.06),
blurRadius: 18,
offset: const Offset(0, 7),
),
],
),
child: Column(
children: [
Container(
width: 70,
height: 70,
decoration: BoxDecoration(
color: const Color(0xFFFFEEEE),
borderRadius: BorderRadius.circular(22),
),
child: const Icon(
Icons.cloud_off_rounded,
color: Color(0xFFD64545),
size: 35,
),
),
const SizedBox(height: 18),
const Text(
'Unable to Load Report',
textAlign: TextAlign.center,
style: TextStyle(
color: deepBlue,
fontSize: 19,
fontWeight: FontWeight.w700,
),
),
const SizedBox(height: 8),
Text(
_errorMessage,
textAlign: TextAlign.center,
style: const TextStyle(
color: Color(0xFF75838D),
fontSize: 14,
height: 1.45,
),
),
const SizedBox(height: 21),
SizedBox(
width: double.infinity,
height: 48,
child: ElevatedButton.icon(
onPressed: _loadReport,
icon: const Icon(
Icons.refresh_rounded,
size: 20,
),
label: const Text(
'Retry',
style: TextStyle(
fontWeight: FontWeight.w700,
),
),
style: ElevatedButton.styleFrom(
backgroundColor: accentBlue,
foregroundColor: Colors.white,
elevation: 0,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(14),
),
),
),
),
],
),
),
),
);
}

// ==========================================================
// CUSTOMER CARD
// ==========================================================

Widget _buildCustomerCard() {
return Container(
width: double.infinity,
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(18),
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(0.06),
blurRadius: 14,
offset: const Offset(0, 5),
),
],
),
child: Row(
children: [
Container(
width: 50,
height: 50,
decoration: BoxDecoration(
color: lightBlue,
borderRadius: BorderRadius.circular(15),
),
child: const Icon(
Icons.person_rounded,
color: accentBlue,
size: 27,
),
),
const SizedBox(width: 13),
Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Text(
'Customer',
style: TextStyle(
fontSize: 12,
color: Colors.grey,
fontWeight: FontWeight.w500,
),
),
const SizedBox(height: 4),
Text(
widget.customer.custname,
maxLines: 2,
overflow: TextOverflow.ellipsis,
style: const TextStyle(
fontSize: 16,
color: deepBlue,
fontWeight: FontWeight.w700,
),
),
const SizedBox(height: 3),
Text(
'Code: ${widget.customer.custcode}',
style: const TextStyle(
fontSize: 12,
color: Color(0xFF70808C),
fontWeight: FontWeight.w500,
),
),
],
),
),
],
),
);
}

// ==========================================================
// FILTER CARD
// ==========================================================

Widget _buildFilterCard() {
return Container(
width: double.infinity,
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(18),
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(0.05),
blurRadius: 14,
offset: const Offset(0, 5),
),
],
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Row(
children: [
Icon(
Icons.tune_rounded,
color: accentBlue,
size: 20,
),
SizedBox(width: 8),
Text(
'Report Filter',
style: TextStyle(
fontSize: 16,
color: deepBlue,
fontWeight: FontWeight.w700,
),
),
],
),
const SizedBox(height: 15),

// ==================================================
// SHIFT
// ==================================================

GestureDetector(
key: _shiftFieldKey,
onTap: _showShiftSelection,
child: Container(
padding: const EdgeInsets.symmetric(
horizontal: 14,
vertical: 12,
),
decoration: BoxDecoration(
color: const Color(0xFFF7FAFC),
borderRadius: BorderRadius.circular(14),
border: Border.all(
color: const Color(0xFFDCE5EB),
),
),
child: Row(
children: [
Container(
width: 42,
height: 42,
decoration: BoxDecoration(
color:
_selectedShift == 'Morning Shift'
? const Color(0xFFFFF4D6)
    : _selectedShift ==
'Evening Shift'
? const Color(0xFFF0EAFF)
    : const Color(0xFFEAF7FF),
borderRadius:
BorderRadius.circular(12),
),
child: Icon(
_selectedShift == 'Morning Shift'
? Icons.wb_sunny_rounded
    : _selectedShift ==
'Evening Shift'
? Icons.nightlight_round
    : Icons.access_time_rounded,
color:
_selectedShift == 'Morning Shift'
? const Color(0xFFE5A51B)
    : _selectedShift ==
'Evening Shift'
? const Color(0xFF7C5CD6)
    : accentBlue,
size: 22,
),
),
const SizedBox(width: 12),
Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Text(
'Shift',
style: TextStyle(
fontSize: 12,
color: Colors.grey,
fontWeight: FontWeight.w500,
),
),
const SizedBox(height: 3),
Text(
_selectedShift ?? 'Select Shift',
style: TextStyle(
fontSize: 15,
color: _selectedShift == null
? const Color(0xFF7A8894)
    : deepBlue,
fontWeight: FontWeight.w600,
),
),
],
),
),
const Icon(
Icons.keyboard_arrow_down_rounded,
color: deepBlue,
),
],
),
),
),

const SizedBox(height: 12),

// ==================================================
// DATE
// ==================================================

GestureDetector(
onTap: _pickDate,
child: Container(
padding: const EdgeInsets.symmetric(
horizontal: 14,
vertical: 12,
),
decoration: BoxDecoration(
color: const Color(0xFFF7FAFC),
borderRadius: BorderRadius.circular(14),
border: Border.all(
color: const Color(0xFFDCE5EB),
),
),
child: Row(
children: [
Container(
width: 42,
height: 42,
decoration: BoxDecoration(
color: lightBlue,
borderRadius:
BorderRadius.circular(12),
),
child: const Icon(
Icons.calendar_month_rounded,
color: accentBlue,
size: 22,
),
),
const SizedBox(width: 12),
Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Text(
'Order Date',
style: TextStyle(
fontSize: 12,
color: Colors.grey,
fontWeight: FontWeight.w500,
),
),
const SizedBox(height: 3),
Text(
_formatDate(_selectedDate),
style: const TextStyle(
fontSize: 15,
color: deepBlue,
fontWeight: FontWeight.w600,
),
),
],
),
),
const Icon(
Icons.calendar_today_rounded,
color: deepBlue,
size: 19,
),
],
),
),
),
],
),
);
}

// ==========================================================
// ACTION BUTTONS
// ==========================================================

Widget _buildActionButtons() {
return Row(
children: [
// ====================================================
// RESET
// ====================================================

Expanded(
child: OutlinedButton.icon(
onPressed: _resetForm,
icon: const Icon(
Icons.refresh_rounded,
size: 20,
),
label: const Text(
'Reset',
style: TextStyle(
fontWeight: FontWeight.w600,
),
),
style: OutlinedButton.styleFrom(
foregroundColor: deepBlue,
side: const BorderSide(
color: Color(0xFFD1DEE6),
),
minimumSize: const Size(
0,
50,
),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(14),
),
),
),
),

const SizedBox(width: 12),

// ====================================================
// SUBMIT
// ====================================================

Expanded(
child: ElevatedButton.icon(
onPressed: _isLoading ? null : _submit,
icon: const Icon(
Icons.receipt_long_rounded,
size: 20,
),
label: const Text(
'Submit',
style: TextStyle(
fontWeight: FontWeight.w600,
),
),
style: ElevatedButton.styleFrom(
backgroundColor: accentBlue,
foregroundColor: Colors.white,
disabledBackgroundColor:
accentBlue.withOpacity(0.5),
disabledForegroundColor: Colors.white,
elevation: 0,
minimumSize: const Size(
0,
50,
),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(14),
),
),
),
),
],
);
}

// ==========================================================
// ORDER SUMMARY
// ==========================================================

Widget _buildOrderSummary() {
final report = _report;

if (report == null) {
return const SizedBox.shrink();
}

final orderStatus =
_getOrderStatus(report.orderstatus);

return Container(
width: double.infinity,
padding: const EdgeInsets.all(17),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(18),
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(0.05),
blurRadius: 14,
offset: const Offset(0, 5),
),
],
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Row(
children: [
Icon(
Icons.analytics_rounded,
color: accentBlue,
size: 21,
),
SizedBox(width: 8),
Text(
'Order Summary',
style: TextStyle(
fontSize: 16,
color: deepBlue,
fontWeight: FontWeight.w700,
),
),
],
),

const SizedBox(height: 16),

// ==================================================
// ORDER VALUE + STATUS
// ==================================================

Row(
children: [
Expanded(
child: _SummaryItem(
title: 'Order Value',
value: _formatOrderValue(
report.ordervalue,
),
icon: Icons.currency_rupee_rounded,
),
),
const SizedBox(width: 10),
Expanded(
child: _SummaryItem(
title: 'Status',
value: orderStatus,
icon: _getOrderStatusIcon(
report.orderstatus,
),
),
),
],
),

const SizedBox(height: 15),

// ==================================================
// CRATE + JAALI
// ==================================================

Row(
children: [
Expanded(
child: _SummaryItem(
title: 'Total Crate',
value: report.crate,
icon: Icons.inventory_2_rounded,
),
),
const SizedBox(width: 10),
Expanded(
child: _SummaryItem(
title: 'Total Jaali',
value: report.jaali,
icon: Icons.shopping_basket_rounded,
),
),
],
),

// ==================================================
// ORDER DATE
// ==================================================

if (report.orderdate.trim().isNotEmpty) ...[
const SizedBox(height: 15),
_ReportInfoRow(
icon: Icons.calendar_month_rounded,
title: 'Order Date',
value: report.orderdate,
),
],

// ==================================================
// SHIFT
// ==================================================

if (report.ordershift.trim().isNotEmpty) ...[
const SizedBox(height: 10),
_ReportInfoRow(
icon: Icons.access_time_rounded,
title: 'Order Shift',
value: _getShiftName(
report.ordershift,
),
),
],

// ==================================================
// NARRATION
// ==================================================

if (report.ovnarr.trim().isNotEmpty) ...[
const SizedBox(height: 15),
Container(
width: double.infinity,
padding: const EdgeInsets.all(13),
decoration: BoxDecoration(
color: const Color(0xFFF7FAFC),
borderRadius: BorderRadius.circular(13),
border: Border.all(
color: const Color(0xFFE5EDF2),
),
),
child: Row(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Icon(
Icons.info_outline_rounded,
color: accentBlue,
size: 19,
),
const SizedBox(width: 9),
Expanded(
child: Text(
report.ovnarr,
style: const TextStyle(
fontSize: 12,
color: Color(0xFF687781),
height: 1.45,
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

// ==========================================================
// PRODUCT SECTIONS
// ==========================================================

List<Widget> _buildProductSections() {
final report = _report;

if (report == null ||
report.topgroups.isEmpty) {
return [
_buildNoProductsCard(),
];
}

final widgets = <Widget>[];

for (int i = 0;
i < report.topgroups.length;
i++) {
final groupName = report.topgroups[i];

final products =
report.products[groupName] ?? [];

widgets.add(
_buildProductSection(
title: groupName,
products: products,
),
);

if (i != report.topgroups.length - 1) {
widgets.add(
const SizedBox(height: 14),
);
}
}

return widgets;
}

// ==========================================================
// PRODUCT SECTION
// ==========================================================

Widget _buildProductSection({
required String title,
required List<OrderReportProduct> products,
}) {
return Container(
width: double.infinity,
padding: const EdgeInsets.all(15),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(18),
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(0.05),
blurRadius: 14,
offset: const Offset(0, 5),
),
],
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Row(
children: [
Container(
width: 7,
height: 22,
decoration: BoxDecoration(
color: accentBlue,
borderRadius:
BorderRadius.circular(5),
),
),
const SizedBox(width: 9),
Expanded(
child: Text(
title,
style: const TextStyle(
fontSize: 15,
color: deepBlue,
fontWeight: FontWeight.w700,
),
),
),
Container(
padding: const EdgeInsets.symmetric(
horizontal: 9,
vertical: 5,
),
decoration: BoxDecoration(
color: lightBlue,
borderRadius:
BorderRadius.circular(10),
),
child: Text(
'${products.length}',
style: const TextStyle(
fontSize: 11,
color: accentBlue,
fontWeight: FontWeight.w700,
),
),
),
],
),

const SizedBox(height: 12),

if (products.isEmpty)
const Padding(
padding: EdgeInsets.symmetric(
vertical: 10,
),
child: Text(
'No products found.',
style: TextStyle(
fontSize: 13,
color: Color(0xFF7A8894),
),
),
)
else
...products.map(
(product) => Padding(
padding: const EdgeInsets.only(
bottom: 8,
),
child: _ProductReportRow(
product: product,
),
),
),
],
),
);
}

// ==========================================================
// PRODUCT ROW
// ==========================================================

Widget _buildNoProductsCard() {
return Container(
width: double.infinity,
padding: const EdgeInsets.all(18),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(18),
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(0.05),
blurRadius: 14,
offset: const Offset(0, 5),
),
],
),
child: const Row(
children: [
Icon(
Icons.inventory_2_outlined,
color: accentBlue,
),
SizedBox(width: 10),
Expanded(
child: Text(
'No product details found.',
style: TextStyle(
color: Color(0xFF687781),
fontSize: 13,
),
),
),
],
),
);
}

// ==========================================================
// IMAGE SECTION
// ==========================================================

Widget _buildImageSection() {
final report = _report;

if (report == null ||
report.imgurl.trim().isEmpty) {
return const SizedBox.shrink();
}

return Container(
width: double.infinity,
padding: const EdgeInsets.all(15),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(18),
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(0.05),
blurRadius: 14,
offset: const Offset(0, 5),
),
],
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Row(
children: [
Icon(
Icons.image_rounded,
color: accentBlue,
size: 21,
),
SizedBox(width: 8),
Text(
'Order Image',
style: TextStyle(
fontSize: 16,
color: deepBlue,
fontWeight: FontWeight.w700,
),
),
],
),
const SizedBox(height: 13),
GestureDetector(
onTap: _showImageDialog,
child: ClipRRect(
borderRadius: BorderRadius.circular(14),
child: Container(
width: double.infinity,
constraints: const BoxConstraints(
maxHeight: 280,
),
color: const Color(0xFFF7FAFC),
child: Image.network(
report.imgurl,
fit: BoxFit.contain,
errorBuilder:
(context, error, stackTrace) {
return const SizedBox(
height: 180,
child: Center(
child: Icon(
Icons.broken_image_rounded,
color: Color(0xFF9AA7AF),
size: 45,
),
),
);
},
loadingBuilder:
(context, child, loadingProgress) {
if (loadingProgress == null) {
return child;
}

return const SizedBox(
height: 180,
child: Center(
child:
CircularProgressIndicator(
color: accentBlue,
),
),
);
},
),
),
),
),
if (report.remarks.trim().isNotEmpty) ...[
const SizedBox(height: 10),
Text(
'Tap image to view details',
style: TextStyle(
fontSize: 11,
color: Colors.grey.shade600,
),
),
],
],
),
);
}

// ==========================================================
// IMAGE DIALOG
// ==========================================================

void _showImageDialog() {
final report = _report;

if (report == null ||
report.imgurl.trim().isEmpty) {
return;
}

showDialog<void>(
context: context,
barrierColor: Colors.black.withOpacity(0.75),
builder: (context) {
return Dialog(
backgroundColor: Colors.transparent,
insetPadding: const EdgeInsets.all(18),
child: Container(
constraints: const BoxConstraints(
maxWidth: 500,
maxHeight: 700,
),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(20),
),
clipBehavior: Clip.antiAlias,
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
Padding(
padding: const EdgeInsets.fromLTRB(
16,
13,
10,
10,
),
child: Row(
children: [
const Expanded(
child: Text(
'Order Image',
style: TextStyle(
color: deepBlue,
fontSize: 16,
fontWeight: FontWeight.w700,
),
),
),
IconButton(
onPressed: () {
Navigator.pop(context);
},
icon: const Icon(
Icons.close_rounded,
color: deepBlue,
),
),
],
),
),
Flexible(
child: InteractiveViewer(
minScale: 0.5,
maxScale: 4,
child: Image.network(
report.imgurl,
fit: BoxFit.contain,
errorBuilder:
(context, error, stackTrace) {
return const Padding(
padding: EdgeInsets.all(40),
child: Icon(
Icons.broken_image_rounded,
color: Color(0xFF9AA7AF),
size: 55,
),
);
},
),
),
),
if (report.remarks.trim().isNotEmpty)
Container(
width: double.infinity,
margin: const EdgeInsets.all(14),
padding: const EdgeInsets.all(13),
decoration: BoxDecoration(
color: const Color(0xFFF7FAFC),
borderRadius:
BorderRadius.circular(13),
),
child: Row(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Icon(
Icons.notes_rounded,
color: accentBlue,
size: 19,
),
const SizedBox(width: 9),
Expanded(
child: Text(
report.remarks,
style: const TextStyle(
color: Color(0xFF687781),
fontSize: 13,
height: 1.4,
),
),
),
],
),
),
],
),
),
);
},
);
}

// ==========================================================
// HELPERS
// ==========================================================

String _formatOrderValue(String value) {
final trimmed = value.trim();

if (trimmed.isEmpty) {
return '₹0';
}

final parsed = double.tryParse(trimmed);

if (parsed == null) {
return '₹$trimmed';
}

return '₹${parsed.toStringAsFixed(2)}';
}

String _getShiftName(String shift) {
if (shift.toUpperCase() == 'M') {
return 'Morning Shift';
}

if (shift.toUpperCase() == 'E') {
return 'Evening Shift';
}

return shift;
}
}

// ============================================================
// SHIFT MENU ROW
// ============================================================

class _ShiftMenuRow extends StatelessWidget {
final String title;
final IconData icon;
final Color color;
final bool selected;

const _ShiftMenuRow({
required this.title,
required this.icon,
required this.color,
required this.selected,
});

@override
Widget build(BuildContext context) {
return Container(
margin: const EdgeInsets.symmetric(
horizontal: 6,
vertical: 4,
),
padding: const EdgeInsets.symmetric(
horizontal: 14,
vertical: 12,
),
decoration: BoxDecoration(
color: selected
? const Color(0xFFEAF7FF)
    : Colors.white,
borderRadius: BorderRadius.circular(14),
),
child: Row(
children: [
Container(
width: 38,
height: 38,
decoration: BoxDecoration(
color: color.withOpacity(0.12),
borderRadius: BorderRadius.circular(11),
),
child: Icon(
icon,
color: color,
size: 21,
),
),
const SizedBox(width: 12),
Expanded(
child: Text(
title,
style: const TextStyle(
fontSize: 14,
fontWeight: FontWeight.w600,
color: Color(0xFF0C447C),
),
),
),
if (selected)
const Icon(
Icons.check_circle_rounded,
color: Color(0xFF0B7FBF),
size: 21,
),
],
),
);
}
}

// ============================================================
// SUMMARY ITEM
// ============================================================

class _SummaryItem extends StatelessWidget {
final String title;
final String value;
final IconData icon;

const _SummaryItem({
required this.title,
required this.value,
required this.icon,
});

@override
Widget build(BuildContext context) {
return Row(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Container(
width: 38,
height: 38,
decoration: BoxDecoration(
color: const Color(0xFFEAF7FF),
borderRadius: BorderRadius.circular(11),
),
child: Icon(
icon,
color: const Color(0xFF0B7FBF),
size: 19,
),
),
const SizedBox(width: 9),
Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
title,
maxLines: 1,
overflow: TextOverflow.ellipsis,
style: const TextStyle(
fontSize: 11,
color: Colors.grey,
fontWeight: FontWeight.w500,
),
),
const SizedBox(height: 2),
Text(
value,
maxLines: 2,
overflow: TextOverflow.ellipsis,
style: const TextStyle(
fontSize: 14,
color: Color(0xFF0C447C),
fontWeight: FontWeight.w700,
),
),
],
),
),
],
);
}
}

// ============================================================
// REPORT INFO ROW
// ============================================================

class _ReportInfoRow extends StatelessWidget {
final IconData icon;
final String title;
final String value;

const _ReportInfoRow({
required this.icon,
required this.title,
required this.value,
});

@override
Widget build(BuildContext context) {
return Container(
width: double.infinity,
padding: const EdgeInsets.symmetric(
horizontal: 12,
vertical: 10,
),
decoration: BoxDecoration(
color: const Color(0xFFF7FAFC),
borderRadius: BorderRadius.circular(12),
border: Border.all(
color: const Color(0xFFE5EDF2),
),
),
child: Row(
children: [
Icon(
icon,
  color: const Color(0xFF0B7FBF),
size: 18,
),
const SizedBox(width: 9),
Text(
'$title:',
style: const TextStyle(
color: Color(0xFF7A8894),
fontSize: 12,
fontWeight: FontWeight.w500,
),
),
const SizedBox(width: 6),
Expanded(
child: Text(
value,
textAlign: TextAlign.end,
style: const TextStyle(
    color: const Color(0xFF0C447C),
fontSize: 12,
fontWeight: FontWeight.w700,
),
),
),
],
),
);
}
}

// ============================================================
// PRODUCT ROW
// ============================================================

class _ProductReportRow extends StatelessWidget {
final OrderReportProduct product;

const _ProductReportRow({
required this.product,
});

@override
Widget build(BuildContext context) {
return Container(
padding: const EdgeInsets.all(12),
decoration: BoxDecoration(
color: const Color(0xFFF7FAFC),
borderRadius: BorderRadius.circular(13),
border: Border.all(
color: const Color(0xFFE5EDF2),
),
),
child: Row(
children: [
Container(
width: 40,
height: 40,
decoration: BoxDecoration(
color: const Color(0xFFEAF7FF),
borderRadius: BorderRadius.circular(11),
),
child: const Icon(
Icons.local_drink_rounded,
color: Color(0xFF0B7FBF),
size: 20,
),
),
const SizedBox(width: 11),
Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
product.prdname,
maxLines: 2,
overflow: TextOverflow.ellipsis,
style: const TextStyle(
fontSize: 13,
color: Color(0xFF0C447C),
fontWeight: FontWeight.w600,
),
),
const SizedBox(height: 4),
Text(
'Code: ${product.prdcode}',
style: const TextStyle(
fontSize: 10,
color: Color(0xFF9AA7AF),
fontWeight: FontWeight.w500,
),
),
],
),
),
const SizedBox(width: 8),
Container(
padding: const EdgeInsets.symmetric(
horizontal: 10,
vertical: 6,
),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(10),
border: Border.all(
color: const Color(0xFFDCE5EB),
),
),
child: Text(
'Qty: ${product.qty}',
style: const TextStyle(
fontSize: 11,
color: Color(0xFF0C447C),
fontWeight: FontWeight.w700,
),
),
),
],
),
);
}
}

