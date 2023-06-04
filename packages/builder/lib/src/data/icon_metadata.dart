import 'package:json_annotation/json_annotation.dart';

part 'icon_metadata.g.dart';

@JsonSerializable()
class IconMetadata {
  final String id;
  final String baseIconId;
  final String name;
  final String codepoint;
  final List<String> aliases;
  final List<String> styles;
  final String version;
  final bool deprecated;
  final List<String> tags;
  final String author;

  IconMetadata({
    required this.id,
    required this.baseIconId,
    required this.name,
    required this.codepoint,
    required this.aliases,
    required this.styles,
    required this.version,
    required this.deprecated,
    required this.tags,
    required this.author,
  });

  factory IconMetadata.fromJson(Map<String, dynamic> json) =>
      _$IconMetadataFromJson(json);
  Map<String, dynamic> toJson() => _$IconMetadataToJson(this);
}
