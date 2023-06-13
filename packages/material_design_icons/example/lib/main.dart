import 'dart:async';

import 'package:collection/collection.dart';
import 'package:example/providers.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MainApp()));
}

class FilterBar extends HookConsumerWidget {
  final String title;

  final NotifierProvider<StringFilterNotifier, Set<String>> provider;

  const FilterBar(this.title, this.provider, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(provider);
    final filterNotifier = ref.watch(provider.notifier);

    final chips = useMemoized(
      () => filterNotifier.values
          .sorted(
            (a, b) {
              final aSelected = filters.contains(a);
              final bSelected = filters.contains(b);

              if (aSelected == bSelected) {
                return a.compareTo(b);
              } else {
                return (aSelected ? -1 : 1);
              }
            },
          )
          .map(
            (filter) => FilterChip(
              label: Text(filter),
              onSelected: (_) {
                filterNotifier.toggle(filter);
              },
              selected: filters.contains(filter),
              showCheckmark: true,
            ),
          )
          .toList(),
      [filters],
    );

    final chipsExpanded = useState(false);

    return Row(
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(
                height: 16,
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 350),
                      child: SizedBox(
                        width:
                            (chipsExpanded.value) ? constraints.maxWidth : null,
                        child: Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: chips,
                        ),
                      ),
                    ),
                  );
                },
              )
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            chipsExpanded.value = !chipsExpanded.value;
          },
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: (chipsExpanded.value)
                ? const Icon(Icons.expand_less)
                : const Icon(Icons.expand_more),
          ),
        )
      ],
    );
  }
}

class MouseDragScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods like buildOverscrollIndicator and buildScrollbar
  @override
  Set<PointerDeviceKind> get dragDevices => {
        ...super.dragDevices,
        PointerDeviceKind.mouse,
      };
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  Widget _buildIconInfo(BuildContext context, MdiIcons icon) {
    return Tooltip(
      message: [
        'Author: ${icon.metadata.author}',
        'Version: ${icon.metadata.version}',
        if (icon.metadata.tags != null)
          'Tags: ${icon.metadata.tags!.join(', ')}',
        if (icon.metadata.styles != null)
          'Styles: ${icon.metadata.styles!.join(', ')}',
      ].join('\n'),
      verticalOffset: 48,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 36,
          ),
          Text(
            icon.metadata.name,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: MouseDragScrollBehavior(),
      home: Scaffold(
        body: NestedScrollView(
          floatHeaderSlivers: true,
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: HookConsumer(
                      builder: (context, ref, child) {
                        final textSearchNotifier =
                            ref.watch(textSearchProvider.notifier);

                        final controller = useTextEditingController();

                        final textIsEmpty = useListenableSelector(
                          controller,
                          () => controller.text.isEmpty,
                        );

                        return SearchBar(
                          controller: controller,
                          leading: const Icon(Icons.search),
                          trailing: (!textIsEmpty)
                              ? [
                                  IconButton(
                                    onPressed: () {
                                      controller.clear();
                                      textSearchNotifier.clear();
                                    },
                                    icon: const Icon(Icons.clear),
                                  )
                                ]
                              : null,
                          onChanged: (value) {
                            textSearchNotifier.tokenize(value);
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: FilterBar('TAGS', tagFilterProvider),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: FilterBar('STYLES', styleFilterProvider),
                  ),
                  const Divider(),
                ],
              ),
            )
          ],
          body: HookConsumer(
            builder: (context, ref, child) {
              final filteredIcons = ref.watch(filteredIconsProvider);

              final icons = useMemoized(
                () => filteredIcons
                    .map(
                      (icon) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          children: [_buildIconInfo(context, icon)],
                        ),
                      ),
                    )
                    .toList(growable: false),
                [filteredIcons],
              );

              final gridScrollController = useScrollController();
              final absorbPointer = useState(false);

              useEffect(() {
                Timer? resetTimer;

                void onScroll() {
                  absorbPointer.value = true;

                  resetTimer?.cancel();
                  resetTimer = Timer(const Duration(milliseconds: 500), () {
                    absorbPointer.value = false;
                  });
                }

                gridScrollController.addListener(onScroll);

                return () {
                  resetTimer?.cancel();
                  gridScrollController.removeListener(onScroll);
                };
              });

              return GridView.builder(
                itemCount: icons.length,
                controller: gridScrollController,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  mainAxisSpacing: 24,
                  maxCrossAxisExtent: 136,
                ),
                itemBuilder: (context, index) => AbsorbPointer(
                  absorbing: absorbPointer.value,
                  child: icons[index],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
