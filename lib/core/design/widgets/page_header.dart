import 'package:flutter/material.dart';

import '../phosphor.dart';

import '../tokens.dart';
import 'icon_circle_button.dart';

/// Header layar: tombol kembali bulat, judul tengah, ruang kosong/aksi di kanan.
class PageHeader extends StatelessWidget {
  const PageHeader({
    required this.title,
    this.onBack,
    this.trailing,
    this.showBack = true,
    super.key,
  });

  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.screenH,
        6,
        AppSpace.screenH,
        6,
      ),
      child: Row(
        children: [
          SizedBox(
            width: AppSpace.minTouch,
            child: showBack
                ? IconCircleButton(
                    icon: PhosphorIconsRegular.arrowLeft,
                    iconSize: 18,
                    semanticLabel: 'Kembali',
                    onPressed: onBack ?? () => Navigator.maybePop(context),
                  )
                : null,
          ),
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppType.header.copyWith(color: c.textPrimary),
              ),
            ),
          ),
          SizedBox(width: AppSpace.minTouch, child: trailing),
        ],
      ),
    );
  }
}
