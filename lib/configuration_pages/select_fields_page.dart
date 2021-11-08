import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tableau_crud_ui/state_and_model/bloc_provider.dart';
import 'package:tableau_crud_ui/state_and_model/configuration_state.dart';
import 'package:tableau_crud_ui/configuration_pages/item_selector.dart';
import 'package:tableau_crud_ui/state_and_model/settings.dart';

class SelectFieldsPage extends StatelessWidget {
  Widget build(BuildContext context) {
    var state = BlocProvider.of<ConfigurationState>(context);
    return ItemSelector<String>(
      leftLabel: "Available fields:",
      sourceStream: state.columnNames,
      sourceItemBuilder: (context, sourceField){
        return Row(
          children: <Widget>[
            Expanded(
              child: Text(sourceField),
            ),
            IconButton(
              icon: Icon(Icons.arrow_forward),
              onPressed: ()=>state.addSelectField(sourceField),
            ),
          ],
        );
      },
      rightFlex: 2,
      rightLabel: "Selected fields:",
      selectorStream: state.selectFields,
      selectorItemBuilder: (context, selectedField)=>SelectorCard(
        selectedField: selectedField,
      ),
    );
  }
}

class SelectorCard extends StatefulWidget {
  SelectorCard({this.selectedField});
  final String selectedField;
  State<StatefulWidget> createState() => _SelectorCardState();
}

class _SelectorCardState extends State<SelectorCard>{
  Widget build(BuildContext context) {
    var state = BlocProvider.of<ConfigurationState>(context);
    var editMode = state.getSelectFieldEditMode(widget.selectedField);
    return Row(
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.delete),
          onPressed: () {
            state.removeSelectField(widget.selectedField);
            state.removePrimaryKeyField(widget.selectedField);
          },
        ),
        Expanded(child: Text(widget.selectedField)),
        Tooltip(
          message: "The data type to use for inserting and updating values",
          child: DropdownButton(
              value: getEditMode(editMode),
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
                state.updateSelectFieldEditMode(widget.selectedField, newValue);
              }
          ),
        ),
        getEditMode(editMode) == editFixedList ?
          IconButton(icon: Icon(Icons.tune), onPressed: fixedListPress(
            context: context,
            selectedField: widget.selectedField,
            editMode: editMode,
          )) :
          Container(width: 48),
        StreamBuilder(
          stream: state.primaryKey,
          builder: (context, AsyncSnapshot<List<String>> pkSnapshot){
            if (!pkSnapshot.hasData){
              return Container();
            }
            var pk = pkSnapshot.data;
            return Tooltip(
              message: "Field is part of the primary key?",
              child: Row(
                children: [
                  Checkbox(
                    value: pk.contains(widget.selectedField),
                    onChanged: (newValue){
                      if (newValue){
                        state.addPrimaryKeyField(widget.selectedField);
                      } else {
                        state.removePrimaryKeyField(widget.selectedField);
                      }
                    },
                  ),
                  Text("PK"),
                ],
              ),
            );
          },
        ),
        IconButton(
          icon: Icon(Icons.arrow_upward),
          onPressed: ()=>state.moveSelectFieldUp(widget.selectedField),
        ),
        IconButton(
          icon: Icon(Icons.arrow_downward),
          onPressed: ()=>state.moveSelectFieldDown(widget.selectedField),
        ),
      ],
    );
  }
}

Function fixedListPress({String selectedField, String editMode, BuildContext context}) {
  return () async {
    await showDialog(
      context: context,
      builder: (context) => EditFixedListDialog(
        selectedField: selectedField,
        editMode: editMode,
      ),
    );
  };
}

class EditFixedListDialog extends StatefulWidget {
  EditFixedListDialog({this.selectedField, this.editMode});
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
    var state = BlocProvider.of<ConfigurationState>(context);
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
                      state.updateSelectFieldEditMode(
                        widget.selectedField,
                        editMode,
                      );
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