import 'dart:ui';
import 'dart:convert';
import 'dart:io';


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/customer_model.dart';
import '../../services/demand_order_service.dart';
import '../../services/preference_service.dart';

import 'package:auto_datetime/auto_datetime.dart';

import 'package:app_settings/app_settings.dart';

import 'package:image_picker/image_picker.dart';

import 'dart:math' as math;

import '../../constants/application_constant.dart';

class DemandOrderScreen extends StatefulWidget {
  final CustomerModel customer;

  const DemandOrderScreen({super.key, required this.customer});

  @override
  State<DemandOrderScreen> createState() => _DemandOrderScreenState();
}

class _DemandOrderScreenState extends State<DemandOrderScreen>
    with WidgetsBindingObserver , SingleTickerProviderStateMixin{
  static const Color deepBlue = Color(0xFF0C447C);
  static const Color accentBlue = Color(0xFF0B7FBF);
  static const Color lightBlue = Color(0xFFEAF7FF);
  static const Color cream = Color(0xFFFAF4E6);

   static const String _baseUrl = ApplicationConstant.defaultBaseUrl;

  late DateTime _selectedDate;

  final GlobalKey _shiftFieldKey = GlobalKey();

  bool _isLoadingProducts = true;
  bool _hasProductError = false;
  bool _orderAlreadyApproved = false;

  bool _isSubmittingOrder = false;

  bool _isRepeatingYesterday = false;

  AnimationController? _targetAnimationController;

  Map<String, dynamic>? _productResponse;

  List<_ProductCategory> _categories = [];

  int _selectedCategoryIndex = 0;

  String xmlstr = '';

  // Product quantity
  final Map<int, int> _quantities = {};

  // Manual quantity TextField controllers
  final Map<int, TextEditingController> _quantityControllers = {};

  final ImagePicker _imagePicker = ImagePicker();
  XFile? _selectedDemandPhoto;
  bool _demandPhotoPromptHandled = false;

  String? _selectedDemandPhotoBase64;

  String _demandRemark = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _targetAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _selectedDate = DateTime.now();

    _loadProducts();

    // _targetAnimationController = AnimationController(
    //   vsync: this,
    //   duration: const Duration(seconds: 3),
    // )..repeat();
  }

  // ===========================================================================
  // LOAD PRODUCTS
  // ===========================================================================

  Future<void> _loadProducts() async {
    if (!mounted) return;

    // Dispose old controllers
    for (final controller in _quantityControllers.values) {
      controller.dispose();
    }

    _quantityControllers.clear();

    setState(() {
      _isLoadingProducts = true;
      _hasProductError = false;
      _productResponse = null;
      _categories = [];
      _selectedCategoryIndex = 0;
      _quantities.clear();
    });

    debugPrint('================================');
    debugPrint('DEMAND ORDER - LOAD PRODUCTS');
    debugPrint('CUSTOMER: ${widget.customer.custname}');
    debugPrint('CUSTCODE: ${widget.customer.custcode}');
    debugPrint('DISTCH: ${widget.customer.distch}');
    debugPrint('================================');

    final response = await DemandOrderService.syncProducts();

    if (!mounted) return;

    if (response == null) {
      debugPrint('================================');
      debugPrint('DEMAND ORDER PRODUCT LOAD FAILED');
      debugPrint('================================');

      setState(() {
        _isLoadingProducts = false;
        _hasProductError = true;
        _productResponse = null;
      });

      await _showConnectionErrorPopup();

      return;
    }

    final categories = _buildDynamicCategories(response);

    debugPrint('================================');
    debugPrint('DYNAMIC CATEGORY RESULT');
    debugPrint('TOTAL CATEGORIES: ${categories.length}');

    for (final category in categories) {
      debugPrint(
        'CATEGORY: ${category.name} | '
        'GROUP IDS: ${category.groupIds} | '
        'PRODUCTS: ${category.products.length} | '
        'SHOW IMAGE: ${category.showGroupImage} | '
        'IMAGE: ${category.groupImage}',
      );
    }

    debugPrint('================================');

    setState(() {
      _isLoadingProducts = false;
      _hasProductError = false;
      _productResponse = response;
      _categories = categories;
      _selectedCategoryIndex = 0;
    });
  }

  // ===========================================================================
  // BUILD DYNAMIC CATEGORIES
  // ===========================================================================

  List<_ProductCategory> _buildDynamicCategories(
    Map<String, dynamic> response,
  ) {
    final selectedDistch = widget.customer.distch.trim();

    final productGroups = response['ProductGroups'];
    final products = response['Products'];

    if (productGroups is! List || products is! List) {
      debugPrint('Invalid ProductGroups / Products response');
      return [];
    }

    // showgrpimg API response  TOP LEVEL par hai:

    final showGroupImage =
        (response['showgrpimg'] ?? '0').toString().trim() == '1';

    debugPrint('SHOW GROUP IMAGE FROM RESPONSE: $showGroupImage');

    // -------------------------------------------------------------------------
    // ProductGroups
    // -------------------------------------------------------------------------

    final groups = productGroups
        .whereType<Map>()
        .map((group) => Map<String, dynamic>.from(group))
        .toList();

    // -------------------------------------------------------------------------
    // Sort by grplevel
    // -------------------------------------------------------------------------

    groups.sort((a, b) {
      final levelA = int.tryParse('${a['grplevel'] ?? 999999}') ?? 999999;

      final levelB = int.tryParse('${b['grplevel'] ?? 999999}') ?? 999999;

      return levelA.compareTo(levelB);
    });

    // -------------------------------------------------------------------------
    // Products
    // -------------------------------------------------------------------------

    final productList = products
        .whereType<Map>()
        .map((product) => Map<String, dynamic>.from(product))
        .toList();

    // -------------------------------------------------------------------------
    // Category Map
    // -------------------------------------------------------------------------

    final Map<String, _ProductCategory> categoryMap = {};

    for (final group in groups) {
      final dcValue = (group['DC'] ?? '').toString().trim();

      final topGroup = (group['topgrp'] ?? '').toString().trim();

      final groupId = int.tryParse('${group['grpid'] ?? ''}');

      if (topGroup.isEmpty || groupId == null) {
        continue;
      }

      // -----------------------------------------------------------------------
      // DC MATCH
      // -----------------------------------------------------------------------

      final dcValues = dcValue
          .split(',')
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .toSet();

      if (!dcValues.contains(selectedDistch)) {
        continue;
      }

      // -----------------------------------------------------------------------
      // GROUP IMAGE
      // "img": "img/gyan_demand_logo.png"

      // https://demand.gyandairy.com/gyantes/img/gyan_demand_logo.png
      // -----------------------------------------------------------------------

      final rawImage = (group['img'] ?? '').toString().trim();

      debugPrint('================ CATEGORY IMAGE DEBUG ================');
      debugPrint('TOPGRP      : $topGroup');
      debugPrint('GRPID       : $groupId');
      debugPrint('RAW IMG     : "$rawImage"');
      debugPrint('SHOWGRPIMG  : ${response['showgrpimg']}');
      debugPrint('========================================================');

      String groupImage = '';

      if (rawImage.isNotEmpty) {
        if (rawImage.startsWith('http://') || rawImage.startsWith('https://')) {
          // Already complete URL
          groupImage = rawImage;
        } else {
          final cleanBaseUrl = _baseUrl.replaceFirst(RegExp(r'/$'), '');

          final cleanImage = rawImage.replaceFirst(RegExp(r'^/'), '');

          groupImage = '$cleanBaseUrl/$cleanImage';
        }
      }

      debugPrint(
        'GROUP IMAGE LOGIC -> '
        'topgrp: $topGroup | '
        'grpid: $groupId | '
        'img: $rawImage | '
        'fullImage: $groupImage',
      );

      if (!categoryMap.containsKey(topGroup)) {
        categoryMap[topGroup] = _ProductCategory(
          name: topGroup,
          groupIds: [],
          products: [],
          showGroupImage: showGroupImage,
          groupImage: groupImage,
          color: accentBlue,
        );
      } else {
        final existingCategory = categoryMap[topGroup]!;

        if (existingCategory.groupImage.isEmpty && groupImage.isNotEmpty) {
          existingCategory.groupImage = groupImage;
        }
      }

      final category = categoryMap[topGroup]!;

      // -----------------------------------------------------------------------
      // grpid add
      // -----------------------------------------------------------------------

      if (!category.groupIds.contains(groupId)) {
        category.groupIds.add(groupId);
      }
    }

    // -------------------------------------------------------------------------
    // PRODUCTS MATCH WITH GROUP IDS
    // -------------------------------------------------------------------------

    for (final category in categoryMap.values) {
      final matchedProducts = productList.where((product) {
        final productGroupId = int.tryParse('${product['grpid'] ?? ''}');

        return productGroupId != null &&
            category.groupIds.contains(productGroupId);
      });

      for (final product in matchedProducts) {
        final prdcode = int.tryParse('${product['prdcode'] ?? ''}');

        final name = (product['name'] ?? '').toString().trim();

        if (prdcode == null || name.isEmpty) {
          continue;
        }

        category.products.add(
          _DemandProduct(
            prdcode: prdcode,
            name: name,
            grpid: int.tryParse('${product['grpid'] ?? ''}') ?? 0,
            rate: (product['rate'] ?? '').toString(),
            mrp: (product['mrp'] ?? '').toString(),
            unit: (product['unit'] ?? '').toString(),
            pimg: (product['pimg'] ?? '').toString(),
          ),
        );
      }
    }

    return categoryMap.values
        .where((category) => category.products.isNotEmpty)
        .toList();
  }

  // ===========================================================================
  // QUANTITY LOGIC
  // ===========================================================================

  int _getProductQuantity(int prdcode) {
    return _quantities[prdcode] ?? 0;
  }

  TextEditingController _getQuantityController(int prdcode) {
    return _quantityControllers.putIfAbsent(
      prdcode,
      () => TextEditingController(text: (_quantities[prdcode] ?? 0).toString()),
    );
  }

  // ===========================================================================
  // PLUS
  // ===========================================================================

  void _increaseProductQuantity(int prdcode) {
    final current = _quantities[prdcode] ?? 0;

    // Maximum quantity = 999
    if (current >= 999) {
      return;
    }

    final newQuantity = current + 1;

    _quantities[prdcode] = newQuantity;

    final controller = _getQuantityController(prdcode);

    controller.text = newQuantity.toString();

    controller.selection = TextSelection.collapsed(
      offset: controller.text.length,
    );
  }

  // ===========================================================================
  // MINUS
  // ===========================================================================

  void _decreaseProductQuantity(int prdcode) {
    final current = _quantities[prdcode] ?? 0;

    if (current <= 0) {
      return;
    }

    final newQuantity = current - 1;

    _quantities[prdcode] = newQuantity;

    final controller = _getQuantityController(prdcode);

    controller.text = newQuantity.toString();

    controller.selection = TextSelection.collapsed(
      offset: controller.text.length,
    );
  }

  // ===========================================================================
  // MANUAL QUANTITY
  // ===========================================================================

  void _setManualQuantity(int prdcode, String value) {
    final trimmedValue = value.trim();

    if (trimmedValue.isEmpty) {
      _quantities[prdcode] = 0;
      return;
    }

    final parsed = int.tryParse(trimmedValue);

    if (parsed == null || parsed < 0) {
      return;
    }

    // Maximum quantity = 999
    if (parsed > 999) {
      _quantities[prdcode] = 999;

      final controller = _getQuantityController(prdcode);

      controller.text = '999';

      controller.selection = const TextSelection.collapsed(offset: 3);

      return;
    }

    _quantities[prdcode] = parsed;
  }

  // ===========================================================================
  // RESET
  // ===========================================================================

  void _resetQuantities() {
    setState(() {
      _quantities.clear();

      for (final controller in _quantityControllers.values) {
        controller.text = '0';

        controller.selection = const TextSelection.collapsed(offset: 1);
      }

      _selectedShift = 'Select Shift';
    });
  }

  // ===========================================================================
  // SUBMIT BUTTON
  // ===========================================================================

  Future<bool> _validateShift() async {
    if (_selectedShift == 'Select Shift') {
      await _showShiftRequiredPopup();
      return false;
    }

    return true;
  }

  Future<void> _showShiftRequiredPopup() async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (dialogContext) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.96),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: accentBlue.withOpacity(0.10),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.access_time_rounded,
                      color: accentBlue,
                      size: 34,
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'Shift Required',
                    style: TextStyle(
                      color: deepBlue,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 9),

                  Text(
                    'Please select a shift\nbefore submitting the order.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                      height: 1.45,
                    ),
                  ),

                  const SizedBox(height: 22),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        'OK',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
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
  }

  String _orderIdGenerator() {
    final now = DateTime.now();

    final year = now.year.toString().padLeft(2, '0');
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    final second = now.second.toString().padLeft(2, '0');

    return '$year$month$day$hour$minute$second';
  }

  // ===========================================================================
  // photo click and upload logic
  // ===========================================================================

  Future<XFile?> _pickDemandPhoto(ImageSource source) async {
    try {
      final photo = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (photo == null) {
        debugPrint('No photo selected');
        return null;
      }

      // Image ko bytes mein read karo
      final imageBytes = await photo.readAsBytes();

      // Bytes ko Base64 String mein convert karo
      final base64Image = base64Encode(imageBytes);

      if (!mounted) return null;

      setState(() {
        _selectedDemandPhoto = photo;
        _selectedDemandPhotoBase64 = base64Image;
      });

      debugPrint('================================');
      debugPrint('DEMAND PHOTO SELECTED');
      debugPrint('================================');
      debugPrint('PATH: ${photo.path}');
      debugPrint('SOURCE: $source');
      debugPrint('IMAGE BYTES: ${imageBytes.length}');
      debugPrint('BASE64 LENGTH: ${base64Image.length}');
      debugPrint('BASE64 IMAGE:');
      debugPrint(base64Image);
      debugPrint('================================');

      return photo;
    } catch (e) {
      debugPrint('================================');
      debugPrint('DEMAND PHOTO PICK ERROR');
      debugPrint(e.toString());
      debugPrint('================================');

      return null;
    }
  }


  Future<void> _showDemandPhotoPopup() async {
    if (!mounted) return;

    XFile? dialogPhoto = _selectedDemandPhoto;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 24,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 18,
                    sigmaY: 18,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.8),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 30,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // =====================================================
                        // ICON
                        // =====================================================
                        Container(
                          width: 58,
                          height: 58,
                          decoration: const BoxDecoration(
                            color: lightBlue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: accentBlue,
                            size: 30,
                          ),
                        ),

                        const SizedBox(height: 14),

                        const Text(
                          'Demand Photo',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            color: deepBlue,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          'Photo is optional',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // =====================================================
                        // PHOTO PREVIEW
                        // =====================================================
                        if (dialogPhoto != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: SizedBox(
                              width: double.infinity,
                              height: 190,
                              child: Image.file(
                                File(dialogPhoto!.path),
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        else
                          Container(
                            width: double.infinity,
                            height: 150,
                            decoration: BoxDecoration(
                              color: lightBlue.withOpacity(0.55),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: accentBlue.withOpacity(0.15),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_a_photo_outlined,
                                  size: 42,
                                  color: accentBlue.withOpacity(0.65),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Add a photo',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 16),

                        // =====================================================
                        // CAMERA + PHOTOS
                        // =====================================================
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  final photo = await _pickDemandPhoto(
                                    ImageSource.camera,
                                  );

                                  if (photo != null) {
                                    dialogPhoto = _selectedDemandPhoto;

                                    setDialogState(() {});
                                  }
                                },
                                icon: const Icon(
                                  Icons.camera_alt_rounded,
                                ),
                                label: const Text('Camera'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: deepBlue,
                                  side: BorderSide(
                                    color: deepBlue.withOpacity(0.25),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 13,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  final photo = await _pickDemandPhoto(
                                    ImageSource.gallery,
                                  );

                                  if (photo != null) {
                                    dialogPhoto = _selectedDemandPhoto;

                                    setDialogState(() {});
                                  }
                                },
                                icon: const Icon(
                                  Icons.photo_library_outlined,
                                ),
                                label: const Text('Photos'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: deepBlue,
                                  side: BorderSide(
                                    color: deepBlue.withOpacity(0.25),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 13,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // =====================================================
                        // SKIP + OK
                        // =====================================================
                        Row(
                          children: [
                            // =================================================
                            // SKIP
                            // =================================================
                            Expanded(
                              child: TextButton(
                                onPressed: () {
                                  _selectedDemandPhoto = null;
                                  _selectedDemandPhotoBase64 = null;

                                  _demandPhotoPromptHandled = true;

                                  // Current dialog close
                                  Navigator.of(dialogContext).pop();

                                  // Next frame mein Remark popup
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    if (!mounted) return;

                                    _showDemandRemarkPopup();
                                  });
                                },
                                child: const Text(
                                  'SKIP',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),

                            // =================================================
                            // OK
                            // =================================================
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  // Selected photo save
                                  _selectedDemandPhoto = dialogPhoto;

                                  // Photo popup handled
                                  _demandPhotoPromptHandled = true;

                                  // =================================================
                                  // PHOTO SELECTED
                                  // =================================================
                                  if (dialogPhoto != null) {
                                    try {
                                      // Image -> Bytes
                                      final imageBytes =
                                      await dialogPhoto!.readAsBytes();

                                      // Bytes -> Base64
                                      final base64Image =
                                      base64Encode(imageBytes);

                                      // Base64 save
                                      _selectedDemandPhotoBase64 =
                                          base64Image;

                                      // Base64 -> Bytes
                                      final decodedBytes =
                                      base64Decode(base64Image);

                                      // =================================================
                                      // IMAGE PREVIEW
                                      // =================================================
                                      if (mounted) {
                                        await showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (previewContext) {
                                            // Preview ke andar current image
                                            // separately maintain hogi.
                                            XFile? previewPhoto =
                                                _selectedDemandPhoto;

                                            Uint8List? previewBytes =
                                                decodedBytes;

                                            return StatefulBuilder(
                                              builder: (
                                                  previewContext,
                                                  setPreviewState,
                                                  ) {
                                                return Dialog(
                                                  backgroundColor:
                                                  Colors.transparent,
                                                  elevation: 0,
                                                  insetPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: 24,
                                                  ),
                                                  child: Container(
                                                    padding:
                                                    const EdgeInsets.all(14),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                        22,
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(0.18),
                                                          blurRadius: 30,
                                                          offset:
                                                          const Offset(
                                                            0,
                                                            12,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Column(
                                                      mainAxisSize:
                                                      MainAxisSize.min,
                                                      children: [
                                                        const Text(
                                                          'Image Preview',
                                                          style: TextStyle(
                                                            fontSize: 19,
                                                            fontWeight:
                                                            FontWeight.w800,
                                                            color: deepBlue,
                                                          ),
                                                        ),

                                                        const SizedBox(
                                                          height: 14,
                                                        ),

                                                        // =================================
                                                        // IMAGE / NO IMAGE
                                                        // =================================
                                                        if (previewPhoto != null &&
                                                            previewBytes != null)
                                                          ClipRRect(
                                                            borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                              16,
                                                            ),
                                                            child:
                                                            Image.memory(
                                                              previewBytes!,
                                                              width: double
                                                                  .infinity,
                                                              height: 300,
                                                              fit: BoxFit.contain,
                                                            ),
                                                          )
                                                        else
                                                          Container(
                                                            width: double
                                                                .infinity,
                                                            height: 300,
                                                            decoration:
                                                            BoxDecoration(
                                                              color: lightBlue
                                                                  .withOpacity(
                                                                0.55,
                                                              ),
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                16,
                                                              ),
                                                              border:
                                                              Border.all(
                                                                color:
                                                                accentBlue
                                                                    .withOpacity(
                                                                  0.15,
                                                                ),
                                                              ),
                                                            ),
                                                            child: Column(
                                                              mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .image_not_supported_outlined,
                                                                  size: 55,
                                                                  color: Colors
                                                                      .grey
                                                                      .withOpacity(
                                                                    0.55,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  height: 10,
                                                                ),
                                                                Text(
                                                                  'No image selected',
                                                                  style:
                                                                  TextStyle(
                                                                    color: Colors
                                                                        .grey
                                                                        .shade600,
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),

                                                        const SizedBox(
                                                          height: 16,
                                                        ),

                                                        // =================================
                                                        // RETAKE + PHOTOS
                                                        // =================================
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child:
                                                              OutlinedButton
                                                                  .icon(
                                                                onPressed:
                                                                    () async {
                                                                  final newPhoto =
                                                                  await _pickDemandPhoto(
                                                                    ImageSource
                                                                        .camera,
                                                                  );

                                                                  if (newPhoto ==
                                                                      null ||
                                                                      !mounted) {
                                                                    return;
                                                                  }

                                                                  try {
                                                                    // New image
                                                                    // bytes
                                                                    final newBytes =
                                                                    await newPhoto
                                                                        .readAsBytes();

                                                                    // New image
                                                                    // Base64
                                                                    final newBase64 =
                                                                    base64Encode(
                                                                      newBytes,
                                                                    );

                                                                    // Old image
                                                                    // replace
                                                                    _selectedDemandPhoto =
                                                                        newPhoto;

                                                                    _selectedDemandPhotoBase64 =
                                                                        newBase64;

                                                                    // New preview
                                                                    previewPhoto =
                                                                        newPhoto;

                                                                    previewBytes =
                                                                        base64Decode(
                                                                          newBase64,
                                                                        );

                                                                    debugPrint(
                                                                      '================================',
                                                                    );
                                                                    debugPrint(
                                                                      'DEMAND PHOTO RETAKEN',
                                                                    );
                                                                    debugPrint(
                                                                      'PATH: ${newPhoto.path}',
                                                                    );
                                                                    debugPrint(
                                                                      'BASE64 UPDATED',
                                                                    );
                                                                    debugPrint(
                                                                      '================================',
                                                                    );

                                                                    // Preview close
                                                                    // NAHI hoga.
                                                                    // Same preview mein
                                                                    // new image dikhegi.
                                                                    setPreviewState(
                                                                          () {},
                                                                    );
                                                                  } catch (e) {
                                                                    debugPrint(
                                                                      '================================',
                                                                    );
                                                                    debugPrint(
                                                                      'RETAKE IMAGE ERROR',
                                                                    );
                                                                    debugPrint(
                                                                      e.toString(),
                                                                    );
                                                                    debugPrint(
                                                                      '================================',
                                                                    );
                                                                  }
                                                                },
                                                                icon: const Icon(
                                                                  Icons
                                                                      .camera_alt_rounded,
                                                                  size: 18,
                                                                ),
                                                                label:
                                                                const Text(
                                                                  'Retake',
                                                                ),
                                                                style:
                                                                OutlinedButton
                                                                    .styleFrom(
                                                                  foregroundColor:
                                                                  deepBlue,
                                                                  side:
                                                                  const BorderSide(
                                                                    color:
                                                                    deepBlue,
                                                                  ),
                                                                  padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                    vertical: 12,
                                                                  ),
                                                                  shape:
                                                                  RoundedRectangleBorder(
                                                                    borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                      13,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),

                                                            const SizedBox(
                                                              width: 10,
                                                            ),

                                                            Expanded(
                                                              child:
                                                              OutlinedButton
                                                                  .icon(
                                                                onPressed:
                                                                    () async {
                                                                  final newPhoto =
                                                                  await _pickDemandPhoto(
                                                                    ImageSource
                                                                        .gallery,
                                                                  );

                                                                  if (newPhoto ==
                                                                      null ||
                                                                      !mounted) {
                                                                    return;
                                                                  }

                                                                  try {
                                                                    // New image
                                                                    // bytes
                                                                    final newBytes =
                                                                    await newPhoto
                                                                        .readAsBytes();

                                                                    // New image
                                                                    // Base64
                                                                    final newBase64 =
                                                                    base64Encode(
                                                                      newBytes,
                                                                    );

                                                                    // Old image
                                                                    // replace
                                                                    _selectedDemandPhoto =
                                                                        newPhoto;

                                                                    _selectedDemandPhotoBase64 =
                                                                        newBase64;

                                                                    // New preview
                                                                    previewPhoto =
                                                                        newPhoto;

                                                                    previewBytes =
                                                                        base64Decode(
                                                                          newBase64,
                                                                        );

                                                                    debugPrint(
                                                                      '================================',
                                                                    );
                                                                    debugPrint(
                                                                      'DEMAND PHOTO CHANGED FROM PHOTOS',
                                                                    );
                                                                    debugPrint(
                                                                      'PATH: ${newPhoto.path}',
                                                                    );
                                                                    debugPrint(
                                                                      'BASE64 UPDATED',
                                                                    );
                                                                    debugPrint(
                                                                      '================================',
                                                                    );

                                                                    // Same preview
                                                                    // mein new image
                                                                    setPreviewState(
                                                                          () {},
                                                                    );
                                                                  } catch (e) {
                                                                    debugPrint(
                                                                      '================================',
                                                                    );
                                                                    debugPrint(
                                                                      'GALLERY IMAGE ERROR',
                                                                    );
                                                                    debugPrint(
                                                                      e.toString(),
                                                                    );
                                                                    debugPrint(
                                                                      '================================',
                                                                    );
                                                                  }
                                                                },
                                                                icon: const Icon(
                                                                  Icons
                                                                      .photo_library_outlined,
                                                                  size: 18,
                                                                ),
                                                                label:
                                                                const Text(
                                                                  'Photos',
                                                                ),
                                                                style:
                                                                OutlinedButton
                                                                    .styleFrom(
                                                                  foregroundColor:
                                                                  accentBlue,
                                                                  side:
                                                                  const BorderSide(
                                                                    color:
                                                                    accentBlue,
                                                                  ),
                                                                  padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                    vertical: 12,
                                                                  ),
                                                                  shape:
                                                                  RoundedRectangleBorder(
                                                                    borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                      13,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),

                                                        const SizedBox(
                                                          height: 8,
                                                        ),

                                                        // =================================
                                                        // REMOVE IMAGE
                                                        // =================================
                                                        if (previewPhoto != null)
                                                          SizedBox(
                                                            width:
                                                            double.infinity,
                                                            child:
                                                            TextButton.icon(
                                                              onPressed: () {
                                                                // =================================
                                                                // IMAGE REMOVE
                                                                // =================================
                                                                _selectedDemandPhoto =
                                                                null;

                                                                _selectedDemandPhotoBase64 =
                                                                null;

                                                                previewPhoto =
                                                                null;

                                                                previewBytes =
                                                                null;

                                                                debugPrint(
                                                                  '================================',
                                                                );
                                                                debugPrint(
                                                                  'DEMAND PHOTO REMOVED',
                                                                );
                                                                debugPrint(
                                                                  'PHOTO: null',
                                                                );
                                                                debugPrint(
                                                                  'BASE64: null',
                                                                );
                                                                debugPrint(
                                                                  '================================',
                                                                );

                                                                // IMPORTANT:
                                                                // Preview CLOSE NAHI HOGA.
                                                                // Sirf image remove hogi.
                                                                setPreviewState(
                                                                      () {},
                                                                );
                                                              },
                                                              icon: const Icon(
                                                                Icons
                                                                    .delete_outline_rounded,
                                                                color:
                                                                Colors.red,
                                                                size: 20,
                                                              ),
                                                              label: const Text(
                                                                'Remove Image',
                                                                style: TextStyle(
                                                                  color:
                                                                  Colors.red,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                                ),
                                                              ),
                                                            ),
                                                          ),

                                                        const SizedBox(
                                                          height: 4,
                                                        ),

                                                        // =================================
                                                        // OK
                                                        // =================================
                                                        SizedBox(
                                                          width:
                                                          double.infinity,
                                                          child:
                                                          ElevatedButton(
                                                            onPressed: () {
                                                              // Preview close
                                                              Navigator.of(
                                                                previewContext,
                                                              ).pop();

                                                              // Remark popup
                                                              // next frame
                                                              WidgetsBinding
                                                                  .instance
                                                                  .addPostFrameCallback(
                                                                    (_) {
                                                                  if (!mounted) {
                                                                    return;
                                                                  }

                                                                  _showDemandRemarkPopup();
                                                                },
                                                              );
                                                            },
                                                            style: ElevatedButton
                                                                .styleFrom(
                                                              backgroundColor:
                                                              deepBlue,
                                                              foregroundColor:
                                                              Colors.white,
                                                              elevation: 0,
                                                              padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                vertical: 13,
                                                              ),
                                                              shape:
                                                              RoundedRectangleBorder(
                                                                borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                  14,
                                                                ),
                                                              ),
                                                            ),
                                                            child: const Text(
                                                              'Submit',
                                                              style: TextStyle(
                                                                fontWeight:
                                                                FontWeight
                                                                    .w700,
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
                                          },
                                        );
                                      }
                                    } catch (e) {
                                      debugPrint(
                                        '================================',
                                      );
                                      debugPrint(
                                        'PHOTO BASE64 CONVERSION ERROR',
                                      );
                                      debugPrint(
                                        e.toString(),
                                      );
                                      debugPrint(
                                        '================================',
                                      );
                                    }
                                  } else {
                                    debugPrint(
                                      '================================',
                                    );
                                    debugPrint(
                                      'DEMAND PHOTO - OK CLICKED',
                                    );
                                    debugPrint(
                                      'NO PHOTO SELECTED',
                                    );
                                    debugPrint(
                                      '================================',
                                    );
                                  }

                                  // Original photo popup close
                                  Navigator.of(dialogContext).pop();

                                  // Agar photo nahi hai
                                  // to Remark popup
                                  if (dialogPhoto == null) {
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                      if (!mounted) return;

                                      _showDemandRemarkPopup();
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: deepBlue,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 13,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text(
                                  'Submit',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }


// ===========================================================================
// DEMAND REMARK POPUP
// ===========================================================================

  Future<void> _showDemandRemarkPopup() async {
    if (!mounted) return;

    final remarkController = TextEditingController(text: _demandRemark);

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 18,
                sigmaY: 18,
              ),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.94),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.8),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 30,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: const BoxDecoration(
                        color: lightBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit_note_rounded,
                        color: accentBlue,
                        size: 30,
                      ),
                    ),

                    const SizedBox(height: 14),

                    const Text(
                      'Remark',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: deepBlue,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'Enter your remark',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 18),

                    TextField(
                      controller: remarkController,
                      maxLength: 150,
                      maxLines: 4,
                      minLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Enter remark...',
                        filled: true,
                        fillColor: lightBlue.withOpacity(0.55),
                        contentPadding: const EdgeInsets.all(16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: accentBlue.withOpacity(0.15),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: accentBlue.withOpacity(0.15),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: accentBlue,
                            width: 1.3,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              Navigator.pop(dialogContext);
                            },
                            child: const Text(
                              'CANCEL',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final remark =
                              remarkController.text.trim();

                              // ==================================================
                              // SAVE REMARK
                              // ==================================================

                              _demandRemark = remark;

                              debugPrint(
                                '================================',
                              );
                              debugPrint('DEMAND REMARK');
                              debugPrint(
                                '================================',
                              );
                              debugPrint(
                                'REMARK: $_demandRemark',
                              );
                              debugPrint(
                                'REMARK LENGTH: ${_demandRemark.length}',
                              );
                              debugPrint(
                                '================================',
                              );

                              // ==================================================
                              // CLOSE REMARK POPUP
                              // ==================================================

                              Navigator.pop(dialogContext);

                              // ==================================================
                              // GENERATE XML ONLY AFTER REMARK OK
                              // ==================================================

                              xmlstr = await _buildOrderXml();

                              if (_demandPhotoPromptHandled && xmlstr.trim().isNotEmpty) {
                                await _submitOrderToServer();
                                return;
                              }



                              debugPrint(
                                '================================',
                              );
                              debugPrint(
                                'XML GENERATED AFTER REMARK OK',
                              );
                              debugPrint(
                                '================================',
                              );

                             // await _submitOrderToServer();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: deepBlue,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                vertical: 13,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Submit',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    // Important:
    // Controller ko yahan dispose NAHI kar rahe.
  }

// ===========================================================================
// BUILD ORDER XML
// ===========================================================================

  Future<String> _buildOrderXml() async {
    // ==========================================================
    // ORDER ID
    // ==========================================================

    final orderId = _orderIdGenerator();

    // ==========================================================
    // IMEI
    // ==========================================================

    final imei = await PreferenceService.getDeviceImei();

    // ==========================================================
    // SHIFT CODE
    // ==========================================================

    String getShiftCode(String selectedShift) {
      switch (selectedShift) {
        case 'Morning Shift':
          return 'M';

        case 'Evening Shift':
          return 'E';

        default:
          return '';
      }
    }

    final shiftCode = getShiftCode(_selectedShift);

    // ==========================================================
    // XML START
    // ==========================================================

    String xmlstr = '';

    xmlstr =
    "<?xml version='1.0'?><itemdata><recdata>";

    // ==========================================================
    // PRODUCTS
    // ==========================================================

    for (final category in _categories) {
      for (final product in category.products) {
        final quantity =
            _quantities[product.prdcode] ?? 0;

        if (quantity <= 0) {
          continue;
        }

        // ========================================================
        // PRODUCT XML
        // ========================================================

        xmlstr +=
        '<orderid>$orderId</orderid>';

        xmlstr +=
        '<IMEI>${imei ?? ''}</IMEI>';

        xmlstr +=
        '<Accode>${widget.customer.custcode}</Accode>';

        xmlstr +=
        '<Shift>$shiftCode</Shift>';

        xmlstr +=
        '<Prdcode>${product.prdcode}</Prdcode>';

        xmlstr +=
        '<OrderDate>${_formatDate(_selectedDate)}</OrderDate>';

        xmlstr +=
        '<Quantity>$quantity</Quantity>';

        xmlstr +=
        '<adv>0</adv>';

        xmlstr +=
        '<remark/>';

        xmlstr +=
        '<img/>';

        // ========================================================
        // PRODUCT DEBUG
        // ========================================================

        debugPrint(
          '================================',
        );
        debugPrint(
          'SUBMIT DEMAND ORDER',
        );
        debugPrint(
          '================================',
        );

        debugPrint(
          'orderid : $orderId',
        );

        debugPrint(
          'IMEI : ${imei ?? ''}',
        );

        debugPrint(
          'Accode : ${widget.customer.custcode}',
        );

        debugPrint(
          'Shift : $shiftCode',
        );

        debugPrint(
          'OrderDate : ${_formatDate(_selectedDate)}',
        );

        debugPrint(
          'Prdcode : ${product.prdcode}',
        );

        debugPrint(
          'Quantity : $quantity',
        );

        debugPrint(
          'adv : 0',
        );

        debugPrint(
          'remark : 0',
        );

        debugPrint(
          'img : 0',
        );
      }
    }

    // ==========================================================
    // CLOSE REC DATA
    // ==========================================================

    xmlstr += '</recdata>';

    // ==========================================================
    // FINAL REMARK
    // ==========================================================

    xmlstr +=
    '<remarks>$_demandRemark</remarks>';

    // ==========================================================
    // FINAL IMAGE
    // ==========================================================

    xmlstr +=
    '<image>${_selectedDemandPhotoBase64 ?? ''}</image>';

    // ==========================================================
    // CLOSE ITEM DATA
    // ==========================================================

    xmlstr += '</itemdata>';

    // ==========================================================
    // FINAL XML DEBUG
    // ==========================================================

    debugPrint(
      '================================',
    );
    debugPrint(
      'FINAL XML',
    );
    debugPrint(
      '================================',
    );
   // debugPrint(xmlstr);
    debugPrint(
      '================================',
    );

    // // ==========================================================
    // // CHUNK DEBUG
    // // ==========================================================
    //
    // const int chunkSize = 800;
    //
    // for (
    // int i = 0;
    // i < xmlstr.length;
    // i += chunkSize
    // ) {
    //   final end =
    //   (i + chunkSize < xmlstr.length)
    //       ? i + chunkSize
    //       : xmlstr.length;
    //
    //   debugPrint(
    //     xmlstr.substring(i, end),
    //   );
    // }

    debugPrint('================================');
    debugPrint('FINAL XML GENERATED');
    debugPrint('XML LENGTH: ${xmlstr.length}');
    debugPrint(
      'IMAGE ATTACHED: ${_selectedDemandPhotoBase64 != null}',
    );
    debugPrint('================================');

    debugPrint(
      '================================',
    );

    // ==========================================================
    // RETURN XML
    // ==========================================================

    return xmlstr;
  }

// ===========================================================================
// SUBMIT ORDER
// ===========================================================================

  Future<void> _submitOrder() async {
    final isValidShift = await _validateShift();

    if (!isValidShift) {
      return;
    }

    // ==========================================================
    // ORDER ALREADY APPROVED
    // ==========================================================

    if (_orderAlreadyApproved) {
      await _showOrderAlreadyApprovedPopup();
      return;
    }

    // ==========================================================
    // FIRST SUBMIT
    // Photo + Remark popup open hoga
    // ==========================================================

    //if (!_demandPhotoPromptHandled) {
      await _showDemandPhotoPopup();
    //}

    // ==========================================================
    // SECOND SUBMIT
    // XML already generated hai
    // Ab API call hogi
    // ==========================================================

    /*if (_demandPhotoPromptHandled && xmlstr.trim().isNotEmpty) {
      await _submitOrderToServer();
      return;
    }*/
  }

  // Future<void> _submitOrderToServer() async {
  //
  //   if (_isSubmittingOrder) return;
  //
  //   setState(() {
  //     _isSubmittingOrder = true;
  //   });
  //
  //   debugPrint('================================');
  //   debugPrint('SUBMIT ORDER TO SERVER');
  //   debugPrint('================================');
  //
  //   debugPrint('XML LENGTH: ${xmlstr.length}');
  //   //debugPrint('XML: $xmlstr');
  //
  //   final result = await DemandOrderService.submitOrder(
  //     xmlstr: xmlstr,
  //   );
  //
  //   if (!mounted) return;
  //
  //   debugPrint('================================');
  //   debugPrint('SUBMIT ORDER API RESULT');
  //   debugPrint('RESULT: $result');
  //   debugPrint('================================');
  //
  //   if (result == null) {
  //     debugPrint('SUBMIT ORDER: NULL RESPONSE');
  //
  //     await _showSubmitOrderErrorPopup(
  //       'Something went wrong from server',
  //     );
  //
  //     return;
  //   }
  //
  //   final statusCode = result['statusCode'];
  //   final responseBody = result['body'] ?? '';
  //
  //   debugPrint('STATUS CODE: $statusCode');
  //   debugPrint('RESPONSE BODY: $responseBody');
  //
  //   // ==========================================================
  //   // HTTP ERROR / EMPTY RESPONSE
  //   // ==========================================================
  //
  //   if (statusCode != 200 || responseBody.toString().trim().isEmpty) {
  //     await _showSubmitOrderErrorPopup(
  //       'Something went wrong from server',
  //     );
  //     return;
  //   }
  //
  //   // ==========================================================
  //   // RESPONSE JSON
  //   // ==========================================================
  //
  //   try {
  //     final decoded = jsonDecode(responseBody);
  //
  //     if (decoded is! Map) {
  //       await _showSubmitOrderErrorPopup(
  //         'Something went wrong from server',
  //       );
  //       return;
  //     }
  //
  //     final response = Map<String, dynamic>.from(decoded);
  //
  //     final message = response['msg']?.toString().trim() ?? '';
  //     final status = response['status']?.toString().trim() ?? '';
  //
  //     debugPrint('MESSAGE: $message');
  //     debugPrint('STATUS: $status');
  //
  //     // ========================================================
  //     // SUCCESS
  //     // ========================================================
  //
  //     if (status == 'success' &&
  //         message == 'Order Submitted Successfully') {
  //       await _showSubmitOrderSuccessPopup(message);
  //       return;
  //     }
  //
  //     // ========================================================
  //     // ORDER BEYOND TIME
  //     // ========================================================
  //
  //     if (message.contains('Order Beyond Time')) {
  //       await _showSubmitOrderErrorPopup(
  //         message,
  //         showRetry: false,
  //       );
  //       return;
  //     }
  //
  //     // ========================================================
  //     // OTHER SERVER MESSAGE
  //     // ========================================================
  //
  //     await _showSubmitOrderErrorPopup(
  //       message.isNotEmpty
  //           ? message
  //           : 'Something went wrong from server',
  //     );
  //   } catch (e) {
  //     debugPrint('SUBMIT ORDER JSON PARSE ERROR: $e');
  //
  //     await _showSubmitOrderErrorPopup(
  //       'Something went wrong from server',
  //     );
  //   }
  // }

  Future<void> _submitOrderToServer() async {
    if (_isSubmittingOrder) return;

    setState(() {
      _isSubmittingOrder = true;
    });

    try {
      debugPrint('================================');
      debugPrint('SUBMIT ORDER TO SERVER');
      debugPrint('================================');

      debugPrint('XML LENGTH: ${xmlstr.length}');
      //debugPrint('XML: $xmlstr');

      final result = await DemandOrderService.submitOrder(
        xmlstr: xmlstr,
      );

      if (!mounted) return;

      debugPrint('================================');
      debugPrint('SUBMIT ORDER API RESULT');
      debugPrint('RESULT: $result');
      debugPrint('================================');

      if (result == null) {
        debugPrint('SUBMIT ORDER: NULL RESPONSE');

        await _showSubmitOrderErrorPopup(
          'Something went wrong from server',
        );

        return;
      }

      final statusCode = result['statusCode'];
      final responseBody = result['body'] ?? '';

      debugPrint('STATUS CODE: $statusCode');
      debugPrint('RESPONSE BODY: $responseBody');

      // ==========================================================
      // HTTP ERROR / EMPTY RESPONSE
      // ==========================================================

      if (statusCode != 200 ||
          responseBody.toString().trim().isEmpty) {
        await _showSubmitOrderErrorPopup(
          'Something went wrong from server',
        );
        return;
      }

      // ==========================================================
      // RESPONSE JSON
      // ==========================================================

      try {
        final decoded = jsonDecode(responseBody);

        if (decoded is! Map) {
          await _showSubmitOrderErrorPopup(
            'Something went wrong from server',
          );
          return;
        }

        final response = Map<String, dynamic>.from(decoded);

        final message = response['msg']?.toString().trim() ?? '';
        final status = response['status']?.toString().trim() ?? '';

        debugPrint('MESSAGE: $message');
        debugPrint('STATUS: $status');

        // ========================================================
        // SUCCESS
        // ========================================================

        if (status == 'success' &&
            message == 'Order Submitted Successfully') {
          debugPrint('================================');
          debugPrint('ORDER SUBMITTED SUCCESSFULLY');
          debugPrint('CALLING TARGET API');
          debugPrint('================================');


          // Order API complete ho gayi.
          // Target Bottom Sheet se pehle background loader hide karo.
          if (mounted) {
            setState(() {
              _isSubmittingOrder = false;
            });
          }

          await _checkTargetAndShowBottomSheet();

          return;
        }

        // ========================================================
        // ORDER BEYOND TIME
        // ========================================================

        if (message.contains('Order Beyond Time')) {
          await _showSubmitOrderErrorPopup(
            message,
            showRetry: false,
          );
          return;
        }

        // ========================================================
        // OTHER SERVER MESSAGE
        // ========================================================

        await _showSubmitOrderErrorPopup(
          message.isNotEmpty
              ? message
              : 'Something went wrong from server',
        );
      } catch (e) {
        debugPrint('SUBMIT ORDER JSON PARSE ERROR: $e');

        await _showSubmitOrderErrorPopup(
          'Something went wrong from server',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingOrder = false;
        });
      }
    }
  }

  Future<void> _showSubmitOrderSuccessPopup(String message) async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (dialogContext) {
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 10,
            sigmaY: 10,
          ),
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 28,
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                24,
                28,
                24,
                22,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.97),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 35,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ==========================================================
                  // SUCCESS ICON
                  // ==========================================================

                  Container(
                    width: 78,
                    height: 78,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.10),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_outline_rounded,
                      color: Colors.green,
                      size: 46,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ==========================================================
                  // TITLE
                  // ==========================================================

                  const Text(
                    'Order Submitted',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: deepBlue,
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ==========================================================
                  // MESSAGE
                  // ==========================================================

                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 26),

                  // ==========================================================
                  // OK BUTTON
                  // ==========================================================

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        'OK',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
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
  }

  Future<void> _checkTargetAndShowBottomSheet() async {
    if (!mounted) return;

    debugPrint('================================');
    debugPrint('CHECKING TARGET');
    debugPrint('CUSTOMER CODE: ${widget.customer.custcode}');
    debugPrint(
      'ORDER DATE: ${_formatDate(_selectedDate)}',
    );
    debugPrint('================================');

    final targetResult = await DemandOrderService.checkTarget(
      distCode: widget.customer.custcode,
      odate: _formatDate(_selectedDate),
    );

    if (!mounted) return;

    debugPrint('================================');
    debugPrint('TARGET API RESULT');
    debugPrint('TARGET RESULT: $targetResult');
    debugPrint('================================');

    if (targetResult == null) {
      await _showSubmitOrderErrorPopup(
        'Something went wrong from server',
      );
      return;
    }

    await _showTargetBottomSheet(targetResult);
  }

  Widget _buildTargetSuccessAnimation() {
    final controller = _targetAnimationController;

    // Controller abhi initialize nahi hua hai
    if (controller == null) {
      return const SizedBox(
        width: double.infinity,
        height: 175,
        child: Center(
          child: Text(
            '😊',
            style: TextStyle(
              fontSize: 72,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 175,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          final progress = controller.value;

          final wave1 =
          math.sin(progress * 2 * math.pi);

          final wave2 =
          math.sin(
            (progress + 0.25) * 2 * math.pi,
          );

          final wave3 =
          math.sin(
            (progress + 0.50) * 2 * math.pi,
          );

          final wave4 =
          math.sin(
            (progress + 0.75) * 2 * math.pi,
          );

          final smileScale =
              1.0 +
                  (math.sin(progress * 2 * math.pi) * 0.08);

          return Stack(
            alignment: Alignment.center,
            children: [
              // 🎈 BALLOON 1
              Transform.translate(
                offset: Offset(
                  wave1 * 12 - 65,
                  -progress * 120 + 60,
                ),
                child: Transform.rotate(
                  angle: wave1 * 0.15,
                  child: const Text(
                    '🎈',
                    style: TextStyle(
                      fontSize: 44,
                    ),
                  ),
                ),
              ),

              // 🎈 BALLOON 2
              Transform.translate(
                offset: Offset(
                  wave2 * 10 - 35,
                  -progress * 135 + 75,
                ),
                child: Transform.rotate(
                  angle: wave2 * 0.12,
                  child: const Text(
                    '🎈',
                    style: TextStyle(
                      fontSize: 38,
                    ),
                  ),
                ),
              ),

              // 🎈 BALLOON 3
              Transform.translate(
                offset: Offset(
                  wave3 * 11 + 35,
                  -progress * 130 + 70,
                ),
                child: Transform.rotate(
                  angle: wave3 * 0.14,
                  child: const Text(
                    '🎈',
                    style: TextStyle(
                      fontSize: 40,
                    ),
                  ),
                ),
              ),

              // 🎈 BALLOON 4
              Transform.translate(
                offset: Offset(
                  wave4 * 13 + 65,
                  -progress * 120 + 60,
                ),
                child: Transform.rotate(
                  angle: wave4 * 0.16,
                  child: const Text(
                    '🎈',
                    style: TextStyle(
                      fontSize: 45,
                    ),
                  ),
                ),
              ),

              // ✨ LEFT SPARKLE
              Transform.translate(
                offset: Offset(
                  wave2 * 8 - 85,
                  wave1 * 12 - 35,
                ),
                child: const Text(
                  '✨',
                  style: TextStyle(
                    fontSize: 26,
                  ),
                ),
              ),

              // ✨ RIGHT SPARKLE
              Transform.translate(
                offset: Offset(
                  wave3 * 8 + 85,
                  wave2 * 12 - 30,
                ),
                child: const Text(
                  '✨',
                  style: TextStyle(
                    fontSize: 25,
                  ),
                ),
              ),

              // 🎉 CELEBRATION
              Transform.translate(
                offset: Offset(
                  wave1 * 8 + 75,
                  wave3 * 8 - 10,
                ),
                child: const Text(
                  '🎉',
                  style: TextStyle(
                    fontSize: 28,
                  ),
                ),
              ),

              // 😊 MAIN SMILE
              Transform.scale(
                scale: smileScale,
                child: const Text(
                  '😊',
                  style: TextStyle(
                    fontSize: 72,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showTargetBottomSheet(
      Map<String, dynamic> targetResult,
      ) async {
    if (!mounted) return;

    final status = targetResult['status']?.toString().trim() ?? '';
    final message = targetResult['message']?.toString().trim() ?? '';
    final targetAch = targetResult['targetach']?.toString().trim() ?? '';

    // ==========================================================
    // STATUS CHECK
    // ==========================================================

    if (status != '1') {
      await _showSubmitOrderErrorPopup(
        message.isNotEmpty
            ? message
            : 'Something went wrong from server',
      );
      return;
    }

    // ==========================================================
    // TARGET DATA
    // ==========================================================

    final targetData = targetResult['TARGET'] is Map
        ? Map<String, dynamic>.from(targetResult['TARGET'])
        : <String, dynamic>{};

    // ==========================================================
    // ACHIEVEMENT DATA
    // ==========================================================

    final achievementData = targetResult['ACH'] is Map
        ? Map<String, dynamic>.from(targetResult['ACH'])
        : <String, dynamic>{};

    // ==========================================================
    // COMBINE KEYS
    // ==========================================================

    final keys = <String>{
      ...targetData.keys,
      ...achievementData.keys,
    }.toList();

    // ==========================================================
    // BOTTOM SHEET
    // ==========================================================

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.45),
      enableDrag: false,
      builder: (bottomSheetContext) {
        final isAchieved = targetAch == '1';

        return SafeArea(
          top: false,
          child: Container(
            width: double.infinity,

            constraints: const BoxConstraints(
              maxHeight: 620,
            ),

            padding: const EdgeInsets.fromLTRB(
              20,
              12,
              20,
              20,
            ),

            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(30),
              ),
            ),

            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  // ==================================================
                  // TOP HANDLE
                  // ==================================================

                  Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ==================================================
                  // SUCCESS / FAILURE ANIMATION
                  // ==================================================

                  if (isAchieved)
                    _buildTargetSuccessAnimation()
                  else
                    const Padding(
                      padding: EdgeInsets.only(
                        top: 12,
                        bottom: 8,
                      ),
                      child: Text(
                        '😢',
                        style: TextStyle(
                          fontSize: 52,
                        ),
                      ),
                    ),

                  // ==================================================
                  // TITLE
                  // ==================================================

                  Text(
                    isAchieved
                        ? 'Target Achieved!'
                        : 'Target Not Achieved',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: deepBlue,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ==================================================
                  // MESSAGE
                  // ==================================================

                  Text(
                    message.isNotEmpty
                        ? message
                        : 'Something went wrong from server',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),

                  // ==================================================
                  // TARGET TABLE
                  // ==================================================

                  if (!isAchieved && keys.isNotEmpty) ...[
                    const SizedBox(height: 22),

                    Container(
                      width: double.infinity,

                      decoration: BoxDecoration(
                        color: const Color(0xFFF7FBFE),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: deepBlue.withOpacity(0.10),
                        ),
                      ),

                      child: Column(
                        children: [

                          // ==================================================
                          // TABLE HEADER
                          // ==================================================

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 13,
                            ),

                            decoration: BoxDecoration(
                              color: deepBlue.withOpacity(0.06),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(18),
                              ),
                            ),

                            child: const Row(
                              children: [

                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'PRODUCT',
                                    style: TextStyle(
                                      color: deepBlue,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),

                                Expanded(
                                  child: Text(
                                    'TARGET',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: deepBlue,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),

                                Expanded(
                                  child: Text(
                                    'ACHIEVEMENT',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: deepBlue,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // ==================================================
                          // TABLE ROWS
                          // ==================================================

                          ...keys.map(
                                (key) {
                              final targetValue =
                                  targetData[key]?.toString() ?? '-';

                              final achievementValue =
                                  achievementData[key]?.toString() ?? '-';

                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 13,
                                ),

                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                ),

                                child: Row(
                                  children: [

                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        key,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.grey.shade800,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),

                                    Expanded(
                                      child: Text(
                                        targetValue,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: deepBlue,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),

                                    Expanded(
                                      child: Text(
                                        achievementValue,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: accentBlue,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // ==================================================
                  // OK BUTTON
                  // ==================================================

                  SizedBox(
                    width: double.infinity,
                    height: 50,

                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(
                          bottomSheetContext,
                        );
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),

                      child: const Text(
                        'OK',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
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
  }

  // Future<void> _showSubmitOrderErrorPopup(
  //     String message, {
  //       bool showRetry = true,
  //     }) async {
  //   if (!mounted) return;
  //
  //   await showDialog<void>(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (dialogContext) {
  //       return AlertDialog(
  //         title: const Text('Order Submission'),
  //         content: Text(message),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.pop(dialogContext);
  //             },
  //             child: const Text('OK'),
  //           ),
  //           if (showRetry)
  //           ElevatedButton(
  //           onPressed: () async {
  //       Navigator.pop(dialogContext);
  //
  //       await _submitOrderToServer();
  //       },
  //       child: const Text('RETRY'),
  //       ),
  //         ],
  //       );
  //     },
  //   );
  // }

  Future<void> _showSubmitOrderErrorPopup(
      String message, {
        bool showRetry = true,
      }) async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (dialogContext) {
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 10,
            sigmaY: 10,
          ),
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 28,
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                24,
                26,
                24,
                22,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.97),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 35,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ==========================================================
                  // ICON
                  // ==========================================================

                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.09),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.error_outline_rounded,
                      color: Colors.redAccent,
                      size: 40,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ==========================================================
                  // TITLE
                  // ==========================================================

                  const Text(
                    'Order Submission',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: deepBlue,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ==========================================================
                  // MESSAGE
                  // ==========================================================

                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ==========================================================
                  // BUTTONS
                  // ==========================================================

                  Row(
                    children: [
                      if (showRetry) ...[
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pop(dialogContext);
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: deepBlue,
                                side: BorderSide(
                                  color: deepBlue.withOpacity(0.20),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(15),
                                ),
                              ),
                              child: const Text(
                                'OK',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),
                      ],

                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () async {
                              Navigator.pop(dialogContext);

                              if (showRetry) {
                                await _submitOrderToServer();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentBlue,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(15),
                              ),
                            ),
                            child: Text(
                              showRetry ? 'RETRY' : 'OK',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ===========================================================================
  // CONNECTION ERROR POPUP
  // ===========================================================================

  Future<void> _showConnectionErrorPopup() async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (dialogContext) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.96),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.cloud_off_rounded,
                      color: Colors.redAccent,
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Connection Error',
                    style: TextStyle(
                      color: deepBlue,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    'Something went wrong\nfrom server',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        'OK',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
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

    if (!mounted) return;

    setState(() {
      _hasProductError = true;
    });
  }

  // ===========================================================================
  // DATE logic implementation
  // ===========================================================================

  final AutoDatetime _autoDatetimePlugin = AutoDatetime();

  // ---------------------------------------------------------------------------
  // CHECK AUTOMATIC DATE & TIME
  // ---------------------------------------------------------------------------

  Future<bool> _isDeviceDateTimeAutomatic() async {
    try {
      final isAutomatic = await _autoDatetimePlugin
          .isAutomaticDateTimeEnabled();

      debugPrint('Automatic Date & Time: ${isAutomatic ? 'ON' : 'OFF'}');

      return isAutomatic;
    } catch (e) {
      debugPrint('Automatic Date & Time check failed: $e');

      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // DATE & TIME REQUIRED POPUP
  // ---------------------------------------------------------------------------

  Future<void> _showDateTimeSettingsPopup() async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Date & Time Required',
            style: TextStyle(
              color: deepBlue,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: const Text(
            'Please enable automatic date & time '
            'on your device before selecting '
            'the order date.',
            style: TextStyle(color: Colors.black87, fontSize: 14, height: 1.45),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'CANCEL',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await _openDateTimeSettings();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: accentBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'SETTINGS',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // OPEN DATE & TIME SETTINGS
  // ---------------------------------------------------------------------------

  Future<void> _openDateTimeSettings() async {
    try {
      await AppSettings.openAppSettings(type: AppSettingsType.date);
    } catch (e) {
      debugPrint('Unable to open Date & Time settings: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // SELECT ORDER DATE
  // ---------------------------------------------------------------------------

  Future<void> _selectDate() async {
    // ============================================================
    // 1. CHECK AUTOMATIC DATE & TIME
    // ============================================================

    final isAutomatic = await _isDeviceDateTimeAutomatic();

    if (!isAutomatic) {
      await _showDateTimeSettingsPopup();
      return;
    }

    // ============================================================
    // 2. EXISTING DATE VALIDATION
    // ============================================================

    final now = DateTime.now();

    final currentDate = DateTime(now.year, now.month, now.day);

    final maxDate = currentDate.add(const Duration(days: 2));

    DateTime initialDate = _selectedDate;

    if (initialDate.isBefore(currentDate) || initialDate.isAfter(maxDate)) {
      initialDate = currentDate;
    }

    // ============================================================
    // 3. DATE PICKER
    // ============================================================

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: currentDate,
      lastDate: maxDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: accentBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: deepBlue,
            ),
          ),
          child: child!,
        );
      },
    );

    // ============================================================
    // 4. SAVE SELECTED DATE
    // ============================================================

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  // ---------------------------------------------------------------------------
  // APP RESUME - RETURN FROM SETTINGS
  // ---------------------------------------------------------------------------

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      _refreshDateAfterSettings();
    }
  }

  // ---------------------------------------------------------------------------
  // REFRESH DATE AFTER RETURNING FROM SETTINGS
  // ---------------------------------------------------------------------------

  Future<void> _refreshDateAfterSettings() async {
    final isAutomatic = await _isDeviceDateTimeAutomatic();

    if (!isAutomatic || !mounted) {
      return;
    }

    final now = DateTime.now();

    final currentDate = DateTime(now.year, now.month, now.day);

    setState(() {
      _selectedDate = currentDate;
    });

    debugPrint(
      'Date refreshed after settings: '
      '${_formatDate(currentDate)}',
    );
  }


  // ===========================================================================
// REPEAT YESTERDAY
// ===========================================================================

  Future<void> _repeatYesterday() async {
    try {
      // ------------------------------------------------------------
      // 1. SHIFT VALIDATION
      // ------------------------------------------------------------

      if (_selectedShift == 'Select Shift') {
        await _showShiftRequiredPopup();
        return;
      }

      // ------------------------------------------------------------
      // 2. GET SHIFT CODE
      // ------------------------------------------------------------

      final shiftCode = _selectedShift == 'Morning Shift'
          ? 'M'
          : _selectedShift == 'Evening Shift'
          ? 'E'
          : '';

      if (shiftCode.isEmpty) {
        return;
      }

      // ------------------------------------------------------------
      // 3. GET DISTRIBUTOR CODE
      // ------------------------------------------------------------

      final distCode = widget.customer.custcode.toString();

      debugPrint('================================');
      debugPrint('REPEAT YESTERDAY');
      debugPrint('DISTCODE: $distCode');
      debugPrint('SHIFT: $shiftCode');
      debugPrint('================================');

      // ------------------------------------------------------------
      // 4. SHOW LOADING
      // ------------------------------------------------------------

      if (!mounted) return;

      setState(() {
        _isRepeatingYesterday = true;
      });

      // ------------------------------------------------------------
      // 5. CALL API
      // ------------------------------------------------------------

      final response = await DemandOrderService.repeatYesterday(
        distCode: distCode,
        shift: shiftCode,
      );

      // ------------------------------------------------------------
      // 6. API ERROR
      // ------------------------------------------------------------

      if (response == null) {
        if (!mounted) return;

        setState(() {
          _isRepeatingYesterday = false;
        });

        await _showConnectionErrorPopup();
        return;
      }

      debugPrint('================================');
      debugPrint('REPEAT YESTERDAY RESPONSE');
      debugPrint(response);
      debugPrint('================================');

      // ------------------------------------------------------------
      // 7. DECODE JSON
      // ------------------------------------------------------------

      final decoded = jsonDecode(response);

      if (decoded is! Map<String, dynamic>) {
        debugPrint('REPEAT YESTERDAY INVALID RESPONSE FORMAT');

        if (!mounted) return;

        setState(() {
          _isRepeatingYesterday = false;
        });

        await _showRepeatYesterdayMessage(
          'Invalid response received from server.',
        );

        return;
      }

      // ------------------------------------------------------------
      // 8. CHECK MESSAGE
      // ------------------------------------------------------------

      final message = (decoded['msg'] ?? '').toString().trim();

      debugPrint('REPEAT YESTERDAY MSG: $message');

      if (message.toLowerCase() != 'success') {
        if (!mounted) return;

        setState(() {
          _isRepeatingYesterday = false;
        });

        await _showRepeatYesterdayMessage(
          message.isEmpty ? 'No Order Found!' : message,
        );

        return;
      }

      // ------------------------------------------------------------
      // 9. GET TOP GROUPS
      // ------------------------------------------------------------

      final topGroups = decoded['topgroups'];

      if (topGroups is! List) {
        debugPrint('REPEAT YESTERDAY TOPGROUPS NOT FOUND');

        if (!mounted) return;

        setState(() {
          _isRepeatingYesterday = false;
        });

        await _showRepeatYesterdayMessage('No Order Found!');

        return;
      }

      // ------------------------------------------------------------
      // 10. GET CURRENT PRODUCT CODES
      // ------------------------------------------------------------

      final availableProductCodes = _categories
          .expand((category) => category.products)
          .map((product) => product.prdcode)
          .toSet();

      debugPrint(
        'AVAILABLE CURRENT PRODUCTS: ${availableProductCodes.length}',
      );

      // ------------------------------------------------------------
      // 11. PREPARE YESTERDAY QUANTITIES
      // ------------------------------------------------------------

      final Map<int, int> repeatedQuantities = {};

      for (final group in topGroups) {
        final groupName = group.toString();

        final groupProducts = decoded[groupName];

        if (groupProducts is! List) {
          continue;
        }

        for (final item in groupProducts) {
          if (item is! Map) {
            continue;
          }

          final prdcode = int.tryParse(
            (item['prdcode'] ?? '').toString(),
          );

          final quantity = int.tryParse(
            (item['qty'] ?? '0').toString(),
          );

          if (prdcode == null || quantity == null) {
            continue;
          }

          // --------------------------------------------------------
          // Product current product list mein hai?
          // --------------------------------------------------------

          if (!availableProductCodes.contains(prdcode)) {
            debugPrint(
              'REPEAT PRODUCT NOT FOUND: $prdcode',
            );
            continue;
          }

          final safeQuantity = quantity.clamp(0, 999);

          repeatedQuantities[prdcode] = safeQuantity;

          debugPrint(
            'REPEAT PRODUCT MATCHED | '
                'PRDCODE: $prdcode | '
                'QTY: $safeQuantity',
          );
        }
      }

      // ------------------------------------------------------------
      // 12. NO ORDER FOUND
      // ------------------------------------------------------------

      if (repeatedQuantities.isEmpty) {
        if (!mounted) return;

        setState(() {
          _isRepeatingYesterday = false;
        });

        await _showRepeatYesterdayMessage('No Order Found!');

        return;
      }

      // ------------------------------------------------------------
      // 13. UPDATE CURRENT QUANTITIES
      // ------------------------------------------------------------

      if (!mounted) return;

      setState(() {
        // Pehle current quantities clear karo
        _quantities.clear();

        // Existing controllers ko reset karo
        for (final controller in _quantityControllers.values) {
          controller.text = '0';
          controller.selection = const TextSelection.collapsed(
            offset: 1,
          );
        }

        // Yesterday ki quantities set karo
        repeatedQuantities.forEach((prdcode, quantity) {
          _quantities[prdcode] = quantity;

          final controller = _getQuantityController(prdcode);

          controller.text = quantity.toString();

          controller.selection = TextSelection.collapsed(
            offset: controller.text.length,
          );
        });

        _isRepeatingYesterday = false;
      });

      // ------------------------------------------------------------
      // 14. SUCCESS LOG
      // ------------------------------------------------------------

      debugPrint('================================');
      debugPrint('REPEAT YESTERDAY SUCCESS');
      debugPrint('TOTAL PRODUCTS: ${repeatedQuantities.length}');
      debugPrint('QUANTITIES: $repeatedQuantities');
      debugPrint('================================');

      await _showRepeatYesterdayMessage(
        'Yesterday\'s order has been loaded successfully.',
      );
    } catch (e, stackTrace) {
      debugPrint('================================');
      debugPrint('REPEAT YESTERDAY SCREEN ERROR');
      debugPrint('ERROR: $e');
      debugPrint('STACK TRACE:');
      debugPrint('$stackTrace');
      debugPrint('================================');

      if (!mounted) return;

      setState(() {
        _isRepeatingYesterday = false;
      });

      await _showConnectionErrorPopup();
    }
  }

  // ===========================================================================
// REPEAT YESTERDAY MESSAGE
// ===========================================================================

  Future<void> _showRepeatYesterdayMessage(String message) async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (dialogContext) {
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 12,
            sigmaY: 12,
          ),
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.96),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: accentBlue.withOpacity(0.10),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.history_rounded,
                      color: accentBlue,
                      size: 34,
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'Repeat Yesterday',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: deepBlue,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 9),

                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                      height: 1.45,
                    ),
                  ),

                  const SizedBox(height: 22),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        'OK',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
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
  }

  // ===========================================================================
  // SHIFT
  // ===========================================================================

  Future<void> _showOrderAlreadyApprovedPopup() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Demand Already Approved',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'This demand has already been approved and can’t be edited.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _callAsmOrders() async {
    try {
      final shiftCode = _selectedShift == 'Morning Shift'
          ? 'M'
          : _selectedShift == 'Evening Shift'
          ? 'E'
          : '';

      if (shiftCode.isEmpty) {
        return;
      }

      final distCode = widget.customer.custcode.toString();

      debugPrint('================================');
      debugPrint('CALLING ASM ORDERS');
      debugPrint('DISTCODE: $distCode');
      debugPrint('SHIFT: $shiftCode');
      debugPrint('================================');

      final response = await DemandOrderService.asmOrders(
        distCode: distCode,
        shift: shiftCode,
      );

      if (response == null) {
        if (!mounted) return;

        _showConnectionErrorPopup();
        return;
      }

      debugPrint('================================');
      debugPrint('ASM ORDERS RESPONSE');
      debugPrint(response);
      debugPrint('================================');

      final decoded = jsonDecode(response);

      if (decoded is! Map<String, dynamic>) {
        debugPrint('ASM ORDERS INVALID RESPONSE FORMAT');
        return;
      }

      final approved = (decoded['approved'] ?? '').toString().trim();

      final orderTable = decoded['OrderTable'];

      debugPrint('================================');
      debugPrint('ASM ORDERS PARSED RESPONSE');
      debugPrint('APPROVED: $approved');
      debugPrint('ORDERTABLE TYPE: ${orderTable.runtimeType}');
      debugPrint(
        'ORDERTABLE COUNT: ${orderTable is List ? orderTable.length : 0}',
      );
      debugPrint('================================');
      if (orderTable is! List) {
        debugPrint('ASM ORDERS ORDERTABLE NOT FOUND');
        return;
      }

      // Current product list ke saare prdcodes
      final availableProductCodes = _categories
          .expand((category) => category.products)
          .map((product) => product.prdcode)
          .toSet();

      debugPrint('================================');
      debugPrint('MATCHING ASM ORDER PRODUCTS');
      debugPrint('AVAILABLE PRODUCT CODES: ${availableProductCodes.length}');
      debugPrint('================================');

      if (!mounted) return;

      setState(() {
        // Previous ASM order ki quantities clear karo
        _quantities.clear();

        // Existing controllers ko 0 karo
        for (final controller in _quantityControllers.values) {
          controller.text = '0';
          controller.selection = const TextSelection.collapsed(offset: 1);
        }

        // Approved status save karo
        _orderAlreadyApproved = approved == '1';

        // Dynamic OrderTable process karo
        for (final item in orderTable) {
          if (item is! Map) continue;

          final prdcode = int.tryParse((item['prdcode'] ?? '').toString());

          final quantity = int.tryParse((item['qty'] ?? '0').toString());

          if (prdcode == null || quantity == null) {
            continue;
          }

          // Current product list me product exist karta hai ya nahi
          if (!availableProductCodes.contains(prdcode)) {
            debugPrint('PRODUCT NOT FOUND IN CURRENT PRODUCT LIST: $prdcode');
            continue;
          }

          final safeQuantity = quantity.clamp(0, 999);

          _quantities[prdcode] = safeQuantity;

          final controller = _getQuantityController(prdcode);

          controller.text = safeQuantity.toString();

          controller.selection = TextSelection.collapsed(
            offset: controller.text.length,
          );

          debugPrint(
            'PRODUCT MATCHED | '
            'PRDCODE: $prdcode | '
            'QUANTITY: $safeQuantity',
          );
        }
      });

      debugPrint('================================');
      debugPrint('ASM ORDER QUANTITY UPDATE COMPLETE');
      debugPrint('APPROVED: $_orderAlreadyApproved');
      debugPrint('QUANTITIES: $_quantities');
      debugPrint('================================');
    } catch (e) {
      debugPrint('ASM ORDERS SCREEN ERROR: $e');

      if (!mounted) return;

      _showConnectionErrorPopup();
    }
  }

  String _selectedShift = 'Select Shift';

  Future<void> _showShiftSelection() async {
    final renderBox =
        _shiftFieldKey.currentContext!.findRenderObject() as RenderBox;

    final offset = renderBox.localToGlobal(Offset.zero);

    final size = renderBox.size;

    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    final selected = await showMenu<String>(
      context: context,
      color: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      position: RelativeRect.fromRect(
        Rect.fromLTWH(offset.dx, offset.dy + size.height + 6, size.width, 0),
        Offset.zero & overlay.size,
      ),
      constraints: BoxConstraints(minWidth: size.width, maxWidth: size.width),
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

      _callAsmOrders();
    }
  }

  // ===========================================================================
  // SEARCH DISTRIBUTOR
  // ===========================================================================

  void _openDistributorSearch() {
    Navigator.pop(context);
  }

  // ===========================================================================
  // CLEAN TEXT
  // ===========================================================================

  String _cleanText(String value) {
    return value
        .replaceAll('\r\n', ' ')
        .replaceAll('\n', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  // ===========================================================================
  // DATE FORMAT
  // ===========================================================================

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;

    return '$day-$month-$year';
  }

  // ===========================================================================
  // DISPOSE
  // ===========================================================================

  @override
  void dispose() {
    for (final controller in _quantityControllers.values) {
      controller.dispose();
    }

    _quantityControllers.clear();

    WidgetsBinding.instance.removeObserver(this);

    _targetAnimationController?.dispose();

    super.dispose();
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    if (_hasProductError) {
      return _buildProductErrorPage();
    }

    final customerName = _cleanText(widget.customer.custname);

    return Scaffold(
      backgroundColor: cream,
      body: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _BackgroundPainter(),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 620,
                        ),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.stretch,
                          children: [
                            _buildTopActions(),
                            const SizedBox(height: 18),
                            _buildCustomerCard(
                              customerName: customerName,
                            ),
                            const SizedBox(height: 16),
                            _buildShiftAndDateRow(),
                            const SizedBox(height: 20),
                            _buildCategorySection(),

                            if (!_isLoadingProducts &&
                                !_hasProductError &&
                                _categories.isNotEmpty) ...[
                              const SizedBox(height: 18),
                              _buildSelectedCategoryProducts(),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // -------------------------------------------------------------
                // FOOTER
                // -------------------------------------------------------------
                _buildBottomButtons(),
              ],
            ),
          ),

          // ==========================================================
          // SUBMIT API LOADING
          // ==========================================================

          if (_isSubmittingOrder)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.35),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ===========================================================================
  // ERROR PAGE
  // ===========================================================================

  Widget _buildProductErrorPage() {
    return Scaffold(
      backgroundColor: cream,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _BackgroundPainter())),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 420),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.88),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: deepBlue.withOpacity(0.10),
                        blurRadius: 30,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 82,
                        height: 82,
                        decoration: BoxDecoration(
                          color: accentBlue.withOpacity(0.10),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.inventory_2_outlined,
                          color: accentBlue,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        'Unable to load products',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: deepBlue,
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Something went wrong\nfrom server',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _selectedShift = 'Select Shift';
                            });

                            _loadProducts();
                          },
                          icon: const Icon(Icons.refresh_rounded, size: 20),
                          label: const Text(
                            'Retry',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentBlue,
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
        ],
      ),
    );
  }

  // ===========================================================================
  // HEADER
  // ===========================================================================
  Widget _buildHeader() {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.chevron_left_rounded,
              color: deepBlue,
              size: 32,
            ),
          ),

          const Expanded(
            child: Center(
              child: Text(
                'Demand Order',
                style: TextStyle(
                  color: deepBlue,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ),

          const SizedBox(width: 32),
        ],
      ),
    );
  }

  // ===========================================================================
  // TOP ACTIONS
  // ===========================================================================

  Widget _buildTopActions() {
    return Row(
      children: [
        Expanded(
          child: _ActionSearchCard(
            icon: Icons.search_rounded,
            iconColor: accentBlue,
            title: 'Search Distributor',
            onTap: _openDistributorSearch,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionSearchCard(
            icon: Icons.history_rounded,
            iconColor: const Color(0xFF7C5CD6),
            title: 'Repeat Yesterday',
            onTap: _repeatYesterday,
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // CUSTOMER CARD
  // ===========================================================================

  Widget _buildCustomerCard({required String customerName}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFF5FBFF)],
        ),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: deepBlue.withOpacity(0.08),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [accentBlue, accentBlue.withOpacity(0.65)],
              ),
              boxShadow: [
                BoxShadow(
                  color: accentBlue.withOpacity(0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 27,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customerName.isEmpty ? 'Customer' : customerName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: deepBlue,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'Code: ${widget.customer.custcode}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // SHIFT + DATE
  // ===========================================================================

  Widget _buildShiftAndDateRow() {
    String formatDate(DateTime date) {
      final day = date.day.toString().padLeft(2, '0');

      final month = date.month.toString().padLeft(2, '0');

      final year = date.year.toString();

      return '$day/$month/$year';
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            key: _shiftFieldKey,
            child: _GlassFieldCard(
              icon: Icons.access_time_rounded,
              iconColor: const Color(0xFFE5A51B),
              label: '',
              value: _selectedShift == 'Please Select Shift'
                  ? 'Select Shift'
                  : _selectedShift,
              trailing: Icons.keyboard_arrow_down_rounded,
              compact: true,
              onTap: _showShiftSelection,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _GlassFieldCard(
            icon: Icons.calendar_month_rounded,
            iconColor: const Color(0xFF2FA365),
            label: 'Order Date',
            value: formatDate(_selectedDate),
            trailing: Icons.arrow_forward_ios_rounded,
            trailingSize: 14,
            compact: true,
            onTap: _selectDate,
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // CATEGORY SECTION
  // ===========================================================================

  Widget _buildCategorySection() {
    if (_isLoadingProducts) {
      return _buildProductLoading();
    }

    if (_hasProductError) {
      return const SizedBox.shrink();
    }

    if (_categories.isEmpty) {
      return _buildNoProducts();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 3),
          child: Text(
            'Product Category',
            style: TextStyle(
              color: deepBlue,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 11),
        SizedBox(
          height: 88,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final category = _categories[index];

              return _CategoryCard(
                category: category,
                selected: _selectedCategoryIndex == index,
                onTap: () {
                  setState(() {
                    _selectedCategoryIndex = index;
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // SELECTED CATEGORY PRODUCTS
  // ===========================================================================

  Widget _buildSelectedCategoryProducts() {
    if (_categories.isEmpty) {
      return const SizedBox.shrink();
    }

    if (_selectedCategoryIndex < 0 ||
        _selectedCategoryIndex >= _categories.length) {
      return const SizedBox.shrink();
    }

    final category = _categories[_selectedCategoryIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // -----------------------------------------------------------------
            // CATEGORY IMAGE
            // -----------------------------------------------------------------

            if (category.showGroupImage && category.groupImage.isNotEmpty)
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.11),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: ClipOval(
                  child: Image.network(
                    category.groupImage,
                    width: 30,
                    height: 30,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) {
                      return const SizedBox.shrink();
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }

                      return SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: category.color,
                        ),
                      );
                    },
                  ),
                ),
              ),

            if (category.showGroupImage && category.groupImage.isNotEmpty)
              const SizedBox(width: 10),

            Expanded(
              child: Text(
                category.name,
                style: const TextStyle(
                  color: deepBlue,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),

            Text(
              '${category.products.length} products',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 11),

        ...category.products.map(
          (product) => Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: _ProductRow(
              product: product,
              quantity: _getProductQuantity(product.prdcode),
              quantityController: _getQuantityController(product.prdcode),
              color: category.color,
              onIncrease: () {
                setState(() {
                  _increaseProductQuantity(product.prdcode);
                });
              },
              onDecrease: () {
                setState(() {
                  _decreaseProductQuantity(product.prdcode);
                });
              },
              onQuantityChanged: (value) {
                setState(() {
                  _setManualQuantity(product.prdcode, value);
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // LOADING
  // ===========================================================================

  Widget _buildProductLoading() {
    return Container(
      height: 116,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.75),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 21,
              height: 21,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: accentBlue,
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Loading products...',
              style: TextStyle(color: deepBlue, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // NO PRODUCTS
  // ===========================================================================

  Widget _buildNoProducts() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 34,
            color: Colors.grey.shade500,
          ),
          const SizedBox(height: 8),
          const Text(
            'No products available',
            style: TextStyle(color: deepBlue, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // BOTTOM BUTTONS
  // ===========================================================================

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        border: Border(
          top: BorderSide(color: deepBlue.withOpacity(0.08), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: deepBlue.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // ---------------------------------------------------------------
            // RESET
            // ---------------------------------------------------------------

            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: _resetQuantities,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: deepBlue,
                    side: BorderSide(
                      color: deepBlue.withOpacity(0.25),
                      width: 1.3,
                    ),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'RESET',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // ---------------------------------------------------------------
            // SUBMIT
            // ---------------------------------------------------------------
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _submitOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'Proceed',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// ACTION CARD
// =============================================================================

class _ActionSearchCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;

  const _ActionSearchCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.88),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.045),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.11),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(icon, color: iconColor, size: 21),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF173B59),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// GLASS FIELD
// =============================================================================

class _GlassFieldCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final IconData trailing;
  final double trailingSize;
  final bool compact;
  final VoidCallback onTap;

  const _GlassFieldCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.trailing,
    this.trailingSize = 23,
    this.compact = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(21),
        child: Ink(
          padding: EdgeInsets.all(compact ? 12 : 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(21),
            border: Border.all(color: Colors.white, width: 1.3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.045),
                blurRadius: 16,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: compact ? 38 : 46,
                height: compact ? 38 : 46,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.11),
                  borderRadius: BorderRadius.circular(compact ? 12 : 15),
                ),
                child: Icon(icon, color: iconColor, size: compact ? 19 : 23),
              ),
              SizedBox(width: compact ? 9 : 13),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (label.isNotEmpty) ...[
                      Text(
                        label,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: compact ? 10.5 : 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: value == 'Select Shift'
                            ? Colors.grey.shade500
                            : const Color(0xFF173B59),
                        fontSize: compact ? 13 : 15,
                        fontWeight: value == 'Select Shift'
                            ? FontWeight.w500
                            : FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(trailing, size: trailingSize, color: Colors.grey.shade500),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// SHIFT MENU
// =============================================================================

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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      color: selected ? color.withOpacity(0.08) : Colors.transparent,
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF173B59),
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (selected)
            Icon(Icons.check_circle_rounded, color: color, size: 19),
        ],
      ),
    );
  }
}

// =============================================================================
// CATEGORY CARD
// =============================================================================

class _CategoryCard extends StatelessWidget {
  final _ProductCategory category;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(21),
        child: Ink(
          width: 68,
          decoration: BoxDecoration(
            color: selected
                ? category.color.withOpacity(0.10)
                : Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(21),
            border: Border.all(
              color: selected ? category.color.withOpacity(0.45) : Colors.white,
              width: selected ? 1.6 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: category.color.withOpacity(selected ? 0.18 : 0.10),
                blurRadius: 15,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (category.showGroupImage && category.groupImage.isNotEmpty)
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: category.color.withOpacity(0.08),
                    ),
                    alignment: Alignment.center,
                    child: ClipOval(
                      child: Image.network(
                        category.groupImage,
                        width: 30,
                        height: 30,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) {
                          return const SizedBox.shrink();
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }

                          return SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: category.color,
                            ),
                          );
                        },
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 40, height: 40),

                const SizedBox(height: 7),

                Text(
                  category.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? category.color : const Color(0xFF173B59),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// PRODUCT ROW
// =============================================================================

class _ProductRow extends StatelessWidget {
  final _DemandProduct product;
  final int quantity;

  final TextEditingController quantityController;

  final Color color;

  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  final ValueChanged<String> onQuantityChanged;

  const _ProductRow({
    required this.product,
    required this.quantity,
    required this.quantityController,
    required this.color,
    required this.onIncrease,
    required this.onDecrease,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FBFE),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white, width: 1.3),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // -------------------------------------------------------------------
          // PRODUCT IMAGE
          // -------------------------------------------------------------------

          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withOpacity(0.12)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: product.pimg.trim().isEmpty
                  ? Icon(Icons.inventory_2_outlined, color: color, size: 27)
                  : Image.network(
                      product.pimg.trim(),
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) {
                        return Icon(
                          Icons.inventory_2_outlined,
                          color: color,
                          size: 27,
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        }

                        return Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: color,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),

          const SizedBox(width: 10),

          // -------------------------------------------------------------------
          // PRODUCT DETAILS
          // -------------------------------------------------------------------
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  softWrap: true,
                  style: const TextStyle(
                    color: Color(0xFF0C447C),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 5),
                Wrap(
                  spacing: 8,
                  runSpacing: 3,
                  children: [
                    _ProductInfoText(label: '${product.prdcode}'),
                    _ProductInfoText(
                      label: 'MRP: ₹${product.mrp.isEmpty ? '-' : product.mrp}',
                    ),
                    _ProductInfoText(
                      label:
                          'Rate: ₹${product.rate.isEmpty ? '-' : product.rate}',
                      bold: true,
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'UOM: ${product.unit.isEmpty ? '-' : product.unit}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // -------------------------------------------------------------------
          // QUANTITY BOX
          // -------------------------------------------------------------------
          Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: color.withOpacity(0.22), width: 1.1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // MINUS
                _QuantityButton(
                  icon: Icons.remove_rounded,
                  onTap: onDecrease,
                  color: color,
                ),

                // -------------------------------------------------------------
                // MANUAL NUMBER
                // -------------------------------------------------------------
                SizedBox(
                  width: 40,
                  height: 40,
                  child: Center(
                    child: TextField(
                      controller: quantityController,

                      keyboardType: TextInputType.number,

                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],

                      textAlign: TextAlign.center,
                      textAlignVertical: TextAlignVertical.center,

                      maxLength: 3,

                      decoration: const InputDecoration(
                        counterText: '',
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),

                      style: const TextStyle(
                        color: Color(0xFF0C447C),
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        height: 1.0,
                      ),

                      onTap: () {
                        // Agar field me default 0 hai,
                        // click karte hi 0 remove ho jayega.
                        if (quantityController.text == '0') {
                          quantityController.clear();
                        }
                      },

                      onChanged: onQuantityChanged,
                    ),
                  ),
                ),

                // PLUS
                _QuantityButton(
                  icon: Icons.add_rounded,
                  onTap: onIncrease,
                  color: color,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// PRODUCT INFO TEXT
// =============================================================================

class _ProductInfoText extends StatelessWidget {
  final String label;
  final bool bold;

  const _ProductInfoText({required this.label, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: Colors.grey.shade600,
        fontSize: 10.5,
        fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
      ),
    );
  }
}

// =============================================================================
// QUANTITY BUTTON
// =============================================================================

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _QuantityButton({
    required this.icon,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 34,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.75),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 19, color: color),
        ),
      ),
    );
  }
}

// =============================================================================
// CIRCLE ICON BUTTON
// =============================================================================

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.9),
      shape: const CircleBorder(),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 46,
          height: 46,
          child: Icon(icon, color: const Color(0xFF0C447C), size: 23),
        ),
      ),
    );
  }
}

// =============================================================================
// PRODUCT CATEGORY MODEL
// =============================================================================

class _ProductCategory {
  final String name;

  final List<int> groupIds;

  final List<_DemandProduct> products;

  // Category color
  final Color color;

  bool showGroupImage;

  // ProductGroups.img  full URL
  String groupImage;

  _ProductCategory({
    required this.name,
    required this.groupIds,
    required this.products,
    required this.showGroupImage,
    required this.groupImage,
    this.color = const Color(0xFF0B7FBF),
  });
}

// =============================================================================
// PRODUCT MODEL
// =============================================================================

class _DemandProduct {
  final int prdcode;
  final String name;
  final int grpid;
  final String rate;
  final String mrp;
  final String unit;
  final String pimg;

  _DemandProduct({
    required this.prdcode,
    required this.name,
    required this.grpid,
    required this.rate,
    required this.mrp,
    required this.unit,
    required this.pimg,
  });
}

// =============================================================================
// BACKGROUND PAINTER
// =============================================================================

class _BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 35);

    paint.color = const Color(0xFFBFE8FA).withOpacity(0.22);

    canvas.drawCircle(
      Offset(size.width * 0.88, size.height * 0.15),
      105,
      paint,
    );

    paint.color = const Color(0xFFD8CBF5).withOpacity(0.14);

    canvas.drawCircle(Offset(size.width * 0.08, size.height * 0.46), 90, paint);

    paint.color = const Color(0xFFB9E9D2).withOpacity(0.13);

    canvas.drawCircle(
      Offset(size.width * 0.92, size.height * 0.82),
      120,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
