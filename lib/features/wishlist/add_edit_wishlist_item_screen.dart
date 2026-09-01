import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme/app_colors.dart';
import '../../models/wishlist_item.dart';
import '../../providers/collection_provider.dart';
import '../../providers/preferences_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../widgets/visi_cherry_logo.dart';
import '../../widgets/visi_feedback.dart';

class AddEditWishlistItemScreen extends ConsumerStatefulWidget {
  final WishlistItem? initialItem;

  const AddEditWishlistItemScreen({
    super.key,
    this.initialItem,
  });

  @override
  ConsumerState<AddEditWishlistItemScreen> createState() => _AddEditWishlistItemScreenState();
}

class _AddEditWishlistItemScreenState extends ConsumerState<AddEditWishlistItemScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _priceController;
  late TextEditingController _storeController;
  late TextEditingController _imagePathController;
  late TextEditingController _productUrlController;
  late TextEditingController _notesController;

  late String _currency;
  late String _collectionId;
  late ItemPriority _priority;
  late bool _isFavorite;

  // Preset lifestyle image URLs for fast aesthetic selection
  final List<String> _presetImages = [
    'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1592945403244-b3fbafd7f539?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1520903920243-00d872a2d1c9?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1517668808822-9ebe02afd2a1?auto=format&fit=crop&w=800&q=80',
  ];

  @override
  void initState() {
    super.initState();
    final item = widget.initialItem;

    _titleController = TextEditingController(text: item?.title ?? '');
    _priceController = TextEditingController(text: item != null ? item.price.toStringAsFixed(0) : '');
    _storeController = TextEditingController(text: item?.store ?? '');
    _imagePathController = TextEditingController(text: item?.imagePath ?? '');
    _productUrlController = TextEditingController(text: item?.productUrl ?? '');
    _notesController = TextEditingController(text: item?.notes ?? '');

    final defaultCurr = ref.read(preferencesProvider).defaultCurrency;
    _currency = item?.currency ?? defaultCurr;

    final collections = ref.read(collectionProvider);
    _collectionId = item?.collectionId ?? (collections.isNotEmpty ? collections.first.id : 'col_dream');

    _priority = item?.priority ?? ItemPriority.medium;
    _isFavorite = item?.isFavorite ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _storeController.dispose();
    _imagePathController.dispose();
    _productUrlController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final store = _storeController.text.trim().isNotEmpty ? _storeController.text.trim() : null;
    final imagePath = _imagePathController.text.trim().isNotEmpty ? _imagePathController.text.trim() : null;
    final productUrl = _productUrlController.text.trim().isNotEmpty ? _productUrlController.text.trim() : null;
    final notes = _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null;

    final isEdit = widget.initialItem != null;
    final id = isEdit ? widget.initialItem!.id : const Uuid().v4();
    final createdAt = isEdit ? widget.initialItem!.createdAt : DateTime.now();

    final newItem = WishlistItem(
      id: id,
      title: title,
      price: price,
      currency: _currency,
      store: store,
      imagePath: imagePath,
      productUrl: productUrl,
      collectionId: _collectionId,
      notes: notes,
      priority: _priority,
      isFavorite: _isFavorite,
      createdAt: createdAt,
    );

    if (isEdit) {
      ref.read(wishlistProvider.notifier).updateItem(newItem);
    } else {
      ref.read(wishlistProvider.notifier).addItem(newItem);
    }

    VisiFeedback.showSuccess(
      context,
      isEdit ? 'Dilek güncellendi' : 'Dilek listene eklendi ✨',
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final collections = ref.watch(collectionProvider);
    final isEdit = widget.initialItem != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Dileği Düzenle' : 'Yeni Dilek'),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: _isFavorite ? AppColors.cherryAccent : (isDark ? Colors.white70 : AppColors.lightTextSecondary),
            ),
            onPressed: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Title Input
                Text('ÜRÜN ADI', style: theme.textTheme.labelSmall),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  style: theme.textTheme.bodyLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
                  decoration: const InputDecoration(
                    hintText: 'Örn: Bang & Olufsen Kulaklık',
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Lütfen bir ürün adı girin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Price and Currency Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('FİYAT', style: theme.textTheme.labelSmall),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            style: theme.textTheme.bodyLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.w700),
                            decoration: const InputDecoration(
                              hintText: '0.00',
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Fiyat girin';
                              }
                              if (double.tryParse(val.trim()) == null) {
                                return 'Geçerli fiyat girin';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('PARA BİRİMİ', style: theme.textTheme.labelSmall),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: _currency,
                            decoration: const InputDecoration(),
                            items: ['₺', '\$', '€', '£', '¥'].map((curr) {
                              return DropdownMenuItem(value: curr, child: Text(curr));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _currency = val);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Store and Collection Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('MAĞAZA / MARKA', style: theme.textTheme.labelSmall),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _storeController,
                            decoration: const InputDecoration(hintText: 'Beymen, Amazon, Apple...'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Collection Picker
                Text('KOLEKSİYON', style: theme.textTheme.labelSmall),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: collections.any((c) => c.id == _collectionId)
                      ? _collectionId
                      : (collections.isNotEmpty ? collections.first.id : null),
                  decoration: const InputDecoration(),
                  items: collections.map((col) {
                    return DropdownMenuItem(
                      value: col.id,
                      child: Row(
                        children: [
                          Text(col.emoji),
                          const SizedBox(width: 8),
                          Text(col.name),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _collectionId = val);
                  },
                ),
                const SizedBox(height: 20),

                // Image URL & Preset Picker
                Text('GÖRSEL URL', style: theme.textTheme.labelSmall),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _imagePathController,
                  decoration: const InputDecoration(
                    hintText: 'https://images.unsplash.com/...',
                    prefixIcon: Icon(Icons.image_outlined, size: 20),
                  ),
                  onChanged: (val) => setState(() {}),
                ),
                const SizedBox(height: 10),

                // Preset Aesthetic Images Row
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _presetImages.length,
                    itemBuilder: (context, index) {
                      final url = _presetImages[index];
                      final isSelected = _imagePathController.text == url;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _imagePathController.text = url;
                          });
                        },
                        child: Container(
                          width: 60,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? AppColors.cherryAccent : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(url, fit: BoxFit.cover),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Priority Selection
                Text('ÖNCELİK SEVİYESİ', style: theme.textTheme.labelSmall),
                const SizedBox(height: 8),
                Row(
                  children: ItemPriority.values.map((p) {
                    final isSelected = _priority == p;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: isSelected
                                ? AppColors.cherryAccent
                                : (isDark ? AppColors.darkCard : AppColors.lightCard),
                            foregroundColor: isSelected
                                ? Colors.white
                                : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                            side: BorderSide(
                              color: isSelected
                                  ? AppColors.cherryAccent
                                  : (isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: () => setState(() => _priority = p),
                          child: Text(p.label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Product URL
                Text('ÜRÜN BAĞLANTISI (URL)', style: theme.textTheme.labelSmall),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _productUrlController,
                  decoration: const InputDecoration(
                    hintText: 'https://...',
                    prefixIcon: Icon(Icons.link_rounded, size: 20),
                  ),
                ),
                const SizedBox(height: 20),

                // Notes Textarea
                Text('NOTLARIM', style: theme.textTheme.labelSmall),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Renk tercihi, beden bilgisi veya özel notlar...',
                  ),
                ),
                const SizedBox(height: 32),

                // Save Action Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cherryAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      elevation: 4,
                      shadowColor: AppColors.cherryAccent.withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const VisiCherryLogo(size: 18, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          isEdit ? 'Dileği Güncelle' : 'Dileği Kaydet',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                      ],
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
