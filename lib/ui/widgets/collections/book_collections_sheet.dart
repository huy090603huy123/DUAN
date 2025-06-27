import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warehouse/models/book.dart';
import 'package:warehouse/services/repositories/data_repository.dart';

// Các imports cần thiết
import '../../../providers/publishes_provider.dart';
import '../../../providers/statistics_provider.dart';
import '../../../utils/helper.dart';
import 'book_collections_list.dart';

class BookCollectionsSheet extends StatelessWidget {
  const BookCollectionsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    // Cung cấp các provider cần thiết cho widget này.
    return ChangeNotifierProvider<StatisticsProvider>(
      create: (_) => StatisticsProvider(dataRepository: DataRepository.instance),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        // Dùng SingleChildScrollView để nội dung dài hơn màn hình có thể cuộn được
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Helper.hPadding),
                child: Text(
                  'Bảng điều khiển',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildStatsGrid(context),
              const SizedBox(height: 32),

              // *** THÊM MỚI: Biểu đồ đường (Line Chart) ***
              _buildBorrowTrendChart(context),

              const SizedBox(height: 32),
              _buildGenrePieChart(context),
              const SizedBox(height: 32),
              _buildTopBorrowedChart(context),
              const SizedBox(height: 32),
              _buildBookLists(context),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget con để xây dựng lưới thống kê
  Widget _buildStatsGrid(BuildContext context) {
    return Consumer<StatisticsProvider>(
      builder: (context, statsProvider, _) {
        final stats = statsProvider.stats;
        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          padding: EdgeInsets.symmetric(horizontal: Helper.hPadding),
          childAspectRatio: 1.8,
          children: [
            _buildStatCard(context: context, title: 'Tổng thiết bị', value: stats.totalInventory.toString(), icon: Icons.inventory_2_outlined, color: Colors.blue),
            _buildStatCard(context: context, title: 'Đang mượn', value: stats.currentlyBorrowed.toString(), icon: Icons.person_pin_circle_outlined, color: Colors.orange),
            _buildStatCard(context: context, title: 'Trả hôm nay', value: stats.returnedToday.toString(), icon: Icons.task_alt_outlined, color: Colors.green),
            _buildStatCard(context: context, title: 'Trễ hạn', value: stats.overdue.toString(), icon: Icons.warning_amber_rounded, color: Colors.red),
          ],
        );
      },
    );
  }

