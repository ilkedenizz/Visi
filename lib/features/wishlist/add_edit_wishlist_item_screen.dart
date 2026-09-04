import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme/app_colors.dart';
import '../../models/user_preferences.dart';
import '../../models/wish_status.dart';
import '../../models/wish_type.dart';
import '../../models/wishlist_item.dart';
import '../../providers/collection_provider.dart';
import '../../providers/image_repository_provider.dart';
import '../../providers/preferences_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../services/image_storage_service.dart';
import '../../widgets/visi_cherry_logo.dart';
import '../../widgets/visi_feedback.dart';
import '../../widgets/visi_image.dart';

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

  late WishType _type;
  late WishStatus _status;
  DateTime? _targetDate;
  late String _currency;
  late String _collectionId;
  late ItemPriority _priority;
  late bool _isFavorite;
  XFile? _selectedImageFile;
  Uint8List? _selectedImageBytes;

  @override
  void initState() {
    super.initState();
    final item = widget.initialItem;

    _titleController = TextEditingController(text: item?.title ?? '');
    _priceController = TextEditingController(text: item != null && item.price > 0 ? item.price.toStringAsFixed(0) : '');
    _storeController = TextEditingController(text: item?.store ?? '');
    _imagePathController = TextEditingController(text: item?.imagePath ?? '');
    _productUrlController = TextEditingController(text: item?.productUrl ?? '');
    _notesController = TextEditingController(text: item?.notes ?? '');

    _type = item?.type ?? WishType.toDo;
    _status = item?.status ?? WishStatus.wishing;
    _targetDate = item?.targetDate;

    final prefs = ref.read(preferencesProvider).asData?.value ?? const UserPreferences();
    _currency = item?.currency ?? prefs.defaultCurrency;

    final collections = ref.read(collectionProvider).asData?.value ?? [];
    final lastColId = prefs.lastSelectedCollectionId;
    _collectionId = item?.collectionId ??
        (lastColId != null && collections.any((c) => c.id == lastColId)
            ? lastColId
            : (collections.isNotEmpty ? collections.first.id : 'col_dream'));

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

  Future<void> _pickImageFromGallery() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() {
          _selectedImageFile = picked;
          _imagePathController.text = '';
        });
        if (kIsWeb) {
          final bytes = await picked.readAsBytes();
          setState(() {
            _selectedImageBytes = bytes;
          });
        } else {
          _imagePathController.text = picked.path;
        }
      }
    } catch (e) {
      if (mounted) {
        VisiFeedback.showError(context, 'Görsel seçilirken bir hata oluştu: $e');
      }
    }
  }

  Widget _buildImagePickerArea(bool isDark, ThemeData theme) {
    final hasImage = _imagePathController.text.trim().isNotEmpty || _selectedImageBytes != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('GÖRSELLEŞTİR', style: theme.textTheme.labelSmall),
        const SizedBox(height: 8),
        if (hasImage) ...[
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: _selectedImageBytes != null
                  ? Image.memory(_selectedImageBytes!, fit: BoxFit.cover)
                  : VisiImage(imageUrl: _imagePathController.text),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickImageFromGallery,
                  icon: const Icon(Icons.photo_library_outlined, size: 18),
                  label: const Text('Görseli değiştir', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    foregroundColor: AppColors.cherryAccent,
                    side: const BorderSide(color: AppColors.cherryAccent),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              TextButton.icon(
                onPressed: _removeImage,
                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.cherryAccent),
                label: const Text('Görseli kaldır', style: TextStyle(color: AppColors.cherryAccent, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ] else ...[
          InkWell(
            onTap: _pickImageFromGallery,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: 130,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.blushPink.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.darkCardBorder : AppColors.cherryAccent.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: AppColors.cherryAccent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add_a_photo_outlined, color: Colors.white, size: 20),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '+ Dileğini görselleştir',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Kendi fotoğrafını veya ilham verici bir görsel ekle',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _removeImage() {
    setState(() {
      _selectedImageFile = null;
      _selectedImageBytes = null;
      _imagePathController.text = '';
    });
  }

  Future<void> _selectTargetDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? DateTime(now.year + 1, now.month, now.day),
      firstDate: now,
      lastDate: DateTime(now.year + 10),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.cherryAccent,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _targetDate = picked);
    }
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final store = _storeController.text.trim().isNotEmpty ? _storeController.text.trim() : null;
    final productUrl = _productUrlController.text.trim().isNotEmpty ? _productUrlController.text.trim() : null;
    final notes = _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null;

    final isEdit = widget.initialItem != null;
    final id = isEdit ? widget.initialItem!.id : const Uuid().v4();
    final createdAt = isEdit ? widget.initialItem!.createdAt : DateTime.now();

    final double priceValue = double.tryParse(_priceController.text.trim()) ?? 0.0;

    String? finalImageReference = isEdit ? (kIsWeb ? widget.initialItem?.imageId : widget.initialItem?.imagePath) : null;

    if (_selectedImageFile != null) {
      if (kIsWeb) {
        final bytes = await _selectedImageFile!.readAsBytes();
        _selectedImageBytes = bytes;
        final repo = ref.read(imageRepositoryProvider);
        final imageId = await repo.saveImage(bytes);
        finalImageReference = imageId;
      } else {
        final savedPath = await ImageStorageService.saveImage(File(_selectedImageFile!.path));
        if (isEdit && widget.initialItem?.imagePath != null && widget.initialItem!.imagePath != savedPath) {
          await ImageStorageService.deleteLocalImage(widget.initialItem!.imagePath!);
        }
        finalImageReference = savedPath;
      }
    } else if (isEdit && widget.initialItem?.imagePath != null && _imagePathController.text.isEmpty && _selectedImageBytes == null) {
      if (!kIsWeb) {
        await ImageStorageService.deleteLocalImage(widget.initialItem!.imagePath!);
      }
      finalImageReference = null;
    }

    final newItem = WishlistItem(
      id: id,
      title: title,
      type: _type,
      status: _status,
      price: _type == WishType.toOwn ? priceValue : 0.0,
      currency: _currency,
      store: _type == WishType.toOwn ? store : null,
      imagePath: kIsWeb ? null : finalImageReference,
      imageId: kIsWeb ? finalImageReference : null,
      productUrl: _type == WishType.toOwn ? productUrl : null,
      collectionId: _collectionId,
      notes: notes,
      targetDate: _targetDate,
      priority: _priority,
      isFavorite: _isFavorite,
      createdAt: createdAt,
    );

    ref.read(preferencesProvider.notifier).updateDefaultCurrency(_currency);
    ref.read(preferencesProvider.notifier).updateLastSelectedCollectionId(_collectionId);

    if (isEdit) {
      await ref.read(wishlistProvider.notifier).updateItem(newItem);
    } else {
      await ref.read(wishlistProvider.notifier).addItem(newItem);
    }

    if (mounted) {
      VisiFeedback.showSuccess(
        context,
        isEdit ? 'Dilek güncellendi' : 'Dilek listene eklendi ✨',
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final collections = ref.watch(collectionProvider).asData?.value ?? [];
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
            onPressed: () => setState(() => _isFavorite = !_isFavorite),
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
                // Title Input
                Text('NE DİLİYORSUN?', style: theme.textTheme.labelSmall),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  autofocus: !isEdit,
                  style: theme.textTheme.bodyLarge?.copyWith(fontSize: 17, fontWeight: FontWeight.w700),
                  decoration: const InputDecoration(
                    hintText: 'Örn: Gitar çalmayı öğrenmek, Japonya\'ya gitmek...',
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Lütfen bir dilek başlığı girin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Wish Type Selection Row
                Text('DİLEK TÜRÜ', style: theme.textTheme.labelSmall),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: WishType.values.map((type) {
                      final isSelected = _type == type;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(type.label),
                          selected: isSelected,
                          selectedColor: AppColors.cherryAccent,
                          backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 13,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: isSelected ? AppColors.cherryAccent : (isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
                            ),
                          ),
                          onSelected: (selected) {
                            if (selected) setState(() => _type = type);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),

                // Image Picker Area
                _buildImagePickerArea(isDark, theme),
                const SizedBox(height: 24),

                // Notes / Description
                Text('BUNU NEDEN İSTİYORUM?', style: theme.textTheme.labelSmall),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Detaylar, duygular veya notlar...',
                  ),
                ),
                const SizedBox(height: 24),

                // Target Date & Collection Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Target Date
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('HEDEF ZAMAN', style: theme.textTheme.labelSmall),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () => _selectTargetDate(context),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.cherryAccent),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _targetDate != null ? '${_targetDate!.year}' : 'Tarih seç',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: _targetDate != null
                                            ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                                            : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                                      ),
                                    ),
                                  ),
                                  if (_targetDate != null)
                                    GestureDetector(
                                      onTap: () => setState(() => _targetDate = null),
                                      child: const Icon(Icons.close_rounded, size: 16),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Collection Picker
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        col.name,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _collectionId = val);
                                ref.read(preferencesProvider.notifier).updateLastSelectedCollectionId(val);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Priority Selection
                Text('ÖNCELİK', style: theme.textTheme.labelSmall),
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

                // Conditional Shopping Section (Displayed ONLY for Sahip Olmak / toOwn)
                if (_type == WishType.toOwn) ...[
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text('ÜRÜN DETAYLARI (OPSİYONEL)', style: theme.textTheme.labelSmall?.copyWith(color: AppColors.cherryAccent)),
                  const SizedBox(height: 12),

                  // Price and Currency Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('TAHMİNİ FİYAT', style: theme.textTheme.labelSmall),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _priceController,
                              keyboardType: TextInputType.number,
                              style: theme.textTheme.bodyLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.w700),
                              decoration: const InputDecoration(hintText: '0.00'),
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
                                if (val != null) {
                                  setState(() => _currency = val);
                                  ref.read(preferencesProvider.notifier).updateDefaultCurrency(val);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Store & Product URL
                  Text('MAĞAZA / BAĞLANTI (URL)', style: theme.textTheme.labelSmall),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _storeController,
                    decoration: const InputDecoration(hintText: 'Örn: Beymen, Amazon...'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _productUrlController,
                    decoration: const InputDecoration(
                      hintText: 'https://...',
                      prefixIcon: Icon(Icons.link_rounded, size: 20),
                    ),
                  ),
                ],

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
