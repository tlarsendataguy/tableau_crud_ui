import 'package:flutter/material.dart';
import 'package:tableau_crud_ui/io/app_state.dart';
import 'package:tableau_crud_ui/io/bloc_provider.dart';
import 'package:tableau_crud_ui/io/configuration_state.dart' as state;
import 'package:tableau_crud_ui/configuration_pages/connection_page.dart';
import 'package:tableau_crud_ui/dialogs.dart';
import 'package:tableau_crud_ui/configuration_pages/filters_page.dart';
import 'package:tableau_crud_ui/configuration_pages/mapped_data_sources_page.dart';
import 'package:tableau_crud_ui/configuration_pages/order_by_fields_page.dart';
import 'package:tableau_crud_ui/configuration_pages/select_fields_page.dart';
import 'package:tableau_crud_ui/styling.dart';

class ConfigurationPage extends StatelessWidget{
  Widget build(BuildContext context) {
    var configState = BlocProvider.of<state.ConfigurationState>(context);

    return StreamBuilder(
      stream: configState.page,
      builder: (context, AsyncSnapshot<state.Page> snapshot){
        if (!snapshot.hasData){
          return Center(child: Text('Loading...'));
        }

        Widget content;
        var page = snapshot.data;

        switch (page){
          case state.Page.connection:
            content = ConnectionPage(configState: configState);
            break;
          case state.Page.selectFields:
            content = SelectFieldsPage();
            break;
          case state.Page.orderByFields:
            content = OrderByFieldsPage();
            break;
          case state.Page.filters:
            content = FiltersPage();
            break;
          case state.Page.mappedDataSources:
            content = MappedDataSourcesPage();
            break;
          default:
            content = Center(child: Text("Invalid page"));
        }
        return Container(
          color: backgroundColor,
          child: Row(
            children: [
              Container(
                width: 60,
                child: Card(
                  child: ConfigurationPageButtons(page: page),
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

class ConfigurationPageButtons extends StatelessWidget {
  ConfigurationPageButtons({this.page});
  final state.Page page;

  Widget build(BuildContext context) {
    var configState = BlocProvider.of<state.ConfigurationState>(context);
    var appState = BlocProvider.of<AppState>(context);
    return ListView(
      children: [
        Tooltip(
          message: 'Save settings and go back',
          child: IconButton(
            focusNode: FocusNode(skipTraversal: true),
            icon: Icon(Icons.save),
            onPressed: () async {
              var settings = configState.generateSettings();
              var error = settings.validate();
              if (error != ''){
                await showDialog(
                  context: context,
                  builder: (context) => OkDialog(
                    child: Text("WARNING! Settings not saved because of the following error: $error"),
                    msgType: MsgType.Error,
                  ),
                );
                return;
              }
              await configState.tIo.saveSettings(settings.toJson());
              appState.updateSettings(settings);
              Navigator.of(context).pop();
            },
          ),
        ),
        Tooltip(
          message: 'Go back without saving',
          child: IconButton(
            focusNode: FocusNode(skipTraversal: true),
            icon: Icon(Icons.cancel),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        Container(height: 40),
        PageButton(goToPage: state.Page.connection, currentPage: page),
        PageButton(goToPage: state.Page.selectFields, currentPage: page),
        PageButton(goToPage: state.Page.orderByFields, currentPage: page),
        PageButton(goToPage: state.Page.filters, currentPage: page),
        PageButton(goToPage: state.Page.mappedDataSources, currentPage: page),
      ],
    );
  }
}

class PageButton extends StatelessWidget{
  PageButton({this.goToPage, this.currentPage});
  final state.Page goToPage;
  final state.Page currentPage;

  Widget build(BuildContext context) {
    var configState = BlocProvider.of<state.ConfigurationState>(context);
    String message;
    IconData icon;
    Color color;

    switch (goToPage){
      case state.Page.connection:
        message = "Connection info";
        icon = Icons.format_list_bulleted;
        break;
      case state.Page.selectFields:
        message = "Select fields";
        icon = Icons.table_chart;
        break;
      case state.Page.orderByFields:
        message = "Order by";
        icon = Icons.sort;
        break;
      case state.Page.filters:
        message = "Map filters";
        icon = Icons.filter_list;
        break;
      case state.Page.mappedDataSources:
        message = "Map data sources";
        icon = Icons.file_download;
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
          focusNode: FocusNode(skipTraversal: true),
          color: color,
          icon: Icon(icon),
          onPressed: goToPage == currentPage ? null :
            () async => await configState.goToPage(goToPage),
        ),
      ),
    );
  }
}

