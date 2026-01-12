import 'package:flutter/material.dart';

class PasswordGuidelinesPage extends StatelessWidget {
  const PasswordGuidelinesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Password Guidelines'),
        backgroundColor: const Color(0xFF010F31),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        // ← OK
        child: SingleChildScrollView(
          // ←  scroll!
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Τίτλος με emoji
              Row(
                children: [
                  const Text('🔒', style: TextStyle(fontSize: 32)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Create a Strong Password',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Εισαγωγή
              Text(
                'Για να προστατέψετε τον λογαριασμό σας, παρακαλούμε δημιουργήστε έναν ισχυρό και μοναδικό κωδικό πρόσβασης ακολουθώντας τις παρακάτω οδηγίες:',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),

              const SizedBox(height: 20),

              // Οδηγίες ως λίστα
              _buildGuideline(
                '1',
                'Ο κωδικός πρέπει να περιέχει τουλάχιστον 8 χαρακτήρες.',
                context,
              ),
              _buildGuideline(
                '2',
                'Να περιλαμβάνει τουλάχιστον ένα κεφαλαίο γράμμα (A–Z).',
                context,
              ),
              _buildGuideline(
                '3',
                'Να περιλαμβάνει τουλάχιστον ένα πεζό γράμμα (a–z).',
                context,
              ),
              _buildGuideline(
                '4',
                'Να περιλαμβάνει τουλάχιστον έναν αριθμό (0–9).',
                context,
              ),
              _buildGuideline(
                '5',
                'Να περιλαμβάνει τουλάχιστον έναν ειδικό χαρακτήρα (π.χ. ! @ # \$ % & *).',
                context,
              ),
              _buildGuideline(
                '6',
                'Μην χρησιμοποιείτε εύκολες ή προβλέψιμες λέξεις, ημερομηνίες ή ονόματα.',
                context,
              ),
              _buildGuideline(
                '7',
                'Μην επαναχρησιμοποιείτε κωδικούς που έχετε σε άλλες εφαρμογές.',
                context,
              ),

              const SizedBox(height: 30),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('💡', style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 8),
                        Text(
                          'Παράδειγμα ισχυρού κωδικού:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'T!me4_Secure@2025',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40), // Extra space στο τέλος
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget για κάθε οδηγία
  Widget _buildGuideline(String number, String text, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            // ← ΣΗΜΑΝΤΙΚΟ: Αποφεύγει overflow!
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                height: 1.4,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
