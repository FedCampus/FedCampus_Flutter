## FAQs

**Q**: Do you collect data? What types of data do you collect?

**A**: In fact, our app does not "collect" data from users. We utilize federated learning and differential privacy techniques to ensure the privacy of our end users. This means that your raw data remains solely on your phone and is never transmitted elsewhere.

Currently, we utilize data from smartwatches to train federated learning algorithms and generate insights employing differential privacy techniques.

* [Federated Learning and Data Privacy] Your privacy is our top priority. FedCampus uses federated learning, a cutting-edge technique that processes data directly on your device. This means that the core learning and analysis happen locally, without your raw data ever leaving your device. Only non-sensitive, aggregated model updates are transmitted to our servers, ensuring your personal information stays private.

* [Differential Privacy and Anonymity] To further safeguard your data, FedCampus implements differential privacy. This process ensures that the insights we derive from user data are useful for the community while making it virtually impossible to identify individual users. 

* [No Raw Data Storage] Consistent with our commitment to privacy and security, FedCampus is designed to not store any raw data on our servers.

**Q**: What do the values in the “DKU Statistics” page mean?

**A**: For every item in the list, two statistics are provided: participant average and your percentile.

Participant average represents the average value of the health statistics within the target group (explained below).

Your percentile indicates your position relative to the target group. For instance, a top percentile of 0% implies you are the first-ranked individual within the target group, while a percentile of 100% signifies you are the last-ranked individual.

**Q**: Can I see the participant average and my percentile among certain group of participants?

**A**: Yes. You first need to configure your group in Account-> Account Settings. After that, you can click the filter button on the right of the calendar button, then choose a specific group you would like to see.

**Q**: Why can’t I use this app outside the DKU network?

**A**: Our server is currently deployed on the DKU network. If you are not located on the DKU campus, you can access it through the DKU VPN (not Duke VPN). Please refer to the DKU VPN Setup guide provided by Duke Kunshan University DKU VPN Setup – Duke Kunshan University for instructions on how to set it up.

Alternatively, you can also access our server through the Duke network.


**Q**: Why do I need to turn the proxy off?

**A**: Our app retrieves health data from Huawei Health Kit, which communicates with the Huawei cloud server. However, there may be instances when the Huawei Health Kit encounters difficulties in accessing the Huawei server due to the DKU proxy. 
We apologize for any inconvenience this may cause.

**Q**: Why does the app crash after I install a new version of the app?

**A**: It is possible because there might be conflicts between different versions of the app, please uninstall and reinstall the app. 
We apologize for any inconvenience this may cause.

**Q**: Do I need to use the Huawei Health app?

**A**: After you pair the Huawei watch with Huawei Health app, you do not need to do so because our app automatically synchronizes health data with Huawei Health, and We only require you to use our app for a minimum of 9 days within a 14-day period. However, if you are interested in accessing additional data that is not included in our app, you can explore the Huawei Health app.

**Q**: Why is there an increase in battery consumption on my phone?

**A**: The increased battery consumption is primarily due to Huawei Health running in the background, particularly on non-Huawei Android phones. If you don't require additional features such as notifications and phone calling provided by the Huawei Smart Watch, you have the option to disable the background running permission for Huawei Health. However, it's important to note that if you disable this permission, Huawei Health may not be able to synchronize data with the watch effectively.

When our app is active, we attempt to bring Huawei Health to the background, and Huawei Health will synchronize data with the watch. In case this action fails due to permission issues, kindly grant the background running permission back to ensure smooth functionality.
