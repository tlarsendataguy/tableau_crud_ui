import 'package:flutter/material.dart';
import 'package:tableau_crud_ui/app_state.dart';
import 'package:tableau_crud_ui/bloc_provider.dart';
import 'package:tableau_crud_ui/data_viewer.dart';

class Home extends StatelessWidget {
  Widget build(BuildContext context) {
    var state = BlocProvider.of<AppState>(context);

    Widget configureButton = null;
    if (state.tableauContext == 'desktop'){
      configureButton = Tooltip(
        message: "Configure extension",
        child: IconButton(
          icon: Icon(Icons.settings),
          onPressed: ()=>Navigator.of(context).pushNamed("/configure"),
        ),
      );
    }

    var buttonBar = Row(
      children: [
        Tooltip(
          message: "Add record",
          child: IconButton(
            icon: Icon(Icons.add),
            onPressed: null,
          ),
        ),
        Tooltip(
          message: "Edit record",
          child: IconButton(
            icon: Icon(Icons.edit),
            onPressed: null,
          ),
        ),
        Tooltip(
          message: "Delete record",
          child: IconButton(
            icon: Icon(Icons.delete),
            onPressed: null,
          ),
        ),
        Tooltip(
          message: "Refresh table",
          child: IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () async {
              var error = await state.readTable();
              if (error != ""){
                await showDialog(
                  context: context,
                  child: Dialog(
                    child: Container(
                      width: 300,
                      child: Column(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: Text(error, softWrap: true),
                            ),
                          ),
                          RaisedButton(
                            child: Text("ok"),
                            onPressed: ()=>Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
            },
          ),
        ),
        Expanded(
          child: Container(),
        ),
        configureButton,
      ],
    );

    return Material(
      color: Color.fromARGB(255, 220, 220, 220),
      child: Column(
        children: <Widget>[
          Card(child: buttonBar),
          Expanded(child: Card(child: Padding(padding: EdgeInsets.all(4.0),child: DataViewer()))),
        ],
      ),
    );
  }
}
