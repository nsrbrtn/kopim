import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    return Scaffold(
      appBar: AppBar(title: Text(strings.assistantScreenTitle)),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            _AssistantOfflineBanner(
              isOffline: isOffline,
              onRetry: () => ref
                  .read(assistantSessionControllerProvider.notifier)
                  .retryPendingMessages(),
            ),
            _AssistantQuickActions(
              onActionSelected:
                  (
                    AiQueryIntent intent,
                    String prompt,
                    Set<AssistantFilter> filters,
                  ) {
                    ref
                        .read(assistantSessionControllerProvider.notifier)
                        .sendMessage(
                          prompt,
                          intentOverride: intent,
                          additionalFilters: filters,
                        );
                    _inputFocusNode.requestFocus();
                  },
            ),
            _AssistantFiltersBar(
              activeFilters: activeFilters,
              onFilterTapped: (AssistantFilter filter) => ref
                  .read(assistantSessionControllerProvider.notifier)
                  .toggleFilter(filter),
            ),
            Expanded(
              child: visibleMessages.isEmpty
                  ? _AssistantEmptyState(strings: strings)
                  : _AssistantMessageList(
                      controller: _scrollController,
                      messages: visibleMessages,
                      onRetry: (String messageId) => ref
                          .read(assistantSessionControllerProvider.notifier)
                          .retryMessage(messageId),
                    ),
            ),
            _AssistantErrorNotice(lastError: lastError, isOffline: isOffline),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            strings.assistantQuickActionsTitle,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _kAssistantQuickActions.length,
              separatorBuilder: (_, int index) => const SizedBox(width: 8),
              itemBuilder: (BuildContext context, int index) {
                final _AssistantQuickActionConfig config =
                    _kAssistantQuickActions[index];
                final String label = strings.assistantQuickActionLabel(
                  config.kind,
                );
                return ActionChip(
                  label: Text(label),
                  onPressed: () {
                    final String prompt = strings.assistantQuickActionPrompt(
                      config.kind,
                    );
                    onActionSelected(
                      config.intent,
                      prompt,
                      config.additionalFilters,
                    );
                  },
                );
              },
            ),
          ),
        ],
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            strings.assistantFiltersTitle,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _kAssistantFilters
                .map((AssistantFilter filter) {
                  final bool selected = activeFilters.contains(filter);
                  return FilterChip(
                    label: Text(strings.assistantFilterLabel(filter)),
                    selected: selected,
                    onSelected: (_) => onFilterTapped(filter),
                  );
                })
                .toList(growable: false),
          ),
        ],
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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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
    final Color backgroundColor = _isUser
        ? colorScheme.primaryContainer
        : colorScheme.surfaceContainerHigh;
    final TextStyle? textStyle = theme.textTheme.bodyMedium?.copyWith(
      color: _isUser ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
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

    final Widget bubble = Container(
      constraints: const BoxConstraints(maxWidth: 520),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
    final bool canSend =
        widget.controller.text.trim().isNotEmpty && !widget.isSending;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            minLines: 1,
            maxLines: 5,
            textInputAction: TextInputAction.send,
            onSubmitted: (String value) {
              final String trimmed = value.trim();
              if (trimmed.isEmpty) {
                return;
              }
              widget.onSubmitted(trimmed);
              widget.controller.clear();
              setState(() {});
            },
            onChanged: (_) => setState(() {}),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface,
              letterSpacing: 0.5,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                letterSpacing: 0.5,
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerLow,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: const BorderSide(color: Colors.transparent),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 1,
                ),
              ),
              suffixIconConstraints:
                  const BoxConstraints(minWidth: 48, minHeight: 48),
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 4),
                child: IconButton(
                  splashRadius: 24,
                  onPressed: canSend
                      ? () {
                          final String value =
                              widget.controller.text.trim();
                          if (value.isEmpty) {
                            return;
                          }
                          widget.onSubmitted(value);
                          widget.controller.clear();
                          setState(() {});
                        }
                      : null,
                  icon: widget.isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send_rounded),
                ),
              ),
            ),
          ),
          if (widget.isOffline)
            Padding(
              padding: const EdgeInsets.only(top: 8, right: 8),
              child: Align(
                alignment: Alignment.centerRight,
                child: Tooltip(
                  message: AppLocalizations.of(
                    context,
                  )!.assistantPendingMessageHint,
                  child: Icon(
                    Icons.cloud_off,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
        ],
      ),
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
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final ThemeData theme = Theme.of(context);
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight > 0
                  ? constraints.maxHeight - 48
                  : 0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Icon(Icons.smart_toy_outlined, size: 48),
                const SizedBox(height: 16),
                Text(
                  strings.assistantEmptyStateTitle,
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  strings.assistantEmptyStateSubtitle,
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _AssistantOnboardingChecklist(strings: strings),
                const SizedBox(height: 24),
                _AssistantFaqSection(strings: strings),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AssistantOnboardingChecklist extends StatelessWidget {
  const _AssistantOnboardingChecklist({required this.strings});

  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<_AssistantChecklistItem> features = <_AssistantChecklistItem>[
      _AssistantChecklistItem(
        icon: Icons.analytics_outlined,
        label: strings.assistantOnboardingFeatureInsights,
      ),
      _AssistantChecklistItem(
        icon: Icons.account_balance_wallet_outlined,
        label: strings.assistantOnboardingFeatureBudgets,
      ),
      _AssistantChecklistItem(
        icon: Icons.savings_outlined,
        label: strings.assistantOnboardingFeatureSavings,
      ),
    ];
    final List<_AssistantChecklistItem> limitations = <_AssistantChecklistItem>[
      _AssistantChecklistItem(
        icon: Icons.sync_outlined,
        label: strings.assistantOnboardingLimitationDataFreshness,
      ),
      _AssistantChecklistItem(
        icon: Icons.shield_outlined,
        label: strings.assistantOnboardingLimitationSecurity,
      ),
      _AssistantChecklistItem(
        icon: Icons.fact_check_outlined,
        label: strings.assistantOnboardingLimitationAccuracy,
      ),
    ];

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              strings.assistantOnboardingTitle,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(
              strings.assistantOnboardingDescription,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ...features.map(_AssistantChecklistRow.new),
            const SizedBox(height: 20),
            Text(
              strings.assistantOnboardingLimitationsTitle,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            ...limitations.map(_AssistantChecklistRow.new),
          ],
        ),
      ),
    );
  }
}

