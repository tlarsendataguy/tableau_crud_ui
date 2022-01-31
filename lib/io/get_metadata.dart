
import 'package:tableau_crud_ui/io/connection_data.dart';
import 'package:tableau_crud_ui/io/io.dart';
import 'package:tableau_crud_ui/io/parse_responses.dart';
import 'package:tableau_crud_ui/io/response_objects.dart';
import 'package:tableau_crud_ui/io/settings.dart';

Future<ResponseObject<QueryResults>> getMetadata(DbIo io, Settings settings) async {
  var function = TestConnectionFunction();
  var request = ConnectionData.fromSettings(settings).generateRequest(function);
  var response = await io.testConnection(request);
  return parseQuery(response);
}
