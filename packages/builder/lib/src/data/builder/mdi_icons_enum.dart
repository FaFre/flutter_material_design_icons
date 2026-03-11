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

  Class generateIconDataClassDefinition() {
    return Class(
      (b) => b
        ..name = 'MdiIconData'
        ..extend = refer('IconData', 'package:flutter/widgets.dart')
        ..fields.add(
          Field(
            (b) => b
              ..name = 'metadata'
              ..type = refer('MdiMetadata')
              ..modifier = FieldModifier.final$,
          ),
        )
        ..constructors.add(
          Constructor(
            (b) => b
              ..constant = true
              ..requiredParameters.add(
                Parameter(
                  (b) => b
                    ..name = 'codePoint'
                    ..type = refer('int'),
                ),
              )
              ..optionalParameters.addAll([
                Parameter(
                  (b) => b
                    ..name = 'metadata'
                    ..named = true
                    ..required = true
                    ..toThis = true,
                ),
              ])
              ..initializers.addAll([
                refer('super').call([
                  refer('codePoint')
                ], {
                  'fontFamily': literalString('Material Design Icons'),
                  'fontPackage': literalString('flutter_material_design_icons'),
                }).code,
              ]),
          ),
        )
        ..methods.add(
          Method(
            (b) => b
              ..name = 'toString'
              ..returns = refer('String')
              ..annotations.add(refer('override'))
              ..lambda = true
              ..body = const Code(
                r"'MdiIconData(U+${codePoint.toRadixString(16).toUpperCase().padLeft(5, '0')})'",
              ),
          ),
        ),
    );
  }

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
            ..type = refer('MdiIconData')
            ..assignment = refer('MdiIconData').newInstance([
              literalNum(int.parse('0x${metadata.codepoint}')),
            ], {
              'metadata': mdiMetadataClass.generateInstance(metadata)
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
        ..type = refer('List<MdiIconData>')
        ..assignment = literalList(
          iconFields.map((f) => refer(f.name)).toList(),
        ).code,
    );

    return Class(
      (b) => b
        ..name = 'MdiIcons'
        ..abstract = true
        ..fields.addAll([
          ...iconFields,
          valuesField,
        ]),
    );
  }
}
