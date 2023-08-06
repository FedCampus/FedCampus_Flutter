import 'package:http/http.dart' as http;

//TODO: for test only, json response and single number response are tested
Future<http.Response> fetchDistance() {
  //sample response: {"distance": "12345", "unit": "m"}
  return http.get(Uri.parse('http://192.168.0.107:9999/api/distance'));
}

Future<http.Response> fetchHeartRate() {
  //sample response: {"high": "120", "low": "60"}
  return http.get(Uri.parse('http://192.168.0.107:9999/api/heartrate'));
}

Future<http.Response> fetchIntenseExercise() {
  //sample response: 78
  return http.get(Uri.parse('http://192.168.0.107:9999/api/intenseexercise'));
}
