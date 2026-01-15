import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../../shared/services/switch_account_service.dart';
import '../../../shared/widgets/switch_account_splash.dart';
import '../../../core/constants/api_constants.dart';
import 'dashboard_greeting.dart';

class DashboardHeader extends StatelessWidget {
  final AuthAuthenticated authState;

  const DashboardHeader({
    super.key,
    required this.authState,
  });

  void _performSwitch(BuildContext context, bool isInParticipantMode) async {
    try {
             if (isInParticipantMode) {
               await SwitchAccountService.switchToOrganizer();
               ScaffoldMessenger.of(context).showSnackBar(
                 const SnackBar(
                   content: Text('Switched to Organizer Mode'),
                   backgroundColor: Colors.green,
                   duration: Duration(seconds: 2),
                 ),
               );
             } else {
               await SwitchAccountService.switchToParticipant();
               ScaffoldMessenger.of(context).showSnackBar(
                 const SnackBar(
                   content: Text('Switched to Participant Mode'),
                   backgroundColor: Colors.blue,
                   duration: Duration(seconds: 2),
                 ),
               );
             }
      
      // Navigate to home to refresh the UI
      context.go('/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Failed to switch account: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Profile Avatar
          _buildProfileAvatar(authState.user),
          const SizedBox(width: 16),
          
          // Profile Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DashboardGreeting(userName: authState.user.fullName),
                const SizedBox(height: 8),
                Text(
                  authState.user.email,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    FutureBuilder<String>(
                      future: SwitchAccountService.getCurrentRoleDisplayName(authState.user),
                      builder: (context, snapshot) {
                        final displayName = snapshot.data ?? 'Participant';
                        final currentRole = displayName.contains('Organizer') ? 'ORGANIZER' : 'PARTICIPANT';
                        
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getRoleColor(currentRole).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            displayName,
                            style: TextStyle(
                              color: _getRoleColor(currentRole),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
                    ),
                    FutureBuilder<bool>(
                      future: SwitchAccountService.isInOrganizerMode(),
                      builder: (context, snapshot) {
                        final isInOrganizerMode = snapshot.data ?? false;
                        
                        if (authState.user.role == 'ORGANIZER' && authState.user.verificationStatus != null && isInOrganizerMode) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getVerificationStatusColor(authState.user.verificationStatus!).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _getVerificationStatusIcon(authState.user.verificationStatus!),
                                      size: 12,
                                      color: _getVerificationStatusColor(authState.user.verificationStatus!),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _getVerificationStatusText(authState.user.verificationStatus!),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: _getVerificationStatusColor(authState.user.verificationStatus!),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // More Actions Menu
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'switch_account' && authState.user.role == 'ORGANIZER' && authState.user.verificationStatus == 'APPROVED') {
                final isInParticipantMode = await SwitchAccountService.isInParticipantMode();
                
                       // Show splash screen - full screen
                       Navigator.of(context).push(
                         PageRouteBuilder(
                           pageBuilder: (context, animation, secondaryAnimation) => SwitchAccountSplash(
                             message: isInParticipantMode 
                                 ? 'Switching to Organizer Mode...' 
                                 : 'Switching to Participant Mode...',
                             onComplete: () {
                               Navigator.of(context).pop(); // Close splash screen
                               
                               // Perform the actual switch
                               _performSwitch(context, isInParticipantMode);
                             },
                           ),
                           transitionDuration: Duration.zero,
                           reverseTransitionDuration: Duration.zero,
                           opaque: true,
                           barrierDismissible: false,
                         ),
                       );
              } else if (value == 'settings') {
                // TODO: Navigate to settings
              }
            },
            itemBuilder: (context) => [
              if (authState.user.role == 'ORGANIZER' && authState.user.verificationStatus == 'APPROVED')
                PopupMenuItem<String>(
                  value: 'switch_account',
                  child: FutureBuilder<bool>(
                    future: SwitchAccountService.isInParticipantMode(),
                    builder: (context, snapshot) {
                      final isInParticipantMode = snapshot.data ?? true;
                      return Row(
                        children: [
                          Icon(
                            isInParticipantMode ? Icons.business : Icons.person,
                            color: isInParticipantMode ? const Color(0xFF10B981) : const Color(0xFF2563EB),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(isInParticipantMode ? 'Switch to Organizer' : 'Switch to Participant'),
                        ],
                      );
                    },
                  ),
                ),
              const PopupMenuItem<String>(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings_outlined, color: Color(0xFF64748B), size: 20),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
            ],
            icon: const Icon(
              Icons.more_vert,
              color: Color(0xFF64748B),
            ),
            tooltip: 'More actions',
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toUpperCase()) {
      case 'ORGANIZER':
        return const Color(0xFF10B981); // Green
      case 'PARTICIPANT':
        return const Color(0xFF2563EB); // Blue
      case 'ADMIN':
        return const Color(0xFFEF4444); // Red
      default:
        return const Color(0xFF64748B); // Gray
    }
  }

  Color _getVerificationStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return const Color(0xFF10B981); // Green
      case 'PENDING':
        return const Color(0xFFF59E0B); // Orange
      case 'REJECTED':
        return const Color(0xFFEF4444); // Red
      default:
        return const Color(0xFF64748B); // Gray
    }
  }

  IconData _getVerificationStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return Icons.check_circle;
      case 'PENDING':
        return Icons.pending;
      case 'REJECTED':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String _getVerificationStatusText(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return 'Verified';
      case 'PENDING':
        return 'Pending';
      case 'REJECTED':
        return 'Rejected';
      default:
        return 'Unknown';
    }
  }

  String _getImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    
    // If already full URL, return as is
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    
    // If starts with /, it's a relative path
    if (url.startsWith('/')) {
      return '${ApiConstants.fileBaseUrl}$url';
    }
    
    // Otherwise, prepend base URL with /
    return '${ApiConstants.fileBaseUrl}/$url';
  }

  Widget _buildProfileAvatar(dynamic user) {
    final profilePictureUrl = user.profilePicture;
    final imageUrl = profilePictureUrl != null && profilePictureUrl.isNotEmpty
        ? _getImageUrl(profilePictureUrl)
        : null;

    debugPrint('📸 Dashboard - Profile picture URL: $profilePictureUrl');
    debugPrint('📸 Dashboard - Final image URL: $imageUrl');

    return CircleAvatar(
      radius: 30,
      backgroundColor: const Color(0xFF2563EB).withOpacity(0.1),
      backgroundImage: imageUrl != null && imageUrl.isNotEmpty
          ? NetworkImage(imageUrl) as ImageProvider?
          : null,
      onBackgroundImageError: (exception, stackTrace) {
        // Handle image loading error - will show fallback icon
        debugPrint('❌ Dashboard - Error loading profile image: $exception');
        debugPrint('❌ Dashboard - Image URL was: $imageUrl');
      },
      child: imageUrl == null || imageUrl.isEmpty
          ? Icon(
              Icons.person,
              color: const Color(0xFF2563EB),
              size: 32,
            )
          : null,
    );
  }
}
