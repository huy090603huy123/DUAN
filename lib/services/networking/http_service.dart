import 'dart:io';
import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;

import 'custom_exception.dart';

class HttpService {
  Future<Map<String, dynamic>> get(String url) async {
    Map<String, dynamic> decodedResponseJson;
    try {
      // SỬA LỖI: Chuyển đổi String thành Uri bằng Uri.parse()
      final response = await http.get(Uri.parse(url));
      decodedResponseJson = _decodeResponse(response, url);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return decodedResponseJson;
  }

  Future<Map<String, dynamic>> post(String url, Map<String, dynamic> body) async {
    Map<String, dynamic> decodedResponseJson;
    try {
      // SỬA LỖI: Chuyển đổi String thành Uri bằng Uri.parse()
      final response = await http.post(
          Uri.parse(url),
          headers: {"Content-Type": "application/json"},
          body: json.encode(body)
      );
      decodedResponseJson = _decodeResponse(response, url);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return decodedResponseJson;
  }

  Future<Map<String, dynamic>> delete(String url) async {
    Map<String, dynamic> decodedResponseJson;
    try {
      // SỬA LỖI: Chuyển đổi String thành Uri bằng Uri.parse()
      final response = await http.delete(Uri.parse(url));
      decodedResponseJson = _decodeResponse(response, url);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return decodedResponseJson;
  }

  Future<Map<String, dynamic>> put(String url, Map<String, dynamic> body) async {
    Map<String, dynamic> decodedResponseJson;
    try {
      // SỬA LỖI: Chuyển đổi String thành Uri bằng Uri.parse()
      final response = await http.put(
          Uri.parse(url),
          headers: {"Content-Type": "application/json"},
          body: json.encode(body)
      );
      decodedResponseJson = _decodeResponse(response, url);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return decodedResponseJson;
  }

  dynamic _decodeResponse(http.Response response, String url) {
    switch (response.statusCode) {
      case 200:
      case 201:
        var responseJson = json.decode(response.body.toString());
        return responseJson;
      case 400:
        print('Request $url failed\nResponse: ${response.statusCode} ${response.reasonPhrase}');
        throw BadRequestException(response.body.toString());
      case 401:
      case 403:
        print('Request $url failed\nResponse: ${response.statusCode} ${response.reasonPhrase}');
        throw UnauthorisedException(response.body.toString());
      case 500:
      default:
        print('Request $url failed\nResponse: ${response.statusCode} ${response.reasonPhrase}');
        throw FetchDataException(
            'Error occurred while Communication with Server with StatusCode : ${response.statusCode}');
    }
  }
}