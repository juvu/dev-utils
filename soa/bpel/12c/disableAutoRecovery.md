# How to disable Auto-Recovery in BPEL


Go to Enterprise Manager:
http://localhost:8001/em

- Expand the Farm and SOA nodes.

- Open **soa-infra (AdminServer)**

- SOA **Infrastructure** > **SOA Administration** > **BPEL Properties**

- **More BPEL Configuration Properties...**

- Change (Apply):

    ```Properties
    MaxRecoverAttempt = 0
    ```
	
- Open **RecoveryConfig**

    - Change following values **FolderRecurringScheduleConfig**

        ```Properties
        maxMessageRaiseSize = 0 
        startWindowTime = 00:00 
        stopWindowTime = 00:00
        subsequentTriggerDelay = 0
        threshHoldTimeInMinutes = 0
        ```

    - Change following values **FolderStartupScheduleConfig**

        ```Properties
        maxMessageRaiseSize = 0
        startupRecoveryDuration = 0
        subsequentTriggerDelay = 0
        ```
