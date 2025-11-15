import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/export_service.dart';
import '../utils/constants.dart';
import '../widgets/custom_appbar.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool _isExporting = false;

  Future<void> _exportToExcel() async {
    setState(() => _isExporting = true);
    try {
      final filePath = await ExportService.exportToExcel();
      await ExportService.shareFile(filePath);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Excel dosyası oluşturuldu ve paylaşıldı'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _exportToPDF() async {
    setState(() => _isExporting = true);
    try {
      final filePath = await ExportService.exportToPDF();
      await ExportService.shareFile(filePath);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF dosyası oluşturuldu ve paylaşıldı'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _backupDatabase() async {
    setState(() => _isExporting = true);
    try {
      final backupPath = await ExportService.backupDatabase();
      await ExportService.shareFile(backupPath);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veritabanı yedeklendi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _restoreDatabase() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['db'],
    );

    if (result == null || result.files.single.path == null) {
      return;
    }

    final filePath = result.files.single.path!;

    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Veritabanını Geri Yükle'),
        content: const Text(
          'Mevcut veritabanı silinecek ve seçilen yedek yüklenecek. Bu işlem geri alınamaz. Devam etmek istediğinize emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Geri Yükle'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isExporting = true);
    try {
      await ExportService.restoreDatabase(filePath);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veritabanı geri yüklendi. Uygulamayı yeniden başlatın.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Raporlar ve Yedekleme',
      ),
      body: _isExporting
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Export Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dışa Aktarma',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        _ReportActionCard(
                          icon: Icons.table_chart,
                          title: 'Excel\'e Aktar',
                          description: 'Tüm ürün listesini Excel formatında dışa aktar',
                          color: AppConstants.successColor,
                          onTap: _exportToExcel,
                        ),
                        const SizedBox(height: 12),
                        _ReportActionCard(
                          icon: Icons.picture_as_pdf,
                          title: 'PDF Rapor Oluştur',
                          description: 'Stok raporunu PDF formatında oluştur',
                          color: AppConstants.errorColor,
                          onTap: _exportToPDF,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Backup Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Yedekleme',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        _ReportActionCard(
                          icon: Icons.backup,
                          title: 'Veritabanını Yedekle',
                          description: 'Tüm verilerinizin yedeğini alın',
                          color: AppConstants.primaryColor,
                          onTap: _backupDatabase,
                        ),
                        const SizedBox(height: 12),
                        _ReportActionCard(
                          icon: Icons.restore,
                          title: 'Veritabanını Geri Yükle',
                          description: 'Daha önce aldığınız yedeği geri yükleyin',
                          color: AppConstants.warningColor,
                          onTap: _restoreDatabase,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Info Card
                Card(
                  color: Colors.blue.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.blue),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Dışa aktarılan dosyalar paylaşım menüsü ile başka uygulamalara gönderilebilir.',
                            style: TextStyle(color: Colors.blue[900]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _ReportActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _ReportActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color),
          ],
        ),
      ),
    );
  }
}

