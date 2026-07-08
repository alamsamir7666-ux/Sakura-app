import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/order.dart';
import '../../core/api/order_service.dart';

class TrackOrderScreen extends ConsumerStatefulWidget {
  const TrackOrderScreen({super.key});

  @override
  ConsumerState<TrackOrderScreen> createState() => _TrackOrderScreenState();
}

class _TrackOrderScreenState extends ConsumerState<TrackOrderScreen> {
  final _controller = TextEditingController();
  OrderTracking? _tracking;
  bool _loading = false;
  String? _error;

  Future<void> _track() async {
    final code = _controller.text.trim();
    if (code.isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
      _tracking = null;
    });

    try {
      final result =
          await ref.read(orderServiceProvider).trackOrder(code);
      setState(() => _tracking = result);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Track Order')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.local_shipping,
                size: 64, color: AppTheme.primaryPink),
            const SizedBox(height: 16),
            const Text('Enter your tracking ID',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
                'Find it in your order confirmation email',
                style: TextStyle(color: AppTheme.warmGray)),
            const SizedBox(height: 24),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'e.g. SAK-123456',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: _track,
                ),
              ),
              onSubmitted: (_) => _track(),
            ),
            const SizedBox(height: 16),
            if (_loading)
              const CircularProgressIndicator(),
            if (_error != null)
              Text(_error!,
                  style: const TextStyle(color: AppTheme.errorRed)),
            if (_tracking != null) ...[
              const SizedBox(height: 24),
              _TrackingTimeline(tracking: _tracking!),
            ],
          ],
        ),
      ),
    );
  }
}

class _TrackingTimeline extends StatelessWidget {
  final OrderTracking tracking;

  const _TrackingTimeline({required this.tracking});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text('Order #${tracking.trackingId}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(tracking.orderStatus.toUpperCase(),
                  style: const TextStyle(
                      color: AppTheme.primaryPink,
                      fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 20),
            ...tracking.timeline.asMap().entries.map((entry) {
              final i = entry.key;
              final event = entry.value;
              final isLast = i == tracking.timeline.length - 1;
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 32,
                      child: Column(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: event.completed
                                  ? AppTheme.successGreen
                                  : AppTheme.warmGray.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: event.completed
                                ? const Icon(Icons.check,
                                    size: 14, color: Colors.white)
                                : null,
                          ),
                          if (!isLast)
                            Expanded(
                              child: Container(
                                width: 2,
                                color: event.completed
                                    ? AppTheme.successGreen
                                    : AppTheme.warmGray.withOpacity(0.2),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(event.label,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: event.completed
                                      ? AppTheme.charcoal
                                      : AppTheme.warmGray,
                                )),
                            if (event.timestamp != null)
                              Text(event.timestamp!,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.warmGray)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
