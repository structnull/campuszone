import 'package:campuszone/globals.dart';
import 'package:campuszone/pages/profilelink.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:shimmer/shimmer.dart';
import 'dart:async';

class ChatMessagePage extends StatefulWidget {
  final dynamic user;
  const ChatMessagePage({super.key, required this.user});

  @override
  State<ChatMessagePage> createState() => _ChatMessagePageState();
}

class _ChatMessagePageState extends State<ChatMessagePage>
    with TickerProviderStateMixin {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _supabase = Supabase.instance.client;
  final Map<String, dynamic> _userProfiles = {};
  final Map<String, bool> _loadingProfiles = {};
  late AnimationController _animationController;
  late Animation<double> _messageAnimation;
  late ValueNotifier<String?> _cacheBusterListener;

  StreamSubscription? _messagesSubscription;
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  String? _currentUserUid;
  String? _recipientId;
  bool _isSending = false;
  bool _isAtBottom = true;
  int _unreadCount = 0;

  // Animation controllers for individual message bubbles
  final Map<String, AnimationController> _messageAnimControllers = {};

  // Monochrome theme colors
  final Color _primaryColor = Colors.black;
  final Color _primaryLightColor = Colors.grey;
  final Color _secondaryColor = Colors.grey;
  final Color _backgroundColor = Colors.white;
  final Color _accentColor = Colors.blue;

  @override
  void initState() {
    super.initState();
    _currentUserUid = _supabase.auth.currentUser!.id;
    _recipientId = widget.user['id'];

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _messageAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();

    // Listen to global cache buster for profile image updates
    _cacheBusterListener = globalCacheBuster;
    _cacheBusterListener.addListener(_onCacheBusterChanged);

    // Listen to scroll controller to detect when user is at the bottom
    _scrollController.addListener(_handleScroll);

    _loadMessages();
    _subscribeToMessages();
  }

  void _handleScroll() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.offset;
      const delta = 50.0; // Margin of error

      setState(() {
        _isAtBottom = currentScroll >= (maxScroll - delta);
        if (_isAtBottom && _unreadCount > 0) {
          _unreadCount = 0;
        }
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messagesSubscription?.cancel();
    _animationController.dispose();
    _cacheBusterListener.removeListener(_onCacheBusterChanged);
    for (var controller in _messageAnimControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  // Refresh profile images when cache buster changes
  void _onCacheBusterChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadMessages() async {
    try {
      final response = await _supabase
          .from('messages')
          .select()
          .or('and(send_id.eq.$_currentUserUid,recipient_id.eq.$_recipientId),and(send_id.eq.$_recipientId,recipient_id.eq.$_currentUserUid)')
          .order('created_at', ascending: true)
          .limit(50);

      if (!mounted) return;
      setState(() {
        _messages = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
      // Create animation controllers for each message
      for (var message in _messages) {
        _createMessageAnimationController(message['id'].toString());
      }

      // Fetch user profiles for all messages
      for (final message in _messages) {
        _fetchProfile(message['send_id']);
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom(animate: true);
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading messages: $error'),
            backgroundColor: Colors.red[900],
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _scrollToBottom({bool animate = false}) {
    if (_scrollController.hasClients) {
      final position = _scrollController.position.maxScrollExtent;
      if (animate) {
        _scrollController.animateTo(
          position,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(position);
      }
    }
  }

  void _subscribeToMessages() {
    _supabase
        .channel('messages')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          callback: (payload, [ref]) {
            final data = payload.newRecord;
            if (((data['send_id'] == _currentUserUid &&
                    data['recipient_id'] == _recipientId) ||
                (data['send_id'] == _recipientId &&
                    data['recipient_id'] == _currentUserUid))) {
              _handleNewMessage(data);
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'messages',
          callback: (payload, [ref]) {
            final data = payload.oldRecord;
            _handleDeletedMessage(data);
          },
        )
        .subscribe();
  }

  void _handleNewMessage(dynamic messageData) {
    if (!mounted) return;
    final message = Map<String, dynamic>.from(messageData);
    setState(() {
      final messageExists = _messages
          .any((m) => m['id'].toString() == message['id'].toString());
      if (!messageExists) {
        _messages.add(message);
        _createMessageAnimationController(message['id'].toString());
        _fetchProfile(message['send_id']);
        if (message['send_id'] == _recipientId && !_isAtBottom) {
          _unreadCount++;
        }
      }
    });
    if (_isAtBottom || message['send_id'] == _currentUserUid) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom(animate: true);
      });
    }

    if (message['send_id'] != _currentUserUid) {
      HapticFeedback.lightImpact();
    }
  }

  void _handleDeletedMessage(dynamic messageData) {
    if (!mounted) return;
    final String messageId = messageData['id'].toString();
    final controller = _messageAnimControllers[messageId];
    if (controller != null) {
      controller.reverse().then((_) {
        if (mounted) {
          setState(() {
            _messages.removeWhere(
                (message) => message['id'].toString() == messageId);
            _messageAnimControllers.remove(messageId);
          });
        }
      });
    } else {
      if (mounted) {
        setState(() {
          _messages.removeWhere(
              (message) => message['id'].toString() == messageId);
        });
      }
    }
  }

  void _createMessageAnimationController(String messageId) {
    if (!_messageAnimControllers.containsKey(messageId)) {
      final controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      );
      _messageAnimControllers[messageId] = controller;
      controller.forward();
    }
  }

  void _fetchProfile(String profileId) async {
    if (_userProfiles.containsKey(profileId) ||
        _loadingProfiles[profileId] == true) {
      return;
    }

    _loadingProfiles[profileId] = true;

    try {
      final data =
          await _supabase.from('users').select().eq('id', profileId).single();
      if (!mounted) return;
      setState(() {
        _userProfiles[profileId] = data;
        _loadingProfiles[profileId] = false;
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          _loadingProfiles[profileId] = false;
        });
      }
    }
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
    });
    _messageController.clear();

    try {
      final messageData = {
        'content': content,
        'send_id': _currentUserUid,
        'recipient_id': _recipientId,
        'created_at': DateTime.now().toIso8601String(),
      };

      // Await the insert. If an error occurs, it will be thrown.
      await _supabase.from('messages').insert(messageData);
      HapticFeedback.lightImpact();
      // The realtime subscription will add the new message.
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending message: $error'),
            backgroundColor: Colors.red[900],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  Future<void> _deleteMessage(dynamic messageId) async {
    try {
      await _supabase.from('messages').delete().eq('id', messageId);
      // The realtime subscription will remove the message.
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting message: $error'),
            backgroundColor: Colors.red[900],
          ),
        );
      }
    }
  }

  void _showDeleteMessageDialog(Map<String, dynamic> message) {
    if (message['send_id'] != _currentUserUid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('You can only delete your own messages'),
          backgroundColor: Colors.black,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Message?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: TextStyle(color: _primaryColor)),
          ),
          TextButton(
            onPressed: () {
              _deleteMessage(message['id']);
              Navigator.of(context).pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage(String profileId) {
    final String baseUrl = _supabase.storage
        .from('profilepic')
        .getPublicUrl('$profileId/profile_picture.jpg');
    final String cacheBuster = _cacheBusterListener.value ?? '';
    final String profileUrl =
        cacheBuster.isNotEmpty ? '$baseUrl?cacheBuster=$cacheBuster' : baseUrl;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProfileLinkPage(userId: profileId),
          ),
        );
      },
      child: Hero(
        tag: 'profile2-$profileId${_cacheBusterListener.value ?? ""}',
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: _primaryColor.withAlpha(20),
              width: 1.5,
            ),
          ),
          child: ClipOval(
            child: Image.network(
              profileUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person, color: _backgroundColor),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, bool isMyMessage) {
    final profileId = message['send_id'];
    final hasProfileData = _userProfiles.containsKey(profileId);
    final username = hasProfileData
        ? _userProfiles[profileId]['name'] ?? 'User'
        : 'Loading...';

    final messageId = message['id'].toString();
    final controller =
        _messageAnimControllers[messageId] ?? _animationController;

    final slideAnimation = Tween<Offset>(
      begin: isMyMessage ? const Offset(1, 0) : const Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutCubic,
    ));

    final fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeOut,
    ));

    return GestureDetector(
      onLongPress: () {
        HapticFeedback.mediumImpact();
        _showDeleteMessageDialog(message);
      },
      child: SlideTransition(
        position: slideAnimation,
        child: FadeTransition(
          opacity: fadeAnimation,
          child: Container(
            margin: EdgeInsets.only(
              top: 8,
              bottom: 8,
              left: isMyMessage ? 64 : 16,
              right: isMyMessage ? 16 : 64,
            ),
            child: Row(
              mainAxisAlignment:
                  isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isMyMessage) _buildProfileImage(profileId),
                if (!isMyMessage) const SizedBox(width: 8),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isMyMessage ? _primaryColor : _secondaryColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(isMyMessage ? 20 : 4),
                        topRight: Radius.circular(isMyMessage ? 4 : 20),
                        bottomLeft: const Radius.circular(20),
                        bottomRight: const Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                          color: Colors.black.withAlpha(10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: isMyMessage
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        if (!isMyMessage)
                          Text(
                            username,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isMyMessage
                                  ? _backgroundColor
                                  : _primaryColor,
                            ),
                          ),
                        if (!isMyMessage) const SizedBox(height: 4),
                        Text(
                          message['content'],
                          style: TextStyle(
                            color:
                                isMyMessage ? _backgroundColor : _primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          timeago.format(
                              DateTime.parse(message['created_at']).toLocal()),
                          style: TextStyle(
                            fontSize: 10,
                            color: isMyMessage
                                ? _backgroundColor.withAlpha(70)
                                : _primaryColor.withAlpha(70),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (isMyMessage) const SizedBox(width: 8),
                if (isMyMessage) _buildProfileImage(profileId),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    if (_isLoading) {
      return Expanded(
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: ListView.builder(
            itemCount: 10,
            itemBuilder: (context, index) => Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
      );
    }

    if (_messages.isEmpty) {
      return Expanded(
        child: Center(
          child: FadeTransition(
            opacity: _messageAnimation,
            child: Text(
              'No messages yet. Start the conversation!',
              style: TextStyle(color: _primaryColor.withAlpha(70)),
            ),
          ),
        ),
      );
    }

    return Expanded(
      child: Stack(
        children: [
          ListView.builder(
            controller: _scrollController,
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final message = _messages[index];
              final isMyMessage = message['send_id'] == _currentUserUid;
              return _buildMessageBubble(message, isMyMessage);
            },
          ),
          if (_unreadCount > 0)
            Positioned(
              bottom: 20,
              right: 20,
              child: GestureDetector(
                onTap: () {
                  _scrollToBottom(animate: true);
                  setState(() {
                    _unreadCount = 0;
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _accentColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                        color: Colors.black.withAlpha(20),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$_unreadCount new ${_unreadCount == 1 ? 'message' : 'messages'}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_downward,
                        color: Colors.white,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        primaryColor: _primaryColor,
        colorScheme: ColorScheme.light(
          primary: _primaryColor,
          secondary: _primaryLightColor,
          surface: _backgroundColor,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: _primaryColor,
          foregroundColor: _backgroundColor,
          elevation: 0,
        ),
        iconTheme: IconThemeData(color: _primaryColor),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: _primaryColor),
          bodyMedium: TextStyle(color: _primaryColor),
        ),
      ),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeOut,
            )),
            child: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  _animationController.reverse().then((_) {
                    Navigator.of(context).pop();
                  });
                },
              ),
              elevation: 0,
              title: Row(
                children: [
                  _buildProfileImage(widget.user['id']),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.user['name'] ?? 'User',
                      style: const TextStyle(
                        fontSize: 24,
                        fontFamily: 'Excalifont',
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.black),
                  onPressed: _loadMessages,
                ),
              ],
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              _buildMessageList(),
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _animationController,
                  curve: Curves.easeOut,
                )),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(
                    color: _backgroundColor,
                    boxShadow: [
                      BoxShadow(
                        offset: const Offset(0, -2),
                        blurRadius: 4,
                        color: _primaryColor.withAlpha(10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            color: _secondaryColor,
                          ),
                          child: TextField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              hintText: 'Type a message...',
                              hintStyle:
                                  TextStyle(color: _primaryColor.withAlpha(50)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                            ),
                            style: TextStyle(color: _primaryColor),
                            textCapitalization: TextCapitalization.sentences,
                            maxLines: null,
                            onChanged: (value) {
                              if (value.length % 10 == 0 && value.isNotEmpty) {
                                HapticFeedback.selectionClick();
                              }
                            },
                            onSubmitted: (value) {
                              if (value.trim().isNotEmpty) {
                                _sendMessage();
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: MaterialButton(
                          onPressed: _sendMessage,
                          color: _primaryColor,
                          textColor: _backgroundColor,
                          minWidth: 0,
                          height: 48,
                          padding: const EdgeInsets.all(12),
                          shape: const CircleBorder(),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                              return ScaleTransition(
                                  scale: animation, child: child);
                            },
                            child: _isSending
                                ? const SizedBox(
                                    key: ValueKey('loading'),
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    Icons.send,
                                    key: ValueKey('send'),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
