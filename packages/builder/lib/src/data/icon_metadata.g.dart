// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'icon_metadata.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IconMetadata _$IconMetadataFromJson(Map<String, dynamic> json) => IconMetadata(
      id: json['id'] as String,
      baseIconId: json['baseIconId'] as String,
      name: json['name'] as String,
      codepoint: json['codepoint'] as String,
      aliases:
          (json['aliases'] as List<dynamic>).map((e) => e as String).toList(),
      styles:
          (json['styles'] as List<dynamic>).map((e) => e as String).toList(),
      version: json['version'] as String,
      deprecated: json['deprecated'] as bool,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      author: json['author'] as String,
    );

Map<String, dynamic> _$IconMetadataToJson(IconMetadata instance) =>
    <String, dynamic>{
      'id': instance.id,
      'baseIconId': instance.baseIconId,
      'name': instance.name,
      'codepoint': instance.codepoint,
      'aliases': instance.aliases,
      'styles': instance.styles,
      'version': instance.version,
      'deprecated': instance.deprecated,
      'tags': instance.tags,
      'author': instance.author,
    };
