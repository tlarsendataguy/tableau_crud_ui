import 'package:flutter/material.dart';
import 'package:tableau_crud_ui/configuration_pages/item_selector.dart';
import 'package:tableau_crud_ui/io/settings.dart';

class OrderByFieldsPage extends StatefulWidget {
  OrderByFieldsPage({this.settings});
  final Settings settings;

  createState() => _OrderByFieldsPageState();
}

class _OrderByFieldsPageState extends State<OrderByFieldsPage> {
  List<String> availableFields;

  initState(){
    super.initState();
    loadAvailableFields();
  }

  void loadAvailableFields() {
    availableFields = [];
    for (var field in widget.settings.tableColumns) {
      if (widget.settings.orderByFields.contains(field)) {
        continue;
      }
      availableFields.add(field);
    }
  }

  void addField(String name) {
    widget.settings.orderByFields.add(name);
    availableFields.remove(name);
  }

  void removeField(String name) {
    widget.settings.orderByFields.remove(name);
    availableFields.clear();
    loadAvailableFields();
  }

  void moveUp(String name) {
    var index = widget.settings.orderByFields.indexOf(name);
    if (index == 0) return;
    widget.settings.orderByFields.remove(name);
    widget.settings.orderByFields.insert(index-1, name);
  }

  void moveDown(String name) {
    var index = widget.settings.orderByFields.indexOf(name);
    if (index + 1 >= widget.settings.orderByFields.length) return;
    widget.settings.orderByFields.remove(name);
    widget.settings.orderByFields.insert(index+1, name);
  }

  Widget build(BuildContext context) {
    return ItemSelector<String>(
      leftLabel: "Available fields:",
      sourceList: availableFields,
      sourceItemBuilder: (context, sourceField){
        return Row(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.add),
              onPressed: ()=>setState(()=>addField(sourceField)),
            ),
            Expanded(
              child: Text(sourceField),
            ),
          ],
        );
      },
      rightLabel: "Order by:",
      selectorList: widget.settings.orderByFields,
      selectorItemBuilder: (context, orderByField){
        return Row(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: ()=>setState(()=>removeField(orderByField)),
            ),
            Expanded(child: Text(orderByField)),
            IconButton(
              icon: Icon(Icons.arrow_upward),
              onPressed: ()=>setState(()=>moveUp(orderByField)),
            ),
            IconButton(
              icon: Icon(Icons.arrow_downward),
              onPressed: ()=>setState(()=>moveDown(orderByField)),
            ),
          ],
        );
      },
    );
  }
}