class _AssistantChecklistItem {
  const _AssistantChecklistItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class _AssistantChecklistRow extends StatelessWidget {
  const _AssistantChecklistRow(this.item);

  final _AssistantChecklistItem item;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(item.icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(item.label, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class _AssistantFaqSection extends StatelessWidget {
  const _AssistantFaqSection({required this.strings});

  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<_AssistantFaqEntry> entries = <_AssistantFaqEntry>[
      _AssistantFaqEntry(
        question: strings.assistantFaqQuestionDataSources,
        answer: strings.assistantFaqAnswerDataSources,
      ),
      _AssistantFaqEntry(
        question: strings.assistantFaqQuestionLimits,
        answer: strings.assistantFaqAnswerLimits,
      ),
      _AssistantFaqEntry(
        question: strings.assistantFaqQuestionImproveResults,
        answer: strings.assistantFaqAnswerImproveResults,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(strings.assistantFaqTitle, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        ...entries.map(
          (_AssistantFaqEntry entry) => _AssistantFaqTile(entry: entry),
        ),
      ],
    );
  }
}

class _AssistantFaqEntry {
  const _AssistantFaqEntry({required this.question, required this.answer});

  final String question;
  final String answer;
}

class _AssistantFaqTile extends StatelessWidget {
  const _AssistantFaqTile({required this.entry});

  final _AssistantFaqEntry entry;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: theme.colorScheme.surfaceContainerLowest,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Text(entry.question, style: theme.textTheme.bodyLarge),
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: Text(entry.answer, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
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
