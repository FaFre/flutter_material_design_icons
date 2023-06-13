import 'package:flutter_material_design_icons/icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TokenFilterNotifier extends Notifier<List<String>> {
  void tokenize(String input) {
    state = input.split(' ');
  }

  void clear() {
    state = [];
  }

  @override
  List<String> build() {
    return [];
  }
}

class StringFilterNotifier extends Notifier<Set<String>> {
  final Provider<Set<String>> _valuesProvider;
  late Set<String> values;

  StringFilterNotifier(this._valuesProvider);

  @override
  Set<String> build() {
    values = ref.watch(_valuesProvider);
    return {};
  }

  void add(String filter) {
    state = {...state, filter};
  }

  void remove(String filter) {
    state = Set.of(state)..remove(filter);
  }

  void toggle(String filter) {
    if (state.contains(filter)) {
      remove(filter);
    } else {
      add(filter);
    }
  }
}

final mdiStylesProvider = Provider(
  (ref) => MdiIcons.values
      .expand<String>((element) => element.metadata.styles ?? [])
      .toSet(),
);

final mdiTagsProvider = Provider(
  (ref) => MdiIcons.values
      .expand<String>((element) => element.metadata.tags ?? [])
      .toSet(),
);

final styleFilterProvider = NotifierProvider<StringFilterNotifier, Set<String>>(
  () => StringFilterNotifier(mdiStylesProvider),
);

final tagFilterProvider = NotifierProvider<StringFilterNotifier, Set<String>>(
  () => StringFilterNotifier(mdiTagsProvider),
);

final textSearchProvider = NotifierProvider<TokenFilterNotifier, List<String>>(
  () => TokenFilterNotifier(),
);

final filteredIconsProvider = Provider((ref) {
  final tokenFilters = ref.watch(textSearchProvider);
  final styleFilters = ref.watch(styleFilterProvider);
  final tagFilters = ref.watch(tagFilterProvider);

  return MdiIcons.values
      .where(
        (icon) =>
            (tokenFilters.isEmpty ||
                tokenFilters.every(icon.metadata.name.contains)) &&
            (tagFilters.isEmpty ||
                (icon.metadata.tags?.any(tagFilters.contains) ?? false)) &&
            (styleFilters.isEmpty ||
                (icon.metadata.styles?.any(styleFilters.contains) ?? false)),
      )
      .toList(growable: false);
});
