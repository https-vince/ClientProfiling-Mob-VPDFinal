import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/schedule_event.dart';
import '../../../shared/widgets/custom_app_bar.dart';

class DayClientsScreen extends StatefulWidget {
  final DateTime date;
  final List<ScheduleEvent> clients;

  /// Called after the user saves in the edit modal.
  /// [original] – unmodified client, [updated] – new client, [toDate] – new date.
  final void Function(
    ScheduleEvent original,
    ScheduleEvent updated,
    DateTime toDate,
  )? onReschedule;

  const DayClientsScreen({
    Key? key,
    required this.date,
    required this.clients,
    this.onReschedule,
  }) : super(key: key);

  @override
  State<DayClientsScreen> createState() => _DayClientsScreenState();
}

class _DayClientsScreenState extends State<DayClientsScreen> {
  late List<ScheduleEvent> _clients;

  @override
  void initState() {
    super.initState();
    // Shallow copy so local mutations don't affect the caller's list directly.
    _clients = List.from(widget.clients);
  }

  // ─── Edit modal ─────────────────────────────────────────────────────────────

  void _showEditModal(BuildContext screenContext, int index) {
    final originalClient = _clients[index];
    ScheduleType selectedStatus = originalClient.type;
    DateTime selectedDate = widget.date;

    showModalBottomSheet(
      context: screenContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
            padding:
                EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: Container(
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
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Header
                  Row(
                    children: [
                      const Icon(Icons.person_outline,
                          color: Color(0xFF2563EB), size: 18),
                      const SizedBox(width: 8),
                      const Text(
                        'EDIT CLIENT',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2563EB),
                          letterSpacing: 1.0,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.pop(modalCtx),
                        child: Icon(Icons.close,
                            color: Colors.grey[400], size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    originalClient.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  Divider(height: 28, color: Colors.grey[100]),

                  // ── Status picker ──────────────────────────────────────────
                  Text(
                    'STATUS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[500],
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ScheduleType.pending,
                      ScheduleType.tentative,
                      ScheduleType.final_,
                      ScheduleType.resolved,
                    ].map((type) {
                      final isSelected = selectedStatus == type;
                      final color = ScheduleEvent.colorForType(type);
                      final label = _labelForType(type);
                      return GestureDetector(
                        onTap: () =>
                            setModalState(() => selectedStatus = type),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? color
                                : color.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: color,
                              width: isSelected ? 0 : 1.2,
                            ),
                          ),
                          child: Text(
                            label,
                            style: TextStyle(
                              color: isSelected ? Colors.white : color,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // ── Date reschedule ────────────────────────────────────────
                  Text(
                    'RESCHEDULE DATE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[500],
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: screenContext,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020, 1, 1),
                        lastDate: DateTime(2030, 12, 31),
                        builder: (context, child) => Theme(
                          data: ThemeData.light().copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: Color(0xFF2563EB),
                            ),
                          ),
                          child: child!,
                        ),
                      );
                      if (picked != null) {
                        setModalState(() => selectedDate = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month_outlined,
                              color: Color(0xFF2563EB), size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              DateFormat('EEEE, MMMM d, yyyy')
                                  .format(selectedDate),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const Icon(Icons.edit_outlined,
                              color: Color(0xFF2563EB), size: 16),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Save button ────────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final updatedClient =
                            originalClient.copyWith(type: selectedStatus);
                        final isDateChanged =
                            selectedDate.day != widget.date.day ||
                                selectedDate.month != widget.date.month ||
                                selectedDate.year != widget.date.year;

                        // Update local list for immediate UI feedback
                        setState(() {
                          if (isDateChanged) {
                            // Client moves away – remove from this screen's list
                            _clients.removeAt(index);
                          } else {
                            // Status change only – update in place
                            _clients[index] = updatedClient;
                          }
                        });

                        // Notify CalendarScreen to sync its events map
                        widget.onReschedule
                            ?.call(originalClient, updatedClient, selectedDate);

                        Navigator.pop(modalCtx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 15,
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
      ),
    );
  }

  // ─── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEEE, MMMM d, yyyy').format(widget.date);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: const CustomAppBar(
        title: 'Day Schedule',
        showMenuButton: false,
      ),
      body: Column(
        children: [
          // Date header banner
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2563EB).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.calendar_today,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateStr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _clients.isEmpty
                            ? 'No clients scheduled'
                            : '${_clients.length} client(s) scheduled',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Client list
          Expanded(
            child: _clients.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.event_available_outlined,
                            size: 72, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'No clients scheduled for this day',
                          style:
                              TextStyle(color: Colors.grey[500], fontSize: 15),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Select another day from the calendar.',
                          style:
                              TextStyle(color: Colors.grey[400], fontSize: 13),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _clients.length,
                    itemBuilder: (context, index) =>
                        _buildClientCard(context, index),
                  ),
          ),
        ],
      ),
    );
  }

  // ─── Client card ─────────────────────────────────────────────────────────────

  Widget _buildClientCard(BuildContext context, int index) {
    final client = _clients[index];
    final label = _labelForType(client.type);
    final number = index + 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left color accent bar
              Container(width: 4, color: client.color),
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showEditModal(context, index),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: client.color.withOpacity(0.12),
                            radius: 22,
                            child: Text(
                              '$number',
                              style: TextStyle(
                                color: client.color,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  client.name,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Container(
                                      width: 7,
                                      height: 7,
                                      decoration: BoxDecoration(
                                        color: client.color,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: client.color.withOpacity(0.1),
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        label,
                                        style: TextStyle(
                                          color: client.color,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.edit_outlined,
                              size: 16, color: Colors.grey[400]),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  String _labelForType(ScheduleType type) {
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
}
