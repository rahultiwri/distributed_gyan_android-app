// import 'dart:ui';
// import 'package:flutter/material.dart';
// import '../../services/menu_service.dart';
//
// import '../../models/banner_model.dart';
// import '../../services/banner_service.dart';
//
//
// class MenuScreen extends StatefulWidget {
//   const MenuScreen({super.key});
//
//   static const Color accent = Color(0xFF0B7FBF);
//
//   @override
//   State<MenuScreen> createState() => _MenuScreenState();
// }
//
// class _MenuScreenState extends State<MenuScreen> {
//   int _navIndex = 0;
//
//   // API menu data
//   List<String> _menuItems = [];
//   List<BannerModel> _banners = [];
//
//   // API state
//   bool _isLoading = true;
//   bool _hasError = false;
//
//   // Shows static error screen after popup OK
//   bool _showErrorPage = false;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _loadUserApps();
//   }
//
//   // --------------------------------------------------------
//   // GET USER APPS
//   // --------------------------------------------------------
//
//   Future<void> _loadUserApps() async {
//     setState(() {
//       _isLoading = true;
//       _hasError = false;
//       _showErrorPage = false;
//     });
//
//     final menuItems = await MenuService.getUserApps();
//
//     if (!mounted) return;
//
//     // ------------------------------------------------------
//     // API ERROR
//     // ------------------------------------------------------
//
//     if (menuItems.isEmpty) {
//       setState(() {
//         _isLoading = false;
//         _hasError = true;
//         _showErrorPage = false;
//         _menuItems = [];
//       });
//
//       _showErrorPopup();
//       return;
//     }
//
//
// // GET BANNER API
//     final banners = await BannerService.getBanner();
//
//     debugPrint('================================');
//     debugPrint('BANNERS RECEIVED IN MENU SCREEN');
//     debugPrint('COUNT: ${banners.length}');
//     debugPrint('================================');
//
//     for (final banner in banners) {
//       debugPrint('ID: ${banner.id}');
//       debugPrint('IMAGE URL: ${banner.imgurl}');
//       debugPrint('================================');
//     }
//
//     // ------------------------------------------------------
//     // API SUCCESS
//     // ------------------------------------------------------
//
//     setState(() {
//       _isLoading = false;
//       _hasError = false;
//       _showErrorPage = false;
//       _menuItems = menuItems;
//     });
//   }
//
//   // --------------------------------------------------------
//   // CONNECTION ERROR POPUP
//   // --------------------------------------------------------
//
//   void _showErrorPopup() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       barrierColor: Colors.black.withOpacity(0.45),
//       builder: (dialogContext) {
//         return Dialog(
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//           insetPadding: const EdgeInsets.symmetric(horizontal: 28),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(28),
//             child: BackdropFilter(
//               filter: ImageFilter.blur(
//                 sigmaX: 12,
//                 sigmaY: 12,
//               ),
//               child: Container(
//                 padding: const EdgeInsets.fromLTRB(24, 26, 24, 22),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.96),
//                   borderRadius: BorderRadius.circular(28),
//                   border: Border.all(
//                     color: Colors.white.withOpacity(0.9),
//                     width: 1.2,
//                   ),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.16),
//                       blurRadius: 30,
//                       offset: const Offset(0, 14),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     // ------------------------------------------------
//                     // CLOUD ICON
//                     // ------------------------------------------------
//
//                     Container(
//                       width: 72,
//                       height: 72,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: MenuScreen.accent.withOpacity(0.10),
//                       ),
//                       child: Center(
//                         child: Container(
//                           width: 54,
//                           height: 54,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             gradient: LinearGradient(
//                               begin: Alignment.topLeft,
//                               end: Alignment.bottomRight,
//                               colors: [
//                                 MenuScreen.accent.withOpacity(0.18),
//                                 MenuScreen.accent.withOpacity(0.06),
//                               ],
//                             ),
//                           ),
//                           child: const Icon(
//                             Icons.cloud_off_rounded,
//                             size: 29,
//                             color: MenuScreen.accent,
//                           ),
//                         ),
//                       ),
//                     ),
//
//                     const SizedBox(height: 20),
//
//                     // ------------------------------------------------
//                     // TITLE
//                     // ------------------------------------------------
//
//                     const Text(
//                       'Connection Error',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontSize: 21,
//                         fontWeight: FontWeight.w800,
//                         color: Color(0xFF172B3A),
//                         letterSpacing: -0.2,
//                       ),
//                     ),
//
//                     const SizedBox(height: 10),
//
//                     // ------------------------------------------------
//                     // MESSAGE
//                     // ------------------------------------------------
//
//                     const Text(
//                       'Something went wrong\nfrom server',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontSize: 14,
//                         height: 1.5,
//                         fontWeight: FontWeight.w500,
//                         color: Color(0xFF71808C),
//                       ),
//                     ),
//
//                     const SizedBox(height: 24),
//
//                     // ------------------------------------------------
//                     // OK BUTTON
//                     // ------------------------------------------------
//
//                     SizedBox(
//                       width: double.infinity,
//                       height: 48,
//                       child: ElevatedButton(
//                         onPressed: () {
//                           Navigator.of(dialogContext).pop();
//
//                           if (!mounted) return;
//
//                           setState(() {
//                             _showErrorPage = true;
//                           });
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: MenuScreen.accent,
//                           foregroundColor: Colors.white,
//                           elevation: 0,
//                           shadowColor: Colors.transparent,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(15),
//                           ),
//                         ),
//                         child: const Text(
//                           'OK',
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w800,
//                             letterSpacing: 0.3,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   // --------------------------------------------------------
//   // CHECK CRATE MENU
//   // --------------------------------------------------------
//
//   bool _isCrateMenu(String title) {
//     return title.toLowerCase().contains('crate');
//   }
//
//   // --------------------------------------------------------
//   // MENU ICON
//   // --------------------------------------------------------
//
//   IconData _iconForMenu(String title) {
//     switch (title.toLowerCase()) {
//       case 'sync from server':
//         return Icons.sync_rounded;
//
//       case 'place order':
//         return Icons.shopping_cart_rounded;
//
//       case 'make payment':
//         return Icons.attach_money_rounded;
//
//       case 'raise complaint':
//         return Icons.report_gmailerrorred_rounded;
//
//       case 'report':
//         return Icons.description_rounded;
//
//       case 'crate ledger':
//         return Icons.folder_rounded;
//
//       case 'crate return':
//         return Icons.undo_rounded;
//
//       case 'crate deduction report':
//         return Icons.auto_awesome_rounded;
//
//       case 'chat bot':
//         return Icons.chat_bubble_rounded;
//
//       case 'ledger':
//         return Icons.account_balance_wallet_rounded;
//
//       case 'target vs achivement':
//         return Icons.track_changes_rounded;
//
//       case 'comparision report':
//         return Icons.compare_arrows_rounded;
//
//       case 'retailer registration':
//         return Icons.person_add_alt_1_rounded;
//
//       case 'retailer dispatch':
//         return Icons.local_shipping_rounded;
//
//       case 'about':
//         return Icons.info_outline_rounded;
//
//       case 'claim':
//         return Icons.assignment_rounded;
//
//       default:
//         return Icons.apps_rounded;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // --------------------------------------------------------
//     // Separate API menus into Operations and Crate Management
//     // --------------------------------------------------------
//
//     final operationsMenus = _menuItems
//         .where((item) => !_isCrateMenu(item))
//         .toList();
//
//     final crateMenus = _menuItems
//         .where((item) => _isCrateMenu(item))
//         .toList();
//
//     // --------------------------------------------------------
//     // LOADING
//     // --------------------------------------------------------
//
//     if (_isLoading) {
//       return const Scaffold(
//         body: Center(
//           child: CircularProgressIndicator(
//             color: MenuScreen.accent,
//           ),
//         ),
//       );
//     }
//
//     // --------------------------------------------------------
//     // STATIC ERROR SCREEN
//     // --------------------------------------------------------
//
//     if (_showErrorPage) {
//       return Scaffold(
//         body: _ErrorView(
//           onRetry: _loadUserApps,
//         ),
//       );
//     }
//
//     // --------------------------------------------------------
//     // MAIN MENU SCREEN
//     // --------------------------------------------------------
//
//     return Scaffold(
//       drawer: _ProfileDrawer(
//         onSignOut: () {
//           Navigator.pushNamedAndRemoveUntil(
//             context,
//             '/login',
//                 (route) => false,
//           );
//         },
//       ),
//       body: Stack(
//         fit: StackFit.expand,
//         children: [
//           // Background image
//           Image.asset(
//             'assets/images/menu1.png',
//             fit: BoxFit.cover,
//           ),
//
//           // Soft scrim
//           Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [
//                   Colors.white.withOpacity(0.55),
//                   Colors.white.withOpacity(0.25),
//                   Colors.white.withOpacity(0.55),
//                 ],
//                 stops: const [0.0, 0.45, 1.0],
//               ),
//             ),
//           ),
//
//           SafeArea(
//             bottom: false,
//             child: Column(
//               children: [
//                 Expanded(
//                   child: SingleChildScrollView(
//                     physics: const BouncingScrollPhysics(),
//                     padding: const EdgeInsets.fromLTRB(
//                       20,
//                       20,
//                       20,
//                       16,
//                     ),
//                     child: Center(
//                       child: ConstrainedBox(
//                         constraints: const BoxConstraints(
//                           maxWidth: 600,
//                         ),
//                         child: Column(
//                           crossAxisAlignment:
//                           CrossAxisAlignment.stretch,
//                           children: [
//                             // THREE-DOT ICON / DRAWER
//                             Align(
//                               alignment: Alignment.topLeft,
//                               child: Builder(
//                                 builder: (context) =>
//                                     ClipRRect(
//                                       borderRadius:
//                                       BorderRadius.circular(20),
//                                       child: BackdropFilter(
//                                         filter: ImageFilter.blur(
//                                           sigmaX: 8,
//                                           sigmaY: 8,
//                                         ),
//                                         child: Material(
//                                           color: const Color(0xFFEAF6FD)
//                                               .withOpacity(0.55),
//                                           shape: const CircleBorder(
//                                             side: BorderSide(
//                                               color: Colors.white70,
//                                               width: 1,
//                                             ),
//                                           ),
//                                           child: InkWell(
//                                             customBorder:
//                                             const CircleBorder(),
//                                             onTap: () => Scaffold.of(
//                                               context,
//                                             ).openDrawer(),
//                                             child: const SizedBox(
//                                               width: 40,
//                                               height: 40,
//                                               child: Icon(
//                                                 Icons.menu_rounded,
//                                                 size: 22,
//                                                 color:
//                                                 MenuScreen.accent,
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                               ),
//                             ),
//
//                             // LOGO
//                             Center(
//                               child: SizedBox(
//                                 width: 190,
//                                 height: 100,
//                                 child: Image.asset(
//                                   'assets/images/Gyan_dairy_logo.png',
//                                   fit: BoxFit.contain,
//                                 ),
//                               ),
//                             ),
//
//                             const SizedBox(height: 16),
//
//                             const Text(
//                               'Distributor Demand App',
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                 fontSize: 24,
//                                 fontWeight: FontWeight.w800,
//                                 color: Color(0xFF0D47A1),
//                               ),
//                             ),
//
//                             const SizedBox(height: 28),
//
//                             // ------------------------------------------------
//                             // OPERATIONS
//                             // ------------------------------------------------
//
//                             if (operationsMenus.isNotEmpty) ...[
//                               const _SectionTitle(
//                                 'Operations',
//                               ),
//                               const SizedBox(height: 12),
//
//                               GridView.count(
//                                 crossAxisCount: 3,
//                                 shrinkWrap: true,
//                                 physics:
//                                 const NeverScrollableScrollPhysics(),
//                                 crossAxisSpacing: 10,
//                                 mainAxisSpacing: 10,
//                                 childAspectRatio: 0.92,
//                                 children:
//                                 operationsMenus.map((menu) {
//                                   return _MenuTile(
//                                     icon: _iconForMenu(menu),
//                                     title: menu,
//                                     compact: true,
//                                   );
//                                 }).toList(),
//                               ),
//                             ],
//
//                             // ------------------------------------------------
//                             // CRATE MANAGEMENT
//                             // ------------------------------------------------
//
//                             if (crateMenus.isNotEmpty) ...[
//                               const SizedBox(height: 26),
//
//                               const _SectionTitle(
//                                 'Crate Management',
//                               ),
//                               const SizedBox(height: 12),
//
//                               GridView.count(
//                                 crossAxisCount: 3,
//                                 shrinkWrap: true,
//                                 physics:
//                                 const NeverScrollableScrollPhysics(),
//                                 crossAxisSpacing: 12,
//                                 mainAxisSpacing: 12,
//                                 childAspectRatio: 0.92,
//                                 children:
//                                 crateMenus.map((menu) {
//                                   return _MenuTile(
//                                     icon: _iconForMenu(menu),
//                                     title: menu,
//                                   );
//                                 }).toList(),
//                               ),
//                             ],
//
//                             const SizedBox(height: 20),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//
//                 // FOOTER NAV BAR
//                 _BottomNav(
//                   currentIndex: _navIndex,
//                   onTap: (index) =>
//                       setState(() => _navIndex = index),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ============================================================
// // STATIC ERROR VIEW
// // ============================================================
//
// class _ErrorView extends StatelessWidget {
//   final VoidCallback onRetry;
//
//   const _ErrorView({
//     required this.onRetry,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       fit: StackFit.expand,
//       children: [
//         // Soft background
//         Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//               colors: [
//                 Color(0xFFF5FBFE),
//                 Color(0xFFE8F5FB),
//                 Color(0xFFDCEFF7),
//               ],
//             ),
//           ),
//         ),
//
//         // Decorative circles
//         Positioned(
//           top: -90,
//           right: -70,
//           child: Container(
//             width: 220,
//             height: 220,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: MenuScreen.accent.withOpacity(0.07),
//             ),
//           ),
//         ),
//
//         Positioned(
//           bottom: -100,
//           left: -80,
//           child: Container(
//             width: 240,
//             height: 240,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: MenuScreen.accent.withOpacity(0.06),
//             ),
//           ),
//         ),
//
//         SafeArea(
//           child: Center(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 28,
//                 vertical: 30,
//               ),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(30),
//                 child: BackdropFilter(
//                   filter: ImageFilter.blur(
//                     sigmaX: 12,
//                     sigmaY: 12,
//                   ),
//                   child: Container(
//                     width: double.infinity,
//                     constraints: const BoxConstraints(
//                       maxWidth: 420,
//                     ),
//                     padding: const EdgeInsets.fromLTRB(
//                       28,
//                       34,
//                       28,
//                       30,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.88),
//                       borderRadius: BorderRadius.circular(30),
//                       border: Border.all(
//                         color: Colors.white.withOpacity(0.9),
//                         width: 1.2,
//                       ),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.07),
//                           blurRadius: 28,
//                           offset: const Offset(0, 14),
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         // ------------------------------------------------
//                         // CLOUD ICON
//                         // ------------------------------------------------
//
//                         Container(
//                           width: 88,
//                           height: 88,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             color: MenuScreen.accent
//                                 .withOpacity(0.09),
//                           ),
//                           child: Container(
//                             margin: const EdgeInsets.all(9),
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               gradient: LinearGradient(
//                                 begin: Alignment.topLeft,
//                                 end: Alignment.bottomRight,
//                                 colors: [
//                                   MenuScreen.accent
//                                       .withOpacity(0.18),
//                                   MenuScreen.accent
//                                       .withOpacity(0.05),
//                                 ],
//                               ),
//                             ),
//                             child: const Icon(
//                               Icons.cloud_off_rounded,
//                               size: 38,
//                               color: MenuScreen.accent,
//                             ),
//                           ),
//                         ),
//
//                         const SizedBox(height: 24),
//
//                         // ------------------------------------------------
//                         // TITLE
//                         // ------------------------------------------------
//
//                         const Text(
//                           'Unable to load menu',
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontSize: 22,
//                             fontWeight: FontWeight.w800,
//                             color: Color(0xFF172B3A),
//                             letterSpacing: -0.3,
//                           ),
//                         ),
//
//                         const SizedBox(height: 11),
//
//                         // ------------------------------------------------
//                         // MESSAGE
//                         // ------------------------------------------------
//
//                         const Text(
//                           'Something went wrong\nfrom server',
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontSize: 14,
//                             height: 1.5,
//                             fontWeight: FontWeight.w500,
//                             color: Color(0xFF71808C),
//                           ),
//                         ),
//
//                         const SizedBox(height: 26),
//
//                         // ------------------------------------------------
//                         // RETRY BUTTON
//                         // ------------------------------------------------
//
//                         SizedBox(
//                           width: double.infinity,
//                           height: 50,
//                           child: ElevatedButton.icon(
//                             onPressed: onRetry,
//                             icon: const Icon(
//                               Icons.refresh_rounded,
//                               size: 20,
//                             ),
//                             label: const Text(
//                               'Retry',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w800,
//                                 letterSpacing: 0.2,
//                               ),
//                             ),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor:
//                               MenuScreen.accent,
//                               foregroundColor: Colors.white,
//                               elevation: 0,
//                               shadowColor: Colors.transparent,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius:
//                                 BorderRadius.circular(15),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// // ============================================================
// // PROFILE DRAWER
// // ============================================================
//
// class _ProfileDrawer extends StatelessWidget {
//   final VoidCallback onSignOut;
//
//   const _ProfileDrawer({
//     required this.onSignOut,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       backgroundColor: const Color(0xFFFAF4E6),
//       surfaceTintColor: Colors.transparent,
//       shadowColor: Colors.black26,
//       child: Container(
//         color: const Color(0xFFFAF4E6),
//         child: SafeArea(
//           child: Column(
//             crossAxisAlignment:
//             CrossAxisAlignment.stretch,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(
//                   16,
//                   12,
//                   12,
//                   8,
//                 ),
//                 child: Row(
//                   children: [
//                     Container(
//                       width: 46,
//                       height: 46,
//                       decoration: BoxDecoration(
//                         color: MenuScreen.accent
//                             .withOpacity(0.14),
//                         shape: BoxShape.circle,
//                       ),
//                       child: const Icon(
//                         Icons.person_rounded,
//                         size: 24,
//                         color: MenuScreen.accent,
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     const Expanded(
//                       child: Text(
//                         'Account',
//                         style: TextStyle(
//                           fontSize: 17,
//                           fontWeight: FontWeight.w700,
//                           color: Color(0xFF1C2B36),
//                         ),
//                       ),
//                     ),
//                     IconButton(
//                       onPressed: () =>
//                           Navigator.of(context).pop(),
//                       icon: const Icon(
//                         Icons.close_rounded,
//                         color: Color(0xFF7A8894),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               const Divider(height: 1),
//
//               ListTile(
//                 leading: const Icon(
//                   Icons.person_outline_rounded,
//                   color: MenuScreen.accent,
//                 ),
//                 title: const Text(
//                   'Profile',
//                   style: TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xFF1C2B36),
//                   ),
//                 ),
//                 onTap: () =>
//                     Navigator.of(context).pop(),
//               ),
//
//               ListTile(
//                 leading: const Icon(
//                   Icons.settings_outlined,
//                   color: MenuScreen.accent,
//                 ),
//                 title: const Text(
//                   'Settings',
//                   style: TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xFF1C2B36),
//                   ),
//                 ),
//                 onTap: () =>
//                     Navigator.of(context).pop(),
//               ),
//
//               ListTile(
//                 leading: const Icon(
//                   Icons.logout_rounded,
//                   color: MenuScreen.accent,
//                 ),
//                 title: const Text(
//                   'Sign out',
//                   style: TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xFF1C2B36),
//                   ),
//                 ),
//                 onTap: () {
//                   Navigator.of(context).pop();
//                   onSignOut();
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // ============================================================
// // SECTION TITLE
// // ============================================================
//
// class _SectionTitle extends StatelessWidget {
//   final String title;
//
//   const _SectionTitle(this.title);
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Container(
//           width: 4,
//           height: 15,
//           decoration: BoxDecoration(
//             color: MenuScreen.accent,
//             borderRadius: BorderRadius.circular(2),
//           ),
//         ),
//         const SizedBox(width: 8),
//         Text(
//           title.toUpperCase(),
//           style: const TextStyle(
//             fontSize: 13,
//             fontWeight: FontWeight.w800,
//             letterSpacing: 0.8,
//             color: Color(0xFF1C2B36),
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// // ============================================================
// // GLASS PANEL
// // ============================================================
//
// class _GlassPanel extends StatelessWidget {
//   final Widget child;
//   final double radius;
//   final EdgeInsets padding;
//
//   const _GlassPanel({
//     required this.child,
//     this.radius = 18,
//     this.padding = const EdgeInsets.all(12),
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(radius),
//       child: BackdropFilter(
//         filter: ImageFilter.blur(
//           sigmaX: 8,
//           sigmaY: 8,
//         ),
//         child: Container(
//           padding: padding,
//           decoration: BoxDecoration(
//             color: const Color(0xFFEAF6FD)
//                 .withOpacity(0.92),
//             borderRadius: BorderRadius.circular(radius),
//             border: Border.all(
//               color: Colors.white.withOpacity(0.75),
//               width: 1,
//             ),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.06),
//                 blurRadius: 16,
//                 offset: const Offset(0, 8),
//               ),
//             ],
//           ),
//           child: child,
//         ),
//       ),
//     );
//   }
// }
//
// // ============================================================
// // MENU TILE
// // ============================================================
//
// class _MenuTile extends StatefulWidget {
//   final IconData icon;
//   final String title;
//   final VoidCallback? onTap;
//   final bool compact;
//
//   const _MenuTile({
//     required this.icon,
//     required this.title,
//     this.onTap,
//     this.compact = false,
//   });
//
//   @override
//   State<_MenuTile> createState() => _MenuTileState();
// }
//
// class _MenuTileState extends State<_MenuTile> {
//   bool _pressed = false;
//
//   @override
//   Widget build(BuildContext context) {
//     final Color iconColor =
//     _pressed ? Colors.white : MenuScreen.accent;
//
//     final Color badgeColor = _pressed
//         ? MenuScreen.accent
//         : MenuScreen.accent.withOpacity(0.12);
//
//     final Color textColor = _pressed
//         ? MenuScreen.accent
//         : const Color(0xFF1C2B36);
//
//     // Slightly smaller footprint when compact (Operations section)
//     final double iconBadgeSize = widget.compact ? 38 : 44;
//     final double iconSize = widget.compact ? 19 : 22;
//     final double fontSize = widget.compact ? 11 : 12;
//     final double tileRadius = widget.compact ? 16 : 18;
//
//     return _GlassPanel(
//       radius: tileRadius,
//       padding: EdgeInsets.symmetric(
//         horizontal: 6,
//         vertical: widget.compact ? 8 : 10,
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: widget.onTap ?? () {},
//           onHighlightChanged: (v) {
//             setState(() => _pressed = v);
//           },
//           borderRadius: BorderRadius.circular(tileRadius),
//           splashColor:
//           MenuScreen.accent.withOpacity(0.18),
//           child: AnimatedContainer(
//             duration: const Duration(
//               milliseconds: 150,
//             ),
//             child: Column(
//               mainAxisAlignment:
//               MainAxisAlignment.center,
//               children: [
//                 AnimatedContainer(
//                   duration: const Duration(
//                     milliseconds: 150,
//                   ),
//                   width: iconBadgeSize,
//                   height: iconBadgeSize,
//                   decoration: BoxDecoration(
//                     color: badgeColor,
//                     shape: BoxShape.circle,
//                     border: Border.all(
//                       color: _pressed
//                           ? Colors.transparent
//                           : MenuScreen.accent
//                           .withOpacity(0.10),
//                       width: 1,
//                     ),
//                   ),
//                   child: Icon(
//                     widget.icon,
//                     size: iconSize,
//                     color: iconColor,
//                   ),
//                 ),
//                 SizedBox(height: widget.compact ? 6 : 8),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 2,
//                   ),
//                   child: Text(
//                     widget.title,
//                     textAlign: TextAlign.center,
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(
//                       fontSize: fontSize,
//                       fontWeight: FontWeight.w600,
//                       letterSpacing: 0.1,
//                       color: textColor,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // ============================================================
// // BOTTOM NAVIGATION
// // ============================================================
//
// class _BottomNav extends StatelessWidget {
//   final int currentIndex;
//   final ValueChanged<int> onTap;
//
//   const _BottomNav({
//     required this.currentIndex,
//     required this.onTap,
//   });
//
//   static const _items = [
//     (
//     icon: Icons.home_rounded,
//     label: 'Home',
//     ),
//     (
//     icon: Icons.checklist_rounded,
//     label: 'Task',
//     ),
//     (
//     icon: Icons.explore_rounded,
//     label: 'Explore',
//     ),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//       borderRadius: const BorderRadius.vertical(
//         top: Radius.circular(22),
//       ),
//       child: BackdropFilter(
//         filter: ImageFilter.blur(
//           sigmaX: 16,
//           sigmaY: 16,
//         ),
//         child: Container(
//           padding: const EdgeInsets.symmetric(
//             vertical: 10,
//           ),
//           decoration: BoxDecoration(
//             color: const Color(0xFFEAF6FD)
//                 .withOpacity(0.20),
//             border: Border(
//               top: BorderSide(
//                 color: const Color(0xFFEAF6FD)
//                     .withOpacity(0.20),
//               ),
//             ),
//           ),
//           child: SafeArea(
//             top: false,
//             child: Row(
//               mainAxisAlignment:
//               MainAxisAlignment.spaceEvenly,
//               children: List.generate(
//                 _items.length,
//                     (index) {
//                   final item = _items[index];
//                   final bool selected =
//                       index == currentIndex;
//
//                   final Color color = selected
//                       ? MenuScreen.accent
//                       : const Color(0xFF7A8894);
//
//                   return InkWell(
//                     onTap: () => onTap(index),
//                     borderRadius:
//                     BorderRadius.circular(14),
//                     child: Padding(
//                       padding:
//                       const EdgeInsets.symmetric(
//                         horizontal: 14,
//                         vertical: 6,
//                       ),
//                       child: Column(
//                         mainAxisSize:
//                         MainAxisSize.min,
//                         children: [
//                           Icon(
//                             item.icon,
//                             size: 22,
//                             color: color,
//                           ),
//                           const SizedBox(height: 3),
//                           Text(
//                             item.label,
//                             style: TextStyle(
//                               fontSize: 11,
//                               fontWeight: selected
//                                   ? FontWeight.w700
//                                   : FontWeight.w500,
//                               color: color,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
//
//



import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../services/menu_service.dart';
import '../../models/banner_model.dart';
import '../../services/banner_service.dart';

import '../place_order/place_order_screen.dart';

import '../customer_details/customer_details_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  static const Color accent = Color(0xFF0B7FBF);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int _navIndex = 0;

  // API menu data
  List<String> _menuItems = [];

  // API banner data
  List<BannerModel> _banners = [];

  // Banner page controller
  final PageController _bannerController = PageController();

  // Auto banner slider
  Timer? _bannerTimer;

  // API state
  bool _isLoading = true;
  bool _hasError = false;

  // Shows static error screen after popup OK
  bool _showErrorPage = false;

  // Current banner
  int _currentBannerIndex = 0;

  @override
  void initState() {
    super.initState();

    _loadUserApps();
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  // --------------------------------------------------------
  // GET USER APPS
  // --------------------------------------------------------

  Future<void> _loadUserApps() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _showErrorPage = false;
    });

    final menuItems = await MenuService.getUserApps();

    if (!mounted) return;

    // ------------------------------------------------------
    // API ERROR
    // ------------------------------------------------------

    if (menuItems.isEmpty) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _showErrorPage = false;
        _menuItems = [];
        _banners = [];
      });

      _stopBannerTimer();
      _showErrorPopup();
      return;
    }

    // ------------------------------------------------------
    // GET BANNER API
    // ------------------------------------------------------

    final banners = await BannerService.getBanner();

    if (!mounted) return;

    debugPrint('================================');
    debugPrint('BANNERS RECEIVED IN MENU SCREEN');
    debugPrint('COUNT: ${banners.length}');
    debugPrint('================================');

    for (final banner in banners) {
      debugPrint('ID: ${banner.id}');
      debugPrint('DESC: ${banner.desc}');
      debugPrint('IMAGE URL: ${banner.imgurl}');
      debugPrint('================================');
    }

    // ------------------------------------------------------
    // API SUCCESS
    // ------------------------------------------------------

    setState(() {
      _isLoading = false;
      _hasError = false;
      _showErrorPage = false;
      _menuItems = menuItems;
      _banners = banners;
      _currentBannerIndex = 0;
    });

    // Start automatic banner slider
    _startBannerTimer();
  }

  // --------------------------------------------------------
  // START AUTO BANNER SLIDER
  // --------------------------------------------------------

  void _startBannerTimer() {
    _stopBannerTimer();

    // Auto slider only required when there are multiple banners.
    if (_banners.length <= 1) {
      return;
    }

    _bannerTimer = Timer.periodic(
      const Duration(seconds: 4),
          (_) {
        if (!mounted || !_bannerController.hasClients) {
          return;
        }

        if (_banners.length <= 1) {
          return;
        }

        final nextPage = _currentBannerIndex + 1;

        // Normal next banner
        if (nextPage < _banners.length) {
          _bannerController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 650),
            curve: Curves.easeInOut,
          );
        } else {
          // Last banner ke baad first banner
          _bannerController.animateToPage(
            0,
            duration: const Duration(milliseconds: 650),
            curve: Curves.easeInOut,
          );
        }
      },
    );
  }

  // --------------------------------------------------------
  // STOP AUTO BANNER SLIDER
  // --------------------------------------------------------

  void _stopBannerTimer() {
    _bannerTimer?.cancel();
    _bannerTimer = null;
  }

  // --------------------------------------------------------
  // RESET AUTO SLIDER AFTER MANUAL SWIPE
  // --------------------------------------------------------

  void _restartBannerTimer() {
    if (_banners.length > 1) {
      _startBannerTimer();
    }
  }

  // --------------------------------------------------------
  // CONNECTION ERROR POPUP
  // --------------------------------------------------------

  void _showErrorPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 12,
                sigmaY: 12,
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(
                  24,
                  26,
                  24,
                  22,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.96),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.9),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.16),
                      blurRadius: 30,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ------------------------------------------------
                    // CLOUD ICON
                    // ------------------------------------------------

                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: MenuScreen.accent.withOpacity(0.10),
                      ),
                      child: Center(
                        child: Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                MenuScreen.accent.withOpacity(0.18),
                                MenuScreen.accent.withOpacity(0.06),
                              ],
                            ),
                          ),
                          child: const Icon(
                            Icons.cloud_off_rounded,
                            size: 29,
                            color: MenuScreen.accent,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ------------------------------------------------
                    // TITLE
                    // ------------------------------------------------

                    const Text(
                      'Connection Error',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF172B3A),
                        letterSpacing: -0.2,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ------------------------------------------------
                    // MESSAGE
                    // ------------------------------------------------

                    const Text(
                      'Something went wrong\nfrom server',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF71808C),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ------------------------------------------------
                    // OK BUTTON
                    // ------------------------------------------------

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();

                          if (!mounted) return;

                          setState(() {
                            _showErrorPage = true;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MenuScreen.accent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shadowColor: Colors.transparent,
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
          ),
        );
      },
    );
  }

  // --------------------------------------------------------
  // CHECK CRATE MENU
  // --------------------------------------------------------

  bool _isCrateMenu(String title) {
    return title.toLowerCase().contains('crate');
  }

  // --------------------------------------------------------
  // MENU COLOR
  // --------------------------------------------------------

  Color _colorForMenu(String title) {
    switch (title.toLowerCase()) {
      case 'sync from server':
        return const Color(0xFF0B7FBF);

      case 'place order':
        return const Color(0xFFE8792B);

      case 'make payment':
        return const Color(0xFF2FA365);

      case 'raise complaint':
        return const Color(0xFFE0455A);

      case 'report':
        return const Color(0xFF7C5CD6);

      case 'crate ledger':
        return const Color(0xFF1E9E8E);

      case 'crate return':
        return const Color(0xFFC9860B);

      case 'crate deduction report':
        return const Color(0xFFCB4E9A);

      case 'chat bot':
        return const Color(0xFF3D8BE0);

      case 'ledger':
        return const Color(0xFF5C7CD6);

      case 'target vs achivement':
        return const Color(0xFFD64545);

      case 'comparision report':
        return const Color(0xFF3AA5A0);

      case 'retailer registration':
        return const Color(0xFF7C5CD6);

      case 'retailer dispatch':
        return const Color(0xFFE0692B);

      case 'about':
        return const Color(0xFF6B7B8A);

      case 'claim':
        return const Color(0xFF2F8FA3);

      default:
        return MenuScreen.accent;
    }
  }

  // --------------------------------------------------------
  // MENU ICON
  // --------------------------------------------------------

  IconData _iconForMenu(String title) {
    switch (title.toLowerCase()) {
      case 'sync from server':
        return Icons.sync_rounded;

      case 'place order':
        return Icons.shopping_cart_rounded;

      case 'make payment':
        return Icons.attach_money_rounded;

      case 'raise complaint':
        return Icons.report_gmailerrorred_rounded;

      case 'report':
        return Icons.description_rounded;

      case 'crate ledger':
        return Icons.folder_rounded;

      case 'crate return':
        return Icons.undo_rounded;

      case 'crate deduction report':
        return Icons.auto_awesome_rounded;

      case 'chat bot':
        return Icons.chat_bubble_rounded;

      case 'ledger':
        return Icons.account_balance_wallet_rounded;

      case 'target vs achivement':
        return Icons.track_changes_rounded;

      case 'comparision report':
        return Icons.compare_arrows_rounded;

      case 'retailer registration':
        return Icons.person_add_alt_1_rounded;

      case 'retailer dispatch':
        return Icons.local_shipping_rounded;

      case 'about':
        return Icons.info_outline_rounded;

      case 'claim':
        return Icons.assignment_rounded;

      default:
        return Icons.apps_rounded;
    }
  }

  // --------------------------------------------------------
  // BANNER VIEW
  // --------------------------------------------------------

  Widget _buildBannerView() {
    if (_banners.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final bannerHeight =
            (constraints.maxWidth / 1.65).clamp(
              180.0,
              250.0,
            );

            return SizedBox(
              height: bannerHeight,
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  // Manual swipe par timer stop/restart.
                  if (notification is ScrollStartNotification &&
                      notification.dragDetails != null) {
                    _stopBannerTimer();
                  }

                  if (notification is ScrollEndNotification) {
                    _restartBannerTimer();
                  }

                  return false;
                },
                child: PageView.builder(
                  controller: _bannerController,
                  itemCount: _banners.length,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (index) {
                    if (!mounted) return;

                    setState(() {
                      _currentBannerIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final banner = _banners[index];

                    final String description =
                    banner.desc.trim();

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 2,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius:
                          BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color:
                              Colors.black.withOpacity(0.10),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius:
                          BorderRadius.circular(20),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // --------------------------------
                              // BANNER IMAGE
                              // --------------------------------

                              Image.network(
                                banner.imgurl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                loadingBuilder:
                                    (context, child,
                                    loadingProgress) {
                                  if (loadingProgress == null) {
                                    return child;
                                  }

                                  return Container(
                                    color:
                                    const Color(0xFFF4F7FA),
                                    alignment: Alignment.center,
                                    child: const SizedBox(
                                      width: 25,
                                      height: 25,
                                      child:
                                      CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        color:
                                        MenuScreen.accent,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder:
                                    (context, error,
                                    stackTrace) {
                                  return Container(
                                    color:
                                    const Color(0xFFF4F7FA),
                                    alignment: Alignment.center,
                                    child: const Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons
                                              .image_not_supported_outlined,
                                          size: 35,
                                          color:
                                          Color(0xFF8A9AA5),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          'Banner unavailable',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color:
                                            Color(0xFF8A9AA5),
                                            fontWeight:
                                            FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),

                              // --------------------------------
                              // BOTTOM GRADIENT
                              // --------------------------------

                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 0,
                                height: 115,
                                child: IgnorePointer(
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin:
                                        Alignment.topCenter,
                                        end:
                                        Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black
                                              .withOpacity(0.58),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // --------------------------------
                              // DESCRIPTION
                              // No box / no glass background
                              // --------------------------------

                              if (description.isNotEmpty)
                                Positioned(
                                  left: 20,
                                  right: 20,
                                  bottom: 0,
                                  child: Text(
                                    description,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.72),
                                      fontSize: 15,
                                      height: 1.35,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.1,
                                      shadows: const [
                                        Shadow(
                                          color: Colors.black45,
                                          blurRadius: 5,
                                          offset: Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                              // --------------------------------
                              // BANNER COUNTER
                              // --------------------------------

                              if (_banners.length > 1)
                                Positioned(
                                  right: 12,
                                  top: 10,
                                  child: Container(
                                    padding:
                                    const EdgeInsets.symmetric(
                                      horizontal: 9,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black
                                          .withOpacity(0.42),
                                      borderRadius:
                                      BorderRadius.circular(
                                          20),
                                      border: Border.all(
                                        color: Colors.white
                                            .withOpacity(0.20),
                                        width: 0.6,
                                      ),
                                    ),
                                    child: Text(
                                      '${index + 1}/${_banners.length}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight:
                                        FontWeight.w700,
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
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 9),

        // --------------------------------
        // PAGE INDICATORS
        // --------------------------------

        if (_banners.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _banners.length,
                  (index) {
                final isActive =
                    index == _currentBannerIndex;

                return AnimatedContainer(
                  duration:
                  const Duration(milliseconds: 280),
                  curve: Curves.easeOut,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 3,
                  ),
                  width: isActive ? 19 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isActive
                        ? MenuScreen.accent
                        : const Color(0xFFD0D9E2),
                    borderRadius:
                    BorderRadius.circular(10),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // --------------------------------------------------------
    // Separate API menus into Operations and Crate Management
    // --------------------------------------------------------

    final operationsMenus = _menuItems
        .where((item) => !_isCrateMenu(item))
        .toList();

    final crateMenus = _menuItems
        .where((item) => _isCrateMenu(item))
        .toList();

    // --------------------------------------------------------
    // LOADING
    // --------------------------------------------------------

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: MenuScreen.accent,
          ),
        ),
      );
    }

    // --------------------------------------------------------
    // STATIC ERROR SCREEN
    // --------------------------------------------------------

    if (_showErrorPage) {
      return Scaffold(
        body: _ErrorView(
          onRetry: _loadUserApps,
        ),
      );
    }

    // --------------------------------------------------------
    // MAIN MENU SCREEN
    // --------------------------------------------------------

    return Scaffold(
      drawer: _ProfileDrawer(
        onSignOut: () {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
                (route) => false,
          );
        },
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            'assets/images/menu1.png',
            fit: BoxFit.cover,
          ),

          // Soft scrim
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.55),
                  Colors.white.withOpacity(0.25),
                  Colors.white.withOpacity(0.55),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),

          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics:
                    const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      20,
                      20,
                      16,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints:
                        const BoxConstraints(
                          maxWidth: 600,
                        ),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.stretch,
                          children: [
                            // --------------------------------
                            // HEADER
                            // MENU BUTTON + CENTER TITLE
                            // --------------------------------

                            SizedBox(
                              height: 48,
                              child: Stack(
                                alignment:
                                Alignment.center,
                                children: [
                                  // MENU BUTTON
                                  Align(
                                    alignment:
                                    Alignment.centerLeft,
                                    child: Builder(
                                      builder: (context) =>
                                          ClipRRect(
                                            borderRadius:
                                            BorderRadius
                                                .circular(20),
                                            child:
                                            BackdropFilter(
                                              filter:
                                              ImageFilter.blur(
                                                sigmaX: 8,
                                                sigmaY: 8,
                                              ),
                                              child: Material(
                                                color: const Color(
                                                    0xFFEAF6FD)
                                                    .withOpacity(
                                                    0.55),
                                                shape:
                                                const CircleBorder(
                                                  side:
                                                  BorderSide(
                                                    color:
                                                    Colors.white70,
                                                    width: 1,
                                                  ),
                                                ),
                                                child:
                                                InkWell(
                                                  customBorder:
                                                  const CircleBorder(),
                                                  onTap: () =>
                                                      Scaffold.of(
                                                        context,
                                                      ).openDrawer(),
                                                  child:
                                                  const SizedBox(
                                                    width: 40,
                                                    height: 40,
                                                    child: Icon(
                                                      Icons
                                                          .menu_rounded,
                                                      size: 22,
                                                      color:
                                                      MenuScreen
                                                          .accent,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                    ),
                                  ),

                                  // --------------------------------
                                  // CENTER TITLE
                                  // --------------------------------

                                  const IgnorePointer(
                                    child: Text(
                                      'Distributor Demand App',
                                      textAlign:
                                      TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight:
                                        FontWeight.w800,
                                        color:
                                        Color(0xFF0D47A1),
                                        letterSpacing:
                                        -0.2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 14),

                            // --------------------------------
                            // BANNER
                            // --------------------------------

                            _buildBannerView(),

                            const SizedBox(height: 28),

                            // --------------------------------
                            // OPERATIONS
                            // --------------------------------

                            if (operationsMenus
                                .isNotEmpty) ...[
                              const _SectionTitle(
                                'Operations',
                              ),

                              const SizedBox(height: 12),

                              GridView.count(
                                crossAxisCount: 3,
                                shrinkWrap: true,
                                physics:
                                const NeverScrollableScrollPhysics(),
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 0.92,
                                  children: operationsMenus.map((menu) {
                                    return _MenuTile(
                                      icon: _iconForMenu(menu),
                                      title: menu,
                                      color: _colorForMenu(menu),
                                      compact: true,
                                      onTap: () {
                                        if (menu.toLowerCase() == 'place order' ) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => const PlaceOrderScreen(),
                                            ),
                                          );
                                        }
                                        else if (menu.toLowerCase() == 'report') {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => const CustomerDetailsScreen(
                                                screenType: 'report',
                                              ),
                                            ),
                                          );
                                        }
                                        else if (menu.toLowerCase() == 'make payment') {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => const CustomerDetailsScreen(
                                                screenType: 'make_payment',
                                              ),
                                            ),
                                          );
                                        }

                                      },
                                    );
                                  }).toList(),
                              ),
                            ],

                            // --------------------------------
                            // CRATE MANAGEMENT
                            // --------------------------------

                            if (crateMenus
                                .isNotEmpty) ...[
                              const SizedBox(height: 26),

                              const _SectionTitle(
                                'Crate Management',
                              ),

                              const SizedBox(height: 12),

                              GridView.count(
                                crossAxisCount: 3,
                                shrinkWrap: true,
                                physics:
                                const NeverScrollableScrollPhysics(),
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.92,
                                children:
                                crateMenus
                                    .map((menu) {
                                  return _MenuTile(
                                    icon:
                                    _iconForMenu(
                                        menu),
                                    title: menu,
                                    color:
                                    _colorForMenu(
                                        menu),
                                  );
                                }).toList(),
                              ),
                            ],

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // --------------------------------
                // FOOTER NAV BAR
                // --------------------------------

                _BottomNav(
                  currentIndex: _navIndex,
                  onTap: (index) =>
                      setState(() =>
                      _navIndex = index),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorView({
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Soft background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFF5FBFE),
                Color(0xFFE8F5FB),
                Color(0xFFDCEFF7),
              ],
            ),
          ),
        ),

        // Decorative circles
        Positioned(
          top: -90,
          right: -70,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
              MenuScreen.accent.withOpacity(0.07),
            ),
          ),
        ),

        Positioned(
          bottom: -100,
          left: -80,
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
              MenuScreen.accent.withOpacity(0.06),
            ),
          ),
        ),

        SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 28,
                vertical: 30,
              ),
              child: ClipRRect(
                borderRadius:
                BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 12,
                    sigmaY: 12,
                  ),
                  child: Container(
                    width: double.infinity,
                    constraints:
                    const BoxConstraints(
                      maxWidth: 420,
                    ),
                    padding:
                    const EdgeInsets.fromLTRB(
                      28,
                      34,
                      28,
                      30,
                    ),
                    decoration: BoxDecoration(
                      color:
                      Colors.white.withOpacity(0.88),
                      borderRadius:
                      BorderRadius.circular(30),
                      border: Border.all(
                        color:
                        Colors.white.withOpacity(0.9),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                          Colors.black.withOpacity(0.07),
                          blurRadius: 28,
                          offset:
                          const Offset(0, 14),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize:
                      MainAxisSize.min,
                      children: [
                        // CLOUD ICON
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: MenuScreen.accent
                                .withOpacity(0.09),
                          ),
                          child: Container(
                            margin:
                            const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient:
                              LinearGradient(
                                begin:
                                Alignment.topLeft,
                                end:
                                Alignment.bottomRight,
                                colors: [
                                  MenuScreen.accent
                                      .withOpacity(0.18),
                                  MenuScreen.accent
                                      .withOpacity(0.05),
                                ],
                              ),
                            ),
                            child: const Icon(
                              Icons.cloud_off_rounded,
                              size: 38,
                              color:
                              MenuScreen.accent,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // TITLE
                        const Text(
                          'Unable to load menu',
                          textAlign:
                          TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight:
                            FontWeight.w800,
                            color:
                            Color(0xFF172B3A),
                            letterSpacing: -0.3,
                          ),
                        ),

                        const SizedBox(height: 11),

                        // MESSAGE
                        const Text(
                          'Something went wrong\nfrom server',
                          textAlign:
                          TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            fontWeight:
                            FontWeight.w500,
                            color:
                            Color(0xFF71808C),
                          ),
                        ),

                        const SizedBox(height: 26),

                        // RETRY BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child:
                          ElevatedButton.icon(
                            onPressed: onRetry,
                            icon: const Icon(
                              Icons.refresh_rounded,
                              size: 20,
                            ),
                            label: const Text(
                              'Retry',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight:
                                FontWeight.w800,
                                letterSpacing: 0.2,
                              ),
                            ),
                            style:
                            ElevatedButton.styleFrom(
                              backgroundColor:
                              MenuScreen.accent,
                              foregroundColor:
                              Colors.white,
                              elevation: 0,
                              shadowColor:
                              Colors.transparent,
                              shape:
                              RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(
                                    15),
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
    );
  }
}

// ============================================================
// PROFILE DRAWER
// ============================================================

class _ProfileDrawer extends StatelessWidget {
  final VoidCallback onSignOut;

  const _ProfileDrawer({
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor:
      const Color(0xFFFAF4E6),
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black26,
      child: Container(
        color: const Color(0xFFFAF4E6),
        child: SafeArea(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding:
                const EdgeInsets.fromLTRB(
                  16,
                  12,
                  12,
                  8,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: MenuScreen.accent
                            .withOpacity(0.14),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        size: 24,
                        color:
                        MenuScreen.accent,
                      ),
                    ),

                    const SizedBox(width: 12),

                    const Expanded(
                      child: Text(
                        'Account',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight:
                          FontWeight.w700,
                          color:
                          Color(0xFF1C2B36),
                        ),
                      ),
                    ),

                    IconButton(
                      onPressed: () =>
                          Navigator.of(context)
                              .pop(),
                      icon: const Icon(
                        Icons.close_rounded,
                        color:
                        Color(0xFF7A8894),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              ListTile(
                leading: const Icon(
                  Icons.person_outline_rounded,
                  color: MenuScreen.accent,
                ),
                title: const Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight:
                    FontWeight.w600,
                    color:
                    Color(0xFF1C2B36),
                  ),
                ),
                onTap: () =>
                    Navigator.of(context)
                        .pop(),
              ),

              ListTile(
                leading: const Icon(
                  Icons.settings_outlined,
                  color: MenuScreen.accent,
                ),
                title: const Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight:
                    FontWeight.w600,
                    color:
                    Color(0xFF1C2B36),
                  ),
                ),
                onTap: () =>
                    Navigator.of(context)
                        .pop(),
              ),

              ListTile(
                leading: const Icon(
                  Icons.logout_rounded,
                  color: MenuScreen.accent,
                ),
                title: const Text(
                  'Sign out',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight:
                    FontWeight.w600,
                    color:
                    Color(0xFF1C2B36),
                  ),
                ),
                onTap: () {
                  Navigator.of(context)
                      .pop();
                  onSignOut();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// SECTION TITLE
// ============================================================

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 15,
          decoration: BoxDecoration(
            color: MenuScreen.accent,
            borderRadius:
            BorderRadius.circular(2),
          ),
        ),

        const SizedBox(width: 8),

        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: Color(0xFF1C2B36),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// GLASS PANEL
// ============================================================

class _GlassPanel extends StatelessWidget {
  final Widget child;
  final double radius;
  final EdgeInsets padding;

  const _GlassPanel({
    required this.child,
    this.radius = 18,
    this.padding =
    const EdgeInsets.all(12),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius:
      BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 8,
          sigmaY: 8,
        ),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF6FD)
                .withOpacity(0.92),
            borderRadius:
            BorderRadius.circular(radius),
            border: Border.all(
              color:
              Colors.white.withOpacity(0.75),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color:
                Colors.black.withOpacity(0.06),
                blurRadius: 16,
                offset:
                const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

// ============================================================
// MENU TILE
// ============================================================

class _MenuTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final bool compact;
  final Color color;

  const _MenuTile({
    required this.icon,
    required this.title,
    this.onTap,
    this.compact = false,
    this.color = MenuScreen.accent,
  });

  @override
  State<_MenuTile> createState() =>
      _MenuTileState();
}

class _MenuTileState
    extends State<_MenuTile> {
  bool _pressed = false;

  // Builds a light-to-dark radial gradient
  // from the base color.
  Color _lighten(
      Color color,
      double amount,
      ) {
    final hsl =
    HSLColor.fromColor(color);

    return hsl
        .withLightness(
      (hsl.lightness + amount)
          .clamp(0.0, 1.0),
    )
        .toColor();
  }

  Color _darken(
      Color color,
      double amount,
      ) {
    final hsl =
    HSLColor.fromColor(color);

    return hsl
        .withLightness(
      (hsl.lightness - amount)
          .clamp(0.0, 1.0),
    )
        .toColor();
  }

  @override
  Widget build(BuildContext context) {
    final Color textColor = _pressed
        ? widget.color
        : const Color(0xFF1C2B36);

    final double iconBadgeSize =
    widget.compact ? 38 : 44;

    final double iconSize =
    widget.compact ? 19 : 22;

    final double fontSize =
    widget.compact ? 11 : 12;

    final double tileRadius =
    widget.compact ? 16 : 18;

    return AnimatedScale(
      duration:
      const Duration(milliseconds: 120),
      scale: _pressed ? 0.97 : 1.0,
      child: Container(
        padding:
        EdgeInsets.symmetric(
          horizontal: 6,
          vertical:
          widget.compact ? 8 : 10,
        ),
        decoration: BoxDecoration(
          color:
          const Color(0xFFF3F4F6),
          borderRadius:
          BorderRadius.circular(
              tileRadius),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0B2A3D)
                  .withOpacity(
                _pressed ? 0.04 : 0.08,
              ),
              blurRadius:
              _pressed ? 8 : 14,
              offset:
              const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap:
            widget.onTap ?? () {},
            onHighlightChanged: (v) {
              setState(() =>
              _pressed = v);
            },
            borderRadius:
            BorderRadius.circular(
                tileRadius),
            splashColor:
            widget.color.withOpacity(
                0.18),
            child: Column(
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: [
                Container(
                  width:
                  iconBadgeSize,
                  height:
                  iconBadgeSize,
                  decoration:
                  BoxDecoration(
                    shape:
                    BoxShape.circle,
                    gradient:
                    RadialGradient(
                      center:
                      const Alignment(
                        -0.3,
                        -0.3,
                      ),
                      radius: 0.9,
                      colors: [
                        _lighten(
                          widget.color,
                          0.14,
                        ),
                        _darken(
                          widget.color,
                          0.06,
                        ),
                      ],
                    ),
                  ),
                  child: Icon(
                    widget.icon,
                    size: iconSize,
                    color: Colors.white,
                  ),
                ),

                SizedBox(
                  height:
                  widget.compact
                      ? 6
                      : 8,
                ),

                Padding(
                  padding:
                  const EdgeInsets
                      .symmetric(
                    horizontal: 2,
                  ),
                  child: Text(
                    widget.title,
                    textAlign:
                    TextAlign.center,
                    maxLines: 2,
                    overflow:
                    TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize:
                      fontSize,
                      fontWeight:
                      FontWeight.w600,
                      letterSpacing:
                      0.1,
                      color:
                      textColor,
                    ),
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

// ============================================================
// BOTTOM NAVIGATION
// ============================================================

class _BottomNav
    extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    (
    icon: Icons.home_rounded,
    label: 'Home',
    ),
    (
    icon: Icons.checklist_rounded,
    label: 'Task',
    ),
    (
    icon: Icons.explore_rounded,
    label: 'Explore',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius:
      const BorderRadius.vertical(
        top: Radius.circular(22),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 16,
          sigmaY: 16,
        ),
        child: Container(
          padding:
          const EdgeInsets.symmetric(
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: const Color(
              0xFFEAF6FD,
            ).withOpacity(0.20),
            border: Border(
              top: BorderSide(
                color: const Color(
                  0xFFEAF6FD,
                ).withOpacity(0.20),
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              mainAxisAlignment:
              MainAxisAlignment
                  .spaceEvenly,
              children:
              List.generate(
                _items.length,
                    (index) {
                  final item =
                  _items[index];

                  final bool selected =
                      index ==
                          currentIndex;

                  final Color color =
                  selected
                      ? MenuScreen
                      .accent
                      : const Color(
                    0xFF7A8894,
                  );

                  return InkWell(
                    onTap: () =>
                        onTap(index),
                    borderRadius:
                    BorderRadius
                        .circular(14),
                    child: Padding(
                      padding:
                      const EdgeInsets
                          .symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      child: Column(
                        mainAxisSize:
                        MainAxisSize.min,
                        children: [
                          Icon(
                            item.icon,
                            size: 22,
                            color: color,
                          ),
                          const SizedBox(
                              height: 3),
                          Text(
                            item.label,
                            style:
                            TextStyle(
                              fontSize: 11,
                              fontWeight:
                              selected
                                  ? FontWeight
                                  .w700
                                  : FontWeight
                                  .w500,
                              color:
                              color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}








