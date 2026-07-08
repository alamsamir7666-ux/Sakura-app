import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/more_models.dart';
import '../../shared/widgets/product_card.dart';

/// Horizontal flash sale banner — shows countdown with discounted products.
/// Matches the web app's FlashSaleSection component.
class FlashSaleSection extends StatefulWidget {
  final List<FlashSale> sales;
  const FlashSaleSection({super.key, required this.sales});

  @override
  State<FlashSaleSection> createState() => _FlashSaleSectionState();
}

class _FlashSaleSectionState extends State<FlashSaleSection> {
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
  }

  void _updateRemaining() {
    if (widget.sales.isNotEmpty) {
      _remaining = widget.sales.first.endTime.difference(DateTime.now());
      if (_remaining.isNegative) _remaining = Duration.zero;
    }
  }

  String get _formattedRemaining {
    final hours = _remaining.inHours;
    final minutes = _remaining.inMinutes.remainder(60);
    final seconds = _remaining.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.sales.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.accentRose, AppTheme.deepRed],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.bolt, color: Colors.white, size: 22),
                    SizedBox(width: 6),
                    Text('FLASH SALE',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            letterSpacing: 1.5)),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.timer, color: Colors.white70, size: 16),
                    const SizedBox(width: 4),
                    Text(_formattedRemaining,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Products
            SizedBox(
              height: 220,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: widget.sales.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final sale = widget.sales[index];
                  return _FlashSaleCard(sale: sale);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FlashSaleCard extends StatelessWidget {
  final FlashSale sale;
  const _FlashSaleCard({required this.sale});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: sale.isSoldOut || sale.isExpired
          ? null
          : () => context.push('/products/${sale.productId}'),
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progress bar
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: LinearProgressIndicator(
                value: sale.progress,
                backgroundColor: Colors.white.withOpacity(0.3),
                color: AppTheme.mutedGold,
                minHeight: 4,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${sale.remaining} left',
                      style: const TextStyle(
                          color: AppTheme.errorRed,
                          fontSize: 10,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('\$${sale.salePrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: AppTheme.accentRose)),
                  const SizedBox(height: 2),
                  Text('${((1 - sale.salePrice / 100) * 100).round()}% OFF',
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.successGreen,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Container(
                    alignment: Alignment.center,
                    padding:
                        const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: sale.isSoldOut || sale.isExpired
                          ? AppTheme.warmGray.withOpacity(0.2)
                          : AppTheme.accentRose,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      sale.isSoldOut
                          ? 'SOLD OUT'
                          : sale.isExpired
                              ? 'EXPIRED'
                              : 'BUY NOW',
                      style: TextStyle(
                        color: sale.isSoldOut || sale.isExpired
                            ? AppTheme.warmGray
                            : Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
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
}
