import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tableau_crud_ui/app_state.dart';
import 'package:tableau_crud_ui/bloc_provider.dart';
import 'package:tableau_crud_ui/data_viewer.dart';
import 'package:tableau_crud_ui/dialogs.dart';
import 'package:tableau_crud_ui/response_objects.dart';
import 'package:tableau_crud_ui/settings.dart';
import 'package:tableau_crud_ui/try_cast.dart';

class Home extends StatelessWidget {
  Widget build(BuildContext context) {
    var state = BlocProvider.of<AppState>(context);

    Widget configureButton = null;
    if (state.tableauContext == 'desktop'){
      configureButton = Tooltip(
        message: "Configure extension",
        child: IconButton(
          icon: Icon(Icons.settings),
          onPressed: ()=>Navigator.of(context).pushNamed("/configure"),
        ),
      );
    }

    var buttonBar = Row(
      children: [
        Tooltip(
          message: "Add record",
          child: IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              var editModes = state.settings.selectFields;
              var initialValues = editModes.keys.map((e)=>null).toList();
              await showDialog(
                  context: context,
                  child: DataEntryDialog(
                  editModes: editModes,
                  initialValues: initialValues,
                  onSubmit: state.insert,
                ),
              );
            },
          ),
        ),
        StreamBuilder(
          stream: state.selectedRow,
          builder: (context, AsyncSnapshot<int> snapshot){
            var onPressed = () async {
              var editModes = state.settings.selectFields;
              var initialValues = state.getSelectedRowValues();
              await showDialog(
                context: context,
                child: DataEntryDialog(
                  editModes: editModes,
                  initialValues: initialValues,
                  onSubmit: state.update,
                ),
              );
            };
            if (!snapshot.hasData || snapshot.data == -1) onPressed = null;
            return Tooltip(
              message: "Edit record",
              child: IconButton(
                icon: Icon(Icons.edit),
                onPressed: onPressed,
              ),
            );
          },
        ),
        StreamBuilder(
          stream: state.selectedRow,
          builder: (context, AsyncSnapshot<int> snapshot){
            var onPressed = ()async{
              var result = await showDialog(
                context: context,
                child: YesNoDialog(
                  child: Text("Are you sure you want to delete this record?"),
                ),
              );
              if (result != 'Yes'){
                return;
              }
              showDialog(
                context: context,
                barrierDismissible: false,
                child: LoadingDialog(message: "Deleting..."),
              );
              var err = await state.delete();
              Navigator.of(context).pop();
              if (err != ''){
                await showDialog(
                  context: null,
                  child: OkDialog(
                    msgType: MsgType.Error,
                    child: Text("Error: $err"),
                  ),
                );
              }
            };
            if (!snapshot.hasData || snapshot.data == -1) onPressed = null;
            return Tooltip(
              message: "Delete record",
              child: IconButton(
                icon: Icon(Icons.delete),
                onPressed: onPressed,
              ),
            );
          },
        ),
        Tooltip(
          message: "Refresh table",
          child: IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () async {
              var error = await state.readTable();
              if (error != ""){
                await showDialog(
                  context: context,
                  child: OkDialog(
                    child: Text(error, softWrap: true),
                    msgType: MsgType.Error),
                );
              }
            },
          ),
        ),
        Expanded(
          child: Container(),
        ),
        PageSelector(),
        configureButton,
      ],
    );

    return Material(
      color: Color.fromARGB(255, 220, 220, 220),
      child: Column(
        children: <Widget>[
          Card(child: buttonBar),
          Expanded(child: Card(child: Padding(padding: EdgeInsets.all(4.0),child: DataViewer()))),
        ],
      ),
    );
  }
}

