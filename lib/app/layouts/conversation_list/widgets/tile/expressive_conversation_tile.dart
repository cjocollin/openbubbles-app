import 'package:animations/animations.dart';
import 'package:bluebubbles/app/layouts/conversation_view/pages/conversation_view.dart';
import 'package:bluebubbles/app/layouts/conversation_list/widgets/tile/conversation_tile.dart';
import 'package:bluebubbles/app/layouts/conversation_list/widgets/tile/material_conversation_tile.dart';
import 'package:bluebubbles/app/wrappers/stateful_boilerplate.dart';
import 'package:bluebubbles/helpers/helpers.dart';
import 'package:bluebubbles/services/services.dart';
import 'package:bluebubbles/widgets/expressive_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bluebubbles/app/components/avatars/contact_avatar_widget.dart';
import 'package:bluebubbles/database/models.dart';

class ExpressiveConversationTile extends CustomStateful<ConversationTileController> {
  const ExpressiveConversationTile({Key? key, required super.parentController, this.deletedMode = false});

  final bool deletedMode;

  @override
  State<StatefulWidget> createState() => _ExpressiveConversationTileState();
}

class _ExpressiveConversationTileState extends CustomState<ExpressiveConversationTile, void, ConversationTileController> {
  final ValueNotifier<double> _dismissProgress = ValueNotifier(0.0);

  @override
  void initState() {
    super.initState();
    tag = controller.chat.guid;
  }

  @override
  void dispose() {
    _dismissProgress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      child: Dismissible(
        key: Key(controller.chat.guid),
        onUpdate: (details) {
          _dismissProgress.value = details.progress;
        },
        background: _buildSwipeAction(Alignment.centerLeft, Icons.archive, Colors.green),
        secondaryBackground: _buildSwipeAction(Alignment.centerRight, Icons.delete, Colors.red),
        onDismissed: (direction) {
           if (direction == DismissDirection.startToEnd) {
             controller.chat.toggleArchived(!controller.chat.isArchived!);
           } else {
             chats.removeChat(controller.chat);
             Chat.softDelete(controller.chat);
           }
        },
        child: OpenContainer(
          tappable: false,
          openBuilder: (context, action) {
            return ConversationView(chat: controller.chat);
          },
          closedShape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.circular(28.0),
          ),
          closedElevation: 0,
          closedColor: Colors.transparent,
          openColor: Theme.of(context).colorScheme.surface,
          middleColor: Theme.of(context).colorScheme.surface,
          transitionDuration: const Duration(milliseconds: 500),
          closedBuilder: (context, action) {
            return ExpressiveCard(
              margin: EdgeInsets.zero,
              onTap: () {
                if (controller.listController.selectedChats.isNotEmpty) {
                  controller.onTap(context, false);
                } else {
                  action();
                }
              },
              onLongPress: () {
                controller.onTap(context, false);
              },
              child: Row(
                children: [
                  _buildAvatar(),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ChatTitle(
                          parentController: controller,
                          style: context.theme.textTheme.headlineMedium!.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ChatSubtitle(
                          parentController: controller,
                          style: context.theme.textTheme.bodyMedium!.copyWith(
                            color: context.theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  MaterialTrailing(parentController: controller),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSwipeAction(Alignment alignment, IconData icon, Color color) {
    return ValueListenableBuilder<double>(
      valueListenable: _dismissProgress,
      builder: (context, progress, child) {
        double scale = 0.8 + (progress * 0.5);
        scale = scale.clamp(0.0, 1.5);
        
        return Container(
          alignment: alignment,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Transform.scale(
            scale: scale,
            child: Icon(icon, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildAvatar() {
    if (controller.chat.isGroup && controller.chat.participants.length >= 2) {
      return SizedBox(
        width: 50,
        height: 50,
        child: Stack(
          children: [
            Positioned(
              right: 0,
              bottom: 0,
              child: _buildSingleAvatar(controller.chat.participants[0], size: 38),
            ),
            Positioned(
              left: 0,
              top: 0,
              child: _buildSingleAvatar(controller.chat.participants[1], size: 38),
            ),
          ],
        ),
      );
    } else {
      return _buildSingleAvatar(controller.chat.participants.isNotEmpty ? controller.chat.participants.first : null, size: 50);
    }
  }

  Widget _buildSingleAvatar(Handle? handle, {required double size}) {
    return ContactAvatarWidget(
      handle: handle,
      size: size,
      borderThickness: 0,
      editable: false,
      customShape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}
