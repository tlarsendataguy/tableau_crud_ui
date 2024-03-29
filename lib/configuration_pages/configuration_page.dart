import 'package:flutter/material.dart';
import 'package:tableau_crud_ui/configuration_pages/general_settings_page.dart';
import 'package:tableau_crud_ui/configuration_pages/import_export_page.dart';
import 'package:tableau_crud_ui/dialogs.dart';
import 'package:tableau_crud_ui/configuration_pages/filters_page.dart';
import 'package:tableau_crud_ui/configuration_pages/mapped_data_sources_page.dart';
import 'package:tableau_crud_ui/configuration_pages/order_by_fields_page.dart';
import 'package:tableau_crud_ui/configuration_pages/select_fields_page.dart';
import 'package:tableau_crud_ui/io/io.dart';
import 'package:tableau_crud_ui/io/settings.dart';
import 'package:tableau_crud_ui/styling.dart';

enum Page {
  selectFields,
  orderByFields,
  filters,
  mappedDataSources,
  general,
  importExport,
}
class ConfigurationPage extends StatefulWidget{
  ConfigurationPage(this.io);
  final IoManager io;

  createState()=>_ConfigurationPageState();
}

class _ConfigurationPageState extends State<ConfigurationPage> {

  Page currentPage = Page.general;
  late Settings settings;
  bool isLoading = true;

  initState(){
    super.initState();
    loadSettings();
  }

  Future loadSettings() async {
    settings = await widget.io.tableau.getSettings();
    setState(()=>isLoading = false);
  }

  void onPageChanged(Page newPage) {
    setState(()=>currentPage=newPage);
  }

  Widget build(BuildContext context) {
    Widget content;

    if (isLoading) {
      return Center(child: Text("Loading..."));
    }

    switch (currentPage){
      case Page.selectFields:
        content = SelectFieldsPage(settings: settings);
        break;
      case Page.orderByFields:
        content = OrderByFieldsPage(settings: settings);
        break;
      case Page.filters:
        content = FiltersPage(tableauIo: widget.io.tableau, settings: settings);
        break;
      case Page.mappedDataSources:
        content = MappedDataSourcesPage(tableauIo: widget.io.tableau, settings: settings);
        break;
      case Page.general:
        content = GeneralSettingsPage(settings: settings, io: widget.io);
        break;
      case Page.importExport:
        content = ImportExportPage(settings: settings);
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
              child: ConfigurationPageButtons(page: currentPage, onPageChanged: onPageChanged, io: widget.io, settings: settings),
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
  }
}

class ConfigurationPageButtons extends StatelessWidget {
  ConfigurationPageButtons({required this.page, required this.onPageChanged, required this.io, required this.settings});
  final Page page;
  final Function(Page newPage) onPageChanged;
  final IoManager io;
  final Settings settings;
  final listScroll = ScrollController();

  Widget build(BuildContext context) {
    return ListView(
      controller: listScroll,
      children: [
        Tooltip(
          message: 'Save settings and go back',
          child: IconButton(
            focusNode: FocusNode(skipTraversal: true),
            icon: Icon(Icons.save),
            onPressed: () async {
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
              await io.tableau.saveSettings(settings.toJson());
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
        PageButton(goToPage: Page.general, currentPage: page, onClick: onPageChanged),
        PageButton(goToPage: Page.selectFields, currentPage: page, onClick: onPageChanged),
        PageButton(goToPage: Page.orderByFields, currentPage: page, onClick: onPageChanged),
        PageButton(goToPage: Page.filters, currentPage: page, onClick: onPageChanged),
        PageButton(goToPage: Page.mappedDataSources, currentPage: page, onClick: onPageChanged),
        Container(height: 40),
        PageButton(goToPage: Page.importExport, currentPage: page, onClick: onPageChanged),
      ],
    );
  }
}

class PageButton extends StatelessWidget{
  PageButton({required this.goToPage, required this.currentPage, required this.onClick});
  final Page goToPage;
  final Page currentPage;
  final Function(Page newPage) onClick;

  Widget build(BuildContext context) {
    String message;
    IconData icon;
    Color? color;

    switch (goToPage){
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
      case Page.mappedDataSources:
        message = "Map data sources";
        icon = Icons.file_download;
        break;
      case Page.general:
        message = "General settings";
        icon = Icons.settings;
        break;
      case Page.importExport:
        message = "Import/export settings";
        icon = Icons.import_export;
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
            () => onClick(goToPage),
        ),
      ),
    );
  }
}

