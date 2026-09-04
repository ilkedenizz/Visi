import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/url_validator.dart';
import '../../models/wishlist_item.dart';
import '../../providers/collection_provider.dart';
import '../../providers/preferences_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../widgets/visi_cherry_logo.dart';
import '../../widgets/visi_feedback.dart';
import '../../models/user_preferences.dart';

class QuickAddBottomSheet extends ConsumerStatefulWidget {
  const QuickAddBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    HapticFeedback.lightImpact();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => const QuickAddBottomSheet(),
    );
  }

  /// Central processing pipeline for external/shared product URLs (e.g. Android Share Sheet)
  static void processSharedUrl(BuildContext context, WidgetRef ref, String rawInput) {
    final extractedUrl = UrlValidator.extractUrl(rawInput);
    if (extractedUrl == null) {
      HapticFeedback.warningNotification();
      VisiFeedback.showError(context, 'Geçerli bir ürün linki bulunamadı.');
      return;
    }

    final normalized = UrlValidator.normalizeForComparison(extractedUrl);
    final wishlist = ref.read(wishlistProvider).asData?.value ?? [];
    final existingIndex = wishlist.indexWhere((item) {
      if (item.productUrl == null || item.productUrl!.isEmpty) return false;
      return UrlValidator.normalizeForComparison(item.productUrl!) == normalized;
    });

    if (existingIndex != -1) {
      HapticFeedback.warningNotification();
      _showDuplicateModal(context, ref, wishlist[existingIndex], extractedUrl);
    } else {
      _createAndNavigateToEdit(context, ref, extractedUrl);
    }
  }

  /// Show duplicate URL prompt dialog with Vişi aesthetic
  static void _showDuplicateModal(
    BuildContext context,
    WidgetRef ref,
    WishlistItem duplicateItem,
    String formattedUrl,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: AppColors.cherryAccent, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Bu dilek zaten listende.',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '"${duplicateItem.title}" dileğin aynı internet adresiyle daha önce kaydedilmiş.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 13,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.open_in_new_rounded, size: 18),
                  label: const Text('Mevcut dileği aç', style: TextStyle(fontWeight: FontWeight.w800)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cherryAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    Navigator.pop(ctx);
                    context.push('/item/${duplicateItem.id}');
                  },
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    side: BorderSide(
                      color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    Navigator.pop(ctx);
                    _createAndNavigateToEdit(context, ref, formattedUrl);
                  },
                  child: const Text('Yine de ekle', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Create temporary item and open edit screen
  static void _createAndNavigateToEdit(BuildContext context, WidgetRef ref, String url) {
    final prefs = ref.read(preferencesProvider).asData?.value ?? const UserPreferences();
    final collections = ref.read(collectionProvider).asData?.value ?? [];
    final defaultCollectionId = prefs.lastSelectedCollectionId ??
        (collections.isNotEmpty ? collections.first.id : '');

    final newItem = WishlistItem(
      id: const Uuid().v4(),
      title: 'Yeni dilek',
      price: 0,
      currency: prefs.defaultCurrency,
      productUrl: url,
      collectionId: defaultCollectionId,
      priority: ItemPriority.medium,
      createdAt: DateTime.now(),
    );

    ref.read(wishlistProvider.notifier).addItem(newItem);
    VisiFeedback.showSuccess(context, 'Listeye eklendi 🍒');
    context.push('/edit-item', extra: newItem);
  }

  @override
  ConsumerState<QuickAddBottomSheet> createState() => _QuickAddBottomSheetState();
}

class _QuickAddBottomSheetState extends ConsumerState<QuickAddBottomSheet> {
  final TextEditingController _urlController = TextEditingController();
  final FocusNode _urlFocusNode = FocusNode();

  String? _clipboardUrl;
  String? _errorMessage;
  bool _isLinkMode = false;
  WishlistItem? _duplicateItem;

  @override
  void initState() {
    super.initState();
    _checkClipboard();
  }

  @override
  void dispose() {
    _urlController.dispose();
    _urlFocusNode.dispose();
    super.dispose();
  }

