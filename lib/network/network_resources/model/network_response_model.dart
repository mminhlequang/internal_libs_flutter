import '../../../internal_core.dart';
import 'package:dio/dio.dart' as dio;

import '../../options.dart';

bool isStatusCodeSuccess(statusCode) => statusCode == 200 || statusCode == 201;

class NetworkResponse<T> {
  static String disconnectError = 'disconnectError';
  static String unknownError = 'unknownError';

  String get responsePrefixData =>
      networkOptions?.responsePrefixData ?? "values";

  String get responsePrefixErrorMessage =>
      networkOptions?.responsePrefixErrorMessage ?? "error";

  int? statusCode;
  T? data;
  String? msg;

  bool get isSuccess => networkOptions?.responseIsSuccess != null
      ? networkOptions!.responseIsSuccess!(this)
      : (isStatusCodeSuccess(statusCode) && data != null);

  bool get isError => !isSuccess;
  bool get isErrorDisconnect => msg == disconnectError;

  NetworkResponse({this.data, this.statusCode, this.msg});

  factory NetworkResponse.fromResponse(dio.Response response,
      {dynamic Function(dynamic)? converter, value, String? prefix}) {
    try {
      return NetworkResponse._fromJson(response.data,
          converter: converter, prefix: prefix, value: value)
        ..statusCode = response.statusCode;
    } catch (e) {
      return NetworkResponse.withErrorConvert(e);
    }
  }

  NetworkResponse._fromJson(dynamic json,
      {dynamic Function(dynamic)? converter, value, String? prefix}) {
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
    print(
        "NetworkErrorRequest: ${error.type.name} ${error.message}");
    try {
      data = null;
      dio.Response? response = error.response;
      statusCode = response?.statusCode ?? 500;
      if (response?.data?[responsePrefixErrorMessage] != null) {
        this.msg = response?.data?[responsePrefixErrorMessage];
      }
    } catch (e) {
      print("NetworkResponse.withErrorRequest: catch=$e");
    }
  }

  NetworkResponse.withErrorConvert(error) {
    print("NetworkResponse.withErrorConvert: $error");
    data = null;
    this.msg = unknownError;
  }

  NetworkResponse.withDisconnect() {
    print("NetworkResponse.withDisconnect");
    data = null;
    this.msg = disconnectError;
  }
}
