
import 'package:internal_network/options.dart';
import 'package:dio/browser.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'log_interceptor.dart';

class AppClient extends DioForBrowser {
  static AppClient? _instance;
  static bool _enableErrorHandler = true;

  factory AppClient({
    bool isAuthorizationCustom = false,
    String? token,
    String? baseUrl,
    bool enableErrorHandler = true,
    BaseOptions? options,
    List<Interceptor>? customInterceptors,
  }) {
    baseUrl ??= appBaseUrl;
    _enableErrorHandler = enableErrorHandler;

    _instance ??= AppClient._(
      baseUrl: appBaseUrl,
      options: options,
      customInterceptors: customInterceptors,
    );
    if (options != null) _instance!.options = options;
    if (appBaseUrl != null) _instance!.options.baseUrl = appBaseUrl!;

    if ((token == null || token.isEmpty)) {
      _instance!.options.headers.remove(r'Authorization');
    } else {
      _instance!.options.headers.addAll({
        r'Authorization': isAuthorizationCustom ? token : ('Bearer $token')
      });
    }
    _instance!.options.headers.addAll(appHeaders);
    return _instance!;
  }

  AppClient._({
    String? baseUrl,
    BaseOptions? options,
    List<Interceptor>? customInterceptors,
  }) : super(options) {
    interceptors.add(InterceptorsWrapper(
      onRequest: _requestInterceptor,
      onResponse: _responseInterceptor,
      onError: _errorInterceptor,
    ));
    if (customInterceptors?.isNotEmpty == true) {
      interceptors.addAll(customInterceptors!);
    }
    if (networkOptions?.customInterceptors?.isNotEmpty == true) {
      interceptors.addAll(networkOptions!.customInterceptors!);
    }
    if (networkOptions?.loggingEnable ?? false) {
      interceptors.add(
        CustomLogInterceptor(
          requestHeader: networkOptions?.loggingrequestHeader ?? false,
          requestBody: networkOptions?.loggingrequestBody ?? false,
          responseBody: networkOptions?.loggingrequestBody ?? false,
          responseHeader: networkOptions?.loggingrequestHeader ?? false,
          error: networkOptions?.loggingerror ?? false,
          logPrint: (o) {
            debugPrint(o.toString());
          },
        ),
      );
      // interceptors.add(
      //   PrettyDioLogger(
      //     requestHeader: networkOptions.loggingrequestHeader,
      //     requestBody: networkOptions.loggingrequestBody,
      //     responseBody: networkOptions.loggingrequestBody,
      //     responseHeader: networkOptions.loggingrequestHeader,
      //     error: networkOptions.loggingerror,
      //     compact: networkOptions.loggingcompact,
      //     maxWidth: networkOptions.loggingmaxWidth,
      //   ),
      // );
    }
    if ((baseUrl ?? appBaseUrl) != null) {
      this.options.baseUrl = (baseUrl ?? appBaseUrl)!;
    }
  }

  _requestInterceptor(
      RequestOptions ops, RequestInterceptorHandler handler) async {
    switch (ops.method) {
      case methodGet:
        ops.queryParameters = appMapParms(ops.queryParameters);

        break;
      case methodPost:
      case methodPut:
      case methodDelete:
        if (ops.data is Map) {
          ops.data = appMapParms(ops.data);
        } else if (ops.data is FormData) {}
        break;
      default:
        break;
    }
    ops.connectTimeout = const Duration(seconds: 30000);
    ops.receiveTimeout = const Duration(seconds: 30000);
    handler.next(ops);
  }

  _responseInterceptor(Response r, ResponseInterceptorHandler handler) {
    handler.next(r);
  }

  _errorInterceptor(DioException e, ErrorInterceptorHandler handler) {
    if (_enableErrorHandler) {
      if (errorInterceptor != null) errorInterceptor!(e);
    }
    handler.next(e);
  }
}
