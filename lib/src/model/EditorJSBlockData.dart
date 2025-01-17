import 'package:editorjs_flutter/src/model/EditorJSBlockFile.dart';

class EditorJSBlockData {
  final String? text;
  final int? level;
  final String? style;
  final List<String>? items;
  final EditorJSBlockFile? file;
  final String? caption;
  final bool? withBorder;
  final bool? stretched;
  final bool? withBackground;
  final Map<String, dynamic> allFields;

  EditorJSBlockData({
    this.text,
    this.level,
    this.style,
    this.items,
    this.file,
    this.caption,
    this.withBorder,
    this.stretched,
    this.withBackground,
    this.allFields = const <String, dynamic>{},
  });

  factory EditorJSBlockData.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['items'] as List?;
    final List<String> itemsList = <String>[];

    if (list != null) {
      list.forEach((element) {
        itemsList.add(element);
      });
    }

    return EditorJSBlockData(
      text: parsedJson['text'],
      level: parsedJson['level'],
      style: parsedJson['style'],
      items: itemsList,
      file: (parsedJson['file'] != null) ? EditorJSBlockFile.fromJson(parsedJson['file']) : null,
      caption: parsedJson['caption'],
      withBorder: parsedJson['withBorder'],
      withBackground: parsedJson['withBackground'],
      allFields: parsedJson,
    );
  }
}
