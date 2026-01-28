import 'package:campuszone/core/core.dart';
import 'package:campuszone/data/models/models.dart';
import 'package:campuszone/data/repositories/repositories.dart';
import 'package:campuszone/globals.dart' as globals;
import 'package:campuszone/presentation/presentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:line_icons/line_icons.dart';

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
      Future.delayed(AppAnimations.fastest, () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: AppAnimations.normal,
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
                          duration: AppAnimations.pageTransition,
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: MessageBubble(
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
                  blurRadius: AppSpacing.xs,
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
                            width: AppIconSize.df,
                            height: AppIconSize.df,
                            child: CircularProgressIndicator(
                                strokeWidth: AppDimensions.loaderStrokeWidth))
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
