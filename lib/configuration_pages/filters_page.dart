import 'package:flutter/material.dart';
import 'package:tableau_crud_ui/configuration_pages/choose_column_dialog.dart';
import 'package:tableau_crud_ui/io/io.dart';
import 'package:tableau_crud_ui/io/settings.dart';

class FiltersPage extends StatefulWidget {
  FiltersPage({this.tableauIo, this.settings});
  final Settings settings;
  final TableauIo tableauIo;

  createState()=>_FiltersPageState();
}

class _FiltersPageState extends State<FiltersPage> {

  String selectedWorksheet = '';
  List<TableauFilter> worksheetFilters = [];
  List<Parameter> parameters = [];
  List<String> worksheets;
  bool loaded = false;

  initState(){
    super.initState();
    loadWorksheets();
  }

  Future loadWorksheets() async {
    worksheets = await widget.tableauIo.getWorksheets();
    setState(()=>loaded = true);
  }

  void addFilter({String worksheet, String fieldName, String mapsTo}) {
    for (var filter in widget.settings.filters) {
      if (filter.worksheet == worksheet && filter.fieldName == fieldName && filter.mapsTo == mapsTo) {
        return;
      }
    }

    widget.settings.filters.add(Filter(
      worksheet: worksheet,
      fieldName: fieldName,
      mapsTo: mapsTo,
    ));
    setState((){});
  }

  void removeFilter({String worksheet, String fieldName, String mapsTo}) {
    for (var i = widget.settings.filters.length-1; i > 0; i++) {
      var filter = widget.settings.filters[i];
      if (filter.worksheet == worksheet && filter.fieldName == fieldName && filter.mapsTo == mapsTo) {
        widget.settings.filters.removeAt(i);
      }
    }
    setState((){});
  }

  Widget build(BuildContext context) {
    if (!loaded) {
      return Center(child: Text("Loading..."));
    }

    return Row(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Column(
            children: <Widget>[
              Center(child: Text("Worksheets:")),
              Expanded(
                child: ListView(
                  children: worksheets.map((e) =>
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
                                  worksheetFilters = await widget.tableauIo.getFilters(e);
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
              SizedBox(height: 8),
              Center(child: Text('Parameters:')),
              Expanded(
                child: ListView(
                  children: [],
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
                                  var mapsTo = await showDialog(context: context, builder: (context) => ChooseColumnDialog("Filter on [${e.fieldName}] from worksheet [$selectedWorksheet] maps to:", widget.settings));
                                  if (mapsTo == '' || mapsTo == null) return;
                                  addFilter(
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
                child: ListView(
                  children: widget.settings.filters.map((e) =>
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Row(
                            children: <Widget>[
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: (){
                                  removeFilter(
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
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
