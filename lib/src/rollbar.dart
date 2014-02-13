library rollbar.rollbar;

import 'dart:html';
import 'dart:convert';
import 'package:stack_trace/stack_trace.dart';
import 'package:logging/logging.dart';

typedef Map<String, Object> CustomPayload();

class Rollbar {
  final Logger _logger;
  final String _accessToken;
  final Object _error;
  final CustomPayload _customPayload;
  final Trace _trace;

  Map<String, Object> get _defaultPayload {
    return {
      "access_token": _accessToken,
      "data": {
        "environment": "production",
        "body": {
          "trace": {
            "frames": _trace.frames.map((frame) {
              return {
                "filename": frame.uri.toString(),
                "lineno": frame.line,
                "method": frame.member
              };
            }).toList(),
            "exception": {
              "class": _error.runtimeType.toString(),
              "message": _error.toString()
            }
          }
        },
        "timestamp": new DateTime.now().millisecondsSinceEpoch / 1000,
        "platform": "browser",
        "language": "dart",
        "client": {
          "javascript": {
            "browser": window.navigator.userAgent,
          }
        },
        "notifier": {
          "name": "rollbar.dart",
          "version": "0.0.1"
        }
      }
    };
  }

  Map<String, Object> get _payload {
    return _deepMerge(_defaultPayload, _customPayload());
  }

  Rollbar(this._accessToken, this._error, StackTrace stackTrace, {CustomPayload customPayload, Logger logger}) :
      this._customPayload = customPayload,
      this._logger = logger,
      this._trace = new Trace.from(stackTrace);

  void send() {
    var request = new HttpRequest();
    request.open("POST", "https://api.rollbar.com/api/1/item/");
    request.setRequestHeader('Content-Type', "application/json");
    _log("Sending error report to Rollbar...");

    request.onLoad.listen((event) {
      switch(request.status) {
      case 200:
        _log("Success. The item was accepted for processing.");
        break;
      case 400:
        _log("Bad request. No JSON payload was found, or it could not be decoded.");
        break;
      case 403:
        _log("Access denied. Check your access_token.");
        break;
      case 422:
        _log("""
          Unprocessable payload. A syntactically valid JSON payload was found, but it had one or more semantic errors.
          The response will contain a "message" key describing the errors.""");
        break;
      case 429:
        _log("""
          Too Many Requests - If rate limiting is enabled for your access token,
          this return code signifies that the rate limit has been reached and the item was not processed.""");
        break;
      case 500:
        _log("Internal server error. There was an error on Rollbar's end.");
        break;
      }
    });
    request.onError.listen((event) {
      _log("Couldn't send the payload to Rollbar");
    });

    var json = JSON.encode(_payload);
    request.send(json);
  }

  void _log(String message) {
    if (_logger != null) {
      _logger.finer(message);
    }
  }

  Map<String, Object> _deepMerge(Map<String, Object> first, Map<String, Object> second) {
    var result = {};
    new List()..addAll(first.keys)..addAll(second.keys)..forEach((key) {
      if (first.containsKey(key) && !second.containsKey(key)) {
        result[key] = first[key];
      } else if (!first.containsKey(key) && second.containsKey(key)) {
        result[key] = second[key];
      } else {
        if (first[key] is Iterable && second[key] is Iterable) {
          result[key] = new List()..addAll(first[key])..addAll(second[key]);
        } else if (first[key] is Map && second[key] is Map) {
          result[key] = _deepMerge(first[key], second[key]);
        } else {
          result[key] = second[key];
        }
      }
    });
    return result;
  }
}