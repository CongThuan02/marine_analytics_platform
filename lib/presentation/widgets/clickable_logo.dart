import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:marine_analytics_platform/core/services/fcm_service.dart';
import 'package:marine_analytics_platform/core/theme/app_theme.dart';

class ClickableLogo extends StatefulWidget {
  final double logoSize;
  final double titleFontSize;
  final double subtitleFontSize;
  final bool showSubtitle;

  const ClickableLogo({
    super.key,
    this.logoSize = 80,
    this.titleFontSize = 32,
    this.subtitleFontSize = 16,
    this.showSubtitle = true,
  });

  @override
  State<ClickableLogo> createState() => _ClickableLogoState();
}

class _ClickableLogoState extends State<ClickableLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  int _tapCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleLogoTap() async {
    // Animate
    await _controller.forward();
    await _controller.reverse();

    _tapCount++;

    // After 3 taps, show FCM token
    if (_tapCount >= 3) {
      _tapCount = 0;
      await _showFCMToken();
    }
  }

  Future<void> _showFCMToken() async {
    final fcmService = FCMService();
    final token = fcmService.fcmToken;

    if (!mounted) return;

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('FCM Token chưa sẵn sàng. Vui lòng đợi...'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show dialog with token
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.notifications_active, color: AppTheme.primaryGreen),
            const SizedBox(width: 8),
            const Text('FCM Token'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Firebase Cloud Messaging token của bạn:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: SelectableText(
                token,
                style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: token));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Đã sao chép FCM Token!'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.copy, size: 18),
            label: const Text('Sao chép'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleLogoTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo with container
            Hero(
              tag: 'app_logo',
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreenLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryGreen.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/logo.png',
                  height: widget.logoSize,
                  width: widget.logoSize,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // App name
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'PAMELA',
                  style: TextStyle(
                    fontSize: widget.titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                    letterSpacing: 2.0,
                    height: 1.2,
                  ),
                ),
                if (widget.showSubtitle) ...[
                  const SizedBox(height: 4),
                  Text(
                    'CRUISE',
                    style: TextStyle(
                      fontSize: widget.subtitleFontSize,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.primaryGreen.withOpacity(0.7),
                      letterSpacing: 3.0,
                      height: 1,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
