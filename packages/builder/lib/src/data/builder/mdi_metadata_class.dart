import 'package:builder/src/data/icon_metadata.dart';
import 'package:code_builder/code_builder.dart';

class MdiMetadataClass {
  final classDefinition = Class(
    (b) => b
      ..name = 'MdiMetadata'
      ..fields.addAll([
        Field(
          (b) => b
            ..name = 'name'
            ..type = refer('String')
            ..modifier = FieldModifier.final$,
        ),
        Field(
          (b) => b
            ..name = 'version'
            ..type = refer('String')
            ..modifier = FieldModifier.final$,
        ),
        Field(
          (b) => b
            ..name = 'author'
            ..type = refer('String')
            ..modifier = FieldModifier.final$,
        ),
        Field(
          (b) => b
            ..name = 'tags'
            ..type = refer('List<String>?')
            ..modifier = FieldModifier.final$,
        ),
        Field(
          (b) => b
            ..name = 'styles'
            ..type = refer('List<String>?')
            ..modifier = FieldModifier.final$,
        ),
      ])
      ..constructors.add(
        Constructor(
          (b) => b
            ..constant = true
            ..optionalParameters.addAll([
              Parameter(
                (b) => b
                  ..name = 'name'
                  ..named = true
                  ..required = true
                  ..toThis = true,
              ),
              Parameter(
                (b) => b
                  ..name = 'version'
                  ..named = true
                  ..required = true
                  ..toThis = true,
              ),
              Parameter(
                (b) => b
                  ..name = 'author'
                  ..named = true
                  ..required = true
                  ..toThis = true,
              ),
              Parameter(
                (b) => b
                  ..name = 'tags'
                  ..named = true
                  ..required = true
                  ..toThis = true,
              ),
              Parameter(
                (b) => b
                  ..name = 'styles'
                  ..named = true
                  ..required = true
                  ..toThis = true,
              ),
            ]),
        ),
      ),
  );

  Expression generateInstance(IconMetadata metadata) {
    return refer(classDefinition.name).newInstance(const Iterable.empty(), {
      'name': literalString(metadata.name),
      'version': literalString(metadata.version),
      'author': literalString(metadata.author),
      'tags':
          (metadata.tags.isNotEmpty) ? literalList(metadata.tags) : literalNull,
      'styles': (metadata.styles.isNotEmpty)
          ? literalList(metadata.styles)
          : literalNull,
    });
  }
}
