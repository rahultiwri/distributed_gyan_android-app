import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../models/customer_model.dart';
import '../../services/place_order_service.dart';


import 'demand_order_screen.dart';

// ---------------------------------------------------------------------------
// Theme colors (matched to the reference design)
// ---------------------------------------------------------------------------
const Color kBgColor = Color(0xFFF6F3EA); // warm cream background
const Color kCardColor = Color(0xFFFFFFFF);
const Color kAccent = Color(0xFF0B7FBF); // blue accent (kept from original)
const Color kTextDark = Color(0xFF1D2430);
const Color kBadgeBg = Color(0xFFE9E4D8);

class PlaceOrderScreen extends StatefulWidget {
  const PlaceOrderScreen({super.key});

  @override
  State<PlaceOrderScreen> createState() => _PlaceOrderScreenState();
}

class _PlaceOrderScreenState extends State<PlaceOrderScreen> {
  Map<int, CustomerModel> _customers = {};

  bool _isLoading = true;
  bool _showErrorPage = false;
  bool _errorPopupShown = false;

  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechAvailable = false;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _syncCustomers();
    _initSpeech();
    _searchController.addListener(() {
      setState(() {
        _query = _searchController.text.trim().toLowerCase();
      });
    });
  }

  Future<void> _initSpeech() async {
    bool available = false;
    try {
      available = await _speech.initialize(
        onStatus: (status) {
          debugPrint('SPEECH STATUS: $status');
          if (status == 'done' || status == 'notListening') {
            if (_isListening) {
              _closeVoiceDialog();
            }
          }
        },
        onError: (error) {
          debugPrint('SPEECH ERROR: ${error.errorMsg}');
          if (mounted) setState(() => _isListening = false);
          _closeVoiceDialog();
        },
      );
    } catch (e) {
      debugPrint('SPEECH INIT EXCEPTION: $e');
      available = false;
    }

    debugPrint('SPEECH AVAILABLE: $available');

    if (!mounted) return;
    setState(() {
      _speechAvailable = available;
    });
  }

  final ValueNotifier<String> _liveText = ValueNotifier<String>('');
  bool _dialogOpen = false;

  Future<void> _toggleListening() async {
    debugPrint('MIC TAPPED - speechAvailable: $_speechAvailable, isListening: $_isListening');

    if (!_speechAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Voice search not available on this device')),
      );
      return;
    }

    if (_isListening) {
      await _speech.stop();
      _closeVoiceDialog();
      return;
    }

    _liveText.value = '';
    setState(() => _isListening = true);
    _openVoiceDialog();

    try {
      await _speech.listen(
        onResult: (result) {
          debugPrint('RECOGNIZED: ${result.recognizedWords}');
          _liveText.value = result.recognizedWords;

          if (result.finalResult) {
            _applyRecognizedText(result.recognizedWords);
          }
        },
        listenFor: const Duration(seconds: 20),
        pauseFor: const Duration(seconds: 3),
        localeId: 'en_IN',
      );
    } catch (e) {
      debugPrint('LISTEN EXCEPTION: $e');
      if (mounted) setState(() => _isListening = false);
      _closeVoiceDialog();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mic error: $e')),
      );
    }
  }

  void _applyRecognizedText(String text) {
    _searchController.text = text;
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: _searchController.text.length),
    );

    if (mounted) {
      setState(() {
        _query = text.trim().toLowerCase();
        _isListening = false;
      });
    }

    _closeVoiceDialog();
  }

  void _openVoiceDialog() {
    if (_dialogOpen) return;
    _dialogOpen = true;

    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 32),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 30, 24, 26),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _PulsingMicIcon(),
                const SizedBox(height: 18),
                const Text(
                  'Listening...',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: kTextDark,
                  ),
                ),
                const SizedBox(height: 14),
                ValueListenableBuilder<String>(
                  valueListenable: _liveText,
                  builder: (context, value, _) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        value.isEmpty ? 'Start speaking' : value,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: value.isEmpty
                              ? Colors.black.withOpacity(0.35)
                              : kTextDark,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    height: 36,
                    child: OutlinedButton(
                      onPressed: () async {
                        await _speech.stop();
                        _applyRecognizedText(_liveText.value);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kAccent,
                        side: const BorderSide(color: kAccent),
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Done',
                        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).then((_) {
      _dialogOpen = false;
    });
  }

  void _closeVoiceDialog() {
    if (_dialogOpen && mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
    _dialogOpen = false;
    if (mounted) setState(() => _isListening = false);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _speech.stop();
    _liveText.dispose();
    super.dispose();
  }

  Future<void> _syncCustomers() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _showErrorPage = false;
    });

    final customers = await PlaceOrderService.syncCustomers();

    if (!mounted) return;

    if (customers.isEmpty) {
      setState(() {
        _isLoading = false;
      });

      await _showConnectionError();

      return;
    }

    setState(() {
      _customers = customers;
      _isLoading = false;
      _showErrorPage = false;
    });
  }

  Future<void> _showConnectionError() async {
    if (!mounted || _errorPopupShown) return;

    _errorPopupShown = true;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            insetPadding: const EdgeInsets.symmetric(horizontal: 28),
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.96),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 72,
                    width: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: kAccent.withOpacity(0.10),
                    ),
                    child: const Icon(
                      Icons.cloud_off_rounded,
                      size: 38,
                      color: kAccent,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Connection Error',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      color: kTextDark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Something went wrong\nfrom server',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Colors.black.withOpacity(0.60),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kAccent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
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
          ),
        );
      },
    );

    _errorPopupShown = false;

    if (!mounted) return;

    setState(() {
      _showErrorPage = true;
    });
  }

  List<CustomerModel> get _filteredCustomers {
    final all = _customers.values.toList();
    if (_query.isEmpty) return all;

    return all.where((c) {
      return c.custname.toLowerCase().contains(_query) ||
          c.custcode.toString().toLowerCase().contains(_query) ||
          c.mobile.toLowerCase().contains(_query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: kBgColor,
        body: Center(
          child: CircularProgressIndicator(color: kAccent),
        ),
      );
    }

    if (_showErrorPage) {
      return _PlaceOrderErrorView(onRetry: _syncCustomers);
    }

    return Scaffold(
      backgroundColor: kBgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            const SizedBox(height: 10),
            if (_customers.isNotEmpty) _buildCustomerCount(),
            const SizedBox(height: 6),
            Expanded(
              child: _customers.isEmpty
                  ? const Center(
                child: Text(
                  'No customers found',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                  ),
                ),
              )
                  : _buildCustomerList(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: null,
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      child: Row(
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: kTextDark,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Place Order',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: kTextDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCount() {
    final count = _filteredCustomers.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: kAccent.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            'Showing ${count == 1 ? 'customer' : 'customers'}: $count',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: kAccent,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kAccent.withOpacity(0.35)),
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            Icon(Icons.search_rounded, color: Colors.black.withOpacity(0.45)),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search by Name or Contact',
                  hintStyle: TextStyle(
                    fontSize: 14.5,
                    color: Colors.black.withOpacity(0.40),
                    fontWeight: FontWeight.w500,
                  ),
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 14.5, color: kTextDark),
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  debugPrint('MIC ICON TAPPED');
                  _toggleListening();
                },
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                    color: _isListening ? kAccent : Colors.black.withOpacity(0.45),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerList() {
    final customers = _filteredCustomers;

    if (customers.isEmpty) {
      return const Center(
        child: Text(
          'No matching customers',
          style: TextStyle(fontSize: 15, color: Colors.black54),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      itemCount: customers.length,
      itemBuilder: (context, index) {
        final customer = customers[index];

        return _CustomerCard(
          customer: customer,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DemandOrderScreen(
                  customer: customer,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: kBgColor,
        border: Border(
          top: BorderSide(color: Color(0xFFE3DDCC), width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 58,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavIcon(icon: Icons.home_rounded, active: false),
              _NavIcon(icon: Icons.search_rounded, active: true),
              _NavIcon(icon: Icons.receipt_long_rounded, active: false),
              _NavIcon(icon: Icons.person_outline_rounded, active: false),
            ],
          ),
        ),
      ),
    );
  }
}

class _PulsingMicIcon extends StatefulWidget {
  const _PulsingMicIcon({super.key});

  @override
  State<_PulsingMicIcon> createState() => _PulsingMicIconState();
}

class _PulsingMicIconState extends State<_PulsingMicIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _scale = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        height: 74,
        width: 74,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: kAccent.withOpacity(0.12),
        ),
        child: const Icon(
          Icons.mic_rounded,
          size: 36,
          color: kAccent,
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final bool active;

  const _NavIcon({required this.icon, required this.active});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: active ? kAccent : Colors.black.withOpacity(0.35),
          size: 24,
        ),
        const SizedBox(height: 4),
        if (active)
          Container(
            width: 18,
            height: 3,
            decoration: BoxDecoration(
              color: kTextDark,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Customer card - matches reference: ID badge top-right, labeled rows
// ---------------------------------------------------------------------------
class _CustomerCard extends StatelessWidget {
  final CustomerModel customer;
  final VoidCallback onTap;

  const _CustomerCard({
    required this.customer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kAccent.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LabeledRow(label: 'Name:', value: customer.custname, bold: true),
                    const SizedBox(height: 8),
                    _LabeledRow(
                      label: 'Phone:',
                      value: customer.mobile.isEmpty ? '-' : customer.mobile,
                      icon: Icons.phone_outlined,
                    ),
                    const SizedBox(height: 8),
                    _LabeledRow(
                      label: 'Address:',
                      value: _formatAddress(customer.address, customer.city),
                      icon: Icons.location_on_outlined,
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 12,
                right: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: kBadgeBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'ID: ${customer.custcode}',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: kTextDark,
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

  String _formatAddress(String address, String city) {
    final cleanAddress =
    address.replaceAll('\n', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
    final cleanCity =
    city.replaceAll('\n', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();

    if (cleanAddress.isEmpty) return cleanCity;
    if (cleanCity.isEmpty) return cleanAddress;
    return '$cleanAddress, $cleanCity';
  }
}

class _LabeledRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final bool bold;

  const _LabeledRow({
    required this.label,
    required this.value,
    this.icon,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 17, color: kAccent),
          const SizedBox(width: 8),
        ] else
          const SizedBox(width: 25),
        Text(
          '$label ',
          style: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
            color: kTextDark,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
              color: kTextDark,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Error view (unchanged behaviour, restyled to match cream theme)
// ---------------------------------------------------------------------------
class _PlaceOrderErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const _PlaceOrderErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgColor,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -80,
            child: _Circle(size: 220, color: kAccent.withOpacity(0.08)),
          ),
          Positioned(
            bottom: -100,
            left: -70,
            child: _Circle(size: 220, color: const Color(0xFF2FA365).withOpacity(0.07)),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 420),
                      padding: const EdgeInsets.fromLTRB(26, 34, 26, 28),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.88),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: Colors.white.withOpacity(0.80)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            height: 82,
                            width: 82,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: kAccent.withOpacity(0.10),
                            ),
                            child: const Icon(
                              Icons.cloud_off_rounded,
                              size: 43,
                              color: kAccent,
                            ),
                          ),
                          const SizedBox(height: 22),
                          const Text(
                            'Unable to load customers',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                              color: kTextDark,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Something went wrong\nfrom server',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.5,
                              color: Colors.black.withOpacity(0.58),
                            ),
                          ),
                          const SizedBox(height: 26),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: onRetry,
                              icon: const Icon(Icons.refresh_rounded, size: 21),
                              label: const Text(
                                'Retry',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kAccent,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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
}

class _Circle extends StatelessWidget {
  final double size;
  final Color color;

  const _Circle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}