import 'package:internal_core/internal_core.dart';
import 'package:internal_network/options.dart';
import 'package:dio/dio.dart' as dio;

class NetworkResponse<T> {
  static String disconnectError = 'disconnectError';
  static String unknownError = 'unknownError';

  String get responsePrefixData =>
      networkOptions?.responsePrefixData ?? "values";

  int? statusCode;
  bool? status;
  T? data;
  String? msg;

  bool get isSuccess => (status == true && data != null);

  bool get isError => status != true;
  bool get isErrorDisconnect => msg == disconnectError;

  NetworkResponse({this.data, this.statusCode, this.status, this.msg});

  factory NetworkResponse.fromResponse(dio.Response response,
      {dynamic Function(dynamic)? converter, value, String? prefix}) {
    try {
      return NetworkResponse._fromJson(response.data,
          converter: converter, prefix: prefix, value: value)
        ..statusCode = response.statusCode
        ..status = response.data?['status'];
    } catch (e) {
      return NetworkResponse.withErrorConvert(e);
    }
  }

  NetworkResponse._fromJson(dynamic json,
      {dynamic Function(dynamic)? converter, value, String? prefix}) {
    status = json?['status'];
    if (value != null) {
      data = value;
    } else if (prefix != null) {
      if (prefix.trim().isEmpty) {
        data = converter != null && json != null ? converter(json) : json;
      } else {
        data = converter != null && json[prefix] != null
            ? converter(json[prefix])
            : json[prefix];
      }
    } else {
      if (responsePrefixData.isNotEmpty == true) {
        data = converter != null && json[responsePrefixData] != null
            ? converter(json[responsePrefixData])
            : json[responsePrefixData];
      } else {
        data = converter != null ? converter(json) : json;
      }
    }
  }

  NetworkResponse.withErrorRequest(dio.DioException error) {
    appDebugPrint("NetworkResponse.withErrorRequest: $error");
    try {
      data = null;
      dio.Response? response = error.response;
      statusCode = response?.statusCode ?? 500;
      if (response?.data?['error'] != null) {
        this.msg = response?.data?['error'];
      }
    } catch (e) {
      appDebugPrint("NetworkResponse.withErrorRequest: catch=$e");
    }
  }

  NetworkResponse.withErrorConvert(error) {
    appDebugPrint("NetworkResponse.withErrorConvert: $error");
    data = null;
    this.msg = unknownError;
  }

  NetworkResponse.withDisconnect() {
    appDebugPrint("NetworkResponse.withDisconnect");
    data = null;
    this.msg = disconnectError;
  }
}
