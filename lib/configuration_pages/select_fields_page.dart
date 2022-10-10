import 'package:flutter/material.dart';
import 'package:tableau_crud_ui/io/settings.dart';

class SelectFieldsPage extends StatefulWidget {
  SelectFieldsPage({this.settings});
  final Settings settings;

  createState()=>_SelectFieldsPageState();
}

class _SelectFieldsPageState extends State<SelectFieldsPage> {

  String error = '';
  List<String> columns = [];
  ScrollController leftScroll = ScrollController();
  ScrollController rightScroll = ScrollController();

  initState(){
    super.initState();
    loadAvailableColumns();
  }

  void loadAvailableColumns() {
    columns = [];
    var selectFields = widget.settings.selectFields.keys.toList();
    for (var column in widget.settings.tableColumns) {
      if (selectFields.contains(column)) {
        continue;
      }
      columns.add(column);
    }
  }

  void addSelectField(String field) {
    widget.settings.selectFields[field]=editNone;
    loadAvailableColumns();
    setState((){});
  }

  void removeSelectField(String field) {
    widget.settings.selectFields.remove(field);
    loadAvailableColumns();
    setState((){});
  }

  void moveSelectFieldUp(String field){
    var oldSelectFields = Map<String,String>.from(widget.settings.selectFields);
    var fields = oldSelectFields.keys.toList();
    var index = fields.indexOf(field);
    if (index < 1) return;
    index--;
    fields.remove(field);
    fields.insert(index, field);
    var newSelectFields = Map<String,String>();
    for (var field in fields){
      newSelectFields[field] = oldSelectFields[field];
    }
    setState(()=>widget.settings.selectFields = newSelectFields);
  }

  void moveSelectFieldDown(String field){
    var oldSelectFields = Map<String,String>.from(widget.settings.selectFields);
    var fields = oldSelectFields.keys.toList();
    var index = fields.indexOf(field);
    if (index == -1 || index == fields.length-1) return;
    index++;
    fields.remove(field);
    fields.insert(index, field);
    var newSelectFields = Map<String,String>();
    for (var field in fields){
      newSelectFields[field] = oldSelectFields[field];
    }
    setState(()=>widget.settings.selectFields = newSelectFields);
  }

