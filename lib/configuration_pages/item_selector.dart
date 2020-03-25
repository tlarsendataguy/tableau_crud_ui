import 'package:flutter/material.dart';

typedef Widget ItemSelectorBuilder<T>(BuildContext context, T item);

class ItemSelector<T> extends StatelessWidget {
  ItemSelector({this.sourceStream, this.sourceItemBuilder, this.selectorStream, this.selectorItemBuilder,this.leftLabel,this.rightLabel, this.leftFlex=1, this.rightFlex=1});
  final Stream<List<T>> sourceStream;
  final Stream<List<T>> selectorStream;
  final ItemSelectorBuilder<T> sourceItemBuilder;
  final ItemSelectorBuilder<T> selectorItemBuilder;
  final String leftLabel;
  final String rightLabel;
  final int leftFlex;
  final int rightFlex;

  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: selectorStream,
      builder: (context, AsyncSnapshot<List<T>> selectSnapshot){
        if (!selectSnapshot.hasData) {
          return Center(child: Text("No data"));
        }
        var selected = selectSnapshot.data;
        return Row(
          children: [
            Expanded(
              flex: leftFlex,
              child: Column(
                children: [
                  Center(child: Text(leftLabel)),
                  Expanded(child:
                  StreamBuilder(
                    stream: sourceStream,
                    builder: (context, AsyncSnapshot<List<T>> sourceSnapshot){
                      if (!sourceSnapshot.hasData) {
                        return Center(child: Text("No data"));
                      }
                      var source = List<T>.from(sourceSnapshot.data);
                      for (var selectedItem in selected){
                        source.remove(selectedItem);
                      }
                      return ListView(
                        children: source.map((sourceItem)=>
                            Card(
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: sourceItemBuilder(context, sourceItem),
                              ),
                            ),
                        ).toList(),
                      );
                    },
                  ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: rightFlex,
              child: Column(
                children: [
                  Center(child: Text(rightLabel)),
                  Expanded(
                    child: ListView(
                      children: selected.map((sourceItem)=>
                          Card(
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: selectorItemBuilder(context, sourceItem),
                            ),
                          ),
                      ).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