  /// Widget con để xây dựng biểu đồ đường thống kê lượt mượn
  Widget _buildBorrowTrendChart(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Helper.hPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lượt mượn theo thời gian',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Consumer<StatisticsProvider>(
            builder: (context, provider, _) {
              return Column(
                children: [
                  // Các nút chuyển đổi Ngày/Tuần/Tháng
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTimeRangeButton(context, provider, '7 ngày', ChartTimeRange.daily),
                      const SizedBox(width: 8),
                      _buildTimeRangeButton(context, provider, '4 tuần', ChartTimeRange.weekly),
                      const SizedBox(width: 8),
                      _buildTimeRangeButton(context, provider, '6 tháng', ChartTimeRange.monthly),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Biểu đồ
                  SizedBox(
                    height: 180,
                    child: provider.stats.borrowTrend.isEmpty
                        ? const Center(child: Text("Không có dữ liệu lượt mượn."))
                        : CustomPaint(
                      painter: _LineChartPainter(
                        data: provider.stats.borrowTrend,
                        lineColor: Theme.of(context).primaryColor,
                      ),
                      size: Size.infinite,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRangeButton(BuildContext context, StatisticsProvider provider, String text, ChartTimeRange range) {
    final bool isSelected = provider.currentTimeRange == range;
    return GestureDetector(
      onTap: () => provider.setTimeRange(range),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Theme.of(context).primaryColor)
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Widget con để xây dựng biểu đồ tròn với chú thích bên dưới
  Widget _buildGenrePieChart(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Helper.hPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tỉ lệ loại thiết bị đang được mượn',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Consumer<StatisticsProvider>(
            builder: (context, statsProvider, _) {
              final stats = statsProvider.stats;
              final genreStats = stats.borrowedByGenre;
              final totalBorrowed = stats.currentlyBorrowed;

              if (genreStats.isEmpty) {
                return const SizedBox(
                  height: 160,
                  child: Center(
                    child: Text('Chưa có thiết bị nào đang được mượn.'),
                  ),
                );
              }
              return Column(
                children: [
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: CustomPaint(
                      painter: _PieChartPainter(data: genreStats),
                      child: Center(
                        child: Text(
                          '$totalBorrowed\nđang mượn',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: genreStats.map((stat) {
                      final percentage = totalBorrowed > 0
                          ? (stat.count / totalBorrowed * 100).toStringAsFixed(1)
                          : "0.0";
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            Container(width: 12, height: 12, color: stat.color),
                            const SizedBox(width: 8),
                            Text('${stat.genreName} (${stat.count} - $percentage%)'),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // --- Các widget con khác không thay đổi ---
  Widget _buildStatCard({ required BuildContext context, required String title, required String value, required IconData icon, required Color color, }) {
    return Container( decoration: BoxDecoration( color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.3)), ), padding: const EdgeInsets.all(16), child: Column( crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [ Row( mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [ Flexible( child: Text( title, style: TextStyle( color: color, fontWeight: FontWeight.w600, fontSize: 14, ), overflow: TextOverflow.ellipsis, ), ), Icon(icon, color: color, size: 24), ], ), Text( value, style: TextStyle( color: color, fontWeight: FontWeight.bold, fontSize: 28, ), ), ], ), );
  }
  Widget _buildTopBorrowedChart(BuildContext context) {
    return Padding( padding: EdgeInsets.symmetric(horizontal: Helper.hPadding), child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [ Text( 'Thiết bị được mượn nhiều nhất', style: Theme.of(context).textTheme.titleLarge?.copyWith( fontWeight: FontWeight.bold, ), ), const SizedBox(height: 16), Consumer<StatisticsProvider>( builder: (context, statsProvider, _) { final topBooks = statsProvider.stats.topBorrowedBooks; if (topBooks.isEmpty) { return const SizedBox( height: 150, child: Center( child: Text('Chưa có dữ liệu thống kê.'), ), ); } final maxCount = topBooks.isNotEmpty ? topBooks.map((e) => e.borrowCount).reduce((a, b) => a > b ? a : b) : 1; return Column( children: topBooks.map((book) { return _buildChartBar( context: context, label: book.bookName, value: book.borrowCount, maxValue: maxCount, ); }).toList(), ); }, ), ], ), );
  }
  Widget _buildChartBar({ required BuildContext context, required String label, required int value, required int maxValue, }) {
    final ratio = maxValue > 0 ? value / maxValue : 0.0; return Padding( padding: const EdgeInsets.symmetric(vertical: 6.0), child: Row( children: [ SizedBox( width: 100, child: Text( label, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500), ), ), const SizedBox(width: 8), Expanded( child: ClipRRect( borderRadius: BorderRadius.circular(5), child: Stack( children: [ Container( height: 20, decoration: BoxDecoration( color: Colors.grey.shade200, ), ), LayoutBuilder( builder: (ctx, constraints) { return AnimatedContainer( duration: const Duration(milliseconds: 500), curve: Curves.easeInOut, width: constraints.maxWidth * ratio, height: 20, decoration: BoxDecoration( color: Theme.of(context).primaryColor, ), ); }, ), ], ), ), ), const SizedBox(width: 8), SizedBox( width: 30, child: Text( value.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.right, ), ), ], ), );
  }
  Widget _buildBookLists(BuildContext context) {
    final publishesProvider = Provider.of<PublishesProvider>(context, listen: false); return Column( crossAxisAlignment: CrossAxisAlignment.start, children: [ Padding( padding: EdgeInsets.symmetric(horizontal: Helper.hPadding), child: Text( 'Mới phát hành', style: Theme.of(context).textTheme.titleLarge?.copyWith( color: Theme.of(context).primaryColor, ), ), ), const SizedBox(height: 8), StreamBuilder<List<Book>>( stream: publishesProvider.getTop5NewBooks(), builder: (context, snapshot) { if (snapshot.connectionState == ConnectionState.waiting) { return const SizedBox(height: 260, child: Center(child: CircularProgressIndicator())); } if (snapshot.hasError) { return SizedBox(height: 260, child: Center(child: Text('Lỗi: ${snapshot.error}'))); } if (!snapshot.hasData || snapshot.data!.isEmpty) { return const SizedBox(height: 260, child: Center(child: Text('Không có sách mới.'))); } final books = snapshot.data!; return BookCollectionList(books: books); }, ), const SizedBox(height: 24), Padding( padding: EdgeInsets.symmetric(horizontal: Helper.hPadding), child: Text( 'Đánh giá cao nhất', style: Theme.of(context).textTheme.titleLarge?.copyWith( color: Theme.of(context).primaryColor, ), ), ), const SizedBox(height: 8), StreamBuilder<List<Book>>( stream: publishesProvider.getTop5RatedBooks(), builder: (context, snapshot) { if (snapshot.connectionState == ConnectionState.waiting) { return const SizedBox(height: 260, child: Center(child: CircularProgressIndicator())); } if (snapshot.hasError) { return SizedBox(height: 260, child: Center(child: Text('Lỗi: ${snapshot.error}'))); } if (!snapshot.hasData || snapshot.data!.isEmpty) { return const SizedBox(height: 260, child: Center(child: Text('Chưa có sách nào được đánh giá.'))); } final books = snapshot.data!; return BookCollectionList(books: books); }, ), const SizedBox(height: 24), ], );
  }
}

// Lớp Painter tùy chỉnh để vẽ biểu đồ tròn
class _PieChartPainter extends CustomPainter {
  final List<GenreStat> data;
  _PieChartPainter({required this.data});
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final total = data.fold<int>(0, (sum, item) => sum + item.count);
    if (total == 0) return;
    double startAngle = -pi / 2;
    for (final stat in data) {
      final sweepAngle = (stat.count / total) * 2 * pi;
      final paint = Paint()..color = stat.color;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle, true, paint);
      startAngle += sweepAngle;
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Lớp Painter tùy chỉnh để vẽ biểu đồ đường
class _LineChartPainter extends CustomPainter {
  final List<TimeDataPoint> data;
  final Color lineColor;
  _LineChartPainter({required this.data, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final double bottomPadding = 20;
    final double leftPadding = 30;
    final double graphWidth = size.width - leftPadding;
    final double graphHeight = size.height - bottomPadding;

    final maxValue = data.map((d) => d.value).reduce(max).toDouble();
    if (maxValue == 0) return;

    final xStep = graphWidth / (data.length > 1 ? data.length - 1 : 1);
    final yStep = graphHeight / maxValue;

    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [lineColor.withOpacity(0.3), lineColor.withOpacity(0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    path.moveTo(leftPadding, graphHeight - (data.first.value * yStep));
    for (int i = 1; i < data.length; i++) {
      path.lineTo(leftPadding + (i * xStep), graphHeight - (data[i].value * yStep));
    }
    canvas.drawPath(path, linePaint);

    // Vẽ vùng tô bóng dưới đường
    final fillPath = Path.from(path);
    fillPath.lineTo(leftPadding + ((data.length - 1) * xStep), graphHeight);
    fillPath.lineTo(leftPadding, graphHeight);
    fillPath.close();
    canvas.drawPath(fillPath, fillPaint);

    // Vẽ các điểm
    for (int i = 0; i < data.length; i++) {
      final x = leftPadding + (i * xStep);
      final y = graphHeight - (data[i].value * yStep);
      canvas.drawCircle(Offset(x, y), 5, Paint()..color = lineColor);
      canvas.drawCircle(Offset(x, y), 3, Paint()..color = Colors.white);

      // Vẽ nhãn trục X
      final textSpan = TextSpan(
        text: data[i].label,
        style: const TextStyle(color: Colors.black54, fontSize: 10),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, size.height - bottomPadding + 5));
    }
  }

  @override
  bool shouldRepaint(_LineChartPainter oldDelegate) => true;
}
