import 'package:builder/src/data/builder/mdi_metadata_class.dart';
import 'package:builder/src/data/icon_metadata.dart';
import 'package:code_builder/code_builder.dart';

class MdiIconsEnum {
  const MdiIconsEnum();

  static const _reservedIdentifiers = {
    'assert',
    'break',
    'case',
    'catch',
    'class',
    'const',
    'continue',
    'default',
    'do',
    'else',
    'enum',
    'extends',
    'false',
    'final',
    'finally',
    'in',
    'is',
    'new',
    'null',
    'rethrow',
    'return',
    'super',
    'switch',
    'this',
    'throw',
    'true',
    'try',
    'var',
    'void',
    'when',
    'while',
    'with'
  };

  static String _kebabToLowerCamel(String input) {
    final camelCase = input.replaceAllMapped(
      RegExp('-(.)'),
      (match) => match.group(1)!.toUpperCase(),
    );

    if (!RegExp(r'^[a-zA-Z_$][a-zA-Z0-9_$]*$').hasMatch(camelCase)) {
      throw const FormatException('The conversion to lower camel case failed. '
          'The result is not a valid dart variable name');
    }

    return camelCase;
  }

  static String _escapeKeyword(String input) {
    if (_reservedIdentifiers.contains(input)) {
      return '$input\$';
    }

    return input;
  }

  static String _emitExpression(Expression expression) => expression
      .accept(
        DartEmitter(useNullSafetySyntax: true),
      )
      .toString();

  Class generateClassDefinition(Iterable<IconMetadata> metadataList) {
    final mdiMetadataClass = MdiMetadataClass();

    final iconFields = metadataList.map(
      (metadata) {
        final name = _escapeKeyword(_kebabToLowerCamel(metadata.name));
        return Field(
          (b) => b
            ..name = name
            ..static = true
            ..modifier = FieldModifier.constant
            ..type = refer('IconData', 'package:flutter/widgets.dart')
            ..assignment = refer(
              'IconData',
              'package:flutter/widgets.dart',
            ).newInstance([
              literalNum(int.parse('0x${metadata.codepoint}')),
            ], {
              'fontFamily': literalString('Material Design Icons'),
              'fontPackage': literalString('flutter_material_design_icons'),
            }).code
            ..docs.addAll([
              '/// **${metadata.name}**',
              '///',
              '/// ![Icon preview](https://fafre.github.io/flutter_material_design_icons/icons/${metadata.name}/${metadata.version}/64.png "${metadata.name}")',
              '///',
              '///',
              '/// *Author: ${metadata.author}*',
              '///',
              '/// *Version: ${metadata.version}*',
              '///',
              if (metadata.tags.isNotEmpty) ...[
                '/// *Tags: ${metadata.tags.join(', ')}*',
                '///',
              ],
              if (metadata.styles.isNotEmpty) ...[
                '/// *Styles: ${metadata.styles.join(', ')}*',
                '///',
              ],
            ])
            ..annotations.addAll([
              if (metadata.deprecated)
                refer('Deprecated').call([
                  literalString(
                    'This icon has been marked as deprecated by the Material Design Icons project',
                  )
                ])
            ]),
        );
      },
    ).toList();

    final valuesField = Field(
      (b) => b
        ..name = 'values'
        ..static = true
        ..modifier = FieldModifier.constant
        ..type = refer('List<IconData>')
        ..assignment = literalList(
          iconFields.map((f) => refer(f.name)).toList(),
        ).code,
    );

    final maybeMetadataOfMethod = Method(
      (b) => b
        ..name = 'maybeMetadataOf'
        ..static = true
        ..returns = refer('MdiMetadata?')
        ..requiredParameters.add(
          Parameter(
            (b) => b
              ..name = 'icon'
              ..type = refer('IconData', 'package:flutter/widgets.dart'),
          ),
        )
        ..body = Code('''
if (icon.fontFamily != 'Material Design Icons' ||
    icon.fontPackage != 'flutter_material_design_icons') {
  return null;
}

switch (icon.codePoint) {
${metadataList.map((metadata) {
          final emitted = _emitExpression(
            mdiMetadataClass.generateInstance(metadata),
          );
          return "  case ${int.parse('0x${metadata.codepoint}')}: return $emitted;";
        }).join('\n')}
}

return null;
'''),
    );

    return Class(
      (b) => b
        ..name = 'MdiIcons'
        ..abstract = true
        ..fields.addAll([
          ...iconFields,
          valuesField,
        ])
        ..methods.add(maybeMetadataOfMethod),
    );
  }

  Extension generateExtensionDefinition() {
    return Extension(
      (b) => b
        ..name = 'MdiIconsExtension'
        ..on = refer('IconData', 'package:flutter/widgets.dart')
        ..methods.addAll([
          Method(
            (b) => b
              ..name = 'mdiMetadata'
              ..type = MethodType.getter
              ..returns = refer('MdiMetadata?')
              ..lambda = true
              ..body = refer('MdiIcons').property('maybeMetadataOf').call([
                refer('this'),
              ]).code,
          ),
          Method(
            (b) => b
              ..name = 'metadata'
              ..type = MethodType.getter
              ..returns = refer('MdiMetadata')
              ..body = const Code('''
final metadata = mdiMetadata;
if (metadata != null) {
  return metadata;
}

throw StateError('IconData is not part of MdiIcons');
'''),
          ),
        ]),
    );
  }
}
