// lib/ui/screens/admin/admin_requests_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:warehouse/models/borrow_request.dart';
import 'package:warehouse/services/repositories/data_repository.dart';

class AdminRequestsScreen extends StatelessWidget {
  const AdminRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // SỬA LỖI: Thêm màu nền sáng để khắc phục lỗi nền đen.
      // Màu grey[100] là một màu nền rất phổ biến cho các trang quản trị.
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Duyệt Yêu Cầu'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<BorrowRequest>>(
        stream: DataRepository.instance.getBorrowRequests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Đã có lỗi xảy ra: ${snapshot.error}', textAlign: TextAlign.center),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_rounded, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('Không có yêu cầu nào', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                ],
              ),
            );
          }

          final requests = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(12.0),
            itemCount: requests.length,
            itemBuilder: (ctx, index) {
              return RequestCard(request: requests[index]);
            },
            separatorBuilder: (ctx, index) => const SizedBox(height: 8),
          );
        },
      ),
    );
  }
}

class RequestCard extends StatelessWidget {
  final BorrowRequest request;
  const RequestCard({super.key, required this.request});

  // ... (các hàm _showSnackBar, _showConfirmationDialog, _approveRequest, _rejectRequest giữ nguyên như trước)
  void _showSnackBar(BuildContext context, String message, {bool isError = false}) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  Future<void> _showConfirmationDialog(
      BuildContext context, {
        required String title,
        required String content,
        required VoidCallback onConfirm,
      }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
              onPressed: () {
                onConfirm();
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }

  void _approveRequest(BuildContext context) async {
    await _showConfirmationDialog(
      context,
      title: 'Duyệt Yêu Cầu?',
      content: 'Bạn có chắc chắn muốn duyệt yêu cầu mượn sách "${request.bookTitle}" của ${request.userName}?',
      onConfirm: () async {
        try {
          final issueData = {
            'userId': request.userId,
            'bookId': request.bookId,
            'bookName': request.bookTitle,
            'bookImageUrl': request.bookImage ?? '',
            'authorName': 'N/A',
            'issueDate': DateTime.now(),
            'dueDate': DateTime.now().add(const Duration(days: 30)),
            'returnDate': null,
            'status': 'DUE',
          };

          await DataRepository.instance.approveBorrowRequest(
            requestId: request.id!,
            bookId: request.bookId,
            issueData: issueData,
          );
          _showSnackBar(context, 'Đã duyệt yêu cầu thành công.');
        } catch (e) {
          _showSnackBar(context, 'Lỗi khi duyệt: ${e.toString()}', isError: true);
        }
      },
    );
  }

  void _rejectRequest(BuildContext context) async {
    await _showConfirmationDialog(
      context,
      title: 'Từ Chối Yêu Cầu?',
      content: 'Bạn có chắc chắn muốn từ chối yêu cầu này?',
      onConfirm: () async {
        try {
          await DataRepository.instance.rejectBorrowRequest(request.id!);
          _showSnackBar(context, 'Đã từ chối yêu cầu.');
        } catch (e) {
          _showSnackBar(context, 'Lỗi khi từ chối: ${e.toString()}', isError: true);
        }
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final statusInfo = _getStatusInfo(request.status);

    return Card(
      // SỬA LỖI: Đặt màu nền của Card là màu trắng để đảm bảo nó luôn nổi bật.
      color: Colors.white,
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.15),
      shape: RoundedRectangleBorder(
        // Bỏ viền bên ngoài để giao diện sạch hơn
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: request.bookImage != null && request.bookImage!.isNotEmpty
                  ? Image.network(
                request.bookImage!,
                width: 50,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(width: 50, height: 70, color: Colors.grey[200], child: const Icon(Icons.broken_image)),
              )
                  : Container(width: 50, height: 70, color: Colors.grey[200], child: const Icon(Icons.book)),
            ),
            title: Text(request.bookTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Người mượn: ${request.userName}'),
                Text('Ngày Y/C: ${DateFormat('dd/MM/yyyy, HH:mm').format(request.requestDate)}'),
              ],
            ),
            isThreeLine: true,
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 8), // Điều chỉnh padding
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatusChip(statusInfo),
                if (request.status == RequestStatus.pending)
                  _buildActionButtons(context)
                else
                  const SizedBox(height: 36)
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(_StatusInfo statusInfo) {
    return Chip(
      avatar: Icon(statusInfo.icon, color: Colors.white, size: 16),
      label: Text(statusInfo.text),
      backgroundColor: statusInfo.color,
      labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      side: BorderSide.none,
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        TextButton.icon(
          icon: const Icon(Icons.close),
          label: const Text('Từ chối'),
          onPressed: () => _rejectRequest(context),
          style: TextButton.styleFrom(foregroundColor: Colors.red.shade700),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          icon: const Icon(Icons.check, size: 18),
          label: const Text('Duyệt'),
          onPressed: () => _approveRequest(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade700,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  _StatusInfo _getStatusInfo(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return _StatusInfo('Đang chờ', Colors.orange.shade700, Icons.hourglass_top_rounded);
      case RequestStatus.approved:
        return _StatusInfo('Đã duyệt', Colors.green.shade700, Icons.check_circle_rounded);
      case RequestStatus.rejected:
        return _StatusInfo('Đã từ chối', Colors.red.shade700, Icons.cancel_rounded);
    }
  }
}

// Lớp tiện ích để chứa thông tin trạng thái
class _StatusInfo {
  final String text;
  final Color color;
  final IconData icon;

  _StatusInfo(this.text, this.color, this.icon);
}