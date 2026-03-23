import 'package:flutter/material.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import 'package:intl/intl.dart';
import '../models/schedule_event.dart';
import 'day_clients_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen>
    with SingleTickerProviderStateMixin {
  DateTime _currentMonth = DateTime(2026, 3, 1);
  final TextEditingController _dateController = TextEditingController();
  DateTime? _selectedDay;
  bool _previewVisible = false;
  // Increments on each month change to trigger AnimatedSwitcher
  int _gridKey = 0;

  // Drag-to-reschedule state
  ScheduleEvent? _pendingDragClient;
  int? _pendingDragFromDay;

  late AnimationController _previewController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // Sample events – replace with backend data when ready
  final Map<int, List<ScheduleEvent>> events = {
    3: [
      ScheduleEvent(name: 'Juan Dela Cruz', type: ScheduleType.pending),
      ScheduleEvent(name: 'Maria Santos', type: ScheduleType.tentative),
    ],
    7: [
      ScheduleEvent(name: 'Pedro Reyes', type: ScheduleType.final_),
      ScheduleEvent(name: 'Ana Gomez', type: ScheduleType.resolved),
      ScheduleEvent(name: 'Carlos Bautista', type: ScheduleType.pending),
    ],
    12: [
      ScheduleEvent(name: 'Rosa Mendoza', type: ScheduleType.tentative),
      ScheduleEvent(name: 'Luis Torres', type: ScheduleType.pending),
      ScheduleEvent(name: 'Elena Ramos', type: ScheduleType.resolved),
      ScheduleEvent(name: 'Miguel Cruz', type: ScheduleType.final_),
    ],
    15: [
      ScheduleEvent(name: 'Patricia Lim', type: ScheduleType.resolved),
    ],
    19: [
      ScheduleEvent(name: 'Roberto Garcia', type: ScheduleType.pending),
      ScheduleEvent(name: 'Carmen Villanueva', type: ScheduleType.tentative),
      ScheduleEvent(name: 'Fernando Aquino', type: ScheduleType.final_),
    ],
    22: [
      ScheduleEvent(name: 'Isabella Santos', type: ScheduleType.pending),
      ScheduleEvent(name: 'Diego Reyes', type: ScheduleType.tentative),
    ],
    25: [
      ScheduleEvent(name: 'Sofia Castillo', type: ScheduleType.resolved),
      ScheduleEvent(name: 'Andres Morales', type: ScheduleType.pending),
      ScheduleEvent(name: 'Valentina Cruz', type: ScheduleType.final_),
      ScheduleEvent(name: 'Lucas Martinez', type: ScheduleType.tentative),
      ScheduleEvent(name: 'Camila Torres', type: ScheduleType.pending),
      ScheduleEvent(name: 'Sebastian Reyes', type: ScheduleType.resolved),
    ],
    28: [
      ScheduleEvent(name: 'Gabriela Santos', type: ScheduleType.tentative),
    ],
  };

  @override
  void initState() {
    super.initState();
    _previewController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _slideAnimation = CurvedAnimation(
      parent: _previewController,
      curve: Curves.easeOutCubic,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _previewController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _previewController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  List<DateTime> _getDaysInMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final daysInMonth = lastDay.day;

    final days = <DateTime>[];

    // Add empty days for the start of the week
    final firstWeekday =
        firstDay.weekday % 7; // Convert to 0=Sunday, 6=Saturday
    for (int i = 0; i < firstWeekday; i++) {
      days.add(firstDay.subtract(Duration(days: firstWeekday - i)));
    }

    // Add all days in the month
    for (int i = 0; i < daysInMonth; i++) {
      days.add(DateTime(month.year, month.month, i + 1));
    }

    return days;
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
      _gridKey++;
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
      _gridKey++;
    });
  }

  void _goToToday() {
    setState(() {
      _currentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
    });
  }

  void _onDayTapped(DateTime day) {
    if (day.month != _currentMonth.month) return;
    setState(() {
      _selectedDay = day;
      _previewVisible = true;
    });
    _previewController.forward(from: 0);
  }

  void _dismissPreview() {
    _previewController.reverse().then((_) {
      if (mounted) setState(() => _previewVisible = false);
    });
  }

  // ── Drag-to-reschedule helpers ──────────────────────────────────────────────

  /// Selects [client] as the active draggable and dismisses any open preview.
  void _selectClientForDrag(ScheduleEvent client, int fromDay) {
    _previewController.stop();
    setState(() {
      _previewVisible = false;
      _pendingDragClient = client;
      _pendingDragFromDay = fromDay;
    });
  }

  void _cancelDrag() {
    setState(() {
      _pendingDragClient = null;
      _pendingDragFromDay = null;
    });
  }

  /// Moves [client] from its original day to [targetDay] in the events map.
  void _dropClientOnDay(ScheduleEvent client, DateTime targetDay) {
    if (_pendingDragFromDay == null) return;
    if (targetDay.month != _currentMonth.month) return;
    setState(() {
      events[_pendingDragFromDay!]?.removeWhere((e) => e.name == client.name);
      if (events[_pendingDragFromDay!]?.isEmpty ?? false) {
        events.remove(_pendingDragFromDay!);
      }
      events.putIfAbsent(targetDay.day, () => []).add(client);
      _pendingDragClient = null;
      _pendingDragFromDay = null;
    });
  }

  void _navigateToDayClients() {
    if (_selectedDay == null) return;
    final sel = _selectedDay!;
    final dayEvents = events[sel.day] ?? [];
    _dismissPreview();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => DayClientsScreen(
          date: sel,
          clients: dayEvents,
          onReschedule: (original, updated, toDate) {
            setState(() {
              // Remove from original day
              events[sel.day]?.remove(original);
              // Add to target day (keyed by day-of-month)
              events.putIfAbsent(toDate.day, () => []).add(updated);
            });
          },
          onClientSelectForDrag: (client, fromDate) {
            _selectClientForDrag(client, fromDate.day);
          },
        ),
        transitionsBuilder: (_, animation, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final days = _getDaysInMonth(_currentMonth);
    final monthName = DateFormat('MMMM yyyy').format(_currentMonth);
    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrow = screenWidth < 380;
    final isMobile = screenWidth < 600;
    final horizontalMargin = isMobile ? 12.0 : 16.0;
    final sectionPadding = isMobile ? 14.0 : 20.0;
    final dayCellHeight = isNarrow ? 86.0 : (isMobile ? 98.0 : 120.0);
    final childAspectRatio =
        ((screenWidth - (horizontalMargin * 2)) / 7) / dayCellHeight;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: CustomAppBar(
        title: 'Calendar',
        showMenuButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.today_outlined, color: Colors.black87),
            onPressed: _goToToday,
            tooltip: 'Go to Today',
          ),
        ],
      ),
      drawer: const AppDrawer(currentPage: 'Calendar'),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: _pendingDragClient != null ? 120 : 0,
            ),
            child: Column(
              children: [
                SizedBox(height: isMobile ? 12 : 20),

                // Legend
                Container(
                  margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
                  padding: EdgeInsets.all(sectionPadding),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF87CEEB).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.info_outline,
                              size: 20,
                              color: Color(0xFF87CEEB),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Schedule Legend',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: isMobile ? 10 : 20,
                        runSpacing: 12,
                        children: [
                          _buildLegendItem('PENDING', const Color(0xFF5B9BD5)),
                          _buildLegendItem(
                              'TENTATIVE', const Color(0xFFFFA500)),
                          _buildLegendItem('FINAL', const Color(0xFFE74C3C)),
                          _buildLegendItem('RESOLVED', const Color(0xFF27AE60)),
                          _buildLegendItem('*NAME', const Color(0xFF95A5A6)),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isMobile ? 12 : 20),

                // Search and Controls
                Container(
                  margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
                  padding: EdgeInsets.all(isMobile ? 12 : 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: isMobile
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildDateSearchField(),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(child: _buildGoButton(compact: true)),
                                const SizedBox(width: 8),
                                Expanded(
                                    child: _buildClearButton(compact: true)),
                              ],
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(child: _buildDateSearchField()),
                            const SizedBox(width: 10),
                            _buildGoButton(),
                            const SizedBox(width: 8),
                            _buildClearButton(),
                          ],
                        ),
                ),
                SizedBox(height: isMobile ? 12 : 20),

                // Calendar Container
                Container(
                  margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Calendar Header
                      Container(
                        padding: EdgeInsets.all(sectionPadding),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF87CEEB).withOpacity(0.1),
                              Colors.white,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: isMobile
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF87CEEB)
                                              .withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: const Icon(
                                          Icons.calendar_month,
                                          color: Color(0xFF87CEEB),
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          monthName,
                                          style: TextStyle(
                                            fontSize: isNarrow ? 16 : 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: _buildMonthNavButtons(),
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF87CEEB)
                                              .withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: const Icon(
                                          Icons.calendar_month,
                                          color: Color(0xFF87CEEB),
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        monthName,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                  _buildMonthNavButtons(),
                                ],
                              ),
                      ),

                      // Days of week header
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          border: Border(
                            top: BorderSide(color: Colors.grey[200]!),
                            bottom: BorderSide(color: Colors.grey[200]!),
                          ),
                        ),
                        child: Row(
                          children:
                              ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                                  .map((day) => Expanded(
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            vertical: isMobile ? 10 : 12,
                                          ),
                                          child: Text(
                                            day,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: isNarrow ? 11 : 13,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey[700],
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                      ))
                                  .toList(),
                        ),
                      ),

                      // Calendar grid — AnimatedSwitcher fades on month change
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, anim) => FadeTransition(
                          opacity: CurvedAnimation(
                              parent: anim, curve: Curves.easeOut),
                          child: child,
                        ),
                        child: GridView.builder(
                          key: ValueKey(_gridKey),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7,
                            childAspectRatio: childAspectRatio,
                          ),
                          itemCount: days.length,
                          itemBuilder: (context, index) {
                            final day = days[index];
                            final isCurrentMonth =
                                day.month == _currentMonth.month;
                            final isToday = day.year == DateTime.now().year &&
                                day.month == DateTime.now().month &&
                                day.day == DateTime.now().day;
                            final dayEvents =
                                isCurrentMonth ? events[day.day] ?? [] : [];

                            final isSelected = _selectedDay != null &&
                                _selectedDay!.day == day.day &&
                                _selectedDay!.month == day.month &&
                                _selectedDay!.year == day.year;
                            return DragTarget<ScheduleEvent>(
                              onWillAccept: (data) =>
                                  _pendingDragClient != null && isCurrentMonth,
                              onAccept: (data) => _dropClientOnDay(data, day),
                              builder: (ctx, candidateData, rejectedData) {
                                final isDropTarget =
                                    candidateData.isNotEmpty && isCurrentMonth;
                                return GestureDetector(
                                  onTap: () => _onDayTapped(day),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    curve: Curves.easeInOut,
                                    decoration: BoxDecoration(
                                      color: isDropTarget
                                          ? const Color(0xFF2563EB)
                                              .withOpacity(0.18)
                                          : isSelected
                                              ? const Color(0xFF2563EB)
                                                  .withOpacity(0.06)
                                              : isToday
                                                  ? const Color(0xFF87CEEB)
                                                      .withOpacity(0.05)
                                                  : Colors.transparent,
                                      border: Border(
                                        right: BorderSide(
                                          color: isDropTarget
                                              ? const Color(0xFF2563EB)
                                                  .withOpacity(0.35)
                                              : Colors.grey[100]!,
                                          width: 0.5,
                                        ),
                                        bottom: BorderSide(
                                          color: isDropTarget
                                              ? const Color(0xFF2563EB)
                                                  .withOpacity(0.35)
                                              : Colors.grey[100]!,
                                          width: 0.5,
                                        ),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding:
                                              EdgeInsets.all(isNarrow ? 4 : 6),
                                          child: Container(
                                            width: isToday
                                                ? (isNarrow ? 24 : 28)
                                                : null,
                                            height: isToday
                                                ? (isNarrow ? 24 : 28)
                                                : null,
                                            decoration: isToday
                                                ? BoxDecoration(
                                                    color:
                                                        const Color(0xFF2563EB),
                                                    shape: BoxShape.circle,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: const Color(
                                                                0xFF2563EB)
                                                            .withOpacity(0.3),
                                                        blurRadius: 8,
                                                        offset:
                                                            const Offset(0, 2),
                                                      ),
                                                    ],
                                                  )
                                                : null,
                                            alignment: Alignment.center,
                                            child: Text(
                                              isCurrentMonth
                                                  ? day.day.toString()
                                                  : '',
                                              style: TextStyle(
                                                fontSize: isNarrow ? 10 : 12,
                                                fontWeight: isToday
                                                    ? FontWeight.bold
                                                    : FontWeight.w600,
                                                color: isToday
                                                    ? Colors.white
                                                    : isCurrentMonth
                                                        ? Colors.black87
                                                        : Colors.grey[400],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: SingleChildScrollView(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: isNarrow ? 2 : 3,
                                            ),
                                            child: Column(
                                              children: dayEvents
                                                  .take(5)
                                                  .map((event) {
                                                return Container(
                                                  margin: const EdgeInsets.only(
                                                      bottom: 3),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 4,
                                                    vertical: 3,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: event.color,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: event.color
                                                            .withOpacity(0.3),
                                                        blurRadius: 2,
                                                        offset:
                                                            const Offset(0, 1),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        width: 4,
                                                        height: 4,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white
                                                              .withOpacity(0.8),
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 3),
                                                      Expanded(
                                                        child: Text(
                                                          event.name,
                                                          style: TextStyle(
                                                            fontSize: isNarrow
                                                                ? 6.5
                                                                : 7,
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            height: 1.2,
                                                          ),
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        ),
                                        if (dayEvents.length > 5)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 4,
                                              left: 4,
                                              right: 4,
                                            ),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[200],
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                '+${dayEvents.length - 5} more',
                                                style: TextStyle(
                                                  fontSize: isNarrow ? 6 : 7,
                                                  color: Colors.grey[700],
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isMobile ? 12 : 20),
              ],
            ),
          ),
          if (_previewVisible) ..._buildOverlay(),
          if (_pendingDragClient != null) _buildDragPanel(),
        ],
      ),
    );
  }

  List<Widget> _buildOverlay() {
    return [
      GestureDetector(
        onTap: _dismissPreview,
        child: Container(color: Colors.black45),
      ),
      Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(_slideAnimation),
            child: _buildPreviewCard(),
          ),
        ),
      ),
    ];
  }

  Widget _buildPreviewCard() {
    final sel = _selectedDay!;
    final dayEvents = events[sel.day] ?? [];
    final dateStr = DateFormat('EEEE, MMMM d, yyyy').format(sel);
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 24,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        MediaQuery.of(context).size.width < 600 ? 16 : 24,
        16,
        MediaQuery.of(context).size.width < 600 ? 16 : 24,
        28,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            children: [
              const Icon(Icons.calendar_today,
                  color: Color(0xFF2563EB), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  dateStr,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _dismissPreview,
                child: Icon(Icons.close, color: Colors.grey[400], size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (dayEvents.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No clients scheduled for this day.',
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
              ),
            )
          else
            ..._buildPreviewEventList(dayEvents),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _navigateToDayClients,
              icon: const Icon(Icons.people_outline, size: 18),
              label: const Text('View All Clients'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPreviewEventList(List<ScheduleEvent> dayEvents) {
    return [
      Text(
        '${dayEvents.length} client(s) scheduled',
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 10),
      ...dayEvents.take(3).map(
            (e) => _buildPreviewEventRow(
              e,
              onSelectForDrag: () => _selectClientForDrag(e, _selectedDay!.day),
            ),
          ),
      if (dayEvents.length > 3)
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '+${dayEvents.length - 3} more clients',
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
        ),
    ];
  }

  Widget _buildPreviewEventRow(
    ScheduleEvent event, {
    VoidCallback? onSelectForDrag,
  }) {
    return GestureDetector(
      onTap: onSelectForDrag,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: event.color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: event.color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: event.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                event.name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: event.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _scheduleTypeLabel(event.type),
                style: TextStyle(
                  fontSize: 10,
                  color: event.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (onSelectForDrag != null) ...[
              const SizedBox(width: 6),
              Icon(Icons.open_with, size: 14, color: Colors.grey[400])
            ],
          ],
        ),
      ),
    );
  }

  String _scheduleTypeLabel(ScheduleType type) {
    switch (type) {
      case ScheduleType.pending:
        return 'PENDING';
      case ScheduleType.tentative:
        return 'TENTATIVE';
      case ScheduleType.final_:
        return 'FINAL';
      case ScheduleType.resolved:
        return 'RESOLVED';
      case ScheduleType.name:
        return 'NAME';
    }
  }

  Widget _buildDateSearchField() {
    return TextField(
      controller: _dateController,
      decoration: InputDecoration(
        hintText: 'Search by date (dd/mm/yyyy)',
        hintStyle: TextStyle(
          color: Colors.grey[400],
          fontSize: 13,
        ),
        prefixIcon: Icon(
          Icons.calendar_today,
          size: 20,
          color: Colors.grey[600],
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color(0xFF2563EB),
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildGoButton({bool compact = false}) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 14 : 20,
          vertical: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 0,
      ),
      child: const Text(
        'Go',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildClearButton({bool compact = false}) {
    return OutlinedButton(
      onPressed: () {
        _dateController.clear();
      },
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 12 : 16,
          vertical: 14,
        ),
        side: BorderSide(color: Colors.grey[300]!),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        'Clear',
        style: TextStyle(
          color: Colors.grey[700],
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildMonthNavButtons() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: _previousMonth,
            icon: const Icon(Icons.chevron_left),
            iconSize: 24,
            color: const Color(0xFF2563EB),
            tooltip: 'Previous Month',
          ),
          Container(
            width: 1,
            height: 24,
            color: Colors.grey[200],
          ),
          IconButton(
            onPressed: _nextMonth,
            icon: const Icon(Icons.chevron_right),
            iconSize: 24,
            color: const Color(0xFF2563EB),
            tooltip: 'Next Month',
          ),
        ],
      ),
    );
  }

  // ── Drag panel ─────────────────────────────────────────────────────────────

  Widget _buildDragPanel() {
    final client = _pendingDragClient!;
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                const Icon(
                  Icons.drag_indicator,
                  color: Color(0xFF2563EB),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Drag to a new date',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _cancelDrag,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Hold and drag the chip below onto any calendar date:',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
            const SizedBox(height: 10),
            Draggable<ScheduleEvent>(
              data: client,
              feedback: Material(
                elevation: 6,
                borderRadius: BorderRadius.circular(8),
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: client.color,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: client.color.withOpacity(0.45),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.person, color: Colors.white, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        client.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              childWhenDragging: Opacity(
                opacity: 0.4,
                child: _buildClientChip(client),
              ),
              child: _buildClientChip(client),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientChip(ScheduleEvent client) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: client.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: client.color.withOpacity(0.45),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: client.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            client.name,
            style: TextStyle(
              color: client.color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.drag_handle,
            size: 16,
            color: client.color.withOpacity(0.6),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
