class CustomException implements Exception {
  // SỬA LỖI: Thêm kiểu dữ liệu rõ ràng và cho phép null
  final String? _message;
  final String? _prefix;

  CustomException([this._message, this._prefix]);

  @override
  String toString() {
    // Thêm kiểm tra null để chuỗi hiển thị đẹp hơn
    return "${_prefix ?? ''}${_message ?? ''}";
  }
}

class FetchDataException extends CustomException {
  // SỬA LỖI: Thay đổi kiểu tham số thành String?
  FetchDataException([String? message])
      : super(message, "Error During Communication: ");
}

class BadRequestException extends CustomException {
  // SỬA LỖI: Thêm kiểu và cho phép tham số là null (String?)
  BadRequestException([String? message]) : super(message, "Invalid Request: ");
}

class UnauthorisedException extends CustomException {
  // SỬA LỖI: Thêm kiểu và cho phép tham số là null (String?)
  UnauthorisedException([String? message]) : super(message, "Unauthorised: ");
}

class InvalidInputException extends CustomException {
  // SỬA LỖI: Thay đổi kiểu tham số thành String?
  InvalidInputException([String? message]) : super(message, "Invalid Input: ");
}