import 'package:flutter/material.dart';
import 'package:tableau_crud_ui/io/response_objects.dart';
import 'package:tableau_crud_ui/io/settings.dart';
import 'package:tableau_crud_ui/styling.dart';

class DataViewer extends StatelessWidget {
  DataViewer({this.data, this.selectedRow, this.settings, this.onSelectRow});
  final QueryResults data;
  final int selectedRow;
  final Settings settings;
  final Function(int selectedRow) onSelectRow;

  final ScrollController horizontalScroller = ScrollController();
  final ScrollController verticalScroller = ScrollController();

  Widget build(BuildContext context) {
    var headerHeight = 20.0;
    var dataHeight = 30.0;
    var maxColWidth = 200.0;
    var paddingWidth = 8.0;

    var columns = <Widget>[];
    var index = 0;
    for (var column in data.data){
      var headerText = data.columnNames[index];
      var editModeRaw = settings.selectFields[headerText];
      var editMode = getEditMode(editModeRaw ?? editNone);
      var valueToString = (value) => value.toString();
      if (editMode == editDate){
        valueToString = (value) {
          if (value == null || value.toString() == "") return 'null';
          return value.toString().substring(0,10);
        };
      }

      columns.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            Container(
              height: headerHeight,
              constraints: BoxConstraints(maxWidth: maxColWidth),
              padding: EdgeInsets.fromLTRB(paddingWidth, 0, paddingWidth, 0),
              child: Text(
                headerText,
              ),
            ),
            ...column.map((e) =>Container(
              height: dataHeight,
              constraints: BoxConstraints(maxWidth: maxColWidth),
              padding: EdgeInsets.fromLTRB(paddingWidth, 0, paddingWidth, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    valueToString(e),
                    overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            )
            ).toList(),
          ],
        ),
      );
      index++;
    }

    var selectionRows = <Widget>[
      Container(
        height: headerHeight,
        color: tableHeaderBackgroundColor,
      ),
    ];
    for (var index = 0; index < data.rowCount(); index++){
      selectionRows.add(
        Container(
          height: dataHeight,
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey)),
            color: index == selectedRow ? Color.fromARGB(30, 0, 0, 255) : null,
          ),
          child: InkWell(
            onTap: (){
              var selection = index;
              if (selection == selectedRow) selection = -1;
              onSelectRow(selection);
            },
          ),
        ),
      );
    }

    return Scrollbar(
      thickness: 10,
      isAlwaysShown: true,
      controller: verticalScroller,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        controller: verticalScroller,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 12, 0),
          child: Stack(
            children: <Widget>[
              Scrollbar(
                thickness: 10,
                isAlwaysShown: true,
                controller: horizontalScroller,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: horizontalScroller,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
                    child: Row(
                      children: columns,
                    ),
                  ),
                ),
              ),
              Column(
                children: selectionRows,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
