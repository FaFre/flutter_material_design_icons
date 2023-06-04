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

  Enum generateEnumDefinition(Iterable<IconMetadata> metadataList) {
    final mdiMetadataClass = MdiMetadataClass();

    return Enum(
      (b) => b
        ..name = 'MdiIcons'
        ..implements.add(refer('IconData', 'package:flutter/widgets.dart'))
        ..fields.addAll([
          Field(
            (b) => b
              ..name = 'codePoint'
              ..type = refer('int')
              ..modifier = FieldModifier.final$
              ..annotations.add(refer('override'))
              ..docs.addAll([
                '/// The Unicode code point at which this icon is stored in the icon font.'
              ]),
          ),
          Field(
            (b) => b
              ..name = 'matchTextDirection'
              ..type = refer('bool')
              ..modifier = FieldModifier.final$
              ..annotations.add(refer('override'))
              ..docs.addAll([
                '/// Whether this icon should be automatically mirrored in right-to-left',
                '/// environments.',
                '///',
                '/// The [Icon] widget respects this value by mirroring the icon when the',
                '/// [Directionality] is [TextDirection.rtl].',
              ]),
          ),
          Field(
            (b) => b
              ..name = 'metadata'
              ..type = refer(mdiMetadataClass.classDefinition.name)
              ..modifier = FieldModifier.final$,
          ),
        ])
        ..methods.addAll([
          Method(
            (b) => b
              ..name = 'fontFamily'
              ..returns = refer('String')
              ..type = MethodType.getter
              ..annotations.add(refer('override'))
              ..docs.addAll([
                '/// The font family from which the glyph for the [codePoint] will be selected.'
              ])
              ..body = literalString('Material Design Icons').code,
          ),
          Method(
            (b) => b
              ..name = 'fontPackage'
              ..returns = refer('String')
              ..type = MethodType.getter
              ..annotations.add(refer('override'))
              ..docs.addAll([
                '/// The name of the package from which the font family is included.',
                '///',
                '/// The name is used by the [Icon] widget when configuring the [TextStyle] so',
                '/// that the given [fontFamily] is obtained from the appropriate asset.',
                '///',
                '/// See also:',
                '///',
                '///  * [TextStyle], which describes how to use fonts from other packages.',
              ])
              ..body = literalString('flutter_material_design_icons').code,
          ),
          Method(
            (b) => b
              ..name = 'toString'
              ..returns = refer('String')
              ..lambda = true
              ..annotations.add(refer('override'))
              ..body = const Code(
                r"'MdiIconData(U+${codePoint.toRadixString(16).toUpperCase().padLeft(5, '0')})'",
              ),
          )
        ])
        ..constructors.add(
          Constructor(
            (b) => b
              ..constant = true
              ..optionalParameters.addAll([
                Parameter(
                  (b) => b
                    ..name = 'codePoint'
                    ..named = true
                    ..required = true
                    ..toThis = true,
                ),
                Parameter(
                  (b) => b
                    ..name = 'metadata'
                    ..named = true
                    ..required = true
                    ..toThis = true,
                ),
                Parameter(
                  (b) => b
                    ..name = 'matchTextDirection'
                    ..named = true
                    ..defaultTo = const Code('false')
                    ..toThis = true,
                )
              ]),
          ),
        )
        ..values.addAll(
          metadataList.map(
            (metadata) => EnumValue(
              (b) => b
                ..name = _escapeKeyword(_kebabToLowerCamel(metadata.name))
                ..namedArguments.addAll({
                  'codePoint': literalNum(int.parse('0x${metadata.codepoint}')),
                  'metadata': mdiMetadataClass.generateInstance(metadata)
                })
                ..annotations.addAll([
                  if (metadata.deprecated)
                    refer('Deprecated').call([
                      literalString(
                        'This icon has been marked as deprecated by the Material Design Icons project',
                      )
                    ])
                ]),
            ),
          ),
        ),
    );
  }
}
