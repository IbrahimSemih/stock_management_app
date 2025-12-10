import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';
import '../utils/constants.dart';
import '../l10n/app_localizations.dart';

class BarcodeScanScreen extends StatefulWidget {
  const BarcodeScanScreen({super.key});

  @override
  State<BarcodeScanScreen> createState() => _BarcodeScanScreenState();
}

class _BarcodeScanScreenState extends State<BarcodeScanScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isScanning = true;
  String? _scannedBarcode;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture capture) {
    if (!_isScanning) return;

    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    setState(() {
      _isScanning = false;
      _scannedBarcode = barcode.rawValue;
    });

    _processBarcode(_scannedBarcode!);
  }

  Future<void> _processBarcode(String barcode) async {
    final productProvider = context.read<ProductProvider>();
    await productProvider.loadAllProducts();

    // Ürünü barkod ile bul
    Product? foundProduct;
    try {
      foundProduct = productProvider.products.firstWhere(
        (p) => p.barcode == barcode,
      );
    } catch (e) {
      foundProduct = null;
    }

    if (!mounted) return;

    if (foundProduct != null && foundProduct.id != null) {
      // Ürün bulundu, detay sayfasına git
      Navigator.pop(context);
      Navigator.pushNamed(
        context,
        AppConstants.routeProductDetail,
        arguments: {'productId': foundProduct.id},
      );
    } else {
      // Ürün bulunamadı, yeni ürün oluşturma seçeneği sun
      _showProductNotFoundDialog(barcode);
    }
  }

  void _showProductNotFoundDialog(String barcode) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr('product_not_found')),
        content: Text(
          '${context.tr('no_barcode_found')}\n\nBarcode: $barcode',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _isScanning = true;
                _scannedBarcode = null;
              });
            },
            child: Text(context.tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
              Navigator.pushNamed(
                context,
                AppConstants.routeProductEdit,
                arguments: {
                  'productId': null,
                  'barcode': barcode,
                },
              );
            },
            child: Text(context.tr('create_product')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('scan_barcode')),
      ),
      body: Stack(
        children: [
          // Camera View
          MobileScanner(
            controller: _controller,
            onDetect: _handleBarcode,
          ),

          // Overlay
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            margin: const EdgeInsets.all(100),
            child: Center(
              child: Text(
                context.tr('point_camera'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Instructions
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.qr_code_scanner,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isScanning
                        ? context.tr('scan_barcode')
                        : context.tr('processing'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Manual Entry Button
          Positioned(
            top: 16,
            right: 16,
            child: FloatingActionButton(
              heroTag: 'barcode_scan_fab',
              mini: true,
              onPressed: () {
                _showManualEntryDialog();
              },
              child: const Icon(Icons.keyboard),
            ),
          ),
        ],
      ),
    );
  }

  void _showManualEntryDialog() {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr('enter_barcode')),
        content: TextField(
          controller: textController,
          decoration: InputDecoration(
            hintText: context.tr('barcode'),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                Navigator.pop(ctx);
                _processBarcode(textController.text.trim());
              }
            },
            child: Text(context.tr('search')),
          ),
        ],
      ),
    );
  }
}

