import 'dart:html' as html;
import 'package:http/http.dart' as http;
import 'package:tableau_crud_ui/io/connection_data.dart';
import 'package:tableau_crud_ui/io/io.dart';

class DbWebIo extends DbIo {
  var _address = html.window.location.href;

  Future<http.Response> testConnection(RequestData request) =>_request(request.toJson(), path:"api/test");
  Future<http.Response> insert(RequestData request) =>_request(request.toJson(), path:"api/insert");
  Future<http.Response> update(RequestData request) =>_request(request.toJson(), path:"api/update");
  Future<http.Response> delete(RequestData request) =>_request(request.toJson(), path:"api/delete");
  Future<http.Response> read(RequestData request) =>_request(request.toJson(), path:"api/read");


  Future<http.Response> _request(String jsonRequest, {String path=""}) async {
      var address = _address;
      if (_address.length > 2 && _address.substring(_address.length-2) == "#/"){
        address = _address.substring(0, _address.length-2);
      }
      var uri = Uri.parse("$address$path");
      return await http.post(uri, headers: {"Content-type":"application/json"}, body: jsonRequest);
  }
}
