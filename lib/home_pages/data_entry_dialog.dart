import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tableau_crud_ui/dialogs.dart';
import 'package:tableau_crud_ui/state_and_model/input_formatting.dart';
import 'package:tableau_crud_ui/state_and_model/settings.dart';
import 'package:tableau_crud_ui/state_and_model/try_cast.dart';

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
        case editDate:
          _textControllers.add(
            TextEditingController(text: value == null ? "" : value.toString().substring(0,10)),
          );
          break;
        default:
          _textControllers.add(null);
          break;
      }
    }
  }

  Widget build(BuildContext context) {
    var rowHeight = 40.0;
    var textBackground = Color.fromARGB(255, 230, 230, 230);
    var keys = widget.editModes.keys.toList();
    var widgets = List<Widget>();
    for (var index = 0; index < keys.length; index++) {
      var key = keys[index];
      Widget editorWidget;
      switch (getEditMode(widget.editModes[key])){
        case editText:
          editorWidget = Container(
            height: 60,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(key),
                ),
                Expanded(
                  child: TextField(
                    maxLength: 255,
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
                  tristate: true,
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
                Expanded(
                  child: TextField(
                    controller: _textControllers[index],
                    decoration: InputDecoration.collapsed(
                      hintText: 'yyyy-mm-dd',
                      filled: true,
                      fillColor: textBackground,
                    ),
                    inputFormatters: [
                      DateInputFormatter(),
                    ],
                  ),
                ),
              ],
            ),
          );
          break;
        case editFixedList:
          var items = parseFixedList(widget.editModes[key]);
          var value = _values[index].toString();
          if (!items.contains(value)) items.insert(0, value);
          editorWidget = Row(
            children: <Widget>[
              Expanded(child: Text(key)),
              Expanded(child: Container(
                color: textBackground,
                child: DropdownButton(
                  icon: Container(),
                  underline: Container(),
                  value: value,
                  items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (value)=>setState(()=>_values[index] = value),
                ),
              )),
            ],
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
      widgets.add(
        Padding(
          padding: EdgeInsets.fromLTRB(0, 4, 0, 4),
          child: editorWidget,
        ),
      );
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
      switch (getEditMode(editMode)){
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
          if (value == "")
            submitValues[key] = null;
          else
            submitValues[key] = value.toString();
          break;
        case editFixedList:
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

  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    switch (numberType){
      case NumberInputFormatterType.decimal:
        if (isTextDecimal(newValue.text)) return newValue;
        return oldValue;
      case NumberInputFormatterType.integer:
        if (isTextInteger(newValue.text)) return newValue;
        return oldValue;
    }
    return oldValue;
  }
}

class DateInputFormatter extends WhitelistingTextInputFormatter {
  DateInputFormatter() : super(r'[0-9\-]');

  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (isTextDate(newValue.text)) return newValue;
    return oldValue;
  }
}

DateTime today() {
  var now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}
