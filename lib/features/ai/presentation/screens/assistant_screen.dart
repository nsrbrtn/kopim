import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kopim/core/widgets/collapsible_list/collapsible_list.dart';
import 'package:kopim/core/widgets/kopim_text_field.dart';
import 'package:kopim/features/ai/domain/entities/ai_user_query_entity.dart';
import 'package:kopim/features/ai/presentation/controllers/assistant_session_controller.dart';
import 'package:kopim/features/ai/presentation/models/assistant_filters.dart';
import 'package:kopim/features/ai/presentation/models/assistant_message.dart';
import 'package:kopim/features/ai/presentation/models/assistant_session_state.dart';
import 'package:kopim/features/app_shell/presentation/models/navigation_tab_content.dart';
import 'package:kopim/l10n/app_localizations.dart';

NavigationTabContent buildAssistantTabContent(
  BuildContext context,
  WidgetRef ref,
) {
  return NavigationTabContent(
    bodyBuilder: (BuildContext context, WidgetRef ref) =>
        const AssistantScreen(),
  );
}

class AssistantScreen extends ConsumerStatefulWidget {
  const AssistantScreen({super.key});

  @override
  ConsumerState<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends ConsumerState<AssistantScreen> {
  late final TextEditingController _inputController;
  late final ScrollController _scrollController;
  late final FocusNode _inputFocusNode;
  ProviderSubscription<AssistantSessionState>? _subscription;

  @override
  void initState() {
    super.initState();
    _inputController = TextEditingController();
    _scrollController = ScrollController();
    _inputFocusNode = FocusNode();
    _subscription = ref.listenManual<AssistantSessionState>(
      assistantSessionControllerProvider,
      (AssistantSessionState? previous, AssistantSessionState next) {
        final int previousLength = previous?.messages.length ?? 0;
        final int nextLength = next.messages.length;
        final bool streamingChanged =
            previous?.streamingMessage?.id != next.streamingMessage?.id ||
            previous?.streamingMessage?.content !=
                next.streamingMessage?.content;
        if ((nextLength > previousLength || streamingChanged) &&
            _scrollController.hasClients) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_scrollController.hasClients) {
              return;
            }
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
            );
          });
        }
      },
      fireImmediately: false,
    );
  }

  @override
  void dispose() {
    _subscription?.close();
    _inputController.dispose();
    _scrollController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final List<AssistantMessage> messages = ref.watch(
      assistantSessionControllerProvider.select(
        (AssistantSessionState state) => state.messages,
      ),
    );
    final AssistantMessage? streamingMessage = ref.watch(
      assistantSessionControllerProvider.select(
        (AssistantSessionState state) => state.streamingMessage,
      ),
    );
    final bool isSending = ref.watch(
      assistantSessionControllerProvider.select(
        (AssistantSessionState state) => state.isSending,
      ),
    );
    final bool isOffline = ref.watch(
      assistantSessionControllerProvider.select(
        (AssistantSessionState state) => state.isOffline,
      ),
    );
    final Set<AssistantFilter> activeFilters = ref.watch(
      assistantSessionControllerProvider.select(
        (AssistantSessionState state) => state.activeFilters,
      ),
    );
    final AssistantErrorType lastError = ref.watch(
      assistantSessionControllerProvider.select(
        (AssistantSessionState state) => state.lastError,
      ),
    );

    final List<AssistantMessage> visibleMessages = <AssistantMessage>[
      ...messages,
    ];
    if (streamingMessage != null) {
      visibleMessages.add(streamingMessage);
    }

    final ThemeData theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 412),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        strings.assistantScreenTitle,
                        style: theme.textTheme.headlineSmall,
                      ),
                      const Spacer(),
                      Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const AssistantUsageInfoScreen(),
                            ),
                          ),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              Icons.help_outline,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _AssistantOfflineBanner(
                    isOffline: isOffline,
                    onRetry: () => ref
                        .read(assistantSessionControllerProvider.notifier)
                        .retryPendingMessages(),
                  ),
                  const SizedBox(height: 8),
                  _AssistantFiltersBar(
                    activeFilters: activeFilters,
                    onFilterTapped: (AssistantFilter filter) => ref
                        .read(assistantSessionControllerProvider.notifier)
                        .toggleFilter(filter),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        color: theme.colorScheme.surfaceContainer,
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            _AssistantErrorNotice(
                              lastError: lastError,
                              isOffline: isOffline,
                            ),
                            Expanded(
                              child: visibleMessages.isEmpty
                                  ? _AssistantEmptyState(strings: strings)
                                  : _AssistantMessageList(
                                      controller: _scrollController,
                                      messages: visibleMessages,
                                      onRetry: (String messageId) => ref
                                          .read(
                                            assistantSessionControllerProvider
                                                .notifier,
                                          )
                                          .retryMessage(messageId),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedBuilder(
                    animation: _inputFocusNode,
                    builder: (BuildContext context, Widget? child) {
                      if (_inputFocusNode.hasFocus) {
                        return const SizedBox.shrink();
                      }
                      return Column(
                        children: <Widget>[
                          const SizedBox(height: 8),
                          _AssistantQuickActions(
                            onActionSelected:
                                (
                                  AiQueryIntent intent,
                                  String prompt,
                                  Set<AssistantFilter> filters,
                                ) {
                                  ref
                                      .read(
                                        assistantSessionControllerProvider
                                            .notifier,
                                      )
                                      .sendMessage(
                                        prompt,
                                        intentOverride: intent,
                                        additionalFilters: filters,
                                      );
                                  _inputFocusNode.requestFocus();
                                },
                          ),
                          const SizedBox(height: 8),
                        ],
                      );
                    },
                  ),
                  _AssistantInputBar(
                    controller: _inputController,
                    focusNode: _inputFocusNode,
                    isSending: isSending,
                    isOffline: isOffline,
                    hintText: strings.assistantInputHint,
                    onSubmitted: (String value) {
                      ref
                          .read(assistantSessionControllerProvider.notifier)
                          .sendMessage(value);
                      _inputController.clear();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AssistantOfflineBanner extends StatelessWidget {
  const _AssistantOfflineBanner({
    required this.isOffline,
    required this.onRetry,
  });

  final bool isOffline;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: isOffline
          ? Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Material(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                color: theme.colorScheme.surfaceContainerHighest,
                child: ListTile(
                  leading: const Icon(Icons.wifi_off, size: 24),
                  title: Text(strings.assistantOfflineBanner),
                  trailing: TextButton(
                    onPressed: onRetry,
                    child: Text(strings.assistantRetryButton),
                  ),
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}

class _AssistantQuickActions extends StatelessWidget {
  const _AssistantQuickActions({required this.onActionSelected});

  final void Function(
    AiQueryIntent intent,
    String prompt,
    Set<AssistantFilter> filters,
  )
  onActionSelected;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    if (_kAssistantQuickActions.isEmpty) {
      return const SizedBox.shrink();
    }
    final ThemeData theme = Theme.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (
            int index = 0;
            index < _kAssistantQuickActions.length;
            index++
          ) ...<Widget>[
            if (index > 0) const SizedBox(width: 8),
            Material(
              color: theme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  final _AssistantQuickActionConfig config =
                      _kAssistantQuickActions[index];
                  final String prompt = strings.assistantQuickActionPrompt(
                    config.kind,
                  );
                  onActionSelected(
                    config.intent,
                    prompt,
                    config.additionalFilters,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Text(
                    strings.assistantQuickActionLabel(
                      _kAssistantQuickActions[index].kind,
                    ),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class AssistantUsageInfoScreen extends StatelessWidget {
  const AssistantUsageInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(strings.assistantScreenTitle)),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Использование ИИ-ассистента',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(
              'В приложении доступен ИИ-ассистент, ответы '
              'которого формируются автоматически на основе моделей '
              'искусственного интеллекта (через сервис OpenRouter).\n\n'
              'Ответы могут содержать ошибки, быть неполными или '
              'устаревшими и не являются финансовой, юридической, '
              'налоговой или иной профессиональной консультацией. Все '
              'решения вы принимаете самостоятельно и на свой риск.\n\n'
              'Не вводите в чат номера карт, пароли, CVV, коды из SMS, '
              'паспортные данные и другую чувствительную личную информацию. '
              'Текст ваших запросов передаётся стороннему сервису для '
              'обработки.\n\n'
              'Продолжая, вы подтверждаете, что ознакомились с этими '
              'условиями и согласны с ними.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            TextButton(onPressed: () {}, child: const Text('Подробнее')),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFF67696A),
                        foregroundColor: const Color(0xFFC9C6BC),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        side: BorderSide.none,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      child: const Text('Отмена'),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFAEF75F),
                        foregroundColor: const Color(0xFF1D3700),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      child: const Text('Принять'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AssistantFiltersBar extends StatelessWidget {
  const _AssistantFiltersBar({
    required this.activeFilters,
    required this.onFilterTapped,
  });

  final Set<AssistantFilter> activeFilters;
  final ValueChanged<AssistantFilter> onFilterTapped;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);
    return KopimExpandableSectionPlayful(
      title: strings.assistantFiltersTitle,
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: _kAssistantFilters
            .map((AssistantFilter filter) {
              final bool selected = activeFilters.contains(filter);
              final Color chipColor = selected
                  ? theme.colorScheme.secondaryContainer
                  : theme.colorScheme.surfaceContainerHighest;
              final Color textColor = selected
                  ? theme.colorScheme.onSecondaryContainer
                  : theme.colorScheme.onSurface;
              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => onFilterTapped(filter),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: chipColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    strings.assistantFilterLabel(filter),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: textColor,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            })
            .toList(growable: false),
      ),
    );
  }
}

class _AssistantMessageList extends StatelessWidget {
  const _AssistantMessageList({
    required this.controller,
    required this.messages,
    required this.onRetry,
  });

  final ScrollController controller;
  final List<AssistantMessage> messages;
  final ValueChanged<String> onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: controller,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: messages.length,
      separatorBuilder: (_, int index) => const SizedBox(height: 8),
      itemBuilder: (BuildContext context, int index) {
        final AssistantMessage message = messages[index];
        return _AssistantMessageBubble(message: message, onRetry: onRetry);
      },
    );
  }
}

class _AssistantMessageBubble extends StatelessWidget {
  const _AssistantMessageBubble({required this.message, required this.onRetry});

  final AssistantMessage message;
  final ValueChanged<String> onRetry;

  bool get _isUser => message.author == AssistantMessageAuthor.user;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final Alignment alignment = _isUser
        ? Alignment.centerRight
        : Alignment.centerLeft;
    final ColorScheme colorScheme = theme.colorScheme;
    final Color bubbleColor = _isUser
        ? colorScheme.secondaryContainer
        : colorScheme.surfaceContainerHigh;
    final TextStyle? textStyle = theme.textTheme.bodyMedium?.copyWith(
      color: _isUser
          ? colorScheme.onSecondaryContainer
          : colorScheme.onSurfaceVariant,
      height: 1.4,
    );

    final Widget content;
    if (message.isStreaming) {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              strings.assistantStreamingPlaceholder,
              style: textStyle,
            ),
          ),
        ],
      );
    } else if (_isUser) {
      content = Text(message.content, style: textStyle);
    } else {
      final MarkdownStyleSheet markdownStyleSheet =
          MarkdownStyleSheet.fromTheme(theme).copyWith(
            p: textStyle,
            strong: textStyle?.copyWith(fontWeight: FontWeight.w600),
            em: textStyle?.copyWith(fontStyle: FontStyle.italic),
            code: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface,
              backgroundColor: colorScheme.surfaceContainerHighest,
              fontFamily: 'monospace',
            ),
            a: textStyle?.copyWith(color: colorScheme.primary),
          );
      content = MarkdownBody(
        data: message.content,
        styleSheet: markdownStyleSheet,
        shrinkWrap: true,
        selectable: true,
      );
    }

    final BorderRadius borderRadius = _isUser
        ? const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(8),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(8),
            bottomRight: Radius.circular(20),
          );
    final BoxDecoration decoration = BoxDecoration(
      color: bubbleColor,
      borderRadius: borderRadius,
      boxShadow: _isUser
          ? <BoxShadow>[
              BoxShadow(
                color: colorScheme.secondaryContainer.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ]
          : null,
    );
    final Widget bubble = Container(
      constraints: const BoxConstraints(maxWidth: 380),
      decoration: decoration,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: content,
    );

    final Widget? status = _buildStatus(strings, theme);

    return Align(
      alignment: alignment,
      child: GestureDetector(
        onLongPress: message.isStreaming
            ? null
            : () async {
                await Clipboard.setData(ClipboardData(text: message.content));
                if (!context.mounted) {
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(strings.assistantMessageCopied)),
                );
              },
        child: Column(
          crossAxisAlignment: _isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: <Widget>[
            bubble,
            if (status != null) ...<Widget>[const SizedBox(height: 4), status],
          ],
        ),
      ),
    );
  }

  Widget? _buildStatus(AppLocalizations strings, ThemeData theme) {
    if (message.author != AssistantMessageAuthor.user || message.isStreaming) {
      return null;
    }
    final TextStyle? style = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return switch (message.deliveryStatus) {
      AssistantMessageDeliveryStatus.delivered => null,
      AssistantMessageDeliveryStatus.sending => Text(
        strings.assistantSendingMessageHint,
        style: style,
      ),
      AssistantMessageDeliveryStatus.pending => Text(
        strings.assistantPendingMessageHint,
        style: style,
      ),
      AssistantMessageDeliveryStatus.failed => Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Flexible(
            child: Text(strings.assistantFailedMessageHint, style: style),
          ),
          TextButton(
            onPressed: () => onRetry(message.id),
            child: Text(strings.assistantRetryButton),
          ),
        ],
      ),
    };
  }
}

