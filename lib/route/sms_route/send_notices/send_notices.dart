import 'package:flutter/material.dart';
import 'package:adsats_flutter/route/sms_route/send_notices/hazard_report/hazard_report_widget.dart';
import 'package:adsats_flutter/route/sms_route/send_notices/safety_notice/safety_notice_widget.dart';
import 'package:adsats_flutter/route/sms_route/send_notices/crew_notice/crew_notice_widget.dart';

class SendNotices extends StatefulWidget {
  const SendNotices({super.key});

  @override
  State<SendNotices> createState() => _SendNoticesState();
}

class _SendNoticesState extends State<SendNotices> {
  int _selectedIndex = 0;
  late List<Widget> _pages;

  GlobalKey recipientsKey = GlobalKey();
  final List<NavigationRailDestination> _navigationRailDestinations = [
    const NavigationRailDestination(
      icon: Icon(Icons.notifications_outlined),
      selectedIcon: Icon(Icons.notifications),
      label: Text("Notice to Crew"),
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
      icon: Icon(Icons.document_scanner_outlined),
      selectedIcon: Icon(Icons.document_scanner),
      label: Text("BCAA report"),
    ),
  ];
  final List<NavigationDestination> _navigationDestinations = [
    const NavigationDestination(
      icon: Icon(Icons.notifications_outlined),
      selectedIcon: Icon(Icons.notifications),
      label: "Notice to Crew",
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
      label: "BCAA report",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pages = [
      const CrewNoticeWidget(),
      const SafetyNoticeWidget(),
      const HazardReportWidget(),
      const Placeholder(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 1533) {
          // https://api.flutter.dev/flutter/material/NavigationBar-class.html
          return Column(
            children: [
              Expanded(
                child: Center(
                    child: Container(
                  constraints: const BoxConstraints(maxWidth: 1536),
                  child: SingleChildScrollView(
                    child: Card(
                      elevation: 20,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: _pages[_selectedIndex],
                      ),
                    ),
                  ),
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
            SizedBox(
              width: 175,
              child: SafeArea(
                child: NavigationRail(
                  onDestinationSelected: (value) {
                    setState(() {
                      _selectedIndex = value;
                    });
                  },
                  destinations: _navigationRailDestinations,
                  selectedIndex: _selectedIndex,
                  elevation: 10,
                  extended: constraints.maxWidth >= 1533,
                  // minExtendedWidth: 144,
                  minWidth: 72,
                  labelType: NavigationRailLabelType.none,
                  useIndicator: true,
                ),
              ),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1536),
                  child: SingleChildScrollView(
                    child: Card(
                      elevation: 20,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: _pages[_selectedIndex],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
