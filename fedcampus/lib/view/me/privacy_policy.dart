import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class PrivacyPolicy extends StatefulWidget {
  const PrivacyPolicy({super.key});

  @override
  State<PrivacyPolicy> createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Terms of Service'),
        ),
        resizeToAvoidBottomInset: false,
        body: Markdown(
          styleSheet:
              MarkdownStyleSheet(textScaler: const TextScaler.linear(1.2)),
          data: """
## Data Collection
The project will collect health data from smartwatches worn by participants. 

## Data Storage
The data will be stored in an isolated virtual machine inside a communication server on campus, which is only accessible under DKU internet. Access to any data will require permissions from the authorized personnel only.

## Data analysis techniques
The data will be analyzed using privacy-preserving techniques, including Federated Learning and Differential Privacy. 

Federated Learning is a machine learning technique that trains an algorithm across multiple decentralized edge devices or servers holding local data samples, without exchanging them. This approach stands in contrast to traditional centralized machine learning techniques where all the local datasets are uploaded to one server. Differential Privacy is a rigorous mathematical definition of privacy which ensure the safety of information about specific individuals.

## Legal considerations
The project will also comply with Chinese laws for Data Security and Export Control. All raw data collected in China, collected from Chinese citizens, or consisting of biological resources in China should be stored on a server located within mainland China. The raw data will not be accessed or viewed by any non-Chinese citizens, including members of the research team.
## Participant Safety and Exclusion Criteria
Participants will be provided with clear instructions on how to wear and use the smartwatches safely. The project will exclude individuals who have a known allergy or sensitivity to materials used in the smartwatches, or those who have any medical conditions that may be adversely affected by wearing a smartwatch or engaging in physical activity.

The project will also ensure that potentially vulnerable subject populations are protected. The project will not involve minors under 18 years old in NC. Access to any data will require permissions from the authorized personnel only.

If you have any concerns or questions about the project's terms of service, please contact the project team at dku-irb@dukekunshan.edu.cn.""",
        ));
  }
}