class _AssistantInputBar extends StatefulWidget {
  const _AssistantInputBar({
    required this.controller,
    required this.focusNode,
    required this.isSending,
    required this.isOffline,
    required this.hintText,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isSending;
  final bool isOffline;
  final String hintText;
  final ValueChanged<String> onSubmitted;

  @override
  State<_AssistantInputBar> createState() => _AssistantInputBarState();
}

class _AssistantInputBarState extends State<_AssistantInputBar> {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final bool canSend =
        widget.controller.text.trim().isNotEmpty && !widget.isSending;

    void handleSend() {
      final String trimmed = widget.controller.text.trim();
      if (trimmed.isEmpty) {
        return;
      }
      widget.onSubmitted(trimmed);
      widget.controller.clear();
      setState(() {});
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        KopimTextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          minLines: 1,
          maxLines: 3,
          textInputAction: TextInputAction.send,
          onSubmitted: (_) => handleSend(),
          onChanged: (_) => setState(() {}),
          placeholder: widget.hintText,
          fillColor: theme.colorScheme.surfaceContainerHigh,
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 4),
            child: IconButton(
              splashRadius: 24,
              onPressed: canSend ? handleSend : null,
              icon: widget.isSending
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    )
                  : Icon(
                      Icons.send_rounded,
                      color: canSend
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
            ),
          ),
        ),
        if (widget.isOffline)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.cloud_off,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  strings.assistantPendingMessageHint,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _AssistantErrorNotice extends StatelessWidget {
  const _AssistantErrorNotice({
    required this.lastError,
    required this.isOffline,
  });

  final AssistantErrorType lastError;
  final bool isOffline;

  @override
  Widget build(BuildContext context) {
    if (lastError == AssistantErrorType.none) {
      return const SizedBox.shrink();
    }
    final AppLocalizations strings = AppLocalizations.of(context)!;
    String message;
    switch (lastError) {
      case AssistantErrorType.network:
        message = strings.assistantNetworkError;
      case AssistantErrorType.timeout:
        message = strings.assistantTimeoutError;
      case AssistantErrorType.rateLimit:
        message = strings.assistantRateLimitError;
      case AssistantErrorType.server:
        message = strings.assistantServerError;
      case AssistantErrorType.disabled:
        message = strings.assistantDisabledError;
      case AssistantErrorType.configuration:
        message = strings.assistantConfigurationError;
      case AssistantErrorType.unknown:
        message = strings.assistantGenericError;
      case AssistantErrorType.none:
        message = '';
    }
    if (message.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            isOffline ? Icons.wifi_off : Icons.info_outline,
            size: 20,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AssistantEmptyState extends StatelessWidget {
  const _AssistantEmptyState({required this.strings});

  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class _AssistantQuickActionConfig {
  const _AssistantQuickActionConfig({
    required this.kind,
    required this.intent,
    this.additionalFilters = const <AssistantFilter>{},
  });

  final _AssistantQuickActionKind kind;
  final AiQueryIntent intent;
  final Set<AssistantFilter> additionalFilters;
}

enum _AssistantQuickActionKind { spending, budgets, savings }

const List<_AssistantQuickActionConfig> _kAssistantQuickActions =
    <_AssistantQuickActionConfig>[
      _AssistantQuickActionConfig(
        kind: _AssistantQuickActionKind.spending,
        intent: AiQueryIntent.analytics,
        additionalFilters: <AssistantFilter>{AssistantFilter.currentMonth},
      ),
      _AssistantQuickActionConfig(
        kind: _AssistantQuickActionKind.budgets,
        intent: AiQueryIntent.budgeting,
        additionalFilters: <AssistantFilter>{AssistantFilter.budgetsOnly},
      ),
      _AssistantQuickActionConfig(
        kind: _AssistantQuickActionKind.savings,
        intent: AiQueryIntent.savings,
        additionalFilters: <AssistantFilter>{AssistantFilter.last30Days},
      ),
    ];

const List<AssistantFilter> _kAssistantFilters = <AssistantFilter>[
  AssistantFilter.currentMonth,
  AssistantFilter.last30Days,
  AssistantFilter.budgetsOnly,
];

extension _AssistantQuickActionStrings on AppLocalizations {
  String assistantQuickActionLabel(_AssistantQuickActionKind kind) {
    switch (kind) {
      case _AssistantQuickActionKind.spending:
        return assistantQuickActionSpendingLabel;
      case _AssistantQuickActionKind.budgets:
        return assistantQuickActionBudgetLabel;
      case _AssistantQuickActionKind.savings:
        return assistantQuickActionSavingsLabel;
    }
  }

  String assistantQuickActionPrompt(_AssistantQuickActionKind kind) {
    switch (kind) {
      case _AssistantQuickActionKind.spending:
        return assistantQuickActionSpendingPrompt;
      case _AssistantQuickActionKind.budgets:
        return assistantQuickActionBudgetPrompt;
      case _AssistantQuickActionKind.savings:
        return assistantQuickActionSavingsPrompt;
    }
  }

  String assistantFilterLabel(AssistantFilter filter) {
    switch (filter) {
      case AssistantFilter.currentMonth:
        return assistantFilterCurrentMonth;
      case AssistantFilter.last30Days:
        return assistantFilterLast30Days;
      case AssistantFilter.budgetsOnly:
        return assistantFilterBudgets;
    }
  }
}
