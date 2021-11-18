import 'package:flutter/material.dart';
import 'package:tableau_crud_ui/io/bloc_provider.dart';
import 'package:tableau_crud_ui/io/configuration_state.dart';
import 'package:tableau_crud_ui/configuration_pages/item_selector.dart';

class MappedDataSourcesPage extends StatelessWidget {
  Widget build(BuildContext context) {
    var state = BlocProvider.of<ConfigurationState>(context);
    var dataSources = state.getDataSources;
    return ItemSelector(
      sourceStream: state.allDataSources.map((e)=>e.keys.toList()),
      sourceItemBuilder: (context, dataSourceId){
        var dataSourceName = dataSources[dataSourceId];
        if (dataSourceName == null) dataSourceName = 'Invalid';
        return Row(
          children: <Widget>[
            Expanded(child: Text("$dataSourceId: $dataSourceName")),
            IconButton(
              icon: Icon(Icons.arrow_forward),
              onPressed: ()=>state.addMappedDataSource(dataSourceId),
            ),
          ],
        );
      },
      selectorStream: state.mappedDataSources,
      selectorItemBuilder:  (context, dataSourceId){
        var dataSourceName = dataSources[dataSourceId];
        if (dataSourceName == null) dataSourceName = 'Invalid';
        return Row(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: ()=>state.removeMappedDataSource(dataSourceId),
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
