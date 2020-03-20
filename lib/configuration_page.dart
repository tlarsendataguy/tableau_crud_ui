
import 'package:flutter/material.dart';
import 'package:tableau_crud_ui/app_state.dart';
import 'package:tableau_crud_ui/bloc_provider.dart';
import 'package:tableau_crud_ui/configuration_state.dart';

class ConfigurationPage extends StatelessWidget{
  Widget build(BuildContext context) {
    var configState = BlocProvider.of<ConfigurationState>(context);
    var appState = BlocProvider.of<AppState>(context);

    return StreamBuilder(
      stream: configState.page,
      builder: (context, AsyncSnapshot<Page> snapshot){
        if (!snapshot.hasData){
          return Center(child: Text('Loading...'));
        }

        Widget content;
        var page = snapshot.data;

        switch (page){
          case Page.connection:
            content = ConnectionPage();
            break;
          case Page.selectFields:
            content = SelectFieldsPage();
            break;
          case Page.orderByFields:
            content = OrderByFieldsPage();
            break;
          case Page.filters:
            content = FiltersPage();
            break;
          default:
            content = Center(child: Text("Invalid page"));
        }
        return Container(
          color: Color.fromARGB(255, 220, 220, 220),
          child: Row(
            children: [
              Container(
                width: 60,
                child: Card(
                  child: ListView(
                    children: [
                      Tooltip(
                        message: 'Save settings and go back',
                        child: IconButton(
                          icon: Icon(Icons.save),
                          onPressed: () async {
                            var settings = configState.generateSettings();
                            await configState.tIo.saveSettings(settings.toJson());
                            appState.updateSettings(settings);
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      Tooltip(
                        message: 'Go back without saving',
                        child: IconButton(
                          icon: Icon(Icons.cancel),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      Container(height: 40),
                      PageButton(goToPage: Page.connection, currentPage: page),
                      PageButton(goToPage: Page.selectFields, currentPage: page),
                      PageButton(goToPage: Page.orderByFields, currentPage: page),
                      PageButton(goToPage: Page.filters, currentPage: page),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(4.0),
                    child: content,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class FiltersPage extends StatelessWidget {
  Widget build(BuildContext context) {
    var state = BlocProvider.of<ConfigurationState>(context);
    return Center(child: Text("Filters"));
  }
}

class OrderByFieldsPage extends StatelessWidget {
  Widget build(BuildContext context) {
    var state = BlocProvider.of<ConfigurationState>(context);
    return Center(child: Text("Order by"));
  }
}

class SelectFieldsPage extends StatelessWidget {
  Widget build(BuildContext context) {
    var state = BlocProvider.of<ConfigurationState>(context);
    return Center(child: Text("Select fields"));
  }
}

class ConnectionPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ConnectionPageState();
}

class _ConnectionPageState extends State<ConnectionPage> {

  Widget build(BuildContext context) {
    var state = BlocProvider.of<ConfigurationState>(context);
    return Center(child: Text("Connection info"));
  }
}

class PageButton extends StatelessWidget{
  PageButton({this.goToPage, this.currentPage});
  final Page goToPage;
  final Page currentPage;

  @override
  Widget build(BuildContext context) {
    var configState = BlocProvider.of<ConfigurationState>(context);
    String message;
    IconData icon;
    Color color;

    switch (goToPage){
      case Page.connection:
        message = "Connection info";
        icon = Icons.format_list_bulleted;
        break;
      case Page.selectFields:
        message = "Select fields";
        icon = Icons.table_chart;
        break;
      case Page.orderByFields:
        message = "Order by";
        icon = Icons.sort;
        break;
      case Page.filters:
        message = "Map filters";
        icon = Icons.filter_list;
        break;
    }

    return Tooltip(
      message: message,
      child: Container(
        width: 48,
        height: 48,
        child: goToPage == currentPage ?
        Icon(icon, color: Colors.blue) :
        IconButton(
          color: color,
          icon: Icon(icon),
          onPressed: goToPage == currentPage ? null :
            ()=>configState.goToPage(goToPage),
        ),
      ),
    );
  }
}