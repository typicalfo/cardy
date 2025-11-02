import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/business_card.dart';
import '../services/card_service.dart';
import '../utils/brightness.dart';

class CardScreen extends StatefulWidget {
  const CardScreen({super.key, this.cardId});

  final String? cardId;

  @override
  State<CardScreen> createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen> {
  BusinessCard? _card;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCard();
    _setupDisplay();
  }

  Future<void> _loadCard() async {
    if (widget.cardId != null) {
      _card = await CardService.getCard(widget.cardId!);
    } else {
      _card = await CardService.getDefaultCard();
    }
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _setupDisplay() async {
    await BrightnessUtils.setMaxBrightness();
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  Future<void> _resetDisplay() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  Future<void> _deleteCard() async {
    if (_card == null) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Card'),
        content: Text('Are you sure you want to delete ${_card!.name}\'s business card?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await CardService.deleteCard(_card!.id);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _editCard() async {
    if (_card == null) return;
    Navigator.pushNamed(context, '/edit', arguments: _card);
  }

  Future<void> _setDefaultCard() async {
    if (_card == null) return;
    await CardService.setDefaultCardId(_card!.id);
    _loadCard(); // Reload to update default indicator
  }

  @override
  void dispose() {
    _resetDisplay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_card?.name ?? 'Business Card'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          if (_card != null) ...[
            IconButton(
              onPressed: _editCard,
              icon: const Icon(Icons.edit),
              tooltip: 'Edit Card',
            ),
            PopupMenuButton<String>(
              onSelected: (value) async {
                switch (value) {
                  case 'delete':
                    await _deleteCard();
                    break;
                  case 'default':
                    await _setDefaultCard();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 16, color: Colors.red),
                      const SizedBox(width: 8),
                      const Text('Delete'),
                    ],
                  ),
                ),
                if (!_card!.isDefault)
                  const PopupMenuItem(
                    value: 'default',
                    child: Row(
                      children: [
                        Icon(Icons.star, size: 16),
                        const SizedBox(width: 8),
                        const Text('Set as Default'),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _card == null
              ? const Center(
                  child: Text(
                    'Card not found',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.grey,
                    ),
                  ),
                )
              : Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (_card!.name.isNotEmpty)
                        Text(
                          _card!.name,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      const SizedBox(height: 16),
                      if (_card!.title.isNotEmpty)
                        Text(
                          _card!.title,
                          style: const TextStyle(
                            fontSize: 28,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      const SizedBox(height: 16),
                      if (_card!.company.isNotEmpty)
                        Text(
                          _card!.company,
                          style: const TextStyle(
                            fontSize: 26,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      const SizedBox(height: 24),
                      if (_card!.phone.isNotEmpty)
                        Text(
                          _card!.phone,
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      const SizedBox(height: 16),
                      if (_card!.email.isNotEmpty)
                        Text(
                          _card!.email,
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      const SizedBox(height: 16),
                      if (_card!.website.isNotEmpty)
                        Text(
                          _card!.website,
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                ),
    );
  }
}