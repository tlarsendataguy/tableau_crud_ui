
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tableau_crud_ui/io/settings.dart';

class GeneralSettingsPage extends StatefulWidget {
  GeneralSettingsPage({required this.settings});
  final Settings settings;

  createState()=>_GeneralSettingsPageState();
}

const _inputWidth = 60.0;

class _GeneralSettingsPageState extends State<GeneralSettingsPage> {

  late TextEditingController pageSizeController;

  initState(){
    super.initState();
    pageSizeController = TextEditingController(text: widget.settings.defaultPageSize.toString());
  }

  Widget build(BuildContext context) {
    return ListView(
      itemExtent: 40,
      children: [
        Row(
          children: [
            Expanded(
              child: Text("Default page size:"),
            ),
            SizedBox(
              width: _inputWidth,
              child: TextField(
                controller: pageSizeController,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
                onChanged: (newValueStr) {
                  var newValue = int.tryParse(newValueStr);
                  if (newValue == null) {
                    return;
                  }
                  widget.settings.defaultPageSize = newValue;
                },
              ),
            )
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Text("Enable insert:"),
            ),
            SizedBox(
              width: _inputWidth,
              child: Checkbox(
                value: widget.settings.enableInsert,
                onChanged: (newValue) {
                  if (newValue != null){
                    setState(()=>widget.settings.enableInsert = newValue);
                  }
                },
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Text("Enable update:"),
            ),
            SizedBox(
              width: _inputWidth,
              child: Checkbox(
                value: widget.settings.enableUpdate,
                onChanged: (newValue) {
                  if (newValue != null) {
                    setState(()=>widget.settings.enableUpdate = newValue);
                  }
                },
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Text("Enable delete:"),
            ),
            SizedBox(
              width: _inputWidth,
              child: Checkbox(
                value: widget.settings.enableDelete,
                onChanged: (newValue) {
                  if (newValue != null) {
                    setState(()=>widget.settings.enableDelete = newValue);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}