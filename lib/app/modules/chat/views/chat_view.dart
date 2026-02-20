import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../theme/app_colors.dart';
import '../chat_controller.dart';
import '../../../utils/image_helper.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final args = Get.arguments as Map<String, dynamic>?;

    debugPrint('🎨 ChatView Build with Args: $args');

    // Safety: if controller isn't initialized for this room yet (happens on reuse)
    if (args != null && args['chat_room_id'] != null) {
      final rid = args['chat_room_id'].toString();
      if (controller.currentChatRoomId != rid) {
        debugPrint('🔄 Room mismatch! Re-initializing controller for $rid');
        controller.setupChatRoom(rid);
      }
    }

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[200],
                  backgroundImage:
                      (args != null &&
                          args['image'] != null &&
                          args['image'].isNotEmpty)
                      ? NetworkImage(ImageHelper.getImageUrl(args['image'])!)
                      : null,
                  child:
                      (args == null ||
                          args['image'] == null ||
                          args['image'].isEmpty)
                      ? const Icon(Icons.person, color: Colors.grey)
                      : null,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.scaffoldBackgroundColor,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    args?['name'] ?? 'consultation'.tr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    args?['specialty'] ?? 'online'.tr,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        // Enable back button - remove automaticallyImplyLeading: false
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam_outlined),
            onPressed: () =>
                Get.snackbar('coming_soon'.tr, 'feature_coming_soon'.tr),
          ),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBackground : AppColors.background,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
                : [const Color(0xFFF8FAFC), const Color(0xFFE2E8F0)],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Obx(
                () => AnimationLimiter(
                  child: ListView.builder(
                    controller: controller.scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    itemCount: controller.messages.length,
                    itemBuilder: (context, index) {
                      final message = controller.messages[index];
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 375),
                        child: SlideAnimation(
                          verticalOffset: 20.0,
                          child: FadeInAnimation(
                            child: _buildMessageItem(message, isDark),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            _buildInputArea(theme, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageItem(ChatMessage message, bool isDark) {
    return Align(
      alignment: message.isSender
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(maxWidth: Get.width * 0.75),
        decoration: BoxDecoration(
          color: message.isSender
              ? AppColors.primary
              : (isDark ? AppColors.darkSurface : Colors.white),
          borderRadius:
              BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(message.isSender ? 20 : 0),
                bottomRight: Radius.circular(message.isSender ? 0 : 20),
              ).copyWith(
                // Extra organic feel
                topLeft: message.isSender
                    ? const Radius.circular(20)
                    : const Radius.circular(12),
                topRight: message.isSender
                    ? const Radius.circular(12)
                    : const Radius.circular(20),
              ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.type == ChatMessageType.image &&
                message.imageUrl != null)
              GestureDetector(
                onTap: () => _showImagePreview(message.imageUrl!),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        Image.network(
                          ImageHelper.getImageUrl(message.imageUrl!) ?? '',
                          fit: BoxFit.cover,
                          loadingBuilder: (ctx, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              height: 200,
                              width: double.infinity,
                              color: Colors.grey[300],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                          errorBuilder: (ctx, err, stack) => Container(
                            height: 150,
                            width: double.infinity,
                            color: Colors.grey[200],
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                  size: 40,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'image_unavailable'.tr,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black38,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.fullscreen,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (message.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Text(
                  message.text,
                  style: TextStyle(
                    color: message.isSender
                        ? Colors.white
                        : (isDark ? Colors.white : AppColors.text),
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(message.time),
                    style: TextStyle(
                      fontSize: 10,
                      color: message.isSender ? Colors.white70 : Colors.grey,
                    ),
                  ),
                  if (message.isSender) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.done_all, size: 12, color: Colors.white70),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(ThemeData theme, bool isDark) {
    return Obx(() {
      if (controller.isChatArchived.value) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'session_expired'.tr,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.text,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: controller.reOpenChat,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text('extend_session_price'.tr),
              ),
            ],
          ),
        );
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 15,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              icon: controller.isUploading.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.attach_file_rounded, color: Colors.grey),
              onPressed: controller.isUploading.value
                  ? null
                  : controller.pickAndSendImage,
            ),
            Expanded(
              child: TextField(
                controller: controller.messageController,
                decoration: InputDecoration(
                  hintText: 'type_message_hint'.tr,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8),
                ),
                maxLines: null,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: controller.sendMessage,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  void _showImagePreview(String url) {
    Get.to(
      () => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: Hero(
            tag: url,
            child: InteractiveViewer(
              child: Image.network(ImageHelper.getImageUrl(url) ?? ''),
            ),
          ),
        ),
      ),
      fullscreenDialog: true,
    );
  }

  String _formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }
}
