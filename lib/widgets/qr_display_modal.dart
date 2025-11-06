import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

enum QrType { website, email, phone, vcard }

class QrDisplayModal extends StatefulWidget {
  const QrDisplayModal({
    super.key,
    required this.payload,
    required this.title,
    required this.type,
    this.logoUrl,
  });

  final String payload;
  final String title;
  final QrType type;
  final String? logoUrl;

  @override
  State<QrDisplayModal> createState() => _QrDisplayModalState();
}

class _QrDisplayModalState extends State<QrDisplayModal> {
  final GlobalKey _qrKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _shareQrCode,
                        icon: const Icon(Icons.share, color: Colors.white),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // QR Code Display
            Expanded(
              child: Center(
                child: RepaintBoundary(
                  key: _qrKey,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.3),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: PrettyQrView.data(
                      data: widget.payload,
                      decoration: PrettyQrDecoration(
                        shape: const PrettyQrSmoothSymbol(
                          roundFactor: 0.15,
                        ),
                        image: widget.logoUrl != null
                            ? PrettyQrDecorationImage(
                                image: NetworkImage(widget.logoUrl!),
                                position: PrettyQrDecorationImagePosition.embedded,
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Footer with instructions
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Scan this QR code to ${_getActionText()}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Point your camera at the code',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getActionText() {
    switch (widget.type) {
      case QrType.website:
        return 'visit the website';
      case QrType.email:
        return 'send an email';
      case QrType.phone:
        return 'make a phone call';
      case QrType.vcard:
        return 'save the contact';
    }
  }

  Future<void> _shareQrCode() async {
    try {
      final RenderRepaintBoundary boundary = _qrKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData != null) {
        final Uint8List pngBytes = byteData.buffer.asUint8List();
        final directory = await getTemporaryDirectory();
        final file = File('${directory.path}/qr_code_${widget.type.name}.png');
        await file.writeAsBytes(pngBytes);
        
        await Share.shareXFiles([XFile(file.path)], text: 'QR Code for ${widget.title}');
      }
    } catch (e) {
      // Handle error silently or show snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to share QR code')),
        );
      }
    }
  }
}