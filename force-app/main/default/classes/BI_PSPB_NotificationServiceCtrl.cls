/**
* @description Triggers and sends notifications for Treatment reminders.
* History
* Version	Author			Date		Detail		Description
* 1.0		Niyas		24-07-2024		Created		Refactored Version
*/
public with sharing class BI_PSPB_NotificationServiceCtrl {
/**
* @description Counts the days and triggers a method to send notifications.
* @param reminders Record that is used to trigger.
* @param daysCount Count of days to send notifications.
*/
public static void sendNotifications(
	List<BI_PSPB_Treatment_Reminder__c> reminders,
	BI_PSPB_TreatmentReminderDaysCtrl daysCount
) {
	try {
		if (reminders.isEmpty() || daysCount == null) {
			BI_PSP_LogMessagesUtility.logError(
				BI_PSPB_NotificationConstantsCtrl.errorMsgRecordNotFound,
				BI_PSPB_NotificationServiceCtrl.class.toString(),
				false,
				BI_PSPB_NotificationConstantsCtrl.severityError
			);
			return;
		}
		Map<Integer, List<Id>> enrolleeIdMap = new Map<Integer, List<Id>>{
			daysCount.before1Day => new List<Id>(),
			daysCount.before3Day => new List<Id>(),
			daysCount.before7Day => new List<Id>(),
			daysCount.before10Day => new List<Id>(),
			daysCount.before14Day => new List<Id>()
		};
        String formattedDate;
		Datetime treatmentDate;
		for (BI_PSPB_Treatment_Reminder__c reminder : reminders) {
			Integer daysDifference = reminder.BI_PSPB_Reminder_Date__c.daysBetween(
				reminder.BI_PSPB_Date_of_Treatment__c
			);
			if (enrolleeIdMap.containsKey(daysDifference)) {
                treatmentDate = reminder.BI_PSPB_Date_of_Treatment__c;
				formattedDate = treatmentDate.format('MM/dd/yyyy');
				enrolleeIdMap.get(daysDifference)
					.add(reminder.BI_PSPB_Care_Program_Enrollee__c);
			}
		}

		handleTriggers(enrolleeIdMap, daysCount, formattedDate);
	} catch (Exception ex) {
		BI_PSP_LogMessagesUtility.exceptionLogMessage(
		ex.getMessage(),
		BI_PSPB_NotificationServiceCtrl.class.toString(),
		ex
	);
	}
}
/**
 * @description Triggering another method for each dates.
 * @param enrolleeIdMap Map of dates and enrollee ids.
 * @param daysCount Count of days to send notifications.
 */
public static void handleTriggers(
	Map<Integer, List<Id>> enrolleeIdMap,
	BI_PSPB_TreatmentReminderDaysCtrl daysCount,
    String formattedDate
) {
	try {
		if (enrolleeIdMap == null || daysCount == null) {
			BI_PSP_LogMessagesUtility.logError(
				BI_PSPB_NotificationConstantsCtrl.errorMsgRecordNotFound,
				BI_PSPB_NotificationServiceCtrl.class.toString(),
				true,
				BI_PSPB_NotificationConstantsCtrl.severityError
			);
			return;
		}
		triggerNotification(
			enrolleeIdMap.get(daysCount.before1Day),
			BI_PSPB_NotificationConstantsCtrl.treatmentOne,
            formattedDate
		);
		triggerNotification(
			enrolleeIdMap.get(daysCount.before3Day),
			BI_PSPB_NotificationConstantsCtrl.treatmentThree,
            formattedDate
		);
		triggerNotification(
			enrolleeIdMap.get(daysCount.before7Day),
			BI_PSPB_NotificationConstantsCtrl.treatmentSeven,
            ''
		);
		triggerNotification(
			enrolleeIdMap.get(daysCount.before10Day),
			BI_PSPB_NotificationConstantsCtrl.treatmentTen,
            ''
		);
		triggerNotification(
			enrolleeIdMap.get(daysCount.before14Day),
			BI_PSPB_NotificationConstantsCtrl.treatmentFourteen,
            ''
		);
	} catch (Exception ex) {
		BI_PSP_LogMessagesUtility.exceptionLogMessage(
			ex.getMessage(),
			BI_PSPB_NotificationServiceCtrl.class.getName(),
			ex
		);
	}
}
/**
* @description Triggers methods for each notification based on days count.
* @param enrolleeIds Enrollee Ids to send notifications.
* @param treatmentType Type of the treatment to trigger.
*/
public static void triggerNotification(
	List<Id> enrolleeIds,
	String treatmentType,
    String formattedDate
) {
	try {
		if (!enrolleeIds.isEmpty()) {
			BI_PSPB_SmsAndEmailSenderCtrl.handleTrigger(
				enrolleeIds,
				treatmentType,
				new List<String>{''},
				formattedDate
			);
			return;
		}
	} catch (Exception ex) {
		BI_PSP_LogMessagesUtility.exceptionLogMessage(
			ex.getMessage(),
			BI_PSPB_NotificationServiceCtrl.class.getName(),
			ex
		);
	}
}
}