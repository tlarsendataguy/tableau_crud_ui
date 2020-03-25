import 'dart:html' as html;
import 'package:http/http.dart' as http;
import 'package:tableau_crud_ui/state_and_model/connection_data.dart';
import 'package:tableau_crud_ui/state_and_model/io.dart';

class DbWebIo extends DbIo {
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
      print('error sending $jsonRequest');
      return '{"Success":false,"Data":"Error connecting to web service"}';
    }
  }
}
