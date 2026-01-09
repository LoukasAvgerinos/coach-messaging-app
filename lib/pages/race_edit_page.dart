import 'package:flutter/material.dart';
import '../models/race_model.dart';
import '../services/profile_service.dart';

/// Race Edit Page - Add or edit a race
/// If race parameter is null, creates a new race
/// If race parameter is provided, edits existing race
class RaceEditPage extends StatefulWidget {
  final String athleteId; // Required: athlete ID
  final Race? race; // null = create new, not null = edit existing

  const RaceEditPage({
    super.key,
    required this.athleteId,
    this.race,
  });

  @override
  State<RaceEditPage> createState() => _RaceEditPageState();
}

class _RaceEditPageState extends State<RaceEditPage> {
  final _formKey = GlobalKey<FormState>();
  final ProfileService _profileService = ProfileService();

  // Form controllers
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _distanceController;
  late TextEditingController _notesController;

  // Form values
  DateTime? _selectedDate;
  String _selectedType = RaceTypes.roadRace;
  String _selectedPriority = RacePriorities.c;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing data if editing
    if (widget.race != null) {
      _nameController = TextEditingController(text: widget.race!.raceName);
      _locationController = TextEditingController(text: widget.race!.location ?? '');
      _distanceController = TextEditingController(text: widget.race!.distance ?? '');
      _notesController = TextEditingController(text: widget.race!.notes ?? '');
      _selectedDate = widget.race!.raceDate;
      _selectedType = widget.race!.raceType;
      _selectedPriority = widget.race!.priority;
    } else {
      _nameController = TextEditingController();
      _locationController = TextEditingController();
      _distanceController = TextEditingController();
      _notesController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _distanceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.race != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Race' : 'Add New Race'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Race Name (REQUIRED)
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Race Name *',
                  hintText: 'e.g., Tour of Larissa',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.event),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter race name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Date Picker (REQUIRED)
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Race Date *',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.calendar_today),
                    errorText: _selectedDate == null && _formKey.currentState?.validate() == false
                        ? 'Please select a date'
                        : null,
                  ),
                  child: Text(
                    _selectedDate != null
                        ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                        : 'Tap to select date',
                    style: TextStyle(
                      color: _selectedDate != null
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Race Type Dropdown (REQUIRED)
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Race Type *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.directions_bike),
                ),
                items: RaceTypes.all.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select race type';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Priority Selector (REQUIRED)
              _buildPrioritySelector(),

              const SizedBox(height: 16),

              // Location (Optional)
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location (Optional)',
                  hintText: 'e.g., Larissa, Greece',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),

              const SizedBox(height: 16),

              // Distance (Optional)
              TextFormField(
                controller: _distanceController,
                decoration: const InputDecoration(
                  labelText: 'Distance (Optional)',
                  hintText: 'e.g., 120km, Half Marathon',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.straighten),
                ),
              ),

              const SizedBox(height: 16),

              // Notes (Optional)
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  hintText: 'Add any additional details...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
              ),

              const SizedBox(height: 24),

              // Save Button
              ElevatedButton(
                onPressed: _isLoading ? null : _saveRace,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.secondary,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        isEditing ? 'Update Race' : 'Create Race',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),

              const SizedBox(height: 16),

              // Required fields note
              Text(
                '* Required fields',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.inversePrimary,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build priority selector with color-coded buttons
  Widget _buildPrioritySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Priority *',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildPriorityButton(
                'A',
                'Goal Race',
                Colors.red,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildPriorityButton(
                'B',
                'Important',
                Colors.orange,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildPriorityButton(
                'C',
                'Training',
                Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          _getPriorityDescription(_selectedPriority),
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.inversePrimary,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  /// Build individual priority button
  Widget _buildPriorityButton(String priority, String label, Color color) {
    final isSelected = _selectedPriority == priority;

    return OutlinedButton(
      onPressed: () {
        setState(() {
          _selectedPriority = priority;
        });
      },
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? color.withOpacity(0.2) : null,
        side: BorderSide(
          color: isSelected ? color : Colors.grey,
          width: isSelected ? 2 : 1,
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Column(
        children: [
          Text(
            priority,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isSelected ? color : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  /// Get priority description
  String _getPriorityDescription(String priority) {
    switch (priority) {
      case 'A':
        return 'Peak race of the season (1-3 per year)';
      case 'B':
        return 'Important preparation race';
      case 'C':
        return 'Training race (lower priority)';
      default:
        return '';
    }
  }

  /// Select date from date picker
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 730)), // 2 years ahead
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// Save race (create or update)
  Future<void> _saveRace() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check if date is selected
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a race date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final isEditing = widget.race != null;

      // Create Race object
      Race race = Race(
        raceId: widget.race?.raceId ??
            'race_${widget.athleteId}_${DateTime.now().millisecondsSinceEpoch}',
        athleteId: widget.athleteId,
        raceName: _nameController.text.trim(),
        raceDate: _selectedDate!,
        raceType: _selectedType,
        priority: _selectedPriority,
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        distance: _distanceController.text.trim().isEmpty
            ? null
            : _distanceController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        status: widget.race?.status ?? 'upcoming',
        result: widget.race?.result,
        createdAt: widget.race?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (isEditing) {
        // Update existing race
        await _profileService.updateRace(race);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Race updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        // Create new race
        await _profileService.createRace(race);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Race created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
