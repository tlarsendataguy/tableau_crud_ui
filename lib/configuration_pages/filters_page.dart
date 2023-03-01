import 'package:flutter/material.dart';
import 'package:tableau_crud_ui/configuration_pages/choose_column_dialog.dart';
import 'package:tableau_crud_ui/io/io.dart';
import 'package:tableau_crud_ui/io/settings.dart';

class FiltersPage extends StatefulWidget {
  FiltersPage({required this.tableauIo, required this.settings});
  final Settings settings;
  final TableauIo tableauIo;

  createState()=>_FiltersPageState();
}

class _FiltersPageState extends State<FiltersPage> {

  String selectedWorksheet = '';
  List<TableauFilter> worksheetFilters = [];
  List<String> parameters = [];
  late List<String> worksheets;
  bool loaded = false;
  ScrollController worksheetsScroll = ScrollController();
  ScrollController parametersScroll = ScrollController();
  ScrollController worksheetFiltersScroll = ScrollController();
  ScrollController mappedScroll = ScrollController();

  initState(){
    super.initState();
    loadWorksheets();
  }

  Future loadWorksheets() async {
    worksheets = await widget.tableauIo.getWorksheets();
    parameters = await widget.tableauIo.getParameters();
    setState(()=>loaded = true);
  }

  void addFilter({required String worksheet, fieldName, parameter, mapsTo}) {
    for (var filter in widget.settings.filters) {
      if (filter.worksheet == worksheet && filter.parameterName == parameter && filter.fieldName == fieldName && filter.mapsTo == mapsTo) {
        return;
      }
    }

    widget.settings.filters.add(Filter(
      worksheet: worksheet,
      fieldName: fieldName,
      parameterName: parameter,
      mapsTo: mapsTo,
    ));
    setState((){});
  }

  void removeFilter({required String worksheet, fieldName, parameter, mapsTo}) {
    for (var i = widget.settings.filters.length-1; i >= 0; i--) {
      var filter = widget.settings.filters[i];
      if (filter.worksheet == worksheet && filter.fieldName == fieldName && filter.parameterName == parameter && filter.mapsTo == mapsTo) {
        widget.settings.filters.removeAt(i);
      }
    }
    setState((){});
  }

  Widget build(BuildContext context) {
    if (!loaded) {
      return Center(child: Text("Loading..."));
    }

    return Column(
      children: [
        Expanded(
          flex: 1,
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Column(
                  children: <Widget>[
                    Center(child: Text("Worksheets:")),
                    Expanded(
                      child: ListView(
                        controller: worksheetsScroll,
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
                        controller: parametersScroll,
                        children: parameters.map((e) =>
                          Card(
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: Row(
                                children: <Widget>[
                                  IconButton(
                                    icon: Icon(Icons.add),
                                    onPressed: () async {
                                      var mapsTo = await showDialog(context: context, builder: (context) => ChooseColumnDialog("Parameter [$e] maps to:", widget.settings));
                                      if (mapsTo == '' || mapsTo == null) return;
                                      addFilter(
                                        worksheet: '',
                                        fieldName: '',
                                        parameter: e,
                                        mapsTo: mapsTo,
                                      );
                                    },
                                  ),
                                  Expanded(
                                    child: Text(e),
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
              Expanded(
                flex: 1,
                child: Column(
                  children: <Widget>[
                    Center(child: Text("Worksheet filters:")),
                    Expanded(
                      child: ListView(
                        controller: worksheetFiltersScroll,
                        children: worksheetFilters.map((e) =>
                            Card(
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: Row(
                                  children: <Widget>[
                                    IconButton(
                                      icon: Icon(Icons.add),
                                      onPressed: () async {
                                        var mapsTo = await showDialog(context: context, builder: (context) => ChooseColumnDialog("Filter on [${e.fieldName}] from worksheet [$selectedWorksheet] maps to:", widget.settings));
                                        if (mapsTo == '' || mapsTo == null) return;
                                        addFilter(
                                          worksheet: selectedWorksheet,
                                          fieldName: e.fieldName,
                                          parameter: '',
                                          mapsTo: mapsTo,
                                        );
                                      },
                                    ),
                                    Expanded(
                                      child: Text(e.fieldName),
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
          ),
        ),
        Expanded(
          flex: 1,
          child: Column(
            children: <Widget>[
              Center(child: Text("Mapped filters:")),
              Expanded(
                child: ListView(
                  controller: mappedScroll,
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
                                    parameter: e.parameterName,
                                    mapsTo: e.mapsTo,
                                  );
                                },
                              ),
                              Expanded(
                                child: e.parameterName != ''
                                    ? Text("Parameter [${e.parameterName}] maps to [${e.mapsTo}]")
                                    : Text("Filter on [${e.fieldName}] from worksheet [${e.worksheet}] maps to [${e.mapsTo}]"),
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
