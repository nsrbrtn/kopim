import 'package:flutter/material.dart';
import 'package:kopim/core/domain/icons/phosphor_icon_descriptor.dart';
import 'package:kopim/core/widgets/phosphor_icon_utils.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class PhosphorIconPickerLabels {
  const PhosphorIconPickerLabels({
    required this.title,

    required this.emptyStateLabel,
    required this.styleLabels,
    required this.groupLabels,
  });

  final String title;

  final String emptyStateLabel;
  final Map<PhosphorIconStyle, String> styleLabels;
  final Map<String, String> groupLabels;
}

const int _kPhosphorIconPickerLimit = 237;

class _IconGroup {
  const _IconGroup({required this.id, required this.iconNames});

  final String id;
  final List<String> iconNames;
}

const List<_IconGroup> _iconGroups = <_IconGroup>[
  _IconGroup(
    id: 'groceries',
    iconNames: <String>[
      'basket',
      'shoppingCart',
      'shoppingCartSimple',
      'shoppingBag',
      'shoppingBagOpen',
      'tag',
      'bowlFood',
      'carrot',
      'fish',
      'eggCrack',
    ],
  ),
  _IconGroup(
    id: 'dining',
    iconNames: <String>[
      'forkKnife',
      'coffee',
      'pizza',
      'hamburger',
      'cake',
      'iceCream',
      'wine',
      'beerBottle',
      'beerStein',
      'ticket',
    ],
  ),
  _IconGroup(
    id: 'clothing',
    iconNames: <String>[
      'tShirt',
      'hoodie',
      'pants',
      'dress',
      'sneaker',
      'handbag',
      'storefront',
      'hairDryer',
      'scissors',
      'flower',
      'flowerLotus',
      'flowerTulip',
      'eyedropper',
      'palette',
    ],
  ),
  _IconGroup(
    id: 'home',
    iconNames: <String>[
      'house',
      'houseLine',
      'couch',
      'bed',
      'lamp',
      'chair',
      'rug',
      'shower',
      'bathtub',
      'washingMachine',
    ],
  ),
  _IconGroup(
    id: 'utilities',
    iconNames: <String>[
      'plug',
      'plugCharging',
      'drop',
      'dropHalfBottom',
      'flame',
      'fan',
      'trash',
      'wifiHigh',
    ],
  ),
  _IconGroup(
    id: 'communication',
    iconNames: <String>[
      'phone',
      'phonePlus',
      'deviceMobile',
      'headset',
      'wifiHigh',
      'wifiMedium',
      'wifiLow',
      'globe',
      'broadcast',
      'deviceTablet',
      'desktop',
      'laptop',
      'monitor',
      'cpu',
    ],
  ),
  _IconGroup(
    id: 'subscriptions',
    iconNames: <String>[
      'playPause',
      'filmReel',
      'musicNotes',
      'musicNotesPlus',
      'headphones',
      'cloud',
    ],
  ),
  _IconGroup(
    id: 'publicTransport',
    iconNames: <String>[
      'bus',
      'train',
      'subway',
      'tram',
      'ticket',
      'mapPin',
      'roadHorizon',
    ],
  ),
  _IconGroup(
    id: 'car',
    iconNames: <String>[
      'car',
      'carSimple',
      'carProfile',
      'gasPump',
      'gasCan',
      'steeringWheel',
      'engine',
      'wrench',
      'toolbox',
      'motorcycle',
      'scooter',
    ],
  ),
  _IconGroup(
    id: 'taxi',
    iconNames: <String>[
      'taxi',
      'car',
      'parking',
      'creditCard',
      'contactlessPayment',
    ],
  ),
  _IconGroup(
    id: 'travel',
    iconNames: <String>[
      'airplane',
      'airplaneInFlight',
      'suitcaseRolling',
      'tent',
      'mountains',
      'compassTool',
      'camera',
    ],
  ),
  _IconGroup(
    id: 'health',
    iconNames: <String>[
      'heartbeat',
      'stethoscope',
      'firstAid',
      'firstAidKit',
      'pill',
      'syringe',
      'tooth',
      'hospital',
    ],
  ),
  _IconGroup(
    id: 'security',
    iconNames: <String>[
      'shieldCheck',
      'shieldStar',
      'lock',
      'keyhole',
      'warningDiamond',
      'identificationBadge',
    ],
  ),
  _IconGroup(
    id: 'education',
    iconNames: <String>[
      'student',
      'exam',
      'bookOpen',
      'bookOpenText',
      'graduationCap',
    ],
  ),
  _IconGroup(
    id: 'family',
    iconNames: <String>['baby', 'personSimple', 'heart', 'handHeart', 'gift'],
  ),
  _IconGroup(id: 'pets', iconNames: <String>['cat', 'dog', 'bone', 'pawPrint']),
  _IconGroup(
    id: 'maintenance',
    iconNames: <String>[
      'hammer',
      'screwdriver',
      'toolbox',
      'paintRoller',
      'paintBucket',
      'ruler',
      'pipeWrench',
    ],
  ),
  _IconGroup(
    id: 'entertainment',
    iconNames: <String>[
      'filmSlate',
      'filmReel',
      'gameController',
      'musicNotes',
      'microphone',
      'microphoneStage',
      'ticket',
      'confetti',
    ],
  ),
  _IconGroup(
    id: 'sports',
    iconNames: <String>[
      'personSimpleRun',
      'barbell',
      'bicycle',
      'medal',
      'medalMilitary',
      'soccerBall',
      'basketball',
      'tennisBall',
      'volleyball',
    ],
  ),
  _IconGroup(
    id: 'finance',
    iconNames: <String>[
      'wallet',
      'coins',
      'piggyBank',
      'bank',
      'handCoins',
      'chartLineUp',
      'chartDonut',
      'vault',
      'scales',
      'briefcase',
      'currencyDollar',
      'currencyEur',
      'currencyRub',
    ],
  ),
  _IconGroup(
    id: 'loans',
    iconNames: <String>[
      'creditCard',
      'contactlessPayment',
      'handCoins',
      'calendarCheck',
      'calendarPlus',
      'warningDiamond',
    ],
  ),
  _IconGroup(
    id: 'documents',
    iconNames: <String>[
      'receipt',
      'receiptX',
      'invoice',
      'fileText',
      'files',
      'scan',
      'barcode',
      'qrCode',
      'scales',
    ],
  ),
  _IconGroup(
    id: 'settings',
    iconNames: <String>[
      'gear',
      'gearFine',
      'bell',
      'notification',
      'repeat',
      'arrowsClockwise',
      'cloud',
      'cloudWarning',
      'lock',
      'password',
    ],
  ),
  _IconGroup(
    id: 'transactionTypes',
    iconNames: <String>[
      'minusCircle',
      'arrowCircleDown',
      'trendDown',
      'shoppingCartSimple',
      'plusCircle',
      'arrowCircleUp',
      'trendUp',
      'handCoins',
      'coins',
      'arrowsLeftRight',
      'arrowRight',
      'arrowUUpRight',
      'swap',
      'arrowCounterClockwise',
      'receipt',
      'arrowsClockwise',
      'gift',
      'sparkle',
      'star',
      'percent',
      'warningCircle',
      'money',
      'fileText',
      'scales',
      'bank',
      'handHeart',
      'heart',
      'smiley',
      'creditCard',
      'calendarCheck',
      'userPlus',
      'wallet',
      'handshake',
      'arrowLeft',
      'user',
      'calendarPlus',
      'clock',
      'repeat',
      'pauseCircle',
      'hourglass',
      'checkCircle',
      'check',
      'sealCheck',
      'xCircle',
      'prohibit',
    ],
  ),
];

