# FedCampus

**A Real-world Privacy-preserving Mobile Application for Smart Campus via Federated Learning & Analytics**

[![Watch the Demo](https://img.shields.io/badge/YouTube-Demo-red)](https://youtu.be/k5iu46IjA38)
[Flutter App Guide](fedcampus/doc/guide.md) | [Django Backend Guide](fa_backend/doc/guide.md) | [Changelog](fedcampus/doc/changelog.md)

![fedcampus](https://github.com/user-attachments/assets/d4f76017-fe65-4edf-8ba3-ab0418adde8f)


## 🚀 Overview

FedCampus is an open-source, cross-platform mobile application that brings **federated learning (FL)** and **federated analytics (FA)** into real-world smart campus scenarios. Developed and deployed at **Duke Kunshan University**, FedCampus empowers privacy-preserving applications like sleep tracking, physical activity monitoring, and personalized health recommendations — all without centralizing user data.

## 🎯 Features

* 🔒 **Privacy-first**: Differential Privacy applied to both FL & FA workflows.
* 📱 **Cross-platform**: Native support for both **Android** (via TFLite) and **iOS** (via CoreML).
* 🧠 **Federated Learning on-device**: Train ML models collaboratively across personal smartphones.
* 📊 **Federated Analytics**: Perform statistical analysis with privacy guarantees.
* 🔁 **MLOps-ready**: Continuously deploy models and algorithms without updating the app.

## 🧩 System Architecture

FedCampus consists of:

* **Flutter-based Mobile App** (Android & iOS)
* **Django-based Backend Server**
* **Huawei Health Kit** integration for smartwatch data
* **Custom FL/FA APIs** for encrypted data processing and model lifecycle management

![fedcampus_workflow](https://github.com/user-attachments/assets/27e937ae-698b-4ca1-9405-ff970561382b)


> For a detailed breakdown, see our [Demo Paper at MobiHoc 2024](https://dl.acm.org/doi/10.1145/3641512.3690630).

## 📱 Smart Campus Use Cases

Deployed with **100+ volunteers**, FedCampus supported:

| Task                               | Type | Description                                                |
| ---------------------------------- | ---- | ---------------------------------------------------------- |
| 💤 Sleep Tracking                  | FL   | Predict sleep efficiency using sensor and phone usage data |
| 🏃‍♂️ Physical Activity Monitoring | FL   | Analyze fitness levels using steps, heart rate, etc.       |
| 🎯 Personalized Recommendations    | FA   | Deliver user-specific health tips based on behaviors       |
| 📈 Heavy Hitters Analysis          | FA   | Identify popular patterns across the student population    |

## 🛠 Developer Guide

### 📲 Flutter Client

Start building or customizing the mobile app:
📖 [Client Developer Guide](fedcampus/doc/guide.md)

### 🔧 Django Backend

Manage models, training, and FA pipelines:
📖 [Backend Developer Guide](fa_backend/doc/guide.md)

## 🧪 Tech Stack

* **Flutter** (Cross-platform UI)
* **TensorFlow Lite**, **CoreML** (On-device inference/training)
* **Django + PyTorch** (Server-side backend)
* **Differential Privacy APIs** (Custom implementations for FL & FA)
* **Huawei Health Kit** (Wearable data integration)

## 👥 Contributors

Developed by:

* Jiaxiang Geng, Beilong Tang, Boyan Zhang, Jiaqi Shao, Bing Luo
  📧 Contact: {jg645, bt132, bz106, js1139, bl291}@duke.edu

Special thanks to: Sichang He, Qingning Zeng, Luyao Wang, Renyuan Zhang

## 🧾 Citation

If you use FedCampus in your work, please cite our demo paper:

```
@inproceedings{geng2024fedcampus,
  title={Demo: FedCampus: A Real-world Privacy-preserving Mobile Application for Smart Campus via Federated Learning & Analytics},
  author={Geng, Jiaxiang and Tang, Beilong and Zhang, Boyan and Shao, Jiaqi and Luo, Bing},
  booktitle={Proceedings of the 25th International Symposium on Mobile Ad Hoc Networking and Computing (MobiHoc)},
  year={2024},
  publisher={ACM}
}
```

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
