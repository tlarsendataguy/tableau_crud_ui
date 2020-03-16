import 'package:tableau_crud_ui/connection_data.dart';
import 'dart:html' as html;
import 'package:http/http.dart' as http;

abstract class Io {
  Future<String> testConnection(RequestData request);
  Future<String> insert(RequestData request);
  Future<String> update(RequestData request);
  Future<String> delete(RequestData request);
  Future<String> read(RequestData request);
}

class MockSuccessIo extends Io {
  Future<String> testConnection(RequestData request) async =>
      '{"Success":true,"Data":{"ColumnNames":["id","category","amount","date"],"RowCount":0,"Data":[[],[],[]]}}';
  Future<String> insert(RequestData request) async =>
      '{"Success":true,"Data":1}';
  Future<String> update(RequestData request) async =>
      '{"Success":true,"Data":1}';
  Future<String> delete(RequestData request) async =>
      '{"Success":true,"Data":1}';
  Future<String> read(RequestData request) async =>
      '{"Success":true,"Data":{"ColumnNames":["id","category","amount","date"],"RowCount":2,"Data":[[1,13],["blah","something"],[123.2,64.02],["2020-01-13T00:00:00Z","2020-02-03T00:00:00Z"]]}}';
}

class MockFailIo extends Io {
  Future<String> testConnection(RequestData request) async =>
      '{"Success":false,"Data";"test connection failed"}';
  Future<String> insert(RequestData request) async =>
      '{"Success":false,"Data";"insert failed"}';
  Future<String> update(RequestData request) async =>
      '{"Success":false,"Data";"update failed"}';
  Future<String> delete(RequestData request) async =>
      '{"Success":false,"Data";"delete failed"}';
  Future<String> read(RequestData request) async =>
      '{"Success":false,"Data";"read failed"}';
}

class WebIo extends Io {
  var _address = html.window.location.href;

  Future<String> testConnection(RequestData request) =>_request(request.toJson());
  Future<String> insert(RequestData request) =>_request(request.toJson());
  Future<String> update(RequestData request) =>_request(request.toJson());
  Future<String> delete(RequestData request) =>_request(request.toJson());
  Future<String> read(RequestData request) =>_request(request.toJson());

  Future<String> _request(String jsonRequest) async {
    try{
      var response = await http.post(_address, headers: {"Content-type":"application/json"}, body: jsonRequest);
      return response.body;
    } catch (ex){
      return '{"Success":false,"Data":"Error connecting to web service"}';
    }
  }
}

