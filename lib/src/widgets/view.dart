import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:editorjs_flutter/src/model/EditorJSBlock.dart';
import 'package:editorjs_flutter/src/model/EditorJSData.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';

typedef EditorJSComponentBuilder = Widget Function(
  BuildContext context,
  EditorJSBlock block,
);

class EditorJSView extends StatefulWidget {
  final String? editorJSData;
  final Map<String, Style>? styles;
  final Map<String?, EditorJSComponentBuilder> customComponentBuilders;

  const EditorJSView({Key? key, this.editorJSData, this.styles, this.customComponentBuilders = const <String?, EditorJSComponentBuilder>{}})
      : super(key: key);

  @override
  EditorJSViewState createState() => EditorJSViewState();
}

class EditorJSViewState extends State<EditorJSView> {
  String? data;
  late EditorJSData dataObject;
  final List<Widget> items = <Widget>[];

  @override
  void initState() {
    super.initState();

    setState(
      () {
        dataObject = EditorJSData.fromJson(jsonDecode(widget.editorJSData!));

        dataObject.blocks!.forEach(
          (element) {
            double levelFontSize = 16;
            double levelFontHeight = 1.5;

            switch (element.data!.level) {
              case 1:
                levelFontSize = 32;
                levelFontHeight = 2.0;
                break;
              case 2:
                levelFontSize = 24;
                levelFontHeight = 1.8;
                break;
              case 3:
                levelFontSize = 22;
                levelFontHeight = 1.8;
                break;
              case 4:
                levelFontSize = 20;
                levelFontHeight = 1.5;
                break;
              case 5:
                levelFontSize = 18;
                levelFontHeight = 1.5;
                break;
              case 6:
                levelFontSize = 16;
                levelFontHeight = 1.5;
                break;
            }

            switch (element.type) {
              case "header":
                items.add(Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    element.data!.text!,
                    style: TextStyle(fontSize: levelFontSize, fontWeight: FontWeight.bold, height: levelFontHeight),
                  ),
                ));
                break;
              case "paragraph":
                final text = element.data!.text;
                items.add(Html(
                  data: text != null ? "<p>" + text + "</p>" : null,
                  style: widget.styles ?? {},
                ));
                break;
              case "list":
                String bullet = "\u2022 ";
                String? style = element.data!.style;
                int counter = 1;

                element.data!.items!.forEach(
                  (element) {
                    if (style == 'ordered') {
                      bullet = counter.toString();
                      items.add(
                        Row(children: [
                          Container(
                              child: Html(
                            data: bullet + element,
                            style: widget.styles ?? {},
                          ))
                        ]),
                      );
                      counter++;
                    } else {
                      items.add(
                        Row(
                          children: <Widget>[
                            Container(
                              child: Html(data: bullet + element, style: widget.styles ?? {}),
                            )
                          ],
                        ),
                      );
                    }
                  },
                );
                break;
              case "delimiter":
                items.add(Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                  // Text('***', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center,)
                  Expanded(child: Divider(color: Colors.grey))
                ]));
                break;
              case "image":
                items.add(CachedNetworkImage(
                  imageUrl: element.data?.file?.url ?? "",
                  errorWidget: (context, _, __) => Icon(Icons.image, size: 50),
                ));
                break;
              default:
                final EditorJSComponentBuilder? builder = widget.customComponentBuilders[element.type];
                if (builder != null) {
                  items.add(builder(
                    context,
                    element,
                  ));
                  break;
                }
            }
            items.add(const SizedBox(height: 10));
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: items);
  }
}
