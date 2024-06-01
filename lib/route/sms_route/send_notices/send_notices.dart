import 'package:flutter/material.dart';
import 'package:adsats_flutter/route/sms_route/send_notices/hazard_report_form.dart';
import 'package:adsats_flutter/route/sms_route/send_notices/safety_Notice.dart';
import 'package:adsats_flutter/route/sms_route/send_notices/send_a_notice.dart';

class SendNotices extends StatefulWidget {
  const SendNotices({super.key});

  @override
  State<SendNotices> createState() => _SendNoticesState();
}

class _SendNoticesState extends State<SendNotices> {
  int _selectedIndex = 0;
  final List<NavigationRailDestination> _navigationRailDestinations = [
    const NavigationRailDestination(
      icon: Icon(Icons.notifications_outlined),
      selectedIcon: Icon(Icons.notifications),
      label: Text("Notice to crew"),
    ),
    const NavigationRailDestination(
      icon: Icon(Icons.gpp_maybe_outlined),
      selectedIcon: Icon(Icons.gpp_maybe),
      label: Text("Safety notice"),
    ),
    const NavigationRailDestination(
      icon: Icon(Icons.report_outlined),
      selectedIcon: Icon(Icons.report),
      label: Text("Hazard report"),
    ),
    const NavigationRailDestination(
      icon: Icon(Icons.report_outlined),
      selectedIcon: Icon(Icons.report),
      label: Text("BCAA reports"),
    ),
  ];
  final List<NavigationDestination> _navigationDestinations = [
    const NavigationDestination(
      icon: Icon(Icons.notifications_outlined),
      selectedIcon: Icon(Icons.notifications),
      label: "Notice to Crews",
    ),
    const NavigationDestination(
      icon: Icon(Icons.gpp_maybe_outlined),
      selectedIcon: Icon(Icons.gpp_maybe),
      label: "Safety Notice",
    ),
    const NavigationDestination(
      icon: Icon(Icons.report_outlined),
      selectedIcon: Icon(Icons.report),
      label: "Hazard Report",
    ),
    const NavigationDestination(
      icon: Icon(Icons.document_scanner_outlined),
      selectedIcon: Icon(Icons.document_scanner),
      label: "BCAA Aircraft Occurrence Reports",
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 1000) {
          // https://api.flutter.dev/flutter/material/NavigationBar-class.html
          return Column(
            children: [
              Expanded(
                child: Center(
                    child: Container(
                  constraints: const BoxConstraints(maxWidth: 1500),
                  child: buildPages(_selectedIndex),
                )),
              ),
              SafeArea(
                child: NavigationBar(
                  onDestinationSelected: (value) {
                    setState(() {
                      _selectedIndex = value;
                    });
                  },
                  destinations: _navigationDestinations,
                  selectedIndex: _selectedIndex,
                  elevation: 10,
                ),
              ),
            ],
          );
        }
        // https://api.flutter.dev/flutter/material/NavigationRail-class.html
        return Row(
          children: [
            SafeArea(
              child: NavigationRail(
                onDestinationSelected: (value) {
                  setState(() {
                    _selectedIndex = value;
                  });
                },
                destinations: _navigationRailDestinations,
                selectedIndex: _selectedIndex,
                elevation: 10,
                extended: constraints.maxWidth >= 1440,
                minExtendedWidth: 144,
                minWidth: 72,
                labelType: NavigationRailLabelType.none,
                useIndicator: true,
              ),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: Center(
                  child: Container(
                constraints: const BoxConstraints(maxWidth: 1500),
                child: buildPages(_selectedIndex),
              ),),
            ),
          ],
        );
      },
    );
  }

  Widget buildPages(int index) {
    switch (index) {
      case 0:
        return const SendANotices();
      case 1:
        return const SafetyNotice();
      case 2:
        return const HazardReport();
      case 3:
        return const Placeholder();
      default:
        return const Placeholder();
    }
  }
}
