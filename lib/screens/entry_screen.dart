import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/activity.dart';
import '../providers/activity_provider.dart';
import '../theme/app_theme.dart';

class EntryScreen extends StatefulWidget {
  const EntryScreen({super.key});

  @override
  State<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _activityNameController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedSegment = Activity.segmentFromHour(TimeOfDay.now().hour);
  String _selectedCategory = Activity.categories.first;
  double _timeSpent = 1.0;
  double _moneySpent = 0;
  int _satisfaction = 3;
  int _energyImpact = 0;
  int _stressImpact = 0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _activityNameController.dispose();
    super.dispose();
  }

  void _onTimeChanged(TimeOfDay time) {
    setState(() {
      _selectedTime = time;
      _selectedSegment = Activity.segmentFromHour(time.hour);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final activity = Activity(
      date: _selectedDate,
      startTime:
          '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}:00',
      timeSegment: _selectedSegment,
      category: _selectedCategory,
      activityName: _activityNameController.text.trim(),
      timeSpent: _timeSpent,
      moneySpent: _moneySpent,
      satisfaction: _satisfaction,
      energyImpact: _energyImpact,
      stressImpact: _stressImpact,
    );

    final provider = context.read<ActivityProvider>();
    final success = await provider.addActivity(activity);

    setState(() => _isSubmitting = false);

    if (success && mounted) {
      _resetForm();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Text('Activity logged successfully'),
            ],
          ),
          backgroundColor: AppTheme.success,
          duration: const Duration(seconds: 2),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${provider.error ?? "Unknown error"}'),
          backgroundColor: AppTheme.danger,
        ),
      );
    }
  }

  void _resetForm() {
    _activityNameController.clear();
    setState(() {
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();
      _selectedSegment = Activity.segmentFromHour(TimeOfDay.now().hour);
      _selectedCategory = Activity.categories.first;
      _timeSpent = 1.0;
      _moneySpent = 0;
      _satisfaction = 3;
      _energyImpact = 0;
      _stressImpact = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Activity'),
        actions: [
          TextButton.icon(
            onPressed: _resetForm,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Reset'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            // ── Date & Time Row ─────────────────────────────
            _buildSectionLabel('When'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildDatePicker()),
                const SizedBox(width: 12),
                Expanded(child: _buildTimePicker()),
              ],
            ),
            const SizedBox(height: 12),
            _buildTimeSegmentChips(),

            const SizedBox(height: 28),

            // ── Category ────────────────────────────────────
            _buildSectionLabel('Category'),
            const SizedBox(height: 8),
            _buildCategorySelector(),

            const SizedBox(height: 28),

            // ── Activity Name ───────────────────────────────
            _buildSectionLabel('Activity Name'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _activityNameController,
              decoration: const InputDecoration(
                hintText: 'e.g. Data Structures lecture, Morning run...',
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter activity name' : null,
            ),

            const SizedBox(height: 28),

            // ── Time & Money ────────────────────────────────
            _buildSectionLabel('Investment'),
            const SizedBox(height: 12),
            _buildSliderTile(
              label: 'Time Spent',
              value: '${_timeSpent.toStringAsFixed(1)} hrs',
              icon: Icons.schedule_rounded,
              slider: Slider(
                value: _timeSpent,
                min: 0.5,
                max: 12,
                divisions: 23,
                activeColor: AppTheme.primary,
                onChanged: (v) => setState(() => _timeSpent = v),
              ),
            ),
            const SizedBox(height: 8),
            _buildSliderTile(
              label: 'Money Spent',
              value: '₹${_moneySpent.toInt()}',
              icon: Icons.currency_rupee_rounded,
              slider: Slider(
                value: _moneySpent,
                min: 0,
                max: 5000,
                divisions: 100,
                activeColor: AppTheme.success,
                onChanged: (v) => setState(() => _moneySpent = v),
              ),
            ),

            const SizedBox(height: 28),

            // ── Satisfaction ────────────────────────────────
            _buildSectionLabel('Satisfaction'),
            const SizedBox(height: 8),
            _buildStarRating(),

            const SizedBox(height: 28),

            // ── Energy & Stress ─────────────────────────────
            _buildSectionLabel('Impact'),
            const SizedBox(height: 12),
            _buildImpactSlider(
              label: 'Energy',
              value: _energyImpact,
              lowEmoji: '😴',
              highEmoji: '⚡',
              color: AppTheme.warning,
              onChanged: (v) => setState(() => _energyImpact = v),
            ),
            const SizedBox(height: 16),
            _buildImpactSlider(
              label: 'Stress',
              value: _stressImpact,
              lowEmoji: '😌',
              highEmoji: '😰',
              color: AppTheme.danger,
              onChanged: (v) => setState(() => _stressImpact = v),
            ),

            const SizedBox(height: 36),

            // ── Submit ──────────────────────────────────────
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_rounded, size: 20),
                          SizedBox(width: 8),
                          Text('Log Activity'),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Builders ───────────────────────────────────────────────────

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
            letterSpacing: 0.5,
          ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2024),
          lastDate: DateTime.now(),
        );
        if (date != null) setState(() => _selectedDate = date);
      },
      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.border),
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          color: AppTheme.surfaceVariant,
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded,
                size: 18, color: AppTheme.textSecondary),
            const SizedBox(width: 10),
            Text(
              DateFormat('MMM d, yyyy').format(_selectedDate),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    return InkWell(
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: _selectedTime,
        );
        if (time != null) _onTimeChanged(time);
      },
      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.border),
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          color: AppTheme.surfaceVariant,
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time_rounded,
                size: 18, color: AppTheme.textSecondary),
            const SizedBox(width: 10),
            Text(
              _selectedTime.format(context),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSegmentChips() {
    const segmentIcons = {
      'Morning': Icons.wb_sunny_rounded,
      'Afternoon': Icons.wb_cloudy_rounded,
      'Evening': Icons.nights_stay_rounded,
      'Night': Icons.dark_mode_rounded,
    };

    return Row(
      children: Activity.timeSegments.map((segment) {
        final isSelected = segment == _selectedSegment;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: segment != Activity.timeSegments.last ? 8 : 0,
            ),
            child: ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    segmentIcons[segment],
                    size: 14,
                    color: isSelected
                        ? AppTheme.primary
                        : AppTheme.textTertiary,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      segment,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: isSelected
                            ? AppTheme.primary
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) setState(() => _selectedSegment = segment);
              },
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategorySelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: Activity.categories.map((category) {
        final isSelected = category == _selectedCategory;
        final color = AppTheme.categoryColors[category] ?? AppTheme.primary;
        final icon = AppTheme.categoryIcons[category] ?? Icons.bolt_rounded;

        return ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: isSelected ? color : AppTheme.textTertiary),
              const SizedBox(width: 6),
              Text(
                category,
                style: TextStyle(
                  color: isSelected ? color : AppTheme.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
          selected: isSelected,
          selectedColor: color.withValues(alpha: 0.1),
          side: BorderSide(
            color: isSelected ? color.withValues(alpha: 0.3) : AppTheme.border,
          ),
          onSelected: (selected) {
            if (selected) setState(() => _selectedCategory = category);
          },
        );
      }).toList(),
    );
  }

  Widget _buildSliderTile({
    required String label,
    required String value,
    required IconData icon,
    required Slider slider,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
      decoration: AppTheme.cardDecoration,
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppTheme.textSecondary),
              const SizedBox(width: 10),
              Text(label, style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontFeatures: [const FontFeature.tabularFigures()],
                      ),
                ),
              ),
            ],
          ),
          slider,
        ],
      ),
    );
  }

  Widget _buildStarRating() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: AppTheme.cardDecoration,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (index) {
          final starValue = index + 1;
          return GestureDetector(
            onTap: () => setState(() => _satisfaction = starValue),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: AnimatedScale(
                scale: _satisfaction >= starValue ? 1.15 : 1.0,
                duration: const Duration(milliseconds: 150),
                child: Icon(
                  _satisfaction >= starValue
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  size: 36,
                  color: _satisfaction >= starValue
                      ? AppTheme.warning
                      : AppTheme.textTertiary,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildImpactSlider({
    required String label,
    required int value,
    required String lowEmoji,
    required String highEmoji,
    required Color color,
    required ValueChanged<int> onChanged,
  }) {
    final labels = ['-2', '-1', '0', '+1', '+2'];
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  labels[value + 2],
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(lowEmoji, style: const TextStyle(fontSize: 20)),
              Expanded(
                child: Slider(
                  value: value.toDouble(),
                  min: -2,
                  max: 2,
                  divisions: 4,
                  activeColor: color,
                  inactiveColor: color.withValues(alpha: 0.15),
                  onChanged: (v) => onChanged(v.round()),
                ),
              ),
              Text(highEmoji, style: const TextStyle(fontSize: 20)),
            ],
          ),
        ],
      ),
    );
  }
}
