import 'package:flutter/material.dart';
import 'package:adsats_flutter/amplify/s3_storage.dart';
import 'package:adsats_flutter/amplify/rest_api_gateway.dart';

class ComplianceWidget extends StatelessWidget {
  const ComplianceWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SizedBox(height: 20), // Add some space between the text and the existing content
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text(
                  'Compliance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                height: 35, // Set the desired height
                width: MediaQuery.of(context).size.width *
                    0.2, // Adjust the width as needed
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search',
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 8, horizontal: 12), // Adjust padding
                    suffixIcon: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 1), // Adjust the horizontal padding
                      child: IconButton(
                        icon: const Icon(
                            Icons.search), // Icon for the search action
                        onPressed: () {
                          // Handle search action
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Add some space between the search bar and the existing content
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              await downloadFileWeb("ADSATS-Logo.svg");
            },
            child: const Text("Download File"),
          ),
          ElevatedButton(
            onPressed: () async {
              await uploadImage();
            },
            child: const Text("Upload File"),
          ),
          ElevatedButton(
            onPressed: () async {
              await getFileProperties("ADSATS-Logo.svg");
            },
            child: const Text("Get File Props"),
          ),
          ElevatedButton(
              onPressed: () async {
                Map<String, String> queryParameters = {
                  "email": "student@example.com",
                  "filter": "Test 1,Test 2"
                };
                await getMethod(queryParameters);
              },
              child: const Text("Test Get Method"))
        ],
      ),
    );
  }
}