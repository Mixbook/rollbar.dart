part of rollbar;

class RollbarRequest {
  String _accessToken;
  Map<String, Object> _data;
  Logger _logger;

  RollbarRequest(this._accessToken, this._data, this._logger);

  Future<Response> send() {
    var json = JSON.encode({"access_token": _accessToken, "data": _data});

    var request = post("https://api.rollbar.com/api/1/item/",
        headers: {"Content-Type": "application/json"},
        body: json);

    return request
        ..then((request) => _logStatus(request))
        ..catchError((error) => _logError(error));
  }

  void _logStatus(Response response) {
    switch(response.statusCode) {
      case 200:
        _logger.finer("Success. The item was accepted for processing.");
        break;
      case 400:
        _logger.warning("Bad request. No JSON payload was found, or it could not be decoded.");
        break;
      case 403:
        _logger.warning("Access denied. Check your access_token.");
        break;
      case 422:
        _logger.warning("""
          Unprocessable payload. A syntactically valid JSON payload was found, but it had one or more semantic errors.
          The response will contain a "message" key describing the errors.""");
        break;
      case 429:
        _logger.warning("""
          Too Many Requests - If rate limiting is enabled for your access token,
          this return code signifies that the rate limit has been reached and the item was not processed.""");
        break;
      case 500:
        _logger.warning("Internal server error. There was an error on Rollbar's end.");
        break;
      }
  }

  void _logError(Object error) {
    _logger.warning("Couldn't send the payload to Rollbar");
  }
}