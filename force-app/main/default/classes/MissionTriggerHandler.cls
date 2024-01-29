public with sharing class MissionTriggerHandler {
    final static String EMAIL_MESSAGE = 'This email has been sent through Apex';
    final static String EMAIL_SUBJECT = 'Test Subject';
    public static void onBeforeInsert(List<Superhero_Mission__c> newRecordList) {
    }

    public static void onBeforeUpdate(List<Superhero_Mission__c> updatedRecordList, Map<Id, Superhero_Mission__c> oldRecordMap) {
        
    }

    public static void onAfterInsert(List<Superhero_Mission__c> newRecordList) {
        sendEmailNotificatonToUsers(newRecordList);
    }

    public static void onAfterUpdate(List<Superhero_Mission__c> updatedRecordList, Map<Id, Superhero_Mission__c> oldRecordMap) {
        sendEmailNotificatonToOwner(updatedRecordList, oldRecordMap);
    }

    static void sendEmailNotificatonToUsers(List<Superhero_Mission__c> recordList) {
        Database.executeBatch(new EmailNotificationBatch(recordList), 200);
    }

    static void sendEmailNotificatonToOwner(List<Superhero_Mission__c> recordList, Map<Id, Superhero_Mission__c> oldRecordMap) {
        List<Messaging.SingleEmailMessage> masterListMails = new List<Messaging.SingleEmailMessage>();

        for(Superhero_Mission__c mission : recordList) {
            if(mission.Status__c != oldRecordMap.get(mission.Id).Status__c && mission.Status__c == ConstantsHelper.COMPLETED_STATUS ) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setSaveAsActivity(false);
                email.setTargetObjectId(mission.OwnerId);
                //email.setWhatId(mission.Id);
                email.setSenderDisplayName('Guild Master');
                email.setSubject(EMAIL_SUBJECT);
                email.setPlainTextBody(EMAIL_MESSAGE);
                masterListMails.add(email);
            }
                
        }
        WithoutSharingSelector.sendEmails(masterListMails);
    }
}