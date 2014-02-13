library rollbar;

import 'dart:async';
import 'package:logging/logging.dart';
import 'package:rollbar/src/rollbar.dart';

install(String accessToken, body(), {Map<String, Object> customPayload(), Logger logger}) {
  var result;
  if (customPayload == null) {
    customPayload = () => {};
  }
  runZoned(() {
    result = body();
  }, onError: (error, stackTrace) {
    try {
      var rollbar = new Rollbar(accessToken, error, stackTrace, customPayload: customPayload, logger: logger);
      rollbar.send();
      // TODO: Find way to rethrow an error with preserved stack trace
    } catch (e) {
      if (logger != null) {
        logger.finer("Exception happened while trying to send error to Rollbar: $e");
      }
    }
    print("Uncaught Error: $error");
    print("Stack Trace:");
    print(stackTrace);
  });
  return result;
}
