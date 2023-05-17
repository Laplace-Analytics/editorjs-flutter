import 'dart:convert';

import 'package:editorjs_flutter/src/model/EditorJSBlock.dart';
import 'package:editorjs_flutter/src/model/EditorJSData.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;

typedef EditorJSComponentBuilder = Widget Function(
  BuildContext context,
  EditorJSBlock block,
);

class EditorJSView extends StatefulWidget {
  final String? editorJSData;
  final Map<String, Style>? styles;
  final Map<String?, EditorJSComponentBuilder> customComponentBuilders;
  final void Function(
      String? url,
      Map<String, String> attributes,
      dom.Element? element,
      )? onLinkTap;

  const EditorJSView({
    Key? key,
    this.editorJSData,
    this.styles,
    this.customComponentBuilders = const <String?, EditorJSComponentBuilder>{},
    this.onLinkTap,
  }) : super(key: key);

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
            switch (element.type) {
              case "header":
                items.add(Align(
                  alignment: Alignment.centerLeft,
                  child: Html(
                    data: "<h${element.data!.level!}>" + element.data!.text! + "</h${element.data!.level!}>",
                    style: widget.styles ?? {},
                    onLinkTap: widget.onLinkTap,
                  ),
                ));
                break;
              case "paragraph":
                final text = element.data!.text;
                items.add(
                  Html(
                    data: text != null ? "<p>" + text + "</p>" : null,
                    style: widget.styles ?? {},
                    onLinkTap: widget.onLinkTap,
                  ),
                );
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
                              onLinkTap: widget.onLinkTap,
                            ),
                          )
                        ]),
                      );
                      counter++;
                    } else {
                      items.add(
                        Row(
                          children: <Widget>[
                            Container(
                              child: Html(
                                data: bullet + element,
                                style: widget.styles ?? {},
                                onLinkTap: widget.onLinkTap,
                              ),
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
