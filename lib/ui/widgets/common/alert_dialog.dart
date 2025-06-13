import 'package:flutter/material.dart';

class AlertDialogBox extends StatelessWidget {
  final String message;

  // SỬA LỖI: Cập nhật cú pháp constructor cho đúng chuẩn null safety.
  const AlertDialogBox({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Prompt"),
      content: Text(message),
      actions: <Widget>[
        // SỬA LỖI: FlatButton đã lỗi thời, thay bằng TextButton.
        TextButton(
          child: Text(
            "Cancel",
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
              color: Theme.of(context).primaryColor,
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
