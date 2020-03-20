import 'package:flutter/material.dart';
import 'package:tableau_crud_ui/app_state.dart';
import 'package:tableau_crud_ui/bloc_provider.dart';
import 'package:tableau_crud_ui/response_objects.dart';

class DataViewer extends StatelessWidget {
  final ScrollController _horizontalScroller = ScrollController();

  Widget build(BuildContext context) {
    var state = BlocProvider.of<AppState>(context);
    return StreamBuilder(
      stream: state.readLoaders,
      builder: (context, AsyncSnapshot<int> snapshot){
        if (!snapshot.hasData || snapshot.data > 0){
          return Center(child: Text("Loading data..."));
        }

        return StreamBuilder(
          stream: state.data,
          builder: (context, AsyncSnapshot<QueryResults> snapshot) {
            if (!snapshot.hasData) {
              return Center(child: Text("No data"));
            }
            var data = snapshot.data;
            var headerHeight = 20.0;
            var dataHeight = 30.0;
            var maxColWidth = 200.0;
            var paddingWidth = 8.0;

            var columns = List<Widget>();
            var index = 0;
            for (var column in data.data){
              var headerText = data.columnNames[index];
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
                            e.toString(),
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
              Container(height: headerHeight),
            ];
            for (var index = 0; index < data.rowCount(); index++){
              selectionRows.add(
                Container(
                  height: dataHeight,
                  decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: Colors.grey))
                  ),
                  child: InkWell(
                    onTap: ()async{
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
                                    child: Text("Row $index"),
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
                    },
                  ),
                ),
              );
            }

            return Scrollbar(
              controller: _horizontalScroller,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Stack(
                  children: <Widget>[
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      controller: _horizontalScroller,
                      child: Row(
                        children: columns,
                      ),
                    ),
                    Column(
                      children: selectionRows,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
