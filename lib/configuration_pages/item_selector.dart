import 'package:flutter/material.dart';

typedef Widget ItemSelectorBuilder<T>(BuildContext context, T item);

class ItemSelector<T> extends StatelessWidget {
  ItemSelector({required this.sourceList, required this.sourceItemBuilder, required this.selectorList, required this.selectorItemBuilder, required this.leftLabel, required this.rightLabel, this.leftFlex=1, this.rightFlex=1});
  final List<T> sourceList;
  final List<T> selectorList;
  final ItemSelectorBuilder<T> sourceItemBuilder;
  final ItemSelectorBuilder<T> selectorItemBuilder;
  final String leftLabel;
  final String rightLabel;
  final int leftFlex;
  final int rightFlex;
  final ScrollController leftController = ScrollController();
  final ScrollController rightController = ScrollController();

  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: leftFlex,
          child: Column(
            children: [
              Center(child: Text(leftLabel)),
              Expanded(
                child: ListView(
                  controller: leftController,
                  children: sourceList.map((sourceItem) =>
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: sourceItemBuilder(context, sourceItem),
                        ),
                      ),
                  ).toList(),
                ),
              ),
              Expanded(
                flex: rightFlex,
                child: Column(
                  children: [
                    Center(child: Text(rightLabel)),
                    Expanded(
                      child: ListView(
                        controller: rightController,
                        children: selectorList.map((sourceItem) =>
                            Card(
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: selectorItemBuilder(
                                    context, sourceItem),
                              ),
                            ),
                        ).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
