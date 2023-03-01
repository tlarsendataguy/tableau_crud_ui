import 'dart:convert';
import 'dart:html' as html;
import 'package:http/http.dart' as http;
import 'package:tableau_crud_ui/io/connection_data.dart';
import 'package:tableau_crud_ui/io/io.dart';

class DbWebIo extends DbIo {
  var _address = html.window.location.href;

  Future<String> testConnection(RequestData request) =>_request(request.toJson());
  Future<String> insert(RequestData request) =>_request(request.toJson());
  Future<String> update(RequestData request) =>_request(request.toJson());
  Future<String> delete(RequestData request) =>_request(request.toJson());
  Future<String> read(RequestData request) =>_request(request.toJson());
  Future<String> encryptPassword(String password) async {
    var jsonRequest = jsonEncode({"password": password});
    return await _request(jsonRequest, path: "encryptpassword");
  }

  Future<String> _request(String jsonRequest, {String path=""}) async {
    try{
      var address = _address;
      if (_address.length > 2 && _address.substring(_address.length-2) == "#/"){
        address = _address.substring(0, _address.length-2);
      }
      var uri = Uri.parse("$address$path");
      var response = await http.post(uri, headers: {"Content-type":"application/json"}, body: jsonRequest);
      return response.body;
    } catch (ex){
      print('error sending $jsonRequest');
      return '{"Success":false,"Data":"Error connecting to web service"}';
    }
  }
}
