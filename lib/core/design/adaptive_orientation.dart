import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Ponsel dikunci potret (desain 390x844 dan pratinjau kamera tegak); layar
/// >= 600 dp (tablet, lipat terbuka) bebas berputar. Android 16 mengabaikan
/// kunci orientasi pada layar besar, jadi tata letak harus siap lebar.
class AdaptiveOrientation extends StatefulWidget {
  const AdaptiveOrientation({required this.child, super.key});

  final Widget child;

  @override
  State<AdaptiveOrientation> createState() => _AdaptiveOrientationState();
}

class _AdaptiveOrientationState extends State<AdaptiveOrientation> {
  bool? _locked;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final compact = MediaQuery.sizeOf(context).shortestSide < 600;
    if (_locked == compact) return;
    _locked = compact;
    SystemChrome.setPreferredOrientations(
      compact ? [DeviceOrientation.portraitUp] : DeviceOrientation.values,
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
