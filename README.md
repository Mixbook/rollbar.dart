# rollbar.dart

A Dart plugin for Rollbar.com

## Quick Start
Import rollbar.dart.

```
import "package:rollbar/rollbar.dart" as rollbar;
```

Then wrap your main entrypoint into `rollbar.install`:

```dart
void main() {
  rollbar.install("your_access_token", () {
    var app = new App();
    app.run();
  });
}
```

That's it!

## Advanced features

### Custom Payload

If you want, you can send any additional data to Rollbar, or overwrite the defaults the package sends.
Just pass it as an additional argument to rollbar.install. E.g. you may want to pass the current user info:

```dart
var app;
rollbar.install("your_access_token", () {
  app = new App();
  app.run();
}, customPayload: () {
  return {"data": {"person": {"id": app.user.id, "email": app.user.email}}};
});
```

This will be merged into the default payload. You can send any additional data you want, just check the
[API docs](https://rollbar.com/docs/api_items/) to know your options
(section "Data Format").

### Logger

You also can provide your logger, then the plugin will write some debug info to it in 'finer' level

```dart
rollbar.install("your_access_token", () {
  var app = new App();
  app.run();
}, logger: Logger.root);
```

### Source Maps

By default, source maps support is enabled, but you need to specify a version of uploaded source maps.
You can do that this way:

```dart
var app;
rollbar.install("your_access_token", () {
  app = new App();
  app.run();
}, sourceMapsCodeVersion: () => app.version);
```

Or you can disable source maps at all:

```dart
var app;
rollbar.install("your_access_token", () {
  app = new App();
  app.run();
}, areSourceMapsEnabled: false);
```

You still have to upload source maps by yourself when you deploy your app, with the same version
as you specified in `sourceMapsCodeVersion`. Check [source maps docs](https://rollbar.com/docs/guides_sourcemaps/)
for more information.

### Custom Error code

If you want to execute some custom code when exception happens you can pass a function to onError argument:

```dart
rollbar.install("your_access_token", () {
  var app = new App();
  app.run();
}, onError: (error, StackTrace stackTrace) {
  // do something with error and/or stackTrace
});
```
