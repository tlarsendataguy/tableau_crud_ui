import 'package:flutter/material.dart';
import 'package:tableau_crud_ui/state_and_model/bloc_provider.dart';
import 'package:tableau_crud_ui/state_and_model/configuration_state.dart';
import 'package:tableau_crud_ui/configuration_pages/item_selector.dart';

class OrderByFieldsPage extends StatelessWidget {
  Widget build(BuildContext context) {
    var state = BlocProvider.of<ConfigurationState>(context);
    return ItemSelector<String>(
      leftLabel: "Available fields:",
      sourceStream: state.columnNames,
      sourceItemBuilder: (context, sourceField){
        return Row(
          children: <Widget>[
            Expanded(
              child: Text(sourceField),
            ),
            IconButton(
              icon: Icon(Icons.arrow_forward),
              onPressed: ()=>state.addOrderByField(sourceField),
            ),
          ],
        );
      },
      rightLabel: "Order by:",
      selectorStream: state.orderByFields,
      selectorItemBuilder: (context, orderByField){
        return Row(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: ()=>state.removeOrderByField(orderByField),
            ),
            Expanded(child: Text(orderByField)),
            IconButton(
              icon: Icon(Icons.arrow_upward),
              onPressed: ()=>state.moveOrderByFieldUp(orderByField),
            ),
            IconButton(
              icon: Icon(Icons.arrow_downward),
              onPressed: ()=>state.moveOrderByFieldDown(orderByField),
            ),
          ],
        );
      },
    );
  }
}
