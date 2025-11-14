import 'package:flutter/material.dart';
import 'package:myapp/services/appwrite_service.dart';
import 'package:appwrite/models.dart' as models;

class SchoolDashboardPage extends StatefulWidget {
  const SchoolDashboardPage({super.key});

  @override
  SchoolDashboardPageState createState() => SchoolDashboardPageState();
}

class SchoolDashboardPageState extends State<SchoolDashboardPage> {
  models.User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await AppwriteService.getCurrentUser();
      if (mounted) {
        setState(() {
          _currentUser = user;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _logout() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    // If user didn't confirm, return
    if (confirmed != true) return;

    try {
      setState(() => _isLoading = true);
      await AppwriteService.deleteCurrentSession();

      if (!mounted) return;

      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error logging out: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildDashboardItem({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withAlpha((0.1 * 255).round()),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Sekolah'),
        actions: [
          _isLoading
              ? const SizedBox(
                  width: 48,
                  height: 48,
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: _logout,
                  tooltip: 'Logout',
                ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              color: Theme.of(
                context,
              ).primaryColor.withAlpha((0.1 * 255).round()),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selamat datang,',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _currentUser?.name ?? 'Guru',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Determine number of columns based on screen width
                      int crossAxisCount = 2; // Default for mobile

                      if (constraints.maxWidth > 1000) {
                        crossAxisCount =
                            4; // All items in one row on large screens
                      } else if (constraints.maxWidth > 600) {
                        crossAxisCount = 3; // 3 columns on medium screens
                      }

                      return GridView.count(
                        crossAxisCount: crossAxisCount,
                        padding: const EdgeInsets.all(16),
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.0,
                        children: [
                          _buildDashboardItem(
                            title: 'Isi Survei',
                            icon: Icons.assignment,
                            color: Colors.blue,
                            onTap: () {
                              Navigator.pushNamed(context, '/survey');
                            },
                          ),
                          _buildDashboardItem(
                            title: 'Riwayat Survei',
                            icon: Icons.history,
                            color: Colors.green,
                            onTap: () {
                              Navigator.pushNamed(context, '/survey-history');
                            },
                          ),
                          _buildDashboardItem(
                            title: 'Buat Pengaduan',
                            icon: Icons.report_problem,
                            color: Colors.orange,
                            onTap: () {
                              Navigator.pushNamed(context, '/complaint');
                            },
                          ),
                          _buildDashboardItem(
                            title: 'Riwayat Pengaduan',
                            icon: Icons.history_edu,
                            color: Colors.purple,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/complaint-history',
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