Future<PhosphorIconDescriptor?> showPhosphorIconPicker({
  required BuildContext context,
  required PhosphorIconPickerLabels labels,
  PhosphorIconDescriptor? initial,
  Set<PhosphorIconStyle>? allowedStyles,
}) {
  return showModalBottomSheet<PhosphorIconDescriptor?>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (BuildContext context) {
      return _PhosphorIconPickerSheet(
        labels: labels,
        initial: initial,
        allowedStyles: allowedStyles,
      );
    },
  );
}

class _PhosphorIconPickerSheet extends StatefulWidget {
  const _PhosphorIconPickerSheet({
    required this.labels,
    this.initial,
    this.allowedStyles,
  });

  final PhosphorIconPickerLabels labels;
  final PhosphorIconDescriptor? initial;
  final Set<PhosphorIconStyle>? allowedStyles;

  @override
  State<_PhosphorIconPickerSheet> createState() =>
      _PhosphorIconPickerSheetState();
}

class _PhosphorIconPickerSheetState extends State<_PhosphorIconPickerSheet>
    with SingleTickerProviderStateMixin {
  late final List<PhosphorIconStyle> _availableStyles;
  late PhosphorIconStyle _selectedStyle;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _availableStyles = _resolveAllowedStyles();
    _selectedStyle = _resolveInitialStyle();
    _tabController = TabController(
      length: _iconGroups.length,
      vsync: this,
      initialIndex: _findInitialGroupIndex(),
    );
    assert(
      _iconGroups.fold<int>(
            0,
            (int total, _IconGroup group) => total + group.iconNames.length,
          ) ==
          _kPhosphorIconPickerLimit,
      'Icon groups must contain exactly $_kPhosphorIconPickerLimit icons.',
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<PhosphorIconStyle> _resolveAllowedStyles() {
    final Set<PhosphorIconStyle> styles =
        widget.allowedStyles ??
        Set<PhosphorIconStyle>.from(PhosphorIconStyle.values);
    // Сохраняем порядок, совпадающий со стандартным перечислением.
    return PhosphorIconStyle.values
        .where(styles.contains)
        .toList(growable: false);
  }

  PhosphorIconStyle _resolveInitialStyle() {
    final PhosphorIconStyle initialStyle =
        widget.initial?.style ?? PhosphorIconStyle.regular;
    return _availableStyles.contains(initialStyle)
        ? initialStyle
        : _availableStyles.first;
  }

  int _findInitialGroupIndex() {
    final String? initialName = widget.initial?.name;
    if (initialName == null) {
      return 0;
    }
    final int index = _iconGroups.indexWhere(
      (_IconGroup group) => group.iconNames.contains(initialName),
    );
    return index >= 0 ? index : 0;
  }

  void _selectStyle(PhosphorIconStyle style) {
    if (style == _selectedStyle) {
      return;
    }
    setState(() {
      _selectedStyle = style;
    });
  }

  void _selectIcon(String name) {
    final PhosphorIconDescriptor descriptor = PhosphorIconDescriptor(
      name: name,
      style: _selectedStyle,
    );
    Navigator.of(context).pop(descriptor);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final EdgeInsets viewInsets = MediaQuery.of(context).viewInsets;
    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        widget.labels.title,
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_availableStyles.length > 1) ...<Widget>[
                  _StyleSelector(
                    selected: _selectedStyle,
                    labels: widget.labels.styleLabels,
                    onSelected: _selectStyle,
                    allowedStyles: _availableStyles,
                  ),
                  const SizedBox(height: 12),
                ],
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 12),
                  tabs: _iconGroups
                      .map(
                        (_IconGroup group) => Tab(
                          text: widget.labels.groupLabels[group.id] ?? group.id,
                        ),
                      )
                      .toList(growable: false),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: _iconGroups
                        .map(_buildGroupGrid)
                        .toList(growable: false),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupGrid(_IconGroup group) {
    final ThemeData theme = Theme.of(context);
    final List<String> icons = group.iconNames;
    if (icons.isEmpty) {
      return Center(
        child: Text(
          widget.labels.emptyStateLabel,
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      );
    }
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double maxWidth = constraints.maxWidth;
        final int crossAxisCount = maxWidth < 480
            ? 4
            : (maxWidth ~/ 72).clamp(4, 10);
        return GridView.builder(
          padding: const EdgeInsets.symmetric(vertical: 4),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: icons.length,
          itemBuilder: (BuildContext context, int index) {
            final String name = icons[index];
            final PhosphorIconDescriptor descriptor = PhosphorIconDescriptor(
              name: name,
              style: _selectedStyle,
            );
            final PhosphorIconData? iconData = resolvePhosphorIconData(
              descriptor,
            );
            final bool isCurrent =
                widget.initial != null &&
                widget.initial!.name == name &&
                widget.initial!.style == _selectedStyle;
            return _IconGridTile(
              iconData: iconData,
              name: name,
              isSelected: isCurrent,
              onTap: () => _selectIcon(name),
            );
          },
        );
      },
    );
  }
}

