import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tableau_crud_ui/dialogs.dart';
import 'package:tableau_crud_ui/io/settings.dart';
import 'package:tableau_crud_ui/io/try_cast.dart';

typedef Future<String> DataEntryOnSubmit(Map<String,dynamic> values);

class DataEntryDialog extends StatefulWidget {
  DataEntryDialog({required this.editModes, required this.initialValues, required this.onSubmit, required this.user})
      : assert(editModes.length == initialValues.length);
  final List<dynamic> initialValues;
  final Map<String,String> editModes;
  final DataEntryOnSubmit onSubmit;
  final String user;

  State<StatefulWidget> createState() => _DataEntryDialogState();
}

class _DataEntryDialogState extends State<DataEntryDialog> {

  var _textControllers = <TextEditingController?>[];
  var _values = [];

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
        case editMultiLineText:
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
    var keys = widget.editModes.keys.toList();
    var widgets = <Widget>[];
    for (var index = 0; index < keys.length; index++) {
      var key = keys[index];
      Widget editorWidget;
      switch (getEditMode(widget.editModes[key] ?? editNone)){
        case editText:
          editorWidget = TextField(
            maxLength: 255,
            decoration: InputDecoration(
                labelText: key
            ),
            controller: _textControllers[index],
          );
          break;
        case editMultiLineText:
          editorWidget = TextField(
            minLines: 3,
            maxLines: 5,
            decoration: InputDecoration(
                labelText: key
            ),
            controller: _textControllers[index],
          );
          break;
        case editInteger:
          editorWidget = TextField(
            controller: _textControllers[index],
            decoration: InputDecoration(
              labelText: key,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9\-]'))
            ],
          );
          break;
        case editNumber:
          editorWidget = TextField(
            controller: _textControllers[index],
            decoration: InputDecoration(
              labelText: key
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.\-]')),
            ],
          );
          break;
        case editBool:
          editorWidget = InputDecorator(
            decoration: InputDecoration(labelText: key, isDense: true, enabledBorder: InputBorder.none),
            child: Row(
              children: [
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
          editorWidget = TextField(
            controller: _textControllers[index],
            decoration: InputDecoration(
              hintText: 'yyyy-mm-dd',
              labelText: key
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9\-]')),
            ],
          );
          break;
        case editFixedList:
          var items = parseFixedList(widget.editModes[key] ?? editNone);
          var value = _values[index].toString();
          if (!items.contains(value)) items.insert(0, value);
          editorWidget = InputDecorator(
            decoration: InputDecoration(
              isDense: true,
              labelText: key,
            ),
            child: DropdownButton(
              isDense: true,
              icon: SizedBox(),
              underline: SizedBox(),
              value: value,
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (value)=>setState(()=>_values[index] = value),
            ),
          );
          break;
        default:
          editorWidget = InputDecorator(
            decoration: InputDecoration(
              isDense: true,
              labelText: key,
              enabledBorder: InputBorder.none,
            ),
            child: Text(_values[index].toString()),
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
                  TextButton(
                    child: Text("Cancel"),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  ElevatedButton(
                    child: Text("Submit"),
                    onPressed: () async {
                      var values = _generateSubmitValues();
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => LoadingDialog(message: "Submitting..."),
                      );
                      var err = await widget.onSubmit(values);
                      Navigator.of(context).pop();
                      if (err != ''){
                        await showDialog(
                          context: context,
                          builder: (context) => OkDialog(
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
      var editMode = widget.editModes[key] ?? editNone;
      var controller = _textControllers[index];
      dynamic value;
      if (controller == null){
        value = _values[index];
      } else {
        value = controller.text;
      }
      switch (getEditMode(editMode)){
        case editBool:
          submitValues[key] = tryCast<bool>(value, false);
          break;
        case editNumber:
          submitValues[key] = double.tryParse(value);
          break;
        case editInteger:
          submitValues[key] = int.tryParse(value);
          break;
        case editText:
        case editMultiLineText:
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
        case editTimestamp:
          submitValues[key] = DateTime.now().toIso8601String();
          break;
        case editUser:
          submitValues[key] = widget.user;
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

DateTime today() {
  var now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}
