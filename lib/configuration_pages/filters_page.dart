import 'package:flutter/material.dart';
import 'package:tableau_crud_ui/state_and_model/bloc_provider.dart';
import 'package:tableau_crud_ui/configuration_pages/choose_column_dialog.dart';
import 'package:tableau_crud_ui/state_and_model/configuration_state.dart';
import 'package:tableau_crud_ui/state_and_model/io.dart';
import 'package:tableau_crud_ui/state_and_model/settings.dart';

class FiltersPage extends StatefulWidget {
  createState()=>_FiltersPageState();
}

class _FiltersPageState extends State<FiltersPage> {

  String selectedWorksheet = '';
  List<TableauFilter> worksheetFilters = [];

  Widget build(BuildContext context) {
    var state = BlocProvider.of<ConfigurationState>(context);

    return Row(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Column(
            children: <Widget>[
              Center(child: Text("Worksheets:")),
              Expanded(
                child: ListView(
                  children: state.worksheets.map((e) =>
                      Card(
                        color: e == selectedWorksheet ? Colors.lightBlueAccent : null,
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(e),
                              ),
                              IconButton(
                                icon: Icon(Icons.arrow_forward),
                                onPressed: () async {
                                  worksheetFilters = await state.getFilters(e);
                                  setState(() {
                                    selectedWorksheet = e;
                                  });
                                },
                              )
                            ],
                          ),
                        ),
                      ),
                  ).toList(),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Column(
            children: <Widget>[
              Center(child: Text("Worksheet filters:")),
              Expanded(
                child: ListView(
                  children: worksheetFilters.map((e) =>
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(e.fieldName),
                              ),
                              IconButton(
                                icon: Icon(Icons.arrow_forward),
                                onPressed: () async {
                                  var mapsTo = await showDialog(context: context, child: ChooseColumnDialog("Filter on [${e.fieldName}] from worksheet [$selectedWorksheet] maps to:"));
                                  if (mapsTo == '' || mapsTo == null) return;
                                  state.addFilter(
                                    worksheet: selectedWorksheet,
                                    fieldName: e.fieldName,
                                    mapsTo: mapsTo,
                                  );
                                },
                              )
                            ],
                          ),
                        ),
                      ),
                  ).toList(),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Column(
            children: <Widget>[
              Center(child: Text("Mapped filters:")),
              Expanded(
                child: StreamBuilder(
                  stream: state.filters,
                  builder: (context, AsyncSnapshot<List<Filter>> snapshot){
                    if (!snapshot.hasData){
                      return Container();
                    }
                    var filters = snapshot.data;
                    return ListView(
                      children: filters.map((e) =>
                          Card(
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: Row(
                                children: <Widget>[
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: (){
                                      state.removeFilter(
                                        worksheet: e.worksheet,
                                        fieldName: e.fieldName,
                                        mapsTo: e.mapsTo,
                                      );
                                    },
                                  ),
                                  Expanded(
                                    child: Text("Filter on [${e.fieldName}] from worksheet [${e.worksheet}] maps to [${e.mapsTo}]"),
                                  ),
                                ],
                              ),
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
      ],
    );
  }
}
