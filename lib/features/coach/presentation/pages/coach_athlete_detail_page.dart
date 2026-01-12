import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:andreopoulos_messasing/features/profile/data/models/athlete_profile_model.dart';
import 'package:andreopoulos_messasing/features/profile/services/profile_service.dart';
import 'package:intl/intl.dart';

/// Coach Athlete Detail Page
/// Shows full athlete profile and allows coach to edit FTP/FTHR metrics
class CoachAthleteDetailPage extends StatefulWidget {
  final AthleteProfile athlete;

  const CoachAthleteDetailPage({
    super.key,
    required this.athlete,
  });

  @override
  State<CoachAthleteDetailPage> createState() => _CoachAthleteDetailPageState();
}

class _CoachAthleteDetailPageState extends State<CoachAthleteDetailPage> {
  final ProfileService _profileService = ProfileService();
  bool _isEditingMetrics = false;
  final TextEditingController _ftpController = TextEditingController();
  final TextEditingController _fthrController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _ftpController.dispose();
    _fthrController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(widget.athlete.fullName),
        backgroundColor: const Color(0xFF010F31),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with athlete avatar and basic info
            _buildHeader(context),

            const SizedBox(height: 16),

            // Performance Metrics Card (Coach editable)
            _buildPerformanceMetricsCard(context),

            const SizedBox(height: 16),

            // Basic Info Card
            _buildBasicInfoCard(context),

            const SizedBox(height: 16),

            // Physical Metrics Card
            _buildPhysicalMetricsCard(context),

            const SizedBox(height: 16),

            // Training Availability Card
            _buildTrainingAvailabilityCard(context),

            const SizedBox(height: 16),

            // Equipment & Facilities Card
            _buildEquipmentCard(context),

            const SizedBox(height: 16),

