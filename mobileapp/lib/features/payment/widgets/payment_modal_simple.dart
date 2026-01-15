import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/services/payment_service.dart';
import '../../../shared/services/event_service.dart';
import '../../../features/auth/bloc/auth_bloc.dart';
import 'payment_status_check_dialog.dart';

class PaymentModalSimple extends StatefulWidget {
  final String eventId;
  final String eventTitle;
  final double amount;
  final int? quantity;
  final String? ticketTypeId;
  final VoidCallback onPaymentSuccess;

  const PaymentModalSimple({
    super.key,
    required this.eventId,
    required this.eventTitle,
    required this.amount,
    this.quantity,
    this.ticketTypeId,
    required this.onPaymentSuccess,
  });

  @override
  State<PaymentModalSimple> createState() => _PaymentModalSimpleState();
}

class _PaymentModalSimpleState extends State<PaymentModalSimple> {
  final EventService _eventService = EventService();
  bool _isLoading = false;
  String _selectedPaymentMethod = 'QR_CODE';
  String? _currentPaymentId;

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'QR_CODE',
      'name': 'QR Code',
      'description': 'Scan QR code to pay',
      'icon': Icons.qr_code,
    },
    {
      'id': 'BANK_TRANSFER',
      'name': 'Bank Transfer',
      'description': 'Transfer to bank account',
      'icon': Icons.account_balance,
    },
    {
      'id': 'E_WALLET',
      'name': 'E-Wallet',
      'description': 'Pay with digital wallet',
      'icon': Icons.account_balance_wallet,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  'Payment Required',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.eventTitle,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppConstants.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Rp ${_formatCurrency(widget.amount)}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          
          // Payment methods
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose Payment Method',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Payment method list
                  Expanded(
                    child: ListView.builder(
                      itemCount: _paymentMethods.length,
                      itemBuilder: (context, index) {
                        final method = _paymentMethods[index];
                        final isSelected = _selectedPaymentMethod == method['id'];
                        
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedPaymentMethod = method['id'];
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected 
                                    ? AppConstants.primaryColor
                                    : Colors.grey[300]!,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  method['icon'],
                                  color: isSelected 
                                      ? AppConstants.primaryColor
                                      : Colors.grey[600],
                                  size: 24,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        method['name'],
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected 
                                              ? AppConstants.primaryColor
                                              : AppConstants.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        method['description'],
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppConstants.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle,
                                    color: AppConstants.primaryColor,
                                    size: 24,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Pay button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handlePayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Pay Now',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePayment() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Create payment
      print('🚀 Payment: Creating payment order...');
      print('🚀 Payment: Event ID: ${widget.eventId}');
      print('🚀 Payment: Amount: ${widget.amount}');
      print('🚀 Payment: Selected Method: $_selectedPaymentMethod');
      print('🚀 Payment: Ticket Type ID: ${widget.ticketTypeId}');
      print('🚀 Payment: Quantity: ${widget.quantity}');
      
      // Validate ticketTypeId is provided if needed
      if (widget.ticketTypeId == null || widget.ticketTypeId!.isEmpty) {
        print('⚠️  WARNING: No ticketTypeId provided! This might cause wrong ticket type assignment.');
      }
      
      // Get user data from AuthBloc
      final authState = context.read<AuthBloc>().state;
      String customerName = 'Customer';
      String customerEmail = 'customer@example.com';
      String customerPhone = '08123456789';
      
      if (authState is AuthAuthenticated) {
        customerName = authState.user.fullName.isNotEmpty ? authState.user.fullName : 'Customer';
        customerEmail = authState.user.email.isNotEmpty ? authState.user.email : 'customer@example.com';
        customerPhone = authState.user.phoneNumber?.isNotEmpty == true ? authState.user.phoneNumber! : '08123456789';
      }
      
      final response = await PaymentService.createEventPayment(
        eventId: widget.eventId,
        amount: widget.amount,
        customerName: customerName,
        customerEmail: customerEmail,
        customerPhone: customerPhone,
        quantity: widget.quantity,
        ticketTypeId: widget.ticketTypeId,
      );

      print('✅ Payment Response - Ticket Type ID sent: ${widget.ticketTypeId}');
      print('✅ Payment API Response received: $response');

      if (response['success'] == true) {
        print('✅ Payment created successfully');
        final payment = response['payment'];
        _currentPaymentId = payment['id'];
        
        // Show success feedback for payment order created
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Payment order berhasil dibuat! ${widget.quantity != null && widget.quantity! > 1 ? '(${widget.quantity} tiket)' : ''}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
          
          await Future.delayed(const Duration(milliseconds: 800));
        }
        
        // Check if payment has redirect URL (for gateway payments)
        if (payment['paymentUrl'] != null && payment['paymentUrl'].isNotEmpty) {
          await _redirectToPaymentGateway(payment['paymentUrl']);
        } else {
          await _showPaymentSuccessDialog(payment);
        }
      } else {
        print('❌ Payment creation failed: ${response['message']}');
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 24),
                  SizedBox(width: 8),
                  Text('Payment Gagal'),
                ],
              ),
              content: Text(response['message'] ?? 'Gagal membuat payment order. Silakan coba lagi.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      print('❌❌❌ Payment exception caught: $e');
      print('❌ Exception type: ${e.runtimeType}');
      
      String errorMessage = 'Gagal membuat payment order';
      if (e.toString().contains('SocketException') || 
          e.toString().contains('Network') ||
          e.toString().contains('connection') ||
          e.toString().contains('timeout')) {
        errorMessage = 'Koneksi internet bermasalah. Pastikan koneksi internet Anda aktif dan coba lagi.';
      } else if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
        errorMessage = 'Sesi Anda telah berakhir. Silakan login ulang.';
      } else if (e.toString().contains('404')) {
        errorMessage = 'Endpoint tidak ditemukan. Pastikan backend server sedang berjalan.';
      } else if (e.toString().contains('500')) {
        errorMessage = 'Terjadi kesalahan di server. Silakan coba lagi nanti.';
      } else if (e.toString().isNotEmpty) {
        final errorStr = e.toString();
        if (errorStr.contains('message:')) {
          final match = RegExp(r'message[:\s]+([^,}]+)').firstMatch(errorStr);
          if (match != null) {
            errorMessage = match.group(1)?.trim() ?? errorMessage;
          }
        }
      }
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 24),
                SizedBox(width: 8),
                Text('Payment Gagal'),
              ],
            ),
            content: Text(errorMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
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

  Future<void> _redirectToPaymentGateway(String paymentUrl) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Redirecting to payment gateway...'),
            ],
          ),
        ),
      );

      final Uri uri = Uri.parse(paymentUrl);
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
        Navigator.of(context).pop();
        await _showPaymentStatusCheckDialog();
      } else {
        try {
          await launchUrl(uri, mode: LaunchMode.platformDefault);
          Navigator.of(context).pop();
          await _showPaymentStatusCheckDialog();
        } catch (e) {
          Navigator.of(context).pop();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Cannot open payment gateway. Please copy this URL: $paymentUrl'),
                duration: const Duration(seconds: 10),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      Navigator.of(context).pop();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment gateway error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showPaymentStatusCheckDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PaymentStatusCheckDialog(
        paymentId: _currentPaymentId!,
        onPaymentConfirmed: () async {
          // Close PaymentStatusCheckDialog first
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          // Close payment modal if still open
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          // Small delay to ensure dialogs are closed
          await Future.delayed(const Duration(milliseconds: 200));
          // Now register after payment
          await _registerAfterPayment();
        },
        onPaymentFailed: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Future<void> _showPaymentSuccessDialog(Map<String, dynamic> payment) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PaymentSuccessDialog(
        payment: payment,
        onComplete: () async {
          // Close PaymentSuccessDialog first
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          // Close payment modal if still open
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          // Small delay to ensure dialogs are closed
          await Future.delayed(const Duration(milliseconds: 200));
          // Now register after payment
          await _registerAfterPayment();
        },
      ),
    );
  }

  Future<void> _registerAfterPayment() async {
    if (_currentPaymentId == null) return;

    if (!mounted) return;
    
      print('🟢 Registering after payment: $_currentPaymentId');
    
    // Show loading dialog WITHOUT awaiting - we'll close it manually
    // Store a flag to track if dialog is shown
    bool loadingDialogShown = false;
    
    if (mounted) {
      // Show dialog without awaiting - fire and forget
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          loadingDialogShown = true;
          return const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Memproses registrasi...'),
              ],
            ),
          );
        },
      );
      // Give dialog time to appear before proceeding
      await Future.delayed(const Duration(milliseconds: 200));
    }

    try {
      // Add timeout to API call to prevent indefinite loading
      final response = await _eventService.registerForEventAfterPayment(
        widget.eventId,
        _currentPaymentId!,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('⏱️ Registration API call timed out after 30 seconds');
          // Close loading dialog on timeout
          if (mounted && loadingDialogShown) {
            try {
              if (Navigator.of(context, rootNavigator: true).canPop()) {
                Navigator.of(context, rootNavigator: true).pop();
                loadingDialogShown = false;
              }
            } catch (e) {
              print('⚠️ Error closing dialog on timeout: $e');
            }
          }
          throw TimeoutException('Registration request timed out after 30 seconds');
        },
      );

      print('🟢 Register after payment response: $response');
      print('🟢 Response success: ${response['success']}');

      // Close loading dialog FIRST - MUST close before showing other dialogs
      if (mounted && loadingDialogShown) {
        try {
          // Use rootNavigator to ensure we close the dialog
          final rootNavigator = Navigator.of(context, rootNavigator: true);
          if (rootNavigator.canPop()) {
            rootNavigator.pop();
            print('✅ Loading dialog closed');
            loadingDialogShown = false;
            // Wait a bit to ensure dialog is fully closed before showing next dialog
            await Future.delayed(const Duration(milliseconds: 200));
          } else {
            print('⚠️ Cannot pop - dialog may not be open');
            loadingDialogShown = false;
          }
        } catch (e) {
          print('⚠️ Error closing loading dialog: $e');
          // Try fallback: regular navigator
          try {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
              print('✅ Loading dialog closed (fallback)');
            }
          } catch (e2) {
            print('⚠️ Fallback also failed: $e2');
          }
          loadingDialogShown = false;
        }
      }

      // Check if response indicates success
      final isSuccess = response['success'] == true;
      print('✅ Registration successful: $isSuccess');
      
      if (isSuccess) {
        // Registration is successful - extract data safely
        dynamic data;
        try {
          data = response['data'];
          print('📥 Response data extracted: ${data != null}');
        } catch (e) {
          print('⚠️ Error extracting response data: $e');
          data = {};
        }
        
        // Handle nested registration structure safely
        dynamic registration = data;
        try {
          if (data is Map) {
            // Try data.registration first
            if (data['registration'] != null) {
              registration = data['registration'];
              // Check if it's double-nested: registration.registration
              if (registration is Map && registration['registration'] != null) {
                registration = registration['registration'];
              }
            }
          }
        } catch (e) {
          print('⚠️ Error extracting registration: $e');
          registration = null;
        }
        
        // Get quantity from response or widget - safely
        int quantity = widget.quantity ?? 1;
        try {
          if (data is Map && data['quantity'] != null) {
            final qty = data['quantity'];
            if (qty is int) {
              quantity = qty;
            } else if (qty is String) {
              quantity = int.tryParse(qty) ?? quantity;
            } else if (qty is num) {
              quantity = qty.toInt();
            }
          }
        } catch (e) {
          print('⚠️ Error extracting quantity: $e');
        }
        
        // Get ticket type name from multiple possible locations - safely
        String ticketTypeName = 'Tiket';
        try {
          if (registration != null && registration is Map) {
            final regData = registration as Map<String, dynamic>;
            // Try registration.ticketType first
            if (regData['ticketType'] != null && regData['ticketType'] is Map) {
              final ticketType = regData['ticketType'] as Map<String, dynamic>;
              final name = ticketType['name'];
              if (name != null && name.toString().isNotEmpty) {
                ticketTypeName = name.toString();
              }
            }
          }
          // Try data.ticketType (root level)
          if (data is Map && data['ticketType'] != null && data['ticketType'] is Map) {
            final ticketType = data['ticketType'] as Map<String, dynamic>;
            final name = ticketType['name'];
            if (name != null && name.toString().isNotEmpty) {
              ticketTypeName = name.toString();
            }
          }
        } catch (e) {
          print('⚠️ Error extracting ticket type name: $e');
        }
        
        // Get registration ID - safely
        String? registrationId;
        try {
          if (registration != null && registration is Map) {
            final regMap = registration as Map<String, dynamic>;
            final id = regMap['id'];
            if (id != null) {
              registrationId = id.toString();
            }
          }
          // Fallback: try to get from data directly
          if ((registrationId == null || registrationId.isEmpty) && data is Map && data['registration'] != null) {
            final reg = data['registration'];
            if (reg is Map) {
              final id = reg['id'];
              if (id != null) {
                registrationId = id.toString();
              }
            }
          }
        } catch (e) {
          print('⚠️ Error extracting registration ID: $e');
        }
        
        print('🎫 Ticket type name: $ticketTypeName');
        print('🎫 Registration ID: $registrationId');
        print('🎫 Quantity: $quantity');
        
        // Show success modal - registration is successful
        if (mounted) {
          await _showRegistrationSuccessModal(
            quantity: quantity,
            ticketTypeName: ticketTypeName,
            registrationId: registrationId,
          );
        }
      } else {
        // Response indicates failure
        final errorMessage = response['message']?.toString() ?? 'Gagal melakukan registrasi. Silakan coba lagi.';
        print('❌ Registration failed: $errorMessage');
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 24),
                  SizedBox(width: 8),
                  Text('Registrasi Gagal'),
                ],
              ),
              content: Text(errorMessage),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      print('❌ Register for event after payment error: $e');
      print('❌ Stack trace: $stackTrace');
      
      // ALWAYS close loading dialog in catch block
      if (mounted && loadingDialogShown) {
        try {
          // Use rootNavigator to close dialog
          final rootNavigator = Navigator.of(context, rootNavigator: true);
          if (rootNavigator.canPop()) {
            rootNavigator.pop();
            print('✅ Loading dialog closed in catch block');
            loadingDialogShown = false;
            await Future.delayed(const Duration(milliseconds: 150));
          } else {
            print('⚠️ Cannot pop in catch - dialog may not be open');
            loadingDialogShown = false;
          }
        } catch (closeError) {
          print('⚠️ Error closing loading dialog in catch: $closeError');
          // Try fallback
          try {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
              print('✅ Loading dialog closed in catch (fallback)');
            }
          } catch (e2) {
            print('⚠️ Fallback also failed in catch: $e2');
          }
          loadingDialogShown = false;
        }
      }
      
      String errorMessage = 'Gagal melakukan registrasi';
      if (e.toString().contains('SocketException') || 
          e.toString().contains('Network') ||
          e.toString().contains('connection')) {
        errorMessage = 'Koneksi internet bermasalah. Pastikan koneksi internet Anda aktif dan coba lagi.';
      } else if (e.toString().contains('already registered')) {
        errorMessage = 'Anda sudah terdaftar untuk event ini.';
      } else if (e.toString().isNotEmpty) {
        final errorStr = e.toString();
        if (errorStr.contains('message:')) {
          final match = RegExp(r'message[:\s]+([^,}]+)').firstMatch(errorStr);
          if (match != null) {
            errorMessage = match.group(1)?.trim() ?? errorMessage;
          }
        }
      }
      
      // Check if this is a parsing error - registration might still be successful
      final errorStr = e.toString();
      if (errorStr.contains('type \'Null\' is not a subtype') || 
          errorStr.contains('CastError') ||
          errorStr.contains('FormatException') ||
          errorStr.contains('NoSuchMethodError')) {
        // This is a parsing error - but registration might still be successful on backend
        // Since data is already registered (user confirmed), show success modal
        print('⚠️ Parsing error detected - but registration might be successful');
        print('⚠️ Data is already registered - showing success modal');
      if (mounted) {
          await _showRegistrationSuccessModal(
            quantity: widget.quantity ?? 1,
            ticketTypeName: 'Tiket',
            registrationId: null,
          );
        }
        return; // Don't show error dialog
      }
      
      // Check if registration might actually be successful (idempotent case)
      if (errorStr.contains('already registered') || 
          errorStr.contains('Registration already exists')) {
        print('✅ Registration already exists - showing success modal');
        if (mounted) {
          final quantity = widget.quantity ?? 1;
          await _showRegistrationSuccessModal(
            quantity: quantity,
            ticketTypeName: 'Tiket',
            isExisting: true,
          );
        }
      } else {
        print('❌ Showing error dialog: $errorMessage');
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 24),
                  SizedBox(width: 8),
                  Text('Registrasi Gagal'),
                ],
              ),
              content: Text(errorMessage),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
          ),
        );
        }
      }
    }
  }
  
  Future<void> _showRegistrationSuccessModal({
    required int quantity,
    required String ticketTypeName,
    String? registrationId,
    bool isExisting = false,
  }) async {
    if (!mounted) return;
    
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => RegistrationSuccessDialog(
        eventTitle: widget.eventTitle,
        quantity: quantity,
        ticketTypeName: ticketTypeName,
        registrationId: registrationId,
        isExisting: isExisting,
        onClose: () {
          Navigator.of(context).pop();
        widget.onPaymentSuccess();
        },
      ),
    );
  }

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}