  /// Inspect clipboard once on modal open
  Future<void> _checkClipboard() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      final text = clipboardData?.text?.trim();
      if (text != null && UrlValidator.isValidUrl(text)) {
        if (mounted) {
          setState(() {
            _clipboardUrl = UrlValidator.validate(text).formattedUrl;
          });
        }
      }
    } catch (_) {}
  }

  void _pasteFromClipboard() {
    if (_clipboardUrl != null) {
      HapticFeedback.selectionClick();
      setState(() {
        _urlController.text = _clipboardUrl!;
        _isLinkMode = true;
        _errorMessage = null;
      });
      _urlFocusNode.requestFocus();
    }
  }

  void _handleUrlSubmit({bool ignoreDuplicate = false}) {
    final validation = UrlValidator.validate(_urlController.text);
    if (!validation.isValid) {
      HapticFeedback.warningNotification();
      setState(() {
        _errorMessage = validation.errorMessage;
      });
      return;
    }

    final formattedUrl = validation.formattedUrl!;
    final normalized = UrlValidator.normalizeForComparison(formattedUrl);
    final wishlist = ref.read(wishlistProvider).asData?.value ?? [];

    if (!ignoreDuplicate) {
      final existingIndex = wishlist.indexWhere((item) {
        if (item.productUrl == null || item.productUrl!.isEmpty) return false;
        return UrlValidator.normalizeForComparison(item.productUrl!) == normalized;
      });

      if (existingIndex != -1) {
        HapticFeedback.warningNotification();
        setState(() {
          _duplicateItem = wishlist[existingIndex];
        });
        return;
      }
    }

    Navigator.pop(context);
    QuickAddBottomSheet._createAndNavigateToEdit(context, ref, formattedUrl);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        top: 20,
        left: 24,
        right: 24,
        bottom: bottomInset + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Duplicate URL Dialog View
          if (_duplicateItem != null) ...[
            _buildDuplicateView(isDark, theme),
          ]
          // Focused Link Input Mode
          else if (_isLinkMode) ...[
            _buildLinkInputView(isDark, theme),
          ]
          // Main Selection Options View
          else ...[
            _buildMainSelectionView(isDark, theme),
          ],
        ],
      ),
    );
  }

  /// Option Selection View (Main View)
  Widget _buildMainSelectionView(bool isDark, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const VisiCherryLogo(size: 22, color: AppColors.cherryAccent),
            const SizedBox(width: 10),
            Text(
              'Dilek Ekle',
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Clipboard Suggestion Pill (if detected)
        if (_clipboardUrl != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.blushPinkDark : AppColors.blushPink,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.cherryAccent.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.link_rounded, size: 18, color: AppColors.cherryAccent),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Panonda bir link bulduk.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.cherryAccent,
                        ),
                      ),
                      Text(
                        _clipboardUrl!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _pasteFromClipboard,
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.cherryAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Yapıştır', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Option 1: Link Ekle
        Material(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                _isLinkMode = true;
              });
              _urlFocusNode.requestFocus();
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.cherryAccent.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.link_rounded, color: AppColors.cherryAccent, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Link ekle',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Ürün bağlantısını yapıştır, hemen kaydet',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.lightTextMuted),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Option 2: Manuel Ekle
        Material(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.pop(context);
              context.push('/add-item');
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.blushPink,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.edit_note_rounded, color: AppColors.cherryAccent, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Manuel ekle',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Tüm detayları kendin doldur',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.lightTextMuted),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Focused Link Entry View
  Widget _buildLinkInputView(bool isDark, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _isLinkMode = false;
                  _errorMessage = null;
                });
              },
            ),
            const VisiCherryLogo(size: 20, color: AppColors.cherryAccent),
          ],
        ),
        const SizedBox(height: 8),

        Text(
          'Bir şey mi buldun?',
          style: theme.textTheme.displayMedium?.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Linkini bırak, sonra detaylarını tamamlarız.',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 13,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        const SizedBox(height: 20),

        // URL Text Field
        TextField(
          controller: _urlController,
          focusNode: _urlFocusNode,
          keyboardType: TextInputType.url,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _handleUrlSubmit(),
          onChanged: (_) {
            if (_errorMessage != null) {
              setState(() {
                _errorMessage = null;
              });
            }
          },
          decoration: InputDecoration(
            hintText: 'https://zara.com/urun-linki...',
            prefixIcon: const Icon(Icons.link_rounded, color: AppColors.cherryAccent),
            suffixIcon: IconButton(
              icon: const Icon(Icons.content_paste_rounded, size: 20),
              onPressed: () async {
                final data = await Clipboard.getData(Clipboard.kTextPlain);
                if (data?.text != null) {
                  _urlController.text = data!.text!;
                }
              },
            ),
          ),
        ),

        // Inline Error Message
        if (_errorMessage != null) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Row(
              children: [
                const Icon(Icons.error_outline_rounded, size: 14, color: AppColors.cherryAccent),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.cherryAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 24),

        // Submit Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _handleUrlSubmit(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cherryAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Listeye ekle',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  /// Duplicate URL Warning View
  Widget _buildDuplicateView(bool isDark, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.cherryAccent, size: 24),
            const SizedBox(width: 8),
            Text(
              'Bu dilek zaten listende.',
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          '"${_duplicateItem!.title}" dileğin aynı internet adresiyle daha önce kaydedilmiş.',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 13,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        const SizedBox(height: 24),

        // Action 1: Mevcut dileği aç
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.open_in_new_rounded, size: 18),
            label: const Text('Mevcut dileği aç', style: TextStyle(fontWeight: FontWeight.w800)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cherryAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () {
              HapticFeedback.selectionClick();
              Navigator.pop(context);
              context.push('/item/${_duplicateItem!.id}');
            },
          ),
        ),
        const SizedBox(height: 12),

        // Action 2: Yine de ekle
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              side: BorderSide(
                color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () => _handleUrlSubmit(ignoreDuplicate: true),
            child: const Text('Yine de ekle', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }
}
