part of rollbar;

class Rollbar {
  String _accessToken;
  Map<String, Object> _config;
  Logger _logger;

  Rollbar(this._accessToken, String environment, {Map<String, Object> config, Logger logger}) {
    _logger = logger != null ? logger : _defaultLogger;

    _config = config != null ? config : {};
    _config.addAll({
      "environment": environment,
      "notifier": {
        "name": "rollbar.dart",
        "version": "0.0.1"
      }
    });
  }

  Future<HttpRequest> trace(Object error, StackTrace stackTrace, {Map<String, Object> otherData}) {
    var body = {
      "trace": {
        "frames": new Trace.from(stackTrace).frames.map((frame) {
          return {
            "filename": Uri.parse(frame.uri.toString()).path,
            "lineno": frame.line,
            "method": frame.member,
            "colno": frame.column
          };
        }).toList(),
        "exception": {
          "class": error.runtimeType.toString(),
          "message": error.toString()
        }
      }
    };

    var data = _generatePayloadData(body, otherData);
    return new RollbarRequest(_accessToken, data, _logger).send();
  }

  Future<HttpRequest> message(String messageBody, {Map<String, Object> metadata, Map<String, Object> otherData}) {
    var body = {
      "message": {
        "body": messageBody
      }
    };

    if (metadata != null) {
      body["message"].addAll(metadata);
    }

    var data = _generatePayloadData(body, otherData);
    return new RollbarRequest(_accessToken, data, _logger).send();
  }

  /// Runs [body] in its own [Zone] and reports any uncaught asynchronous or synchronous
  /// errors from the zone to Rollbar.
  ///
  /// Use [otherData] to return a map of additional data that will be attached to the
  /// payload sent to Rollbar. The returned data will attached to the payload's `data`
  /// property.
  ///
  /// The returned stream will contain futures that complete with the HTTP request for
  /// each error reported to Rollbar. The futures can be used to listen for completion
  /// or errors while calling the Rollbar API. The stream will also contain any uncaught
  /// errors originating from the zone. Use [Stream.handleError] to process these errors.
  Stream<Future<HttpRequest>> traceErrorsInZone(body(), {Map<String, Object> otherData(error, StackTrace trace)}) {
    var errors = new StreamController.broadcast();

    runZoned(body, onError: (error, stackTrace) {
      var request;

      try {
        request = trace(error, stackTrace, otherData: otherData != null ? otherData(error, stackTrace) : null);
      } catch (error, stackTrace) {
        request = trace(error, stackTrace);
      }

      errors.add(request);
      errors.addError(error, stackTrace);
    });

    return errors.stream;
  }

  Map<String, Object> _generatePayloadData(Map body, Map otherData) {
    var data = {
      "body": body,
      "timestamp": new DateTime.now().millisecondsSinceEpoch / 1000,
      "language": "dart",
      "platform": "browser"
    };

    if (otherData != null) {
      data = deepMerge(data, otherData);
    }

    return deepMerge(_config, data);
  }
}
