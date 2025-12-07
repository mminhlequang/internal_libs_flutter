import 'package:dio/dio.dart';

/// [CustomLogInterceptor] is used to print logs during network requests.
/// It should be the last interceptor added,
/// otherwise modifications by following interceptors will not be logged.
/// This is because the execution of interceptors is in the order of addition.
///
/// **Note**
/// When used in Flutter, make sure to use `debugPrint` to print logs.
/// Alternatively `dart:developer`'s `log` function can also be used.
///
/// ```dart
/// dio.interceptors.add(
///   LogInterceptor(
///    logPrint: (o) => debugPrint(o.toString()),
///   ),
/// );
/// ```
class CustomLogInterceptor extends Interceptor {
  CustomLogInterceptor({
    this.request = true,
    this.requestHeader = true,
    this.requestBody = false,
    this.responseHeader = true,
    this.responseBody = false,
    this.error = true,
    this.logPrint = _debugPrint,
  });

  /// Print request [Options]
  bool request;

  /// Print request header [Options.headers]
  bool requestHeader;

  /// Print request data [Options.data]
  bool requestBody;

  /// Print [Response.data]
  bool responseBody;

  /// Print [Response.headers]
  bool responseHeader;

  /// Print error message
  bool error;

  /// Log printer; defaults print log to console.
  /// In flutter, you'd better use debugPrint.
  /// you can also write log in a file, for example:
  /// ```dart
  ///  final file=File("./log.txt");
  ///  final sink=file.openWrite();
  ///  dio.interceptors.add(LogInterceptor(logPrint: sink.writeln));
  ///  ...
  ///  await sink.close();
  /// ```
  void Function(Object object) logPrint;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    logPrint('*** Request ***');
    _printKV('uri', options.uri);
    //options.headers;

    if (request) {
      print(
          'method: ${options.method}, responseType: ${options.responseType}, followRedirects: ${options.followRedirects}, persistentConnection: ${options.persistentConnection}, connectTimeout: ${options.connectTimeout}, sendTimeout: ${options.sendTimeout}, receiveTimeout: ${options.receiveTimeout}, extra: ${options.extra}');
      // _printKV(
      //   'receiveDataWhenStatusError',
      //   options.receiveDataWhenStatusError,
      // );
      // _printKV('extra', options.extra);
    }
    if (requestHeader) {
      logPrint('headers:');
      options.headers.forEach((key, v) => _printKV(' $key', v));
    }
    if (requestBody) {
      logPrint('data:');
      _printAll(options.data);
    }
    logPrint('');

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    logPrint('*** Response ***');
    _printResponse(response);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (error) {
      logPrint('*** DioException ***:');
      logPrint('uri: ${err.requestOptions.uri}');
      logPrint('$err');
      if (err.response != null) {
        _printResponse(err.response!);
      }
      logPrint('');
    }

    handler.next(err);
  }

  void _printResponse(Response response) {
    _printKV('uri', response.requestOptions.uri);
    if (responseHeader) {
      _printKV('statusCode', response.statusCode);
      if (response.isRedirect == true) {
        _printKV('redirect', response.realUri);
      }

      logPrint('headers:');
      response.headers.forEach((key, v) => _printKV(' $key', v.join('\r\n\t')));
    }
    if (responseBody) {
      logPrint('Response Text:');
      _printAll(response.toString());
    }
    logPrint('');
  }

  void _printKV(String key, Object? v) {
    logPrint('$key: $v');
  }

  void _printAll(msg) {
    msg.toString().split('\n').forEach(logPrint);
  }
}

void _debugPrint(Object? object) {
  assert(() {
    print(object);
    return true;
  }());
}
