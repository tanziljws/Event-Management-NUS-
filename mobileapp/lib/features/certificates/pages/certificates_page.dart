import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/bottom_navigation.dart';
import '../../../shared/services/navigation_service.dart';
import '../../../shared/services/certificate_service.dart';
import '../../../shared/models/certificate_model.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../widgets/certificates_header.dart';

class CertificatesPage extends StatefulWidget {
  const CertificatesPage({super.key});

  @override
  State<CertificatesPage> createState() => _CertificatesPageState();
}

class _CertificatesPageState extends State<CertificatesPage> {
  final CertificateService _certificateService = CertificateService();
  final TextEditingController _searchController = TextEditingController();
  List<CertificateModel> _certificates = [];
  bool _isLoading = true;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCertificates();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _loadCertificates();
  }

  Future<void> _loadCertificates() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response = await _certificateService.getUserCertificates(
        page: _currentPage,
        limit: 10,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      if (response['success'] == true) {
        final certificatesData = response['data']['certificates'] as List<dynamic>? ?? [];
        setState(() {
          _certificates = certificatesData
              .map((json) => CertificateModel.fromJson(json as Map<String, dynamic>))
              .toList();
          _totalPages = response['data']['pagination']['pages'] ?? 1;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response['message'] ?? 'Failed to load certificates';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading certificates: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return const Scaffold(
            body: Center(child: Text('Please login first')),
          );
        }

        return Scaffold(
          backgroundColor: AppConstants.backgroundColor,
          body: Column(
            children: [
              // Header dengan search bar terintegrasi
              CertificatesHeader(
                onBackPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  } else {
                    context.go('/home');
                  }
                },
                onSearchPressed: () {
                  // TODO: Implement advanced search/filter
                },
                searchController: _searchController,
                onSearchChanged: _onSearchChanged,
              ),
              
              const SizedBox(height: 8),
              
              // Content
              Expanded(
                child: _buildCertificatesList(),
              ),
            ],
          ),
          bottomNavigationBar: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              if (authState is AuthAuthenticated) {
                return BottomNavigation(currentIndex: NavigationService().currentIndex);
              }
              return const SizedBox.shrink();
            },
          ),
        );
      },
    );
  }

  Widget _buildCertificatesList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppConstants.errorColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading certificates',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppConstants.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(
                fontSize: 14,
                color: AppConstants.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadCertificates,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_certificates.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _certificates.length,
      itemBuilder: (context, index) {
        final certificate = _certificates[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 0,
          color: AppConstants.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppConstants.borderLight),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.workspace_premium,
                      color: AppConstants.warningColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            certificate.registration.event.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppConstants.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Event: ${_formatDate(certificate.registration.event.eventDate)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppConstants.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Status Badge
                    Builder(
                      builder: (context) {
                        final statusInfo = _getStatusInfo(certificate.status);
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusInfo['color'].withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                statusInfo['icon'],
                                size: 14,
                                color: statusInfo['color'],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                statusInfo['label'],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: statusInfo['color'],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Certificate Number (only if available)
                if (certificate.certificateNumber != null && certificate.certificateNumber!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.confirmation_number,
                          size: 16,
                          color: AppConstants.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'No. Sertifikat: ${certificate.certificateNumber}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppConstants.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                // Issued Date (only if available)
                if (certificate.issuedAt != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: AppConstants.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Diterbitkan: ${_formatDate(certificate.issuedAt)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppConstants.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                // Event End DateTime (if pending/ready)
                if (certificate.status != 'available' && certificate.eventEndDateTime != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 16,
                          color: AppConstants.warningColor,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Event selesai: ${_formatDateTime(certificate.eventEndDateTime)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppConstants.warningColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                // Status Message
                if (certificate.status != 'available')
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppConstants.primaryColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: AppConstants.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _getStatusInfo(certificate.status)['message'],
                            style: TextStyle(
                              fontSize: 12,
                              color: AppConstants.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                // Action Buttons
                Builder(
                  builder: (context) {
                    if (certificate.status == 'available') {
                      // Available - Show View & Download
                      return Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: certificate.certificateUrl != null && certificate.certificateUrl!.isNotEmpty
                                  ? () => _viewCertificate(certificate)
                                  : null,
                              icon: const Icon(Icons.visibility),
                              label: const Text('Lihat'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: certificate.certificateUrl != null && certificate.certificateUrl!.isNotEmpty
                                  ? () => _downloadCertificate(certificate)
                                  : null,
                              icon: const Icon(Icons.download),
                              label: const Text('Download'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppConstants.primaryColor,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      );
                    } else if (certificate.status == 'ready') {
                      // Ready - Show Generate Button
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading
                              ? null
                              : () => _generateCertificate(certificate.registration.id),
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Icon(Icons.auto_awesome),
                          label: Text(_isLoading ? 'Generating...' : 'Generate Certificate'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      );
                    } else {
                      // Pending - Show Disabled Button
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: null,
                          icon: const Icon(Icons.schedule),
                          label: const Text('Event Belum Selesai'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            foregroundColor: Colors.grey[600],
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.workspace_premium,
            size: 80,
            color: AppConstants.textMuted,
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada sertifikat',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppConstants.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Selesaikan event untuk mendapatkan sertifikat',
            style: TextStyle(
              fontSize: 14,
              color: AppConstants.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go('/events'),
            icon: const Icon(Icons.event),
            label: const Text('Lihat Events'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }


  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateTime);
      return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTime;
    }
  }

  Map<String, dynamic> _getStatusInfo(String? status) {
    switch (status) {
      case 'available':
        return {
          'label': 'Tersedia',
          'color': AppConstants.successColor,
          'icon': Icons.check_circle,
          'message': 'Sertifikat siap diunduh',
        };
      case 'ready':
        return {
          'label': 'Siap Digenerate',
          'color': AppConstants.primaryColor,
          'icon': Icons.auto_awesome,
          'message': 'Event sudah selesai, sertifikat dapat digenerate',
        };
      case 'pending':
      default:
        return {
          'label': 'Menunggu',
          'color': AppConstants.warningColor,
          'icon': Icons.schedule,
          'message': 'Event belum selesai',
        };
    }
  }

  Future<void> _generateCertificate(String registrationId) async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response = await _certificateService.generateCertificate(registrationId);

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sertifikat berhasil digenerate!'),
            backgroundColor: AppConstants.successColor,
          ),
        );
        // Reload certificates
        _loadCertificates();
      } else {
        setState(() {
          _error = response['message'] ?? 'Gagal generate sertifikat';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_error!),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generate sertifikat: $e'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _viewCertificate(CertificateModel certificate) async {
    if (certificate.certificateUrl == null || certificate.certificateUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sertifikat belum tersedia'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
      return;
    }

    try {
      final certificateUrl = _certificateService.getCertificateUrl(certificate.certificateUrl!);
      
      // Show PDF viewer
      await showDialog(
        context: context,
        builder: (context) => Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.8,
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.workspace_premium,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Sertifikat - ${certificate.registration.event.title}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // PDF Viewer
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.picture_as_pdf,
                            size: 64,
                            color: AppConstants.textMuted,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'PDF Viewer',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppConstants.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Membuka sertifikat PDF...',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppConstants.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () async {
                              Navigator.pop(context);
                              await _openCertificateInBrowser(certificateUrl);
                            },
                            icon: const Icon(Icons.open_in_browser),
                            label: const Text('Buka di Browser'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstants.primaryColor,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error membuka sertifikat: $e'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
    }
  }

  void _downloadCertificate(CertificateModel certificate) async {
    if (certificate.certificateUrl == null || certificate.certificateUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sertifikat belum tersedia'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
      return;
    }

    try {
      final certificateUrl = _certificateService.getCertificateUrl(certificate.certificateUrl!);
      await _openCertificateInBrowser(certificateUrl);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Membuka sertifikat untuk ${certificate.registration.event.title}'),
          backgroundColor: AppConstants.successColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error membuka sertifikat: $e'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
    }
  }

  Future<void> _openCertificateInBrowser(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      throw Exception('Failed to open certificate: $e');
    }
  }
}