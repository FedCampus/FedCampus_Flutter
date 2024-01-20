# Developer Guide

### Application walk-through

Currently the application has three pages, `Health`, `Statistics`, and `Account`.

#### Health

The Health page provides users with health-related information and features. Here's an overview of its components:

- Calendar Button: Located at the top of the page, this button allows users to select a specific date from a calendar dialog popup.
- Health Cards: The page displays two columns of health cards. The content of these cards can be customized through the `healthEntries` configuration, which follows a table-driven approach. The data for these cards is retrieved from the `HealthDataModel`.
- Partitioning: The page automatically partitions the health cards into two columns in a recursive manner, ensuring that they have roughly the same height.

#### Statistics

The Statistics page presents users with statistical information from differential privacy. Here's an overview of its components:

- Calendar and Filter Buttons: At the top of the page, there is a calendar button that allows users to select a date from a calendar dialog popup. To the right of the calendar button, there is a filter button that enables users to choose a specific group to view.
- Health Cards: The page displays a list of health cards. Similar to the Health page, the content of these cards can be customized through the `entries` configuration, following a table-driven approach. The data for these cards is retrieved from the `ActivityDataModel`.
- Participant Average and Percentile: Each health card shows the average data of participants and the user's percentile. The percentile represents the user's ranking, for example, in a group of 100 people, top 25% indicates a rank around 25.

#### Account

The Account page focuses on user account management. Here are its main features:

- Settings: Users can access and modify application settings from this section.
- Account management: The page provides options for logging in, logging out, and registering a new account.

Additionally, the application includes a splash screen that can be toggled on or off. This feature is particularly useful for providing a first-time tour or displaying news updates (to be added).

### State management

The application utilizes the [provider](https://pub.dev/packages/provider) package for efficient state management. The following providers are currently implemented:

There are currently four providers.

- `MyAppState`
  - This provider manages application-wide settings, including the locale and dark mode preferences.
- `UserModel`
  - The UserModel provider handles user-related states, such as login information and user category (status, grade, gender).
- `HealthDataModel`
  - This provider manages the health data displayed on the Health page.
- `ActivityDataModel`
  - The ActivityDataModel provider handles statistical data derived from differential privacy, which is shown on the Statistics page.

By utilizing these providers, the application ensures seamless state management and facilitates the proper flow of data between different components and pages.

### Health data retrieval

The retrieval of health data is handled by the base class `FedHealthData` in the `health_handler.dart` file. The application currently supports three platforms: Huawei Health, Google Fit, and Apple Health. To add support for a new platform, you need to implement the FedHealthData class.

For Huawei Health integration, the implementation involves native Android code located in the `android/app/src/main/kotlin/com/cuhk/fedcampus/` directory. This code allows the application to interact with the Huawei Health SDK and retrieve health data specific to Huawei devices and other Android devices compatible with Huawei Health.

Additionally, on Android devices, the application also accesses screen time data through native Android code. This code enables the application to retrieve screen time information from the device's operating system in a similar manner to the Huawei Health integration.

When implementing support for a new platform, it is important to follow the existing structure and conventions of the codebase. By adhering to these guidelines, you can ensure that the new platform integration seamlessly integrates with the existing health data retrieval system.

### Federated learning and federated analytics

- Federated learning
  - `FedKit`, which is a depenency of `FedCampus_Flutter`
  - Currently not enabled
- Federated analytics
  - The application employs federated analytics using a differential privacy.
  - Adding Noise to Raw Data: In the `getDayDataAndSendAndTrain` function within the `datawrapper.dart` file, the application introduces noise to the raw data before transmitting it to the backend server.
