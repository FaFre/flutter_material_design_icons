import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:build/build.dart';
import 'package:builder/src/data/builder/mdi_icons_enum.dart';
import 'package:builder/src/data/builder/mdi_metadata_class.dart';
import 'package:builder/src/data/icon_metadata.dart';
import 'package:code_builder/code_builder.dart' show DartEmitter, Library;
import 'package:source_gen/source_gen.dart';

class IconDataGenerator extends Generator {
  final String metadataPath;

  const IconDataGenerator(this.metadataPath);

  @override
  FutureOr<String?> generate(LibraryReader library, BuildStep buildStep) async {
    final metadataFile = File(metadataPath);

    if (await metadataFile.exists()) {
      final metadataJson = await metadataFile
          .readAsString()
          .then((content) => jsonDecode(content) as List<dynamic>);

      final metadataList = metadataJson
          .map((e) => IconMetadata.fromJson(e as Map<String, dynamic>));

      final library = Library(
        (b) => b
          ..ignoreForFile.addAll(['require_trailing_commas'])
          ..body.addAll([
            MdiMetadataClass().classDefinition,
            const MdiIconsEnum().generateEnumDefinition(metadataList),
          ]),
      );

      final emitter =
          DartEmitter(orderDirectives: true, useNullSafetySyntax: true);

      return library.accept(emitter).toString();
    }

    return null;
  }
}

Builder iconEnumBuilder(BuilderOptions options) => PartBuilder(
      [IconDataGenerator(options.config['metadataPath'] as String)],
      '.enum.dart',
    );