class _StyleSelector extends StatelessWidget {
  const _StyleSelector({
    required this.selected,
    required this.labels,
    required this.onSelected,
    required this.allowedStyles,
  });

  final PhosphorIconStyle selected;
  final Map<PhosphorIconStyle, String> labels;
  final ValueChanged<PhosphorIconStyle> onSelected;
  final List<PhosphorIconStyle> allowedStyles;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: allowedStyles
          .map((PhosphorIconStyle style) {
            final bool isSelected = style == selected;
            final String label = labels[style] ?? style.name;
            return ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (_) => onSelected(style),
              selectedColor: theme.colorScheme.primary.withValues(alpha: 0.12),
            );
          })
          .toList(growable: false),
    );
  }
}

class _IconGridTile extends StatelessWidget {
  const _IconGridTile({
    required this.iconData,
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  final PhosphorIconData? iconData;
  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color borderColor = isSelected
        ? theme.colorScheme.primary
        : theme.dividerColor.withValues(alpha: 0.2);
    final Color background = isSelected
        ? theme.colorScheme.primary.withValues(alpha: 0.08)
        : theme.colorScheme.surface;
    final String label = formatPhosphorIconName(name);
    return Tooltip(
      message: label,
      child: Semantics(
        button: true,
        label: label,
        selected: isSelected,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: iconData != null
                    ? Icon(iconData, size: 36)
                    : const Icon(Icons.category_outlined, size: 36),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