  Widget build(BuildContext context) {
    if (error != '') {
      return Center(child: Text(error));
    }

    Widget buildSourceColumn(BuildContext context, int index) {
      return Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: ()=>addSelectField(columns[index]),
          ),
          Expanded(
            child: Text(columns[index]),
          ),
        ],
      );
    }

    Widget buildSelectedField(BuildContext context, int index) {
      var selectedFields = widget.settings.selectFields.keys.toList();
      var selectedField = selectedFields[index];
      return SelectorCard(
        settings: widget.settings,
        selectedField: selectedField,
        onMoveFieldUp: moveSelectFieldUp,
        onMoveFieldDown: moveSelectFieldDown,
        onDeleteField: removeSelectField,
      );
    }

    return Column(
      children: [
        Expanded(
          flex: 1,
          child: Column(
            children: [
              Text("Available fields:"),
              Expanded(
                child: ListView.builder(
                  controller: leftScroll,
                  itemCount: columns.length,
                  itemBuilder: buildSourceColumn,
                ),
              )
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              Text("Selected fields:"),
              Expanded(
                child: ListView.builder(
                  controller: rightScroll,
                  itemCount: widget.settings.selectFields.length,
                  itemBuilder: buildSelectedField,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SelectorCard extends StatefulWidget {
  SelectorCard({this.settings, this.selectedField, this.onMoveFieldUp, this.onMoveFieldDown, this.onDeleteField});
  final Settings settings;
  final String selectedField;
  final Function(String) onMoveFieldUp;
  final Function(String) onMoveFieldDown;
  final Function(String) onDeleteField;
  State<StatefulWidget> createState() => _SelectorCardState();
}

class _SelectorCardState extends State<SelectorCard>{

  String selectedEditMode() {
    return getEditMode(widget.settings.selectFields[widget.selectedField]);
  }

  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.delete),
          onPressed: ()=>widget.onDeleteField(widget.selectedField),
        ),
        Expanded(child: Text(widget.selectedField)),
        Tooltip(
          message: "The data type to use for inserting and updating values",
          child: DropdownButton(
              value: selectedEditMode(),
              items: [
                DropdownMenuItem(value: editNone, child: Text(editNone)),
                DropdownMenuItem(value: editText, child: Text(editText)),
                DropdownMenuItem(value: editMultiLineText, child: Text(editMultiLineText)),
                DropdownMenuItem(value: editDate, child: Text(editDate)),
                DropdownMenuItem(value: editInteger, child: Text(editInteger)),
                DropdownMenuItem(value: editNumber, child: Text(editNumber)),
                DropdownMenuItem(value: editBool, child: Text(editBool)),
                DropdownMenuItem(value: editFixedList, child: Text(editFixedList)),
              ],
              onChanged: (newValue) {
                if (newValue == editFixedList){
                  newValue = generateFixedList([]);
                }
                setState(()=>widget.settings.selectFields[widget.selectedField] = newValue);
              }
          ),
        ),
        selectedEditMode() == editFixedList ?
          SizedBox(
            width: 48,
            child: IconButton(icon: Icon(Icons.tune), onPressed: fixedListPress(
              settings: widget.settings,
              context: context,
              selectedField: widget.selectedField,
              editMode: widget.settings.selectFields[widget.selectedField],
            )),
          ) :
          Container(width: 48),
        Tooltip(
          message: "Field is part of the primary key?",
          child: Row(
            children: [
              Checkbox(
                value: widget.settings.primaryKey.contains(widget.selectedField), // pk.contains(widget.selectedField),
                onChanged: (newValue){
                  if (newValue){
                    setState(() => widget.settings.primaryKey.add(widget.selectedField));
                  } else {
                    setState(() => widget.settings.primaryKey.remove(widget.selectedField));
                  }
                },
              ),
              Text("PK"),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.arrow_upward),
          onPressed: ()=>widget.onMoveFieldUp(widget.selectedField),
        ),
        IconButton(
          icon: Icon(Icons.arrow_downward),
          onPressed: ()=>widget.onMoveFieldDown(widget.selectedField),
        ),
      ],
    );
  }
}

Function fixedListPress({Settings settings, String selectedField, String editMode, BuildContext context}) {
  return () async {
    await showDialog(
      context: context,
      builder: (context) => EditFixedListDialog(
        settings: settings,
        selectedField: selectedField,
        editMode: editMode,
      ),
    );
  };
}

class EditFixedListDialog extends StatefulWidget {
  EditFixedListDialog({this.settings, this.selectedField, this.editMode});
  final Settings settings;
  final String selectedField;
  final String editMode;

  State<StatefulWidget> createState() => _EditFixedListDialogState();
}

class _EditFixedListDialogState extends State<EditFixedListDialog> {

  List<String> items;
  TextEditingController controller;

  initState() {
    super.initState();
    var data = getEditModeData(widget.editMode);
    if (data == ''){
      items = [];
    } else {
      items = data.split('|');
    }
    controller = TextEditingController();
  }

  void addItem(){
    setState((){
      items.add(controller.text);
      controller.text = "";
    });
  }

  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        children: <Widget>[
          Expanded(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: controller,
                            decoration: InputDecoration(
                              labelText: "New item",
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: addItem,
                        ),
                      ],
                    ),
                    Container(height: 10),
                    Expanded(
                      child: ListView(
                        children: items.map((item)=> Container(
                          height: 40,
                          child: Row(
                            children: <Widget>[
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: ()=>setState((){
                                  items.remove(item);
                                }),
                              ),
                              Expanded(child: Text(item)),
                              IconButton(
                                icon: Icon(Icons.arrow_upward),
                                onPressed: ()=>setState((){
                                  var index = items.indexOf(item);
                                  if (index < 1) return;
                                  index--;
                                  items.remove(item);
                                  items.insert(index, item);
                                }),
                              ),
                              IconButton(
                                icon: Icon(Icons.arrow_downward),
                                onPressed:  ()=>setState((){
                                  var index = items.indexOf(item);
                                  if (index >= items.length-1) return;
                                  index++;
                                  items.remove(item);
                                  items.insert(index, item);
                                }),
                              ),
                            ],
                          ),
                        )).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(
                    child: Text("Cancel"),
                    onPressed: ()=>Navigator.of(context).pop(),
                  ),
                  ElevatedButton(
                    child: Text("Save"),
                    onPressed: (){
                      var editMode = generateFixedList(items);
                      widget.settings.selectFields[widget.selectedField] = editMode;
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
}