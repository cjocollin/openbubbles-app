import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:bluebubbles/app/components/avatars/contact_avatar_widget.dart';
import 'package:bluebubbles/app/layouts/settings/pages/advanced/notification_providers_panel.dart';
import 'package:bluebubbles/app/layouts/settings/pages/advanced/tasker_panel.dart';
import 'package:bluebubbles/app/layouts/settings/pages/profile/profile_panel.dart';
import 'package:bluebubbles/app/layouts/settings/pages/scheduling/message_reminders_panel.dart';
import 'package:bluebubbles/app/layouts/settings/pages/server/backup_restore_panel.dart';
import 'package:bluebubbles/app/layouts/settings/pages/system/device_panel.dart';
import 'package:bluebubbles/app/layouts/settings/widgets/content/next_button.dart';
import 'package:bluebubbles/main.dart';
import 'package:bluebubbles/utils/logger/logger.dart';
import 'package:bluebubbles/src/rust/api/api.dart' as api;
import 'package:bluebubbles/helpers/helpers.dart';
import 'package:bluebubbles/services/network/backend_service.dart';
import 'package:bluebubbles/services/rustpush/rustpush_service.dart';
import 'package:bluebubbles/app/layouts/settings/pages/misc/about_panel.dart';
import 'package:bluebubbles/app/layouts/settings/pages/message_view/attachment_panel.dart';
import 'package:bluebubbles/app/layouts/settings/pages/conversation_list/chat_list_panel.dart';
import 'package:bluebubbles/app/layouts/settings/pages/message_view/conversation_panel.dart';
import 'package:bluebubbles/app/layouts/settings/pages/desktop/desktop_panel.dart';
import 'package:bluebubbles/app/layouts/settings/pages/misc/misc_panel.dart';
import 'package:bluebubbles/app/layouts/settings/pages/system/notification_panel.dart';
import 'package:bluebubbles/app/layouts/settings/pages/advanced/private_api_panel.dart';
import 'package:bluebubbles/app/layouts/settings/pages/advanced/redacted_mode_panel.dart';
import 'package:bluebubbles/app/layouts/settings/pages/server/server_management_panel.dart';
import 'package:bluebubbles/app/layouts/settings/pages/scheduling/scheduled_messages_panel.dart';
import 'package:bluebubbles/app/layouts/settings/widgets/settings_widgets.dart';
import 'package:bluebubbles/app/layouts/settings/pages/theming/theming_panel.dart';
import 'package:bluebubbles/app/layouts/settings/pages/misc/troubleshoot_panel.dart';
import 'package:bluebubbles/app/wrappers/stateful_boilerplate.dart';
import 'package:bluebubbles/app/wrappers/tablet_mode_wrapper.dart';
import 'package:bluebubbles/database/models.dart';
import 'package:bluebubbles/services/services.dart';
import 'package:bluebubbles/database/database.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:get/get.dart' hide Response;
import 'package:skeletonizer/skeletonizer.dart';
import 'package:universal_io/io.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bluebubbles/app/layouts/settings/widgets/expressive_settings_tile.dart';
import 'package:bluebubbles/app/layouts/settings/widgets/server_connection_tile.dart';
import 'package:bluebubbles/widgets/expressive_card.dart';
import 'package:bluebubbles/app/layouts/setup/setup_view.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({
    super.key,
    this.initialPage,
  });

  final Widget? initialPage;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends OptimizedState<SettingsPage> {
  final RxBool uploadingContacts = false.obs;
  final RxnDouble progress = RxnDouble();
  final RxnInt totalSize = RxnInt();
  api.DeviceInfo? deviceInfo;

  @override
  void initState() {
    super.initState();

    if (showAltLayoutContextless && backend.getRemoteService() != null) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        ns.pushAndRemoveSettingsUntil(
          context,
          widget.initialPage ?? ServerManagementPanel(),
          (route) => route.isFirst,
        );
      });
    } else if (widget.initialPage != null) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        ns.pushSettings(
          context,
          widget.initialPage!,
        );
      });
    }
    
    (() async {
      await pushService.initFuture;
      var value = await api.getDeviceInfoState(state: pushService.state);
      setState(() {
        deviceInfo = value;
      });
    })();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: ss.settings.immersiveMode.value
            ? Colors.transparent
            : context.theme.colorScheme.surface, // navigation bar color
        systemNavigationBarIconBrightness:
            context.theme.colorScheme.brightness.opposite,
        statusBarColor: Colors.transparent, // status bar color
        statusBarIconBrightness: context.theme.colorScheme.brightness.opposite,
      ),
      child: Actions(
          actions: {
            GoBackIntent: GoBackAction(context),
          },
          child: Obx(() => Container(
                color:
                    context.theme.colorScheme.surface.themeOpacity(context),
                child: TabletModeWrapper(
                  initialRatio: 0.4,
                  minRatio: kIsDesktop || kIsWeb ? 0.2 : 0.33,
                  maxRatio: 0.5,
                  allowResize: true,
                  left: SettingsScaffold(
                      title: "Settings",
                      initialHeader:
                          kIsWeb ? "Server & Message Management" : (!iOS) ? "Profile" : null,
                      iosSubtitle: iosSubtitle,
                      materialSubtitle: materialSubtitle,
                      tileColor: tileColor,
                      headerColor: headerColor,
                      bodySlivers: [
                        if (!kIsWeb && !iOS)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 8),
                              child: ExpressiveCard(
                                onTap: () {
                                  ns.pushAndRemoveSettingsUntil(
                                    context,
                                    ProfilePanel(),
                                    (route) => route.isFirst,
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      ContactAvatarWidget(
                                        handle: null,
                                        borderThickness: 0.1,
                                        editable: false,
                                        fontSize: 22,
                                        size: 50,
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              ss.settings.redactedMode.value && ss.settings.hideContactInfo.value
                                                  ? "User Name"
                                                  : ss.settings.userName.value,
                                              style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              "Tap to view profile",
                                              style: context.textTheme.bodySmall,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.arrow_forward_ios, size: 16),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (backend.getRemoteService() != null)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: SizedBox(
                                height: 200,
                                child: ServerConnectionTile(
                                  onTap: () {
                                    ns.pushAndRemoveSettingsUntil(
                                      context,
                                      ServerManagementPanel(),
                                      (route) => route.isFirst,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        SliverPadding(
                          padding: const EdgeInsets.all(16),
                          sliver: SliverGrid.count(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            children: [
                              ExpressiveSettingsTile(
                                title: "Appearance",
                                subtitle: "Theme, Skin, Colors",
                                icon: Icons.palette,
                                color: Colors.blue,
                                onTap: () => ns.pushAndRemoveSettingsUntil(context, ThemingPanel(), (route) => route.isFirst),
                              ),
                              ExpressiveSettingsTile(
                                title: "Media",
                                subtitle: "Photos, Videos, Audio",
                                icon: Icons.perm_media,
                                color: Colors.purple,
                                onTap: () => ns.pushAndRemoveSettingsUntil(context, AttachmentPanel(), (route) => route.isFirst),
                              ),
                              ExpressiveSettingsTile(
                                title: "Notifications",
                                subtitle: "Alerts, Sounds",
                                icon: Icons.notifications,
                                color: Colors.red,
                                onTap: () => ns.pushAndRemoveSettingsUntil(context, NotificationPanel(), (route) => route.isFirst),
                              ),
                              ExpressiveSettingsTile(
                                title: "Chat List",
                                subtitle: "Sorting, Layout",
                                icon: Icons.list,
                                color: Colors.green,
                                onTap: () => ns.pushAndRemoveSettingsUntil(context, ChatListPanel(), (route) => route.isFirst),
                              ),
                              ExpressiveSettingsTile(
                                title: "Conversation",
                                subtitle: "Bubbles, Effects",
                                icon: Icons.sms,
                                color: Colors.orange,
                                onTap: () => ns.pushAndRemoveSettingsUntil(context, ConversationPanel(), (route) => route.isFirst),
                              ),
                              if (kIsDesktop)
                                ExpressiveSettingsTile(
                                  title: "Desktop",
                                  subtitle: "Window, System Tray",
                                  icon: Icons.desktop_windows,
                                  color: Colors.blueGrey,
                                  onTap: () => ns.pushAndRemoveSettingsUntil(context, DesktopPanel(), (route) => route.isFirst),
                                ),
                              ExpressiveSettingsTile(
                                title: "More",
                                subtitle: "Misc Settings",
                                icon: Icons.more_horiz,
                                color: Colors.teal,
                                onTap: () => ns.pushAndRemoveSettingsUntil(context, MiscPanel(), (route) => route.isFirst),
                              ),
                              if (ss.serverDetailsSync().item4 >= 205)
                                ExpressiveSettingsTile(
                                  title: "Scheduled",
                                  subtitle: "Scheduled Messages",
                                  icon: Icons.schedule_send,
                                  color: Colors.pink,
                                  onTap: () => ns.pushAndRemoveSettingsUntil(context, ScheduledMessagesPanel(), (route) => route.isFirst),
                                ),
                              if (Platform.isAndroid)
                                ExpressiveSettingsTile(
                                  title: "Reminders",
                                  subtitle: "Message Reminders",
                                  icon: Icons.alarm,
                                  color: Colors.indigo,
                                  onTap: () => ns.pushAndRemoveSettingsUntil(context, MessageRemindersPanel(), (route) => route.isFirst),
                                ),
                              if (usingRustPush)
                                ExpressiveSettingsTile(
                                  title: "Device",
                                  subtitle: "Hosted Device Info",
                                  icon: Icons.laptop,
                                  color: Colors.deepPurple,
                                  onTap: () => ns.pushAndRemoveSettingsUntil(context, DevicePanel(), (route) => route.isFirst),
                                ),
                              // Advanced
                              ExpressiveSettingsTile(
                                title: "Private API",
                                subtitle: "Advanced Features",
                                icon: Icons.security,
                                color: Colors.amber,
                                onTap: () => ns.pushAndRemoveSettingsUntil(context, PrivateAPIPanel(), (route) => route.isFirst),
                              ),
                              ExpressiveSettingsTile(
                                title: "Redacted Mode",
                                subtitle: "Hide Sensitive Info",
                                icon: Icons.visibility_off,
                                color: Colors.deepOrange,
                                onTap: () => ns.pushAndRemoveSettingsUntil(context, RedactedModePanel(), (route) => route.isFirst),
                              ),
                              if (Platform.isAndroid)
                                ExpressiveSettingsTile(
                                  title: "Tasker",
                                  subtitle: "Automation",
                                  icon: Icons.bolt,
                                  color: Colors.yellow[800]!,
                                  onTap: () => ns.pushAndRemoveSettingsUntil(context, TaskerPanel(), (route) => route.isFirst),
                                ),
                              ExpressiveSettingsTile(
                                title: "Troubleshoot",
                                subtitle: "Logs & Tools",
                                icon: Icons.build,
                                color: Colors.brown,
                                onTap: () => ns.pushAndRemoveSettingsUntil(context, TroubleshootPanel(), (route) => route.isFirst),
                              ),
                            ],
                          ),
                        ),
                        // Other sections (Backup, About, Danger Zone)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                ExpressiveCard(
                                  onTap: () => ns.pushAndRemoveSettingsUntil(context, BackupRestorePanel(), (route) => route.isFirst),
                                  child: const ListTile(
                                    leading: Icon(Icons.backup, color: Colors.blue),
                                    title: Text("Backup & Restore"),
                                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ExpressiveCard(
                                  onTap: () => ns.pushAndRemoveSettingsUntil(context, AboutPanel(), (route) => route.isFirst),
                                  child: const ListTile(
                                    leading: Icon(Icons.info, color: Colors.green),
                                    title: Text("About & Links"),
                                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Danger Zone",
                                  style: context.textTheme.titleMedium?.copyWith(
                                    color: context.theme.colorScheme.error,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ExpressiveCard(
                                  color: context.theme.colorScheme.errorContainer.withOpacity(0.3),
                                  onTap: () async {
                                    if (usingRustPush) {
                                      await (backend as RustPushBackend).markFailedToLogin(hw: true, logout: true);
                                    }
                                    Get.offAll(() => SetupView());
                                  },
                                  child: ListTile(
                                    leading: Icon(Icons.refresh, color: context.theme.colorScheme.error),
                                    title: Text("Reconfigure", style: TextStyle(color: context.theme.colorScheme.error, fontWeight: FontWeight.bold)),
                                    subtitle: Text("Reset connection settings", style: TextStyle(color: context.theme.colorScheme.error)),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ExpressiveCard(
                                  color: context.theme.colorScheme.errorContainer.withOpacity(0.3),
                                  onTap: () async {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text("Reset App?", style: context.theme.textTheme.titleLarge),
                                        content: Text("This will delete all data and reset the app. This action cannot be undone.", style: context.theme.textTheme.bodyLarge),
                                        backgroundColor: context.theme.colorScheme.properSurface,
                                        actions: [
                                          TextButton(
                                            child: Text("Cancel", style: context.theme.textTheme.bodyLarge!.copyWith(color: context.theme.colorScheme.primary)),
                                            onPressed: () => Navigator.of(context).pop(),
                                          ),
                                          TextButton(
                                            child: Text("Reset", style: context.theme.textTheme.bodyLarge!.copyWith(color: context.theme.colorScheme.error)),
                                            onPressed: () async {
                                              Navigator.of(context).pop();
                                              await ss.prefs.clear();
                                              if (usingRustPush) {
                                                await (backend as RustPushBackend).markFailedToLogin(hw: true, logout: true);
                                              }
                                              Get.offAll(() => SetupView());
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  child: ListTile(
                                    leading: Icon(Icons.delete_forever, color: context.theme.colorScheme.error),
                                    title: Text("Reset App", style: TextStyle(color: context.theme.colorScheme.error, fontWeight: FontWeight.bold)),
                                    subtitle: Text("Clear all data and reset", style: TextStyle(color: context.theme.colorScheme.error)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  right: LayoutBuilder(builder: (context, constraints) {
                    ns.maxWidthSettings = constraints.maxWidth;
                    return PopScope(
                      canPop: false,
                      onPopInvoked: (_) async {
                        Get.until((route) {
                          if (route.settings.name == "initial") {
                            Get.back();
                          } else {
                            Get.back(id: 3);
                          }
                          return true;
                        }, id: 3);
                      },
                      child: Navigator(
                        key: Get.nestedKey(3),
                        onPopPage: (route, _) {
                          route.didPop(false);
                          return false;
                        },
                        pages: [
                          CupertinoPage(
                              name: "initial",
                              child: Scaffold(
                                  backgroundColor:
                                      ss.settings.skin.value != Skins.iOS
                                          ? tileColor
                                          : headerColor,
                                  body: Center(
                                    child: Text(
                                        "Select a settings page from the list",
                                        style:
                                            context.theme.textTheme.bodyLarge),
                                  ))),
                        ],
                      ),
                    );
                  }),
                ),
              ))),
    );
  }
}