            // Health Info Card
            _buildHealthInfoCard(context),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey,
            child: Text(
              widget.athlete.name[0].toUpperCase() +
                  widget.athlete.surname[0].toUpperCase(),
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.athlete.fullName,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Age: ${widget.athlete.age} • ${widget.athlete.city ?? "No city"}',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetricsCard(BuildContext context) {
    return StreamBuilder<PerformanceMetrics?>(
      stream: _profileService.streamPerformanceMetrics(widget.athlete.athleteId),
      builder: (context, snapshot) {
        PerformanceMetrics? metrics = snapshot.data;

        // Initialize controllers with current values
        if (metrics != null && !_isEditingMetrics) {
          _ftpController.text = metrics.ftp?.toString() ?? '';
          _fthrController.text = metrics.fthr?.toString() ?? '';
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.speed,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Performance Metrics',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      if (!_isEditingMetrics)
                        IconButton(
                          icon: const Icon(Icons.edit),
                          color: Theme.of(context).colorScheme.primary,
                          onPressed: () {
                            setState(() {
                              _isEditingMetrics = true;
                            });
                          },
                        ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 8),

                  // Editable or display mode
                  if (_isEditingMetrics)
                    _buildEditMetricsForm(context, metrics)
                  else
                    _buildDisplayMetrics(context, metrics),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDisplayMetrics(BuildContext context, PerformanceMetrics? metrics) {
    return Column(
      children: [
        _buildMetricRow(
          context,
          'FTP (Functional Threshold Power)',
          metrics?.ftp != null ? '${metrics!.ftp} watts' : 'Not set',
        ),
        const SizedBox(height: 12),
        _buildMetricRow(
          context,
          'FTHR (Functional Threshold Heart Rate)',
          metrics?.fthr != null ? '${metrics!.fthr} bpm' : 'Not set',
        ),
        if (metrics?.lastUpdated != null) ...[
          const SizedBox(height: 16),
          Text(
            'Last updated: ${DateFormat('MMM dd, yyyy - HH:mm').format(metrics!.lastUpdated!)}',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.inversePrimary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEditMetricsForm(BuildContext context, PerformanceMetrics? metrics) {
    return Column(
      children: [
        TextField(
          controller: _ftpController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'FTP (watts)',
            hintText: 'Enter FTP value',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: Icon(
              Icons.speed,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _fthrController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'FTHR (bpm)',
            hintText: 'Enter FTHR value',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: Icon(
              Icons.favorite,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: _isSaving
                  ? null
                  : () {
                      setState(() {
                        _isEditingMetrics = false;
                        // Reset controllers to original values
                        _ftpController.text = metrics?.ftp?.toString() ?? '';
                        _fthrController.text = metrics?.fthr?.toString() ?? '';
                      });
                    },
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _isSaving ? null : () => _saveMetrics(metrics),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF010F31),
                foregroundColor: Colors.white,
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Save'),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _saveMetrics(PerformanceMetrics? existingMetrics) async {
    setState(() {
      _isSaving = true;
    });

    try {
      final coachId = FirebaseAuth.instance.currentUser?.uid;
      if (coachId == null) throw Exception('Not logged in');

      int? ftp = _ftpController.text.isNotEmpty
          ? int.tryParse(_ftpController.text)
          : null;
      int? fthr = _fthrController.text.isNotEmpty
          ? int.tryParse(_fthrController.text)
          : null;

      PerformanceMetrics newMetrics = PerformanceMetrics(
        metricsId: widget.athlete.athleteId,
        athleteId: widget.athlete.athleteId,
        ftp: ftp,
        fthr: fthr,
        lastUpdated: DateTime.now(),
        updatedByCoachId: coachId,
      );

      await _profileService.updatePerformanceMetrics(newMetrics);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Performance metrics updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        setState(() {
          _isEditingMetrics = false;
          _isSaving = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving metrics: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }

      setState(() {
        _isSaving = false;
      });
    }
  }

  Widget _buildMetricRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoCard(BuildContext context) {
    return _buildInfoCard(
      context,
      'Basic Information',
      Icons.person,
      [
        _buildInfoRow(context, 'Email', widget.athlete.email),
        _buildInfoRow(
          context,
          'Phone',
          widget.athlete.phone ?? 'Not provided',
        ),
        _buildInfoRow(
          context,
          'Date of Birth',
          DateFormat('MMM dd, yyyy').format(widget.athlete.dateOfBirth),
        ),
        _buildInfoRow(context, 'Age', '${widget.athlete.age} years old'),
      ],
    );
  }

  Widget _buildPhysicalMetricsCard(BuildContext context) {
    return _buildInfoCard(
      context,
      'Physical Metrics',
      Icons.fitness_center,
      [
        _buildInfoRow(context, 'Weight', '${widget.athlete.weight} kg'),
        _buildInfoRow(context, 'Height', '${widget.athlete.height} cm'),
        _buildInfoRow(
          context,
          'BMI',
          widget.athlete.bmi.toStringAsFixed(1),
        ),
      ],
    );
  }

  Widget _buildTrainingAvailabilityCard(BuildContext context) {
    return _buildInfoCard(
      context,
      'Training Availability',
      Icons.calendar_today,
      [
        _buildInfoRow(
          context,
          'Available Days/Week',
          '${widget.athlete.availableTrainingDays} days',
        ),
        _buildInfoRow(
          context,
          'Available Hours/Week',
          '${widget.athlete.availableHoursPerWeek} hours',
        ),
      ],
    );
  }

  Widget _buildEquipmentCard(BuildContext context) {
    return _buildInfoCard(
      context,
      'Equipment & Facilities',
      Icons.sports_gymnastics,
      [
        _buildInfoRow(
          context,
          'Equipment',
          widget.athlete.equipment ?? 'Not specified',
        ),
        _buildInfoRow(
          context,
          'Gym Access',
          widget.athlete.hasGymAccess ? 'Yes' : 'No',
        ),
      ],
    );
  }

  Widget _buildHealthInfoCard(BuildContext context) {
    return _buildInfoCard(
      context,
      'Health Information',
      Icons.local_hospital,
      [
        _buildInfoRow(
          context,
          'Medical Conditions',
          widget.athlete.medicalConditions ?? 'None reported',
        ),
        _buildInfoRow(
          context,
          'Supplements',
          widget.athlete.supplements ?? 'None reported',
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
