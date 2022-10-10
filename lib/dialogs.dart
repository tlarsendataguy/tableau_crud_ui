import 'package:flutter/material.dart';

enum MsgType {
  Normal,
  Success,
  Error,
}

class OkDialog extends StatelessWidget {
  OkDialog({this.child, this.msgType});
  final Widget child;
  final MsgType msgType;

  Widget build(BuildContext context) {
    Color color;
    switch (msgType){
      case MsgType.Error:
        color = Color.fromARGB(255, 255, 200, 200);
        break;
      case MsgType.Success:
        color = Color.fromARGB(255, 200, 255, 200);
        break;
      default:
        break;
    }
    return Dialog(
      child: Card(
        color: color,
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              child,
              ElevatedButton(
                child: Text("Ok"),
                onPressed: Navigator.of(context).pop,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class YesNoDialog extends StatelessWidget {
  YesNoDialog({this.child});
  final Widget child;

  Widget build(BuildContext context) {
    return Dialog(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              child,
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(
                    child: Text("No"),
                    onPressed: ()=>Navigator.of(context).pop("No"),
                  ),
                  ElevatedButton(
                    child: Text("Yes"),
                    onPressed: ()=>Navigator.of(context).pop("Yes"),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class LoadingDialog extends StatelessWidget {
  LoadingDialog({this.message});
  final String message;

  Widget build(BuildContext context) {
    return Dialog(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Text(message),
        ),
      ),
    );
  }
}