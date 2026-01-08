import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/athlete_profile_model.dart';
import '../services/profile_service.dart';

class ProfileEditPage extends StatefulWidget {
  final AthleteProfile? existingProfile;

  const ProfileEditPage({super.key, this.existingProfile});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  final ProfileService _profileService = ProfileService();

  bool _isLoading = false;
  bool _isNewProfile = true;

  // Text Controllers
  late TextEditingController _nameController;
  late TextEditingController _surnameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _cityController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late TextEditingController _availableHoursController;
  late TextEditingController _trainingDaysController;
  late TextEditingController _equipmentController;
  late TextEditingController _medicalConditionsController;
  late TextEditingController _supplementsController;

  // Date of Birth
  DateTime? _selectedDateOfBirth;

  // Gym Access
  bool _hasGymAccess = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadExistingData();
  }

  /// Initialize all text controllers
  void _initializeControllers() {
    final user = FirebaseAuth.instance.currentUser;

    _nameController = TextEditingController();
    _surnameController = TextEditingController();
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController();
    _cityController = TextEditingController();
    _weightController = TextEditingController();
    _heightController = TextEditingController();
    _availableHoursController = TextEditingController();
    _trainingDaysController = TextEditingController();
    _equipmentController = TextEditingController();
    _medicalConditionsController = TextEditingController();
    _supplementsController = TextEditingController();
  }

  /// Load existing profile data if editing
  void _loadExistingData() async {
    if (widget.existingProfile != null) {
      // Editing existing profile
      setState(() {
        _isNewProfile = false;
        final profile = widget.existingProfile!;

        _nameController.text = profile.name;
        _surnameController.text = profile.surname;
        _emailController.text = profile.email;
        _phoneController.text = profile.phone ?? '';
        _cityController.text = profile.city ?? '';
        _weightController.text = profile.weight.toString();
        _heightController.text = profile.height.toString();
        _availableHoursController.text = profile.availableHoursPerWeek
            .toString();
        _trainingDaysController.text = profile.availableTrainingDays.toString();
        _equipmentController.text = profile.equipment ?? '';
        _medicalConditionsController.text = profile.medicalConditions ?? '';
        _supplementsController.text = profile.supplements ?? '';
        _selectedDateOfBirth = profile.dateOfBirth;
        _hasGymAccess = profile.hasGymAccess;
      });
    } else {
      // Check if profile exists in database
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final existingProfile = await _profileService.getAthleteProfileByUserId(
          userId,
        );
        if (existingProfile != null) {
          setState(() {
            _isNewProfile = false;
          });
          _loadProfileData(existingProfile);
        }
      }
    }
  }

  /// Load profile data into controllers
  void _loadProfileData(AthleteProfile profile) {
    setState(() {
      _nameController.text = profile.name;
      _surnameController.text = profile.surname;
      _emailController.text = profile.email;
      _phoneController.text = profile.phone ?? '';
      _cityController.text = profile.city ?? '';
      _weightController.text = profile.weight.toString();
      _heightController.text = profile.height.toString();
      _availableHoursController.text = profile.availableHoursPerWeek.toString();
      _trainingDaysController.text = profile.availableTrainingDays.toString();
      _equipmentController.text = profile.equipment ?? '';
      _medicalConditionsController.text = profile.medicalConditions ?? '';
      _supplementsController.text = profile.supplements ?? '';
      _selectedDateOfBirth = profile.dateOfBirth;
      _hasGymAccess = profile.hasGymAccess;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _availableHoursController.dispose();
    _trainingDaysController.dispose();
    _equipmentController.dispose();
    _medicalConditionsController.dispose();
    _supplementsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(_isNewProfile ? 'Create Profile' : 'Edit Profile'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.secondary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildForm(),
    );
  }

  /// Build the form
  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Instructions
            _buildInstructions(),

            const SizedBox(height: 24),

            // Section 1: Basic Information
            _buildSectionTitle('Basic Information', Icons.person),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _nameController,
              label: 'First Name',
              hint: 'Enter your first name',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your first name';
                }
                return null;
              },
            ),
            _buildTextField(
              controller: _surnameController,
              label: 'Last Name',
              hint: 'Enter your last name',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your last name';
                }
                return null;
              },
            ),
            _buildTextField(
              controller: _emailController,
              label: 'Email',
              hint: 'your.email@example.com',
              enabled: false, // Email cannot be changed
              keyboardType: TextInputType.emailAddress,
            ),
            _buildTextField(
              controller: _phoneController,
              label: 'Phone (Optional)',
              hint: '+30 123 456 7890',
              keyboardType: TextInputType.phone,
            ),
            _buildTextField(
              controller: _cityController,
              label: 'City (Optional)',
              hint: 'Athens, Thessaloniki, etc.',
            ),
            _buildDatePicker(),

            const SizedBox(height: 24),

            // Section 2: Physical Metrics
            _buildSectionTitle('Physical Metrics', Icons.fitness_center),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _weightController,
                    label: 'Weight (kg)',
                    hint: '75',
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Invalid';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _heightController,
                    label: 'Height (cm)',
                    hint: '180',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Invalid';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Section 3: Training Availability
            _buildSectionTitle('Training Availability', Icons.calendar_today),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _availableHoursController,
                    label: 'Hours/Week',
                    hint: '10',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Invalid';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _trainingDaysController,
                    label: 'Days/Week',
                    hint: '5',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      final days = int.tryParse(value);
                      if (days == null || days < 1 || days > 7) {
                        return '1-7 days';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Section 4: Equipment & Facilities
            _buildSectionTitle('Equipment & Facilities', Icons.directions_bike),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _equipmentController,
              label: 'Equipment (Optional)',
              hint: 'Road bike, Power meter, Heart rate monitor...',
              maxLines: 3,
            ),
            _buildGymAccessSwitch(),

            const SizedBox(height: 24),

            // Section 5: Health Information
            _buildSectionTitle('Health Information', Icons.health_and_safety),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _medicalConditionsController,
              label: 'Medical Conditions (Optional)',
              hint: 'Any health issues, injuries, allergies...',
              maxLines: 3,
            ),
            _buildTextField(
              controller: _supplementsController,
              label: 'Supplements (Optional)',
              hint: 'Protein, Creatine, Vitamins...',
              maxLines: 2,
            ),

            const SizedBox(height: 32),

            // Save Button
            _buildSaveButton(),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Continuing in next file part...
  // PART 2: UI Components and Save Logic for ProfileEditPage

  /// Build instructions banner
  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Fill in your athlete profile. Fields marked with * are required.',
              style: TextStyle(color: Colors.blue.shade900, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  /// Build section title
  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  /// Build text field
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool enabled = true,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: enabled
              ? Theme.of(context).colorScheme.secondary
              : Theme.of(context).colorScheme.secondary.withOpacity(0.5),
        ),
        validator: validator,
      ),
    );
  }

  /// Build date picker for date of birth
  Widget _buildDatePicker() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _selectDateOfBirth(context),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _selectedDateOfBirth == null
                  ? Colors.red.shade300
                  : Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date of Birth *',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _selectedDateOfBirth != null
                        ? '${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.year}'
                        : 'Select your date of birth',
                    style: TextStyle(
                      fontSize: 16,
                      color: _selectedDateOfBirth != null
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.calendar_today,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Select date of birth
  Future<void> _selectDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now().subtract(
        const Duration(days: 365 * 10),
      ), // At least 10 years old
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  /// Build gym access switch
  Widget _buildGymAccessSwitch() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gym Access',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Do you have access to a gym?',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
              ],
            ),
            Switch(
              value: _hasGymAccess,
              onChanged: (value) {
                setState(() {
                  _hasGymAccess = value;
                });
              },
              activeColor: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  /// Build save button
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.secondary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          _isNewProfile ? 'Create Profile' : 'Save Changes',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  /// Save profile
  Future<void> _saveProfile() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      _showSnackBar('Please fill in all required fields', isError: true);
      return;
    }

    // Check date of birth
    if (_selectedDateOfBirth == null) {
      _showSnackBar('Please select your date of birth', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      // Check if profile exists
      final existingProfile = await _profileService.getAthleteProfileByUserId(
        user.uid,
      );

      if (existingProfile != null) {
        // Update existing profile
        final updatedProfile = existingProfile.copyWith(
          name: _nameController.text.trim(),
          surname: _surnameController.text.trim(),
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          city: _cityController.text.trim().isEmpty
              ? null
              : _cityController.text.trim(),
          dateOfBirth: _selectedDateOfBirth!,
          weight: double.parse(_weightController.text.trim()),
          height: double.parse(_heightController.text.trim()),
          availableHoursPerWeek: int.parse(
            _availableHoursController.text.trim(),
          ),
          availableTrainingDays: int.parse(_trainingDaysController.text.trim()),
          equipment: _equipmentController.text.trim().isEmpty
              ? null
              : _equipmentController.text.trim(),
          hasGymAccess: _hasGymAccess,
          medicalConditions: _medicalConditionsController.text.trim().isEmpty
              ? null
              : _medicalConditionsController.text.trim(),
          supplements: _supplementsController.text.trim().isEmpty
              ? null
              : _supplementsController.text.trim(),
          updatedAt: DateTime.now(),
        );

        await _profileService.updateAthleteProfile(updatedProfile);

        _showSnackBar('Profile updated successfully!');
      } else {
        // Create new profile
        final newProfile = AthleteProfile(
          athleteId: user.uid, // Use user ID as athlete ID
          userId: user.uid,
          name: _nameController.text.trim(),
          surname: _surnameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          city: _cityController.text.trim().isEmpty
              ? null
              : _cityController.text.trim(),
          dateOfBirth: _selectedDateOfBirth!,
          weight: double.parse(_weightController.text.trim()),
          height: double.parse(_heightController.text.trim()),
          availableHoursPerWeek: int.parse(
            _availableHoursController.text.trim(),
          ),
          availableTrainingDays: int.parse(_trainingDaysController.text.trim()),
          equipment: _equipmentController.text.trim().isEmpty
              ? null
              : _equipmentController.text.trim(),
          hasGymAccess: _hasGymAccess,
          medicalConditions: _medicalConditionsController.text.trim().isEmpty
              ? null
              : _medicalConditionsController.text.trim(),
          supplements: _supplementsController.text.trim().isEmpty
              ? null
              : _supplementsController.text.trim(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _profileService.createAthleteProfile(newProfile);

        _showSnackBar('Profile created successfully!');
      }

      // Navigate back
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error saving profile: $e');
      _showSnackBar('Error saving profile: ${e.toString()}', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Show snackbar
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

// END OF ProfileEditPage
