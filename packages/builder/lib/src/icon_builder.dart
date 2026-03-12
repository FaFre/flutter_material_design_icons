import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:build/build.dart';
import 'package:builder/src/data/builder/mdi_icons_enum.dart';
import 'package:builder/src/data/builder/mdi_metadata_class.dart';
import 'package:builder/src/data/icon_metadata.dart';
import 'package:code_builder/code_builder.dart' show DartEmitter, Library;
import 'package:package_config/package_config.dart';
import 'package:source_gen/source_gen.dart';

class IconDataGenerator extends Generator {
  final String metadataPath;

  const IconDataGenerator(this.metadataPath);

  Future<File> _resolveMetadataFile(BuildStep buildStep) async {
    final packageConfig = await findPackageConfig(Directory.current);

    if (packageConfig == null) {
      throw StateError('Could not resolve package_config.json');
    }

    Package? package;

    for (final candidate in packageConfig.packages) {
      if (candidate.name == buildStep.inputId.package) {
        package = candidate;
        break;
      }
    }

    if (package == null) {
      throw StateError(
        'Could not resolve package root for ${buildStep.inputId.package}',
      );
    }

    return File.fromUri(package.root.resolve(metadataPath));
  }

  @override
  FutureOr<String?> generate(LibraryReader library, BuildStep buildStep) async {
    final metadataFile = await _resolveMetadataFile(buildStep);

    if (await metadataFile.exists()) {
      final metadataJson = await metadataFile
          .readAsString()
          .then((content) => jsonDecode(content) as List<dynamic>);

      final metadataList = metadataJson
          .map((e) => IconMetadata.fromJson(e as Map<String, dynamic>));

      final library = Library(
        (b) => b
          ..ignoreForFile.addAll([
            'require_trailing_commas',
            'avoid_escaping_inner_quotes',
            'unused_element',
            'use_super_parameters',
            'avoid_classes_with_only_static_members',
            'prefer_const_constructors',
          ])
          ..body.addAll([
            MdiMetadataClass().classDefinition,
            const MdiIconsEnum().generateClassDefinition(metadataList),
            const MdiIconsEnum().generateExtensionDefinition(),
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
