class MyException implements Exception {
  final String _message;

  MyException([this._message = 'Error']);

  @override
  String toString() {
    return _message;
  }
}

class ClientException extends MyException {
  ClientException(super._message);
}

class InternetConnectionException extends MyException {
  InternetConnectionException(super._message);
}
