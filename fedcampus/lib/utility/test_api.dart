import 'package:http/http.dart' as http;

//TODO: for test only
Future<http.Response> fetchResponse() {
  return http.get(Uri.parse('http://192.168.0.107:9999/api/test/'));
}
