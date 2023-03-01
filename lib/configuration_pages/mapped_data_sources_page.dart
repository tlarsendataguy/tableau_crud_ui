import 'package:flutter/material.dart';
import 'package:tableau_crud_ui/configuration_pages/item_selector.dart';
import 'package:tableau_crud_ui/io/io.dart';
import 'package:tableau_crud_ui/io/settings.dart';

class MappedDataSourcesPage extends StatefulWidget {
  MappedDataSourcesPage({required this.tableauIo, required this.settings});
  final TableauIo tableauIo;
  final Settings settings;

  createState() => _MappedDataSourcesPageState();
}

class _MappedDataSourcesPageState extends State<MappedDataSourcesPage> {

  Map<String, String> dataSources = {};
  late List<String> availableDataSources;
  bool loaded = false;

  initState(){
    super.initState();
    loadDataSources();
  }

  Future loadDataSources() async {
    dataSources = await widget.tableauIo.getAllDataSources();
    loadAvailableDataSources();
    setState(()=>loaded = true);
  }

  void addDataSource(String dataSourceId) {
    availableDataSources.remove(dataSourceId);
    widget.settings.mappedDataSources.add(dataSourceId);
    setState((){});
  }

  void removeDataSource(String dataSourceId) {
    widget.settings.mappedDataSources.remove(dataSourceId);
    loadAvailableDataSources();
    setState((){});
  }

  void loadAvailableDataSources() {
    availableDataSources = [];
    for (var dataSource in dataSources.keys) {
      if (widget.settings.mappedDataSources.contains(dataSource)) {
        continue;
      }
      availableDataSources.add(dataSource);
    }
  }

  Widget build(BuildContext context) {
    if (!loaded) {
      return Center(child: Text("Loading..."));
    }

    return ItemSelector(
      sourceList: availableDataSources,
      sourceItemBuilder: (context, dataSourceId){
        var dataSourceName = dataSources[dataSourceId];
        if (dataSourceName == null) dataSourceName = 'Invalid';
        return Row(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                if (dataSourceId != null) {
                  addDataSource(dataSourceId.toString());
                }
              },
            ),
            Expanded(child: Text("$dataSourceId: $dataSourceName")),
          ],
        );
      },
      selectorList: widget.settings.mappedDataSources,
      selectorItemBuilder:  (context, dataSourceId){
        var dataSourceName = dataSources[dataSourceId];
        if (dataSourceName == null) dataSourceName = 'Invalid';
        return Row(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: (){
                if (dataSourceId != null) {
                  removeDataSource(dataSourceId.toString());
                }
              },
            ),
            Expanded(child: Text("$dataSourceId: $dataSourceName")),
          ],
        );
      },
      leftLabel: 'Data sources available:',
      rightLabel: 'Mapped data sources:',
    );
  }
}