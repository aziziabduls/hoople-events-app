import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hoople_mobile_app/core/utils/format_number.dart';
import 'package:hoople_mobile_app/models/experience_model.dart';
import 'package:hoople_mobile_app/widgets/hoople_button.dart';

class ExperiencePaymentSheet extends StatefulWidget {
  final Experience experience;
  final ExperienceItem ticket;
  final Color prominentColor;
  final VoidCallback onPaymentSuccess;

  const ExperiencePaymentSheet({
    super.key,
    required this.experience,
    required this.ticket,
    required this.prominentColor,
    required this.onPaymentSuccess,
  });

  @override
  State<ExperiencePaymentSheet> createState() => _ExperiencePaymentSheetState();
}

class _ExperiencePaymentSheetState extends State<ExperiencePaymentSheet> {
  String _selectedMethod = 'VA'; // 'VA', 'Transfer', 'QRIS', 'E-Wallet'
  String _selectedBank = 'BCA';
  String _selectedEWallet = 'GoPay';
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  final Map<String, Map<String, String>> _bankData = {
    'BCA': {
      'name': 'BCA Virtual Account',
      'number': '8077708123456789',
      'instruction':
          '1. Login to m-BCA\n2. Select Transfer > BCA Virtual Account\n3. Enter the VA number\n4. Confirm and Pay',
      'logo': 'assets/images/bca_logo.png',
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                                "Registration - ${widget.experience.basicInfo.title} (${widget.ticket.name})",
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
                        // 8.gap,
                        // Container(
                        //   padding: const EdgeInsets.symmetric(
                        //     horizontal: 20,
                        //     vertical: 12,
                        //   ),
                        //   decoration: BoxDecoration(
                        //     color: widget.prominentColor.withValues(alpha: 0.1),
                        //     borderRadius: BorderRadius.circular(20),
                        //     border: Border.all(
                        //       color: isDark
                        //           ? Colors.green
                        //           : widget.prominentColor.withValues(
                        //               alpha: 0.2,
                        //             ),
                        //       width: 1.5,
                        //     ),
                        //   ),
                        //   child: Text(
                        //     formatNumber(widget.ticket.price),
                        //     style: theme.textTheme.headlineSmall?.copyWith(
                        //       // color: widget.prominentColor,
                        //       color: isDark
                        //           ? Colors.yellow
                        //           : widget.prominentColor,
                        //       fontWeight: FontWeight.w900,
                        //       // fontFamily: 'sf-pro',
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: widget.prominentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark
                              ? Colors.green.withValues(alpha: 0.5)
                              : widget.prominentColor.withValues(
                                  alpha: 0.2,
                                ),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Ticket Price",
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.textTheme.bodyMedium?.color
                                      ?.withValues(alpha: 0.7),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                formatNumberIDR(widget.ticket.price),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.textTheme.bodyMedium?.color
                                      ?.withValues(alpha: 0.9),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Platform Fee",
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.textTheme.bodyMedium?.color
                                      ?.withValues(alpha: 0.7),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                formatNumberIDR(2000),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.textTheme.bodyMedium?.color
                                      ?.withValues(alpha: 0.9),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Divider(
                              color: isDark ? Colors.white10 : Colors.black12,
                              height: 1,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Total Payment",
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                formatNumberIDR(widget.ticket.price + 2000),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: isDark
                                      ? Colors.yellow
                                      : widget.prominentColor,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildMethodSelector(),
                    const SizedBox(height: 24),
                    if (_selectedMethod == 'VA') _buildVAPayment(),
                    if (_selectedMethod == 'Transfer') _buildTransferPayment(),
                    if (_selectedMethod == 'QRIS') _buildQRISPayment(),
                    if (_selectedMethod == 'E-Wallet') _buildEWalletPayment(),
                    const SizedBox(height: 32),
                    const SizedBox(height: 80),
                  ],
                ),
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: HoopleButton(
                    onTap: () {
                      Navigator.pop(context);
                      widget.onPaymentSuccess();
                    },
                    text: "Confirm Payment",
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
        const SizedBox(width: 8),
        _buildMethodTab('Transfer', Icons.account_balance_rounded),
        const SizedBox(width: 8),
        _buildMethodTab('QRIS', Icons.qr_code_scanner_rounded),
        const SizedBox(width: 8),
        _buildMethodTab('E-Wallet', Icons.phone_android_rounded),
      ],
    );
  }

  Widget _buildMethodTab(String method, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    bool isSelected = _selectedMethod == method;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedMethod = method),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
          decoration: BoxDecoration(
            color: isSelected
                ? widget.prominentColor
                : widget.prominentColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? (isDark ? Colors.green : widget.prominentColor)
                  : (isDark
                        ? Colors.white10
                        : Colors.black.withValues(alpha: 0.12)),
              width: 1.5,
            ),
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
                size: 20,
              ),
              const SizedBox(height: 4),
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
                  fontSize: 11,
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
          style: TextStyle(fontSize: 14),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
          border: Border.all(
            color: isSelected
                ? (isDark ? Colors.green : widget.prominentColor)
                : (isDark
                      ? Colors.white10
                      : Colors.black.withValues(alpha: 0.12)),
            width: 1.5,
          ),
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
              fontSize: 10,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? Colors.white24
                  : Colors.black.withValues(alpha: 0.12),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Image.asset(
                'assets/images/qris_mockup.png',
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

  Widget _buildEWalletPayment() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final List<String> eWallets = ['GoPay', 'ShopeePay', 'OVO', 'Dana'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select E-Wallet Provider",
          style: TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 12),
        Row(
          children: eWallets.map((wallet) {
            bool isSelected = _selectedEWallet == wallet;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedEWallet = wallet),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? widget.prominentColor
                        : widget.prominentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? (isDark ? Colors.green : widget.prominentColor)
                          : (isDark
                                ? Colors.white10
                                : Colors.black.withValues(alpha: 0.12)),
                      width: 1.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: widget.prominentColor.withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      wallet,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : theme.textTheme.bodyMedium?.color?.withValues(
                                alpha: 0.7,
                              ),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        const Text(
          "Registered Phone Number",
          style: TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => FocusScope.of(context).unfocus(),
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            hintText: "e.g. 08123456789",
            hintStyle: TextStyle(
              color: isDark ? Colors.white30 : Colors.black38,
            ),
            prefixIcon: Icon(
              Icons.phone_iphone_rounded,
              color: isDark ? Colors.white30 : Colors.black38,
            ),
            suffixIcon: _phoneController.text.isNotEmpty
                ? TextButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                    },
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: widget.prominentColor,
                    ),
                  )
                : null,
            filled: true,
            fillColor: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.05),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 20,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDark ? Colors.white10 : Colors.black12,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: widget.prominentColor,
                width: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildPaymentInfoCard(
          '$_selectedEWallet Payment Instruction',
          'Push Notification',
          '1. Enter your registered $_selectedEWallet phone number above\n2. Tap "Confirm Payment" below\n3. Open $_selectedEWallet and pay the push notification prompt within 5 minutes',
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
            color: widget.prominentColor.withValues(
              alpha: theme.brightness == Brightness.dark ? 0.08 : 0.12,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: theme.brightness == Brightness.dark
                  ? Colors.green
                  : widget.prominentColor,
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
                      color: theme.brightness == Brightness.dark
                          ? Colors.green
                          : widget.prominentColor,
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
                      letterSpacing: -1,
                      // fontFamily: 'sf-pro',
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
