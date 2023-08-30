import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class About extends StatefulWidget {
  const About({super.key});

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('About'),
        ),
        resizeToAvoidBottomInset: false,
        body: Markdown(
          styleSheet: MarkdownStyleSheet(textScaleFactor: 1.2),
          data: """
## Federated Learning: Using Differential Privacy algorithms to Analyze Privacy-Preserving Health Data Collected on Smartwatches
### Project Team: Duke Kunshan University undergraduates

### Study Purpose
The primary goal of this study is to investigate the application of federated learning and differential privacy algorithms in analyzing health data collected from smartwatches, while preserving participant privacy. The study also aims to gain insights about student health at DKU.

### Data Collection and Data Analysis
Health data will be collected from smartwatches worn by participants. The project will use privacy-preserving techniques, including Federated Learning and Differential Privacy, to ensure that the data is analyzed without compromising participant privacy.
#### Federated Learning
Federated learning is a machine learning approach that allows for the training of an algorithm across multiple devices or servers holding local data samples, without exchanging them. In the context of this study, federated learning will be used to analyze health data collected from smartwatches. Each smartwatch can be thought of as a local node that participates in the learning process, contributing to a global model without ever sharing the raw data it has collected.
#### Differential Privacy
Differential Privacy is a rigorous mathematical definition of privacy. In the simplest setting, consider an algorithm that analyzes a dataset and computes statistics about it (such as the data's mean, variance, median, mode, etc.). Differential privacy ensures that the output of the algorithm does not reveal any information about any individual in the dataset.
### Outcome and Benefits
The project has significant implications for future health studies, privacy laws, and technology development. The following are some potential outcomes and benefits of the project:
* The project will demonstrate the effectiveness of privacy-preserving techniques, including Federated Learning and Differential Privacy, in analyzing health data collected from smartwatches.
* The project will provide insights into student health at DKU, which can inform future health studies and interventions.
* The project will contribute to the development of privacy-preserving technologies, which can be applied in various domains beyond health data analysis.
* The project will promote awareness of privacy issues and the importance of protecting participant privacy in research studies.""",
        ));
  }
}
