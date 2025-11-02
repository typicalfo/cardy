import 'package:flutter/material.dart';
import '../models/business_card.dart';
import '../services/card_service.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<BusinessCard> _cards = [];
  bool _isLoading = true;
  String _searchQuery = '';
  List<BusinessCard> _filteredCards = [];

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    final cards = await CardService.getCards();
    if (mounted) {
      setState(() {
        _cards = cards;
        _filteredCards = cards;
        _isLoading = false;
      });
    }
  }

  void _filterCards(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredCards = _cards;
      } else {
        final lowerQuery = query.toLowerCase();
        _filteredCards = _cards.where((card) {
          return card.name.toLowerCase().contains(lowerQuery) ||
              card.company.toLowerCase().contains(lowerQuery) ||
              card.email.toLowerCase().contains(lowerQuery);
        }).toList();
      }
    });
  }

  Future<void> _refreshCards() async {
    setState(() => _isLoading = true);
    await _loadCards();
  }

  void _navigateToCard(BusinessCard card) {
    Navigator.pushNamed(
      context,
      '/card',
      arguments: card.id,
    ).then((_) => _loadCards()); // Refresh when returning
  }

  void _navigateToEdit(BusinessCard card) {
    Navigator.pushNamed(
      context,
      '/edit',
      arguments: card,
    ).then((_) => _loadCards()); // Refresh when returning
  }

  Future<void> _deleteCard(BusinessCard card) async {
    final confirmed = await _showDeleteConfirmation(card);
    if (confirmed == true) {
      await CardService.deleteCard(card.id);
      _loadCards();
    }
  }

  Future<bool> _showDeleteConfirmation(BusinessCard card) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Card'),
        content: Text('Are you sure you want to delete ${card.name}\'s business card?'),
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
    return result ?? false;
  }

  Future<void> _setDefaultCard(BusinessCard card) async {
    await CardService.setDefaultCardId(card.id);
    _loadCards();
  }

  Widget _buildEmptyState() {
    final isSearchMode = _searchQuery.isNotEmpty;
    
    if (isSearchMode) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No cards found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search terms',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                setState(() => _searchQuery = '');
                _filterCards('');
              },
              icon: const Icon(Icons.clear),
              label: const Text('Clear Search'),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.business_center,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No business cards yet',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Create your first business card to start networking\nand sharing your professional information',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/edit'),
              icon: const Icon(Icons.add),
              label: const Text('Create Business Card'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine crossAxisCount based on screen width
        int crossAxisCount;
        if (constraints.maxWidth > 1200) {
          crossAxisCount = 4; // Desktop
        } else if (constraints.maxWidth > 800) {
          crossAxisCount = 3; // Tablet
        } else if (constraints.maxWidth > 600) {
          crossAxisCount = 2; // Large phone
        } else {
          crossAxisCount = 1; // Small phone
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.6,
          ),
          itemCount: _filteredCards.length,
          itemBuilder: (context, index) {
            return AnimatedContainer(
              duration: Duration(milliseconds: 300 + (index * 50)),
              curve: Curves.easeOut,
              child: _buildCardGridItem(_filteredCards[index]),
            );
          },
        );
      },
    );
  }

  Widget _buildCardGridItem(BusinessCard card) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: Card(
        elevation: 4,
        child: AnimatedScale(
          scale: 1.0,
          duration: const Duration(milliseconds: 150),
          child: InkWell(
            onTap: () => _navigateToCard(card),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                card.name,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (card.isDefault)
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Default',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (card.company.isNotEmpty)
                          Text(
                            card.company,
                            style: Theme.of(context).textTheme.bodyMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        if (card.title.isNotEmpty)
                          Text(
                            card.title,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        const Spacer(),
                        if (card.email.isNotEmpty)
                          Text(
                            card.email,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AnimatedIconButton(
                        onPressed: () => _navigateToCard(card),
                        icon: const Icon(Icons.visibility_outlined),
                        tooltip: 'View',
                      ),
                      AnimatedIconButton(
                        onPressed: () => _navigateToEdit(card),
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: 'Edit',
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (value) async {
                          switch (value) {
                            case 'delete':
                              await _deleteCard(card);
                              break;
                            case 'default':
                              await _setDefaultCard(card);
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                const Icon(Icons.delete, size: 16, color: Colors.red),
                                const SizedBox(width: 8),
                                const Text('Delete'),
                              ],
                            ),
                          ),
                          if (!card.isDefault)
                            PopupMenuItem(
                              value: 'default',
                              child: Row(
                                children: [
                                  const Icon(Icons.star, size: 16),
                                  const SizedBox(width: 8),
                                  const Text('Set as Default'),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: _filteredCards.length,
      itemBuilder: (context, index) {
        return _buildCardListItem(_filteredCards[index]);
      },
    );
  }

  Widget _buildCardListItem(BusinessCard card) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => _navigateToCard(card),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      card.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  if (card.isDefault)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Default',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              if (card.company.isNotEmpty)
                Text(
                  card.company,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              if (card.title.isNotEmpty)
                Text(
                  card.title,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => _navigateToCard(card),
                    child: const Text('View'),
                  ),
                  TextButton(
                    onPressed: () => _navigateToEdit(card),
                    child: const Text('Edit'),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) async {
                      switch (value) {
                        case 'delete':
                          await _deleteCard(card);
                          break;
                        case 'default':
                          await _setDefaultCard(card);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 16, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                      if (!card.isDefault)
                        const PopupMenuItem(
                          value: 'default',
                          child: Row(
                            children: [
                              Icon(Icons.star, size: 16),
                              SizedBox(width: 8),
                              Text('Set as Default'),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: TextField(
        onChanged: _filterCards,
        decoration: InputDecoration(
          hintText: 'Search business cards...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    setState(() => _searchQuery = '');
                    _filterCards('');
                  },
                  icon: const Icon(Icons.clear),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Business Cards'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/edit'),
            icon: const Icon(Icons.add),
            tooltip: 'Add New Card',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshCards,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  _buildSearchBar(),
                  Expanded(
                    child: _filteredCards.isEmpty
                        ? _buildEmptyState()
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              // Use grid layout for wider screens, list for narrow screens
                              if (constraints.maxWidth > 600) {
                                return _buildCardGrid();
                              } else {
                                return _buildCardList();
                              }
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}

class AnimatedIconButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Icon icon;
  final String? tooltip;

  const AnimatedIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
  });

  @override
  State<AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<AnimatedIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: IconButton(
              onPressed: widget.onPressed,
              icon: widget.icon,
              tooltip: widget.tooltip,
              visualDensity: VisualDensity.compact,
            ),
          );
        },
      ),
    );
  }
}