import 'package:flutter/material.dart';
import 'package:tableau_crud_ui/io/bloc_provider.dart';
import 'package:tableau_crud_ui/io/configuration_state.dart';

class ChooseColumnDialog extends StatefulWidget{
  ChooseColumnDialog(this.header);
  final String header;
  State<StatefulWidget> createState() => _ChooseColumnDialogState();
}

class _ChooseColumnDialogState extends State<ChooseColumnDialog>{
  var selectedColumn = '';

  Widget build(BuildContext context) {
    var state = BlocProvider.of<ConfigurationState>(context);
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
                      child: StreamBuilder(
                        stream: state.columnNames,
                        builder: (context, AsyncSnapshot<List<String>> snapshot){
                          if (!snapshot.hasData) {
                            return Container();
                          }
                          return ListView(
                            children: snapshot.data.map((e) =>
                                FlatButton(
                                  color: e == selectedColumn ? Colors.lightBlueAccent : null,
                                  child: Text(e),
                                  onPressed: ()=>setState(()=>selectedColumn=e),
                                )).toList(),
                          );
                        },
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
                FlatButton(
                  child: Text("Cancel"),
                  onPressed: ()=>Navigator.of(context).pop(""),
                ),
                RaisedButton(
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