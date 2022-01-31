import 'package:flutter/material.dart';
import 'package:tableau_crud_ui/io/settings.dart';

class ChooseColumnDialog extends StatefulWidget{
  ChooseColumnDialog(this.header, this.settings);
  final String header;
  final Settings settings;
  State<StatefulWidget> createState() => _ChooseColumnDialogState();
}

class _ChooseColumnDialogState extends State<ChooseColumnDialog>{
  var selectedColumn = '';

  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        children: <Widget>[
          Expanded(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  children: [
                    Text(widget.header),
                    Expanded(
                      child: ListView(
                        children: widget.settings.tableColumns.map((e) =>
                          TextButton(
                            style: TextButton.styleFrom(backgroundColor: e == selectedColumn ? Colors.lightBlueAccent : null),
                            child: Text(e),
                            onPressed: ()=>setState(()=>selectedColumn=e),
                          ),
                        ).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(
                  child: Text("Cancel"),
                  onPressed: ()=>Navigator.of(context).pop(""),
                ),
                ElevatedButton(
                  child: Text("Select"),
                  onPressed: selectedColumn == "" ?
                  null :
                      ()=>Navigator.of(context).pop(selectedColumn),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}