import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class DefaultTextLogo extends StatelessWidget {
  const DefaultTextLogo({
    super.key,
    // this.appBarHeight,
  });

  // final double? appBarHeight;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          context.go('/documents');
        },
        child: const Text(
          'ADSATS',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class DefaultLogoWidget extends StatelessWidget {
  const DefaultLogoWidget({super.key});

  // const DefaultLogoWidget({super.key, this.height});
  // final double? height;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          context.go('/documents');
        },
        child: SvgPicture.asset(
          'svg/ADSATS_Logo.svg',
          height: 40,
        ),
      ),
    );
  }
}
