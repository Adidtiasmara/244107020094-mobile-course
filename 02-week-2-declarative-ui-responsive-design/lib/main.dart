
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const AcademicOverviewApp());
}

class AcademicOverviewApp extends StatefulWidget {
  const AcademicOverviewApp({super.key});

  @override
  State<AcademicOverviewApp> createState() => _AcademicOverviewAppState();
}

class _AcademicOverviewAppState extends State<AcademicOverviewApp> {
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Academic Overview',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
      ),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: AcademicOverviewPage(
        isDark: isDark,
        onThemeChanged: (value) {
          setState(() {
            isDark = value;
          });
        },
      ),
    );
  }
}

class AcademicOverviewPage extends StatelessWidget {
  const AcademicOverviewPage({
    required this.isDark,
    required this.onThemeChanged,
    super.key,
  });

  final bool isDark;
  final ValueChanged<bool> onThemeChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Academic Overview'),
        actions: [
          Semantics(
            label: 'Pengaturan tema',
            value: isDark ? 'Mode gelap aktif' : 'Mode terang aktif',
            toggled: isDark,
            child: CupertinoSwitch(
              value: isDark,
              onChanged: onThemeChanged,
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ProfileHeader(),
            const SizedBox(height: 20),
            Text(
              'Academic Summary',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            const AcademicLayout(),
          ],
        ),
      ),
    );
  }
}

class AcademicLayout extends StatelessWidget {
  const AcademicLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 700) {
          return const Column(
            children: [
              AcademicCard(
                title: 'Assignments',
                value: '8',
                icon: Icons.assignment_outlined,
              ),
              SizedBox(height: 16),
              AcademicCard(
                title: 'Attendance',
                value: '92%',
                icon: Icons.event_available_outlined,
              ),
              SizedBox(height: 16),
              AcademicCard(
                title: 'GPA',
                value: '3.75',
                icon: Icons.school_outlined,
              ),
              SizedBox(height: 16),
              AcademicCard(
                title: 'Current Week',
                value: '02',
                icon: Icons.calendar_month_outlined,
              ),
            ],
          );
        }

        return const Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: AcademicCard(
                    title: 'Assignments',
                    value: '8',
                    icon: Icons.assignment_outlined,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: AcademicCard(
                    title: 'Attendance',
                    value: '92%',
                    icon: Icons.event_available_outlined,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AcademicCard(
                    title: 'GPA',
                    value: '3.75',
                    icon: Icons.school_outlined,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: AcademicCard(
                    title: 'Current Week',
                    value: '02',
                    icon: Icons.calendar_month_outlined,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      label:
          'Profil Muhammad Firman Aditiasmara, Teknik Informatika, Semester 5',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            CircleAvatar(
              radius: 30,
              child: Icon(Icons.person),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Muhammad Firman Aditiasmara',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text('Teknik Informatika'),
                  Text('Semester 5'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AcademicCard extends StatelessWidget {
  const AcademicCard({
    required this.title,
    required this.value,
    required this.icon,
    super.key,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$title: $value',
      child: Card(
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(minHeight: 110),
          child: Row(
            children: [
              Icon(
                icon,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
