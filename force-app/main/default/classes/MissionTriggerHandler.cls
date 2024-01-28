public with sharing class MissionTriggerHandler {
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
        EmailTemplate emt= [Select Id from EmailTemplate where DeveloperName = 'Owner_Notification'];
        List<Messaging.SingleEmailMessage> masterListMails = new List<Messaging.SingleEmailMessage>();

        for(Superhero_Mission__c mission : recordList) {
            if(mission.Status__c != oldRecordMap.get(mission.Id).Status__c && mission.Status__c == ConstantsHelper.COMPLETED_STATUS ) {
                
                Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(emt.Id, mission.OwnerId, mission.Id);
                email.setSaveAsActivity(false);
                email.setTargetObjectId(mission.OwnerId);
                email.setWhatId(mission.Id);
                email.setSenderDisplayName('Guild Master');
                masterListMails.add(email);
            }
                
        }
        System.debug('Messaging.sendEmail ' + masterListMails);
        Messaging.sendEmail(masterListMails);
    }
}