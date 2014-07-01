# rollbar.dart

A Dart plugin for Rollbar.

## Quick Start
Import rollbar.dart.

```dart
import 'package:rollbar/rollbar.dart';
```

Initialize an instance of `Rollbar` with your access token and environment.

```dart
var rollbar = new Rollbar(token, environment);
```

Log errors to Rollbar with the `Rollbar.trace()` method.

```dart
try {
  throw "Some error";
} catch (error, stackTrace) {
  rollbar.trace(error, stackTrace);
}
```

Log messages to Rollbar with the `Rollbar.message()` method.

```dart
rollbar.message("User clicked Checkout");
```

Use `Rollbar.traceErrorsInZone()` to run a block of a code in a new zone, and log any of the its uncaught errors to Rollbar. The method will catch both synchronous and asynchronous errors. This method is useful for logging all the uncaught errors in your application. See this [guide](https://www.dartlang.org/articles/zones/) for more information about zones in Dart.

```dart
rollbar.traceErrorsInZone(() {
  new Future.error("oh noes");
});
```

## Advanced features

### Configuration
The `Rollbar` constructor allows you to define data to be sent on each request to Rollbar. Use the constructor's `config` parameter to set this data.

```dart
var rollbar = new Rollbar(token, environment, config: {
  "person": {
    "id": 1,
    "username": "jimmyp",
    "email": "jimmyp@mixbook.com"
  }
})
```

### Customizing Payload Data
Methods that send data to Rollbar, `Rollbar.message()`, `Rollbar.trace()` and `Rollbar.traceErrorsInZone()` all allow you to define additional data to send to Rollbar.

```dart
rollbar.trace(error, stackTrace, otherData: {
  "custom": {
    "project_id": 5
  }
})
```

The data will be merged into the default payload. Check the
[API docs](https://rollbar.com/docs/api_items/) for all the options that Rollbar supports (section "Data Format").

### Logger

You also can provide your own logger. The plugin will write debug info to it in the 'finer' level. If no logger is provided, a default one will be used.

```dart
var logger = new Logger("mylogger");
var rollbar = new Rollbar(token, environment, logger: logger);
```

### Source Maps

Rollbar supports [source maps](https://rollbar.com/mixbook/montage-client/docs/guides_sourcemaps/) for your JavaScript stack traces.

By default, source maps are disabled, but you can enable them by setting the appropriate flags in the `Rollbar` constructor.

```dart
var rollbar = new Rollbar(token, environment, config: {
  "client": {
    "javascript": {
      "source_map_enabled": true, // required
      "code_version": "1.0", // required
      "guess_uncaught_frames": true // optional value
    }
  }
});
```

The source maps will need to be available to Rollbar. Check their [documentation](https://rollbar.com/docs/guides_sourcemaps/) for how to do this.
