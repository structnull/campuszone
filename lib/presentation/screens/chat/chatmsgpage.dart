import 'package:campuszone/core/core.dart';
import 'package:campuszone/data/models/models.dart';
import 'package:campuszone/data/repositories/repositories.dart';
import 'package:campuszone/globals.dart' as globals;
import 'package:campuszone/presentation/presentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:line_icons/line_icons.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatMessagePage extends StatefulWidget {
  final UserModel user;
  const ChatMessagePage({super.key, required this.user});

  @override
  State<ChatMessagePage> createState() => _ChatMessagePageState();
}

class _ChatMessagePageState extends State<ChatMessagePage> {
  final TextEditingController _messageController = TextEditingController();
  final MessageRepository _repository = MessageRepository();
  final String? _currentUserId = SupabaseService.currentUserId;
  final ScrollController _scrollController = ScrollController();

  bool _isSending = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    try {
      await _repository.sendMessage(
        text: text,
        senderId: _currentUserId!,
        receiverId: widget.user.id,
      );
      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        AppSnackbar.show(context, 'Failed to send message', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut);
        }
      });
    }
  }

  void _deleteMessage(MessageModel message) async {
    if (message.senderId != _currentUserId) return;

    final confirm = await AppDialog.showConfirmation(
        context: context,
        title: 'Delete Message?',
        message: 'This action cannot be undone.');

    if (confirm == true) {
      try {
        await _repository.deleteMessage(message.id);
      } catch (e) {
        if (mounted) {
          AppSnackbar.show(context, 'Failed to delete message', isError: true);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        backgroundColor: AppColors.scaffoldBackground,
        appBar: AppAppBar(
          showBackButton: true,
          title: widget.user.name,
          actions: [
            IconButton(
              icon: Icon(LineIcons.syncIcon),
              onPressed: () => setState(() {}),
            )
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<MessageModel>>(
                stream: _repository.getMessagesStream(
                    _currentUserId!, widget.user.id),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return AppEmptyState(
                        title: "Error loading messages",
                        icon: LineIcons.exclamationCircle);
                  }
                  if (!snapshot.hasData) {
                    return Center(child: AppLoader());
                  }

                  final messages = snapshot.data!;
                  if (messages.isEmpty) {
                    return AppEmptyState(
                        title: "No messages yet", icon: LineIcons.comments);
                  }

                  return AnimationLimiter(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.all(AppSpacing.md),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isMyMessage = message.senderId == _currentUserId;
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: _MessageBubble(
                                message: message,
                                isMyMessage: isMyMessage,
                                senderProfileUrl: widget.user.profilePicPath !=
                                            null &&
                                        widget.user.profilePicPath!.isNotEmpty
                                    ? SupabaseService.getProfilePictureUrl(
                                        widget.user.id,
                                        cacheBuster:
                                            globals.globalCacheBuster.value)
                                    : null,
                                onLongPress: () => _deleteMessage(message),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(color: AppColors.cardColor, boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 4,
                  offset: Offset(0, -2),
                )
              ]),
              child: Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _messageController,
                      hintText: "Type a message...",
                      onFieldSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  IconButton(
                    icon: _isSending
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : Icon(LineIcons.paperPlane, color: AppColors.primary),
                    onPressed: _sendMessage,
                  )
                ],
              ),
            )
          ],
        ));
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMyMessage;
  final String? senderProfileUrl;
  final VoidCallback onLongPress;

  const _MessageBubble({
    required this.message,
    required this.isMyMessage,
    this.senderProfileUrl,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment:
              isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMyMessage) ...[
              AppAvatar(imageUrl: senderProfileUrl, radius: 16),
              SizedBox(width: 8),
            ],
            Flexible(
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color:
                        isMyMessage ? AppColors.primary : AppColors.cardColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                      bottomLeft: isMyMessage
                          ? Radius.circular(16)
                          : Radius.circular(4),
                      bottomRight: isMyMessage
                          ? Radius.circular(4)
                          : Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.shadow.withValues(alpha: 0.05),
                          blurRadius: 2,
                          offset: Offset(0, 1))
                    ]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.content,
                      style: AppTextStyles.bodyMedium.copyWith(
                          color: isMyMessage
                              ? AppColors.white
                              : AppColors.textPrimary),
                    ),
                    SizedBox(height: 4),
                    Text(
                      timeago.format(message.createdAt),
                      style: AppTextStyles.caption.copyWith(
                          color: isMyMessage
                              ? AppColors.white.withValues(alpha: 0.7)
                              : AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
