import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

// curl -X 'POST' \
//   'https://api.startomation.com/api/v1/common/proxy' \
//   -H 'accept: application/json' \
//   -H 'Content-Type: application/json' \
//   -d '{
//   "url": "string",
//   "method": "GET",
//   "headers": {
//     "additionalProp1": "string",
//     "additionalProp2": "string",
//     "additionalProp3": "string"
//   },
//   "data": {},
//   "params": {
//     "additionalProp1": "string",
//     "additionalProp2": "string",
//     "additionalProp3": "string"
//   }
// }' 


/// Cấu hình proxy cho network client
class ProxyConfig {
  final String proxyEndpoint; 
  final Map<String, String>? customHeaders;
  final Duration? timeout;

  const ProxyConfig({
    required this.proxyEndpoint, 
    this.customHeaders,
    this.timeout,
  });
}

/// Custom Proxy Interceptor cho endpoint POST proxy
class CustomProxyInterceptor extends Interceptor {
  final String proxyEndpoint; 
  final Map<String, String>? customHeaders;
  final Duration? timeout;

  CustomProxyInterceptor({
    required this.proxyEndpoint, 
    this.customHeaders,
    this.timeout,
  });

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    if (  proxyEndpoint.isNotEmpty) {
      try {
        // Tạo payload cho proxy API
        final proxyPayload = {
          'url': options.uri.toString(),
          'method': options.method,
          'headers': {
            ...options.headers,
            ...?customHeaders,
          },
          'data': options.data ?? {},
          'params': options.queryParameters,
        };

        // Tạo request mới đến proxy endpoint
        final proxyRequest = RequestOptions(
          method: 'POST',
          path: proxyEndpoint,
          headers: {
            'accept': 'application/json',
            'Content-Type': 'application/json',
          },
          data: proxyPayload,
          connectTimeout: timeout ?? const Duration(seconds: 30),
          receiveTimeout: timeout ?? const Duration(seconds: 30),
        );

        // Thay thế request gốc bằng request đến proxy
        options.method = proxyRequest.method;
        options.path = proxyRequest.path;
        options.headers = proxyRequest.headers;
        options.data = proxyRequest.data;
        options.connectTimeout = proxyRequest.connectTimeout;
        options.receiveTimeout = proxyRequest.receiveTimeout;

        // Thêm flag để nhận biết đây là proxy request
        options.extra['isProxyRequest'] = true;
        options.extra['originalRequest'] = {
          'method': options.method,
          'url': options.uri.toString(),
          'headers': options.headers,
          'data': options.data,
          'params': options.queryParameters,
        };
      } catch (e) {
        debugPrint('Proxy interceptor error: $e');
      }
    }

    handler.next(options);
  }
}
