import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hoople_mobile_app/core/utils/format_number.dart';
import 'package:hoople_mobile_app/models/event_model.dart';

class PaymentSheet extends StatefulWidget {
  final EventModel event;
  final Color prominentColor;

  const PaymentSheet({
    super.key,
    required this.event,
    required this.prominentColor,
  });

  @override
  State<PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<PaymentSheet> {
  String _selectedMethod = 'VA'; // 'VA', 'Transfer', 'QRIS'
  String _selectedBank = 'BCA';

  final Map<String, Map<String, String>> _bankData = {
    'BCA': {
      'name': 'BCA Virtual Account',
      'number': '8077708123456789',
      'instruction':
          '1. Login to m-BCA\n2. Select Transfer > BCA Virtual Account\n3. Enter the VA number\n4. Confirm and Pay',
      'logo': 'assets/images/bca_logo.png', // Mockup logo path
    },
    'Mandiri': {
      'name': 'Mandiri Virtual Account',
      'number': '8870808123456789',
      'instruction':
          '1. Login to Livin\' by Mandiri\n2. Select Pay > Multi Payment\n3. Select Service Provider\n4. Enter VA number',
      'logo': 'assets/images/mandiri_logo.png',
    },
    'BNI': {
      'name': 'BNI Virtual Account',
      'number': '9880008123456789',
      'instruction':
          '1. Login to BNI Mobile Banking\n2. Select Transfer > Virtual Account Billing\n3. Enter VA number\n4. Confirm and Pay',
      'logo': 'assets/images/bni_logo.png',
    },
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        Navigator.pop(context);
      },
      child: Material(
        color: colorScheme.surface,
        borderRadius: SmoothBorderRadius.only(
          topLeft: const SmoothRadius(cornerRadius: 32, cornerSmoothing: 0.6),
          topRight: const SmoothRadius(
            cornerRadius: 32,
            cornerSmoothing: 0.6,
          ),
        ),
        child: SafeArea(
          top: false,
          child: Container(
            decoration: ShapeDecoration(
              color: colorScheme.surface,
              shape: SmoothRectangleBorder(
                borderRadius: SmoothBorderRadius.only(
                  topLeft: const SmoothRadius(
                    cornerRadius: 32,
                    cornerSmoothing: 0.6,
                  ),
                  topRight: const SmoothRadius(
                    cornerRadius: 32,
                    cornerSmoothing: 0.6,
                  ),
                ),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Stack(
              children: [
                ListView(
                  physics: const ClampingScrollPhysics(),
                  children: [
                    // Center(
                    //   child: Container(
                    //     width: 40,
                    //     height: 4,
                    //     decoration: BoxDecoration(
                    //       color: Colors.white24,
                    //       borderRadius: BorderRadius.circular(2),
                    //     ),
                    //   ),
                    // ),
                    // const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Payment",
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -1,
                                ),
                              ),
                              Text(
                                "Registration Fee - ${widget.event.name}",
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.textTheme.bodyMedium?.color
                                      ?.withValues(
                                        alpha: 0.5,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: widget.prominentColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: widget.prominentColor.withValues(
                                alpha: 0.2,
                              ),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            formatNumber(widget.event.price.toInt()),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: widget.prominentColor,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'sf-pro',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildMethodSelector(),
                    const SizedBox(height: 24),
                    if (_selectedMethod == 'VA') _buildVAPayment(),
                    if (_selectedMethod == 'Transfer') _buildTransferPayment(),
                    if (_selectedMethod == 'QRIS') _buildQRISPayment(),
                    const SizedBox(height: 32),

                    // Spacer(),
                    const SizedBox(height: 80),
                  ],
                ),
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // showExpressiveSnack(
                        //   context: context,
                        //   message: 'Payment processing...',
                        //   icon: Icons.access_time,
                        // );
                        // showExpressiveSnack(
                        //   context: context,
                        //   message: 'Joined successfully',
                        //   icon: Icons.check,
                        // );
                        // ScaffoldMessenger.of(context).showSnackBar(
                        //   const SnackBar(
                        //     behavior: SnackBarBehavior.floating,
                        //     content: Text("Payment processing..."),
                        //   ),
                        // );
                        // ScaffoldMessenger.of(context).showSnackBar(
                        //   const SnackBar(
                        //     behavior: SnackBarBehavior.floating,
                        //     content: Text("Joined successfully!"),
                        //   ),
                        // );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.prominentColor,
                        foregroundColor: Colors.white,
                        elevation: 8,
                        shadowColor: widget.prominentColor.withValues(
                          alpha: 0.5,
                        ),
                        shape: SmoothRectangleBorder(
                          borderRadius: SmoothBorderRadius(
                            cornerRadius: 20,
                            cornerSmoothing: 0.6,
                          ),
                        ),
                      ),
                      child: const Text(
                        "Confirm Payment",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMethodSelector() {
    return Row(
      children: [
        _buildMethodTab('VA', Icons.account_balance_wallet_rounded),
        const SizedBox(width: 12),
        _buildMethodTab('Transfer', Icons.account_balance_rounded),
        const SizedBox(width: 12),
        _buildMethodTab('QRIS', Icons.qr_code_scanner_rounded),
      ],
    );
  }

  Widget _buildMethodTab(String method, IconData icon) {
    bool isSelected = _selectedMethod == method;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedMethod = method),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? widget.prominentColor
                : widget.prominentColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: widget.prominentColor.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? Colors.white
                    : Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                size: 24,
              ),
              const SizedBox(height: 6),
              Text(
                method,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : Theme.of(
                          context,
                        ).textTheme.bodyMedium?.color?.withValues(
                          alpha: 0.5,
                        ),
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVAPayment() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select Bank",
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 12),
        Row(
          children: _bankData.keys
              .map((bank) => _buildBankCircle(bank))
              .toList(),
        ),
        const SizedBox(height: 24),
        _buildPaymentInfoCard(
          _bankData[_selectedBank]!['name']!,
          _bankData[_selectedBank]!['number']!,
          _bankData[_selectedBank]!['instruction']!,
        ),
      ],
    );
  }

  Widget _buildBankCircle(String bank) {
    bool isSelected = _selectedBank == bank;
    return GestureDetector(
      onTap: () => setState(() => _selectedBank = bank),
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: isSelected
              ? widget.prominentColor
              : widget.prominentColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: widget.prominentColor.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            bank,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransferPayment() {
    return _buildPaymentInfoCard(
      'Manual Bank Transfer',
      '0123 4567 8901 (BCA)',
      '1. Transfer exactly the amount shown above\n2. Upload proof of payment in the next screen\n3. Wait for admin verification (max 1 hour)',
      subTitle: 'A/N Optimind Tech Indonesia',
    );
  }

  Widget _buildQRISPayment() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Image.asset(
                'assets/images/qris_mockup.png', // Replace with a real QRIS if needed
                height: 200,
                width: 200,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  width: 200,
                  color: Colors.grey[200],
                  child: const Icon(
                    Icons.qr_code_2_rounded,
                    size: 100,
                    color: Colors.black45,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Scan with your e-wallet or bank app",
                style: TextStyle(color: Colors.black54, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildInstructionCard(
          '1. Screenshot or Save this QR Code\n2. Open your Payment App (Gopay, OVO, Dana, or Bank App)\n3. Select Scan/Pay and upload the QR from Gallery',
        ),
      ],
    );
  }

  Widget _buildPaymentInfoCard(
    String title,
    String number,
    String instruction, {
    String? subTitle,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: widget.prominentColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: widget.prominentColor.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: widget.prominentColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withValues(
                        alpha: 0.7,
                      ),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (subTitle != null) ...[
                Text(
                  subTitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withValues(
                      alpha: 0.5,
                    ),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    number,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      fontFamily: 'sf-pro',
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: number));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          behavior: SnackBarBehavior.floating,
                          content: Text("Copied to clipboard"),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: widget.prominentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.copy_rounded,
                        color: widget.prominentColor,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildInstructionCard(instruction),
      ],
    );
  }

  Widget _buildInstructionCard(String instruction) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Instructions",
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          instruction,
          style: theme.textTheme.bodyMedium?.copyWith(
            height: 1.6,
            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