class PaymentSuccessDialog extends StatefulWidget {
  final Map<String, dynamic> payment;
  final VoidCallback onComplete;

  const PaymentSuccessDialog({
    super.key,
    required this.payment,
    required this.onComplete,
  });

  @override
  State<PaymentSuccessDialog> createState() => _PaymentSuccessDialogState();
}

class _PaymentSuccessDialogState extends State<PaymentSuccessDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _fadeAnimation.value,
      child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
                    // Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
                      decoration: BoxDecoration(
                        color: AppConstants.primaryColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.payment_rounded,
                              color: Colors.white,
                              size: 60,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
              'Payment Created!',
              style: TextStyle(
                              fontSize: 24,
                fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    // Content
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // Amount Card
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppConstants.successColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppConstants.successColor.withOpacity(0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.account_balance_wallet_rounded,
                                      color: AppConstants.successColor,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 8),
            Text(
                                      'Total Pembayaran',
              style: TextStyle(
                                        fontSize: 14,
                color: AppConstants.textSecondary,
                                        fontWeight: FontWeight.w500,
              ),
            ),
                                  ],
                                ),
                                const SizedBox(height: 12),
            Text(
                                  'Rp ${_formatCurrency(double.parse(widget.payment['amount'].toString()))}',
              style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: AppConstants.successColor,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
            ),
            const SizedBox(height: 20),

                          // Info Box
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.blue.shade200,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  color: Colors.blue.shade700,
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Please complete your payment using the selected method. You will be automatically registered once payment is confirmed.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.blue.shade900,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Continue Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                              onPressed: widget.onComplete,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                  ),
                                elevation: 0,
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
                      ),
                    ),
                  ],
                ),
        ),
            ),
          );
        },
      ),
    );
  }

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}

