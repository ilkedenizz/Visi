import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../models/collection_model.dart';
import '../../models/wish_status.dart';
import '../../models/wishlist_item.dart';
import '../../providers/collection_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../widgets/visi_cherry_logo.dart';
import '../../widgets/visi_feedback.dart';
import '../../widgets/visi_image.dart';

class WishlistItemDetailScreen extends ConsumerWidget {
  final String itemId;

  const WishlistItemDetailScreen({
    super.key,
    required this.itemId,
  });

  String _formatPrice(double price, String currency) {
    final formatter = NumberFormat('#,##0.##', 'tr_TR');
    return '$currency${formatter.format(price)}';
  }

  String _formatDate(DateTime date) {
    return DateFormat('d MMMM yyyy', 'tr_TR').format(date);
  }

  Future<void> _openProductUrl(BuildContext context, String? url) async {
    if (url == null || url.isEmpty) return;

    final uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          VisiFeedback.showInfo(context, 'Bağlantı açılamadı');
        }
      }
    } catch (_) {}
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, WishlistItem item) {
    HapticFeedback.warningNotification();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            VisiCherryLogo(size: 20, color: AppColors.cherryAccent),
            SizedBox(width: 8),
            Text('Dileği Sil'),
          ],
        ),
        content: Text('"${item.title}" dilek listenizden silinsin mi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final deleted = await ref.read(wishlistProvider.notifier).deleteItem(item.id);
              if (context.mounted) {
                context.pop();
                if (deleted != null) {
                  VisiFeedback.showSuccessWithUndo(
                    context: context,
                    message: 'Dilek silindi 🍒',
                    undoLabel: 'Geri Al',
                    onUndo: () {
                      ref.read(wishlistProvider.notifier).undoDelete();
                    },
                  );
                }
              }
            },
            child: const Text(
              'Sil',
              style: TextStyle(color: AppColors.cherryAccent, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final wishlist = ref.watch(wishlistProvider);
    final collections = ref.watch(collectionProvider);

    final item = wishlist.firstWhere(
      (i) => i.id == itemId,
      orElse: () => WishlistItem(
        id: '',
        title: 'Bulunamadı',
        price: 0,
        collectionId: '',
        createdAt: DateTime.now(),
      ),
    );

    if (item.id.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Dilek Detayı')),
        body: const Center(child: Text('Dilek bulunamadı')),
      );
    }

    final CollectionModel? collection = collections.any((c) => c.id == item.collectionId)
        ? collections.firstWhere((c) => c.id == item.collectionId)
        : (collections.isNotEmpty ? collections.first : null);

    final isFulfilled = item.status == WishStatus.fulfilled;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero Image Sliver App Bar
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: isDark ? Colors.black54 : Colors.white70,
                child: IconButton(
                  icon: Icon(Icons.arrow_back_rounded, color: isDark ? Colors.white : AppColors.lightTextPrimary),
                  onPressed: () => context.pop(),
                ),
              ),
            ),
            actions: [
              // Favorite Button
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: isDark ? Colors.black54 : Colors.white70,
                  child: IconButton(
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 240),
                      transitionBuilder: (child, anim) => ScaleTransition(
                        scale: Tween<double>(begin: 0.7, end: 1.0).animate(
                          CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
                        ),
                        child: child,
                      ),
                      child: Icon(
                        item.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        key: ValueKey(item.isFavorite),
                        color: item.isFavorite ? AppColors.cherryAccent : (isDark ? Colors.white : AppColors.lightTextPrimary),
                      ),
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      ref.read(wishlistProvider.notifier).toggleFavorite(item.id);
                    },
                  ),
                ),
              ),
              // Share Button
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: isDark ? Colors.black54 : Colors.white70,
                  child: IconButton(
                    icon: Icon(Icons.share_outlined, color: isDark ? Colors.white : AppColors.lightTextPrimary),
                    onPressed: () async {
                      HapticFeedback.lightImpact();
                      final shareText = '${item.title} ${item.type.label}${item.price > 0 ? " (${item.currency}${item.price})" : ""}';
                      await Clipboard.setData(ClipboardData(text: shareText.trim()));
                      if (context.mounted) {
                        VisiFeedback.showSuccess(context, 'Dilek kopyalandı 🍒');
                      }
                    },
                  ),
                ),
              ),
              // Options Popup Menu (Edit / Delete)
              Padding(
                padding: const EdgeInsets.only(right: 8.0, top: 8, bottom: 8),
                child: CircleAvatar(
                  backgroundColor: isDark ? Colors.black54 : Colors.white70,
                  child: PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert_rounded, color: isDark ? Colors.white : AppColors.lightTextPrimary),
                    onSelected: (value) {
                      if (value == 'edit') {
                        context.push('/edit-item', extra: item);
                      } else if (value == 'delete') {
                        _confirmDelete(context, ref, item);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 20),
                            SizedBox(width: 8),
                            Text('Düzenle'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.cherryAccent),
                            SizedBox(width: 8),
                            Text('Sil', style: TextStyle(color: AppColors.cherryAccent)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  VisiImage(imageUrl: item.imagePath),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.3),
                            Colors.transparent,
                            isDark ? AppColors.darkBackground : AppColors.lightBackground,
                          ],
                          stops: const [0.0, 0.6, 1.0],
                        ),
                      ),
                    ),
                  ),
                  if (isFulfilled)
                    Positioned(
                      top: 100,
                      left: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.cherryAccent,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3)),
                          ],
                        ),
                        child: const Row(
                          children: [
                            Text('✨ GERÇEK OLDU', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Story Content Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Wish Type & Collection Badges
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.cherryAccent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          item.type.label,
                          style: const TextStyle(
                            color: AppColors.cherryAccent,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (collection != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkCard : AppColors.blushPink,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(collection.emoji, style: const TextStyle(fontSize: 12)),
                              const SizedBox(width: 4),
                              Text(
                                collection.name,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Title
                  Text(
                    item.title,
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Interactive Wish Status Selector Bar
                  Text('DURUM', style: theme.textTheme.labelSmall),
                  const SizedBox(height: 8),
                  Row(
                    children: WishStatus.values.map((st) {
                      final isSelected = item.status == st;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3.0),
                          child: InkWell(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              ref.read(wishlistProvider.notifier).updateItem(item.copyWith(status: st));
                              if (st == WishStatus.fulfilled) {
                                VisiFeedback.showSuccess(context, 'Tebrikler! Dileğin gerçek oldu ✨🍒');
                              }
                            },
                            borderRadius: BorderRadius.circular(14),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.cherryAccent
                                    : (isDark ? AppColors.darkCard : AppColors.lightCard),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.cherryAccent
                                      : (isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
                                ),
                              ),
                              child: Text(
                                st.label,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Target Date & Priority Row (if present)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (item.targetDate != null) ...[
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.cherryAccent),
                            const SizedBox(width: 6),
                            Text(
                              'Hedef: ${item.targetDate!.year}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : AppColors.lightSurface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${item.priority.label} Öncelik',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Optional Price Display (ONLY IF price > 0)
                  if (item.price > 0) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('TAHMİNİ FİYAT', style: theme.textTheme.labelSmall),
                        Text(
                          _formatPrice(item.price, item.currency),
                          style: theme.textTheme.displayLarge?.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                  ],

                  // Notes / Description Section
                  if (item.notes != null && item.notes!.isNotEmpty) ...[
                    Text('BUNU NEDEN İSTİYORUM?', style: theme.textTheme.labelSmall),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : AppColors.lightCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                        ),
                      ),
                      child: Text(
                        item.notes!,
                        style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Optional Store / Brand
                  if (item.store != null && item.store!.isNotEmpty) ...[
                    Row(
                      children: [
                        const Icon(Icons.storefront_outlined, size: 16, color: AppColors.cherryAccent),
                        const SizedBox(width: 6),
                        Text(
                          'Mağaza / Yer: ${item.store}',
                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Optional Product URL Button
                  if (item.productUrl != null && item.productUrl!.isNotEmpty) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.open_in_new_rounded, size: 18),
                        label: const Text('Ürüne Git ↗', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          backgroundColor: AppColors.cherryAccent,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: () => _openProductUrl(context, item.productUrl),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Created Date Footer
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const VisiCherryLogo(size: 14, color: AppColors.cherryAccent),
                        const SizedBox(width: 6),
                        Text(
                          '${_formatDate(item.createdAt)} tarihinde eklendi',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