class PageSelector extends StatelessWidget {
  Widget build(BuildContext context) {
    var state = BlocProvider.of<AppState>(context);
    //return Container();
    return StreamBuilder(
      stream: state.data,
      builder: (context, AsyncSnapshot<QueryResults> snapshot){
        if (!snapshot.hasData){
          return Container();
        }
        if (snapshot.data.totalRowCount == 0 || snapshot.data.totalRowCount == null){
          return Container();
        }
        var page = state.page;
        var totalPages = (snapshot.data.totalRowCount / state.pageSize).ceil();
        return Row(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: page <= 1 ? null : () async {
                state.page = page-1;
                var err = await state.readTable();
                if (err != ''){
                  await showDialog(
                    context: context,
                    child: OkDialog(
                      child: Text("Error: $err"),
                      msgType: MsgType.Error,
                    ),
                  );
                }
              },
            ),
            Text("$page of $totalPages"),
            IconButton(
              icon: Icon(Icons.arrow_forward_ios),
              onPressed: page >= totalPages ? null : () async {
                state.page = page + 1;
                var err = await state.readTable();
                if (err != '') {
                  await showDialog(
                    context: context,
                    child: OkDialog(
                      child: Text("Error: $err"),
                      msgType: MsgType.Error,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}

typedef Future<String> DataEntryOnSubmit(Map<String,dynamic> values);

class DataEntryDialog extends StatefulWidget {
  DataEntryDialog({this.editModes, this.initialValues, this.onSubmit})
      : assert(editModes.length == initialValues.length);
  final List<dynamic> initialValues;
  final Map<String,String> editModes;
  final DataEntryOnSubmit onSubmit;

  State<StatefulWidget> createState() => _DataEntryDialogState();
}

class _DataEntryDialogState extends State<DataEntryDialog> {

  var _textControllers = List<TextEditingController>();
  var _values = List<dynamic>();

  initState(){
    super.initState();
    var editModes = widget.editModes.values.toList();
    for (var index = 0; index < editModes.length; index++){
      var value = widget.initialValues[index];
      _values.add(value);
      var editMode = editModes[index];
      switch (editMode){
        case editNumber:
        case editInteger:
        case editText:
          _textControllers.add(
              TextEditingController(text: value == null ? "" : value.toString()),
          );
          break;
        default:
          _textControllers.add(null);
          break;
      }
    }
  }

  Widget build(BuildContext context) {
    var rowHeight = 60.0;
    var textBackground = Color.fromARGB(255, 230, 230, 230);
    var keys = widget.editModes.keys.toList();
    var widgets = List<Widget>();
    for (var index = 0; index < keys.length; index++) {
      var key = keys[index];
      Widget editorWidget;
      switch (widget.editModes[key]){
        case editText:
          editorWidget = Container(
            height: rowHeight,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(key),
                ),
                Expanded(
                  child: TextField(
                    controller: _textControllers[index],
                    decoration: InputDecoration.collapsed(
                        hintText: '',
                        filled: true,
                        fillColor: textBackground,
                    ),
                  ),
                ),
              ],
            ),
          );
          break;
        case editInteger:
          editorWidget = Container(
            height: rowHeight,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(key),
                ),
                Expanded(
                  child: TextField(
                    controller: _textControllers[index],
                    decoration: InputDecoration.collapsed(
                      hintText: '',
                      filled: true,
                      fillColor: textBackground,
                    ),
                    inputFormatters: [
                      NumberInputFormatter(NumberInputFormatterType.integer),
                    ],
                  ),
                ),
              ],
            ),
          );
          break;
        case editNumber:
          editorWidget = Container(
            height: rowHeight,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(key),
                ),
                Expanded(
                  child: TextField(
                    controller: _textControllers[index],
                    decoration: InputDecoration.collapsed(
                      hintText: '',
                      filled: true,
                      fillColor: textBackground,
                    ),
                    inputFormatters: [
                      NumberInputFormatter(NumberInputFormatterType.decimal),
                    ],
                  ),
                ),
              ],
            ),
          );
          break;
        case editBool:
          editorWidget = Container(
            height: rowHeight,
            child: Row(
              children: <Widget>[
                Expanded(child: Text(key)),
                Checkbox(
                  value: _values[index],
                  onChanged: (newValue)=>setState(()=>_values[index]=newValue),
                ),
              ],
            ),
          );
          break;
        case editDate:
          editorWidget = Container(
            height: rowHeight,
            child: Row(
              children: <Widget>[
                Expanded(child: Text(key)),
                Expanded(child: Text(_values[index].toString(),textAlign: TextAlign.end)),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () async {
                    DateTime initialDate;
                    if (_values[index] == null){
                      initialDate = today();
                    } else {
                      initialDate = DateTime.parse(_values[index]);
                    }
                    var newDate = await showDatePicker(
                      context: context,
                      initialDate: initialDate,
                      firstDate: DateTime(1900),
                      lastDate: DateTime(9999,12,31,59,59,59),
                    );
                    if (newDate != null){
                      setState((){
                        _values[index] = newDate.toIso8601String();
                      });
                    }
                  },
                ),
                IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    setState((){
                      _values[index] = null;
                    });
                  },
                ),
              ],
            ),
          );
          break;
        default:
          editorWidget = Container(
            height: rowHeight,
            child: Row(
              children: <Widget>[
                Expanded(child: Text(key)),
                Expanded(child: Text(_values[index].toString(), textAlign: TextAlign.end)),
              ],
            ),
          );
          break;
      }
      widgets.add(editorWidget);
    }
    return Dialog(
      child: Column(
        children: [
          Expanded(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: ListView(children: widgets),
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  FlatButton(
                    child: Text("Cancel"),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  RaisedButton(
                    child: Text("Submit"),
                    onPressed: () async {
                      var values = _generateSubmitValues();
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        child: LoadingDialog(message: "Submitting..."),
                      );
                      var err = await widget.onSubmit(values);
                      Navigator.of(context).pop();
                      if (err != ''){
                        await showDialog(
                          context: context,
                          child: OkDialog(
                            msgType: MsgType.Error,
                            child: Text("Error: $err"),
                          ),
                        );
                        return;
                      }
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String,dynamic> _generateSubmitValues(){
    var submitValues = Map<String,dynamic>();
    var keys = widget.editModes.keys.toList();
    for (var index = 0; index < _textControllers.length; index++){
      var key = keys[index];
      var editMode = widget.editModes[key];
      var controller = _textControllers[index];
      dynamic value;
      if (controller == null){
        value = _values[index];
      } else {
        value = controller.text;
      };
      switch (editMode){
        case editBool:
          submitValues[key] = tryCast<bool>(value, null);
          break;
        case editNumber:
          submitValues[key] = double.tryParse(value);
          break;
        case editInteger:
          submitValues[key] = int.tryParse(value);
          break;
        case editText:
          submitValues[key] = value.toString();
          break;
        case editDate:
          if (value == null)
            submitValues[key] = null;
          else
            submitValues[key] = value.toString();
          break;
        default:
          continue;
      }
    }
    return submitValues;
  }
}

enum NumberInputFormatterType {
  integer,
  decimal,
}

class NumberInputFormatter extends WhitelistingTextInputFormatter {
  NumberInputFormatter(this.numberType) : super(r'[0-9.\-]');
  final NumberInputFormatterType numberType;

  final decimalFormat = RegExp(r'^-?[0-9]*\.?[0-9]*$');
  final integerFormat = RegExp(r'^-?[0-9]*$');

  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    bool isOk;
    switch (numberType){
      case NumberInputFormatterType.decimal:
        isOk = decimalFormat.hasMatch(newValue.text) || newValue.text.isEmpty;
        break;
      case NumberInputFormatterType.integer:
        isOk = integerFormat.hasMatch(newValue.text) || newValue.text.isEmpty;
        break;
    }
    if (isOk) return newValue;
    return oldValue;
  }
}

DateTime today() {
  var now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}