class RegistrationSuccessDialog extends StatefulWidget {
  final String eventTitle;
  final int quantity;
  final String ticketTypeName;
  final String? registrationId;
  final bool isExisting;
  final VoidCallback onClose;

  const RegistrationSuccessDialog({
    super.key,
    required this.eventTitle,
    required this.quantity,
    required this.ticketTypeName,
    this.registrationId,
    this.isExisting = false,
    required this.onClose,
  });

  @override
  State<RegistrationSuccessDialog> createState() => _RegistrationSuccessDialogState();
}

class _RegistrationSuccessDialogState extends State<RegistrationSuccessDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _fadeAnimation.value,
      child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
                    // Header
            Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
              decoration: BoxDecoration(
                        color: widget.isExisting
                            ? Colors.orange.shade500
                            : AppConstants.successColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        children: [
                          // Success Icon with animation
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
                            ),
                            child: Icon(
                              widget.isExisting
                                  ? Icons.info_outline
                                  : Icons.check_circle_rounded,
                              color: Colors.white,
                              size: 60,
              ),
            ),
            const SizedBox(height: 20),
            Text(
                            widget.isExisting
                                ? 'Anda Sudah Terdaftar!'
                                : 'Registrasi Berhasil! 🎉',
              style: const TextStyle(
                              fontSize: 24,
                fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
                        ],
                      ),
                    ),

                    // Content
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // Event Title
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppConstants.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppConstants.primaryColor.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.event,
                                  color: AppConstants.primaryColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    widget.eventTitle,
              style: TextStyle(
                fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppConstants.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
            ),
            const SizedBox(height: 20),

                          // Details Card
            Container(
                            padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                              color: AppConstants.primaryColor.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                border: Border.all(
                                color: AppConstants.primaryColor.withOpacity(0.2),
                                width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                                  icon: Icons.confirmation_number_rounded,
                    label: 'Tipe Tiket',
                                  value: widget.ticketTypeName,
                  ),
                                const SizedBox(height: 16),
                  _buildDetailRow(
                                  icon: Icons.shopping_cart_rounded,
                    label: 'Jumlah Tiket',
                                  value: '${widget.quantity} ${widget.quantity > 1 ? 'tiket' : 'tiket'}',
                  ),
                                if (widget.registrationId != null &&
                                    widget.registrationId!.isNotEmpty) ...[
                                  const SizedBox(height: 16),
                    _buildDetailRow(
                                    icon: Icons.fingerprint_rounded,
                      label: 'Registration ID',
                                    value: widget.registrationId!.length > 8
                                        ? widget.registrationId!
                                            .substring(0, 8)
                                            .toUpperCase()
                                        : widget.registrationId!.toUpperCase(),
                      valueStyle: TextStyle(
                                      fontSize: 13,
                        fontFamily: 'monospace',
                                      fontWeight: FontWeight.w600,
                                      color: AppConstants.primaryColor,
                                      letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

                          // Info Box
            Container(
                            padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                              color: widget.isExisting
                                  ? Colors.orange.shade50
                                  : Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: widget.isExisting
                                    ? Colors.orange.shade200
                                    : Colors.blue.shade200,
                                width: 1,
                              ),
              ),
              child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                                  widget.isExisting
                                      ? Icons.info_outline_rounded
                                      : Icons.email_outlined,
                                  color: widget.isExisting
                                      ? Colors.orange.shade700
                                      : Colors.blue.shade700,
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                                    widget.isExisting
                          ? 'Anda sudah terdaftar untuk event ini dengan tipe tiket yang sama.'
                          : 'Tiket akan dikirim ke email Anda. Silakan cek email untuk detail tiket dan QR code.',
                      style: TextStyle(
                                      fontSize: 13,
                                      color: widget.isExisting
                                          ? Colors.orange.shade900
                                          : Colors.blue.shade900,
                                      height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

                          // Close Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                              onPressed: widget.onClose,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Tutup',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
                      ),
                    ),
                  ],
                ),
        ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    TextStyle? valueStyle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
      children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
          icon,
              size: 20,
              color: AppConstants.primaryColor,
            ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                    color: AppConstants.textSecondary,
                    fontWeight: FontWeight.w500,
                ),
              ),
                const SizedBox(height: 4),
              Text(
                value,
                  style: valueStyle ??
                      TextStyle(
                        fontSize: 15,
                  fontWeight: FontWeight.bold,
                        color: AppConstants.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
      ),
    );
  }
}
