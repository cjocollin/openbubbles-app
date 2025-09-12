import 'package:bluebubbles/services/services.dart';
import 'package:bluebubbles/widgets/expressive_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

class ServerConnectionTile extends StatelessWidget {
  final VoidCallback onTap;

  const ServerConnectionTile({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final state = socket.state.value;
      final isConnected = state == SocketState.connected;
      final isError = state == SocketState.error || state == SocketState.disconnected;
      
      Color color = isConnected ? Colors.green : (isError ? Colors.red : Colors.orange);
      String statusText = isConnected ? "Connected" : (isError ? "Disconnected" : "Connecting...");
      IconData icon = isConnected ? Icons.cloud_done_rounded : (isError ? Icons.cloud_off_rounded : Icons.cloud_sync_rounded);

      return ExpressiveCard(
        onTap: onTap,
        child: Stack(
          children: [
            // Background Pulse
            if (isConnected || state == SocketState.connecting)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [color.withOpacity(0.2), Colors.transparent],
                    ),
                  ),
                ).animate(onPlay: (controller) => controller.repeat())
                .scale(duration: const Duration(seconds: 2), begin: const Offset(0.5, 0.5), end: const Offset(1.5, 1.5))
                .fadeOut(duration: const Duration(seconds: 2)),
              ),
            
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 48,
                    color: color,
                  ).animate(target: isError ? 1 : 0)
                   .shake(hz: 4, curve: Curves.easeInOutCubic)
                   .tint(color: Colors.red, duration: 300.ms),
                  const SizedBox(height: 16),
                  Text(
                    "Server Connection",
                    style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: color.withOpacity(0.5)),
                    ),
                    child: Text(
                      statusText,
                      style: context.textTheme.labelLarge?.copyWith(color: color, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
