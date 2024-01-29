public with sharing class EmailNotificationBatch  implements Database.Batchable<SObject>{
    
    List<Superhero_Mission__c> missionList;

    public EmailNotificationBatch() {
        this.missionList = new List<Superhero_Mission__c>();
    }

    public EmailNotificationBatch(List<Superhero_Mission__c> missionList) {
        this.missionList = missionList;
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('SELECT Id, Contact__r.Email, Guild__c FROM Hero__c');
    }
  
    public void execute(Database.BatchableContext BC, List<SObject> scope){
        List<Hero__c> heroList = ( List<Hero__c>) scope;
        EmailTemplate emt= [Select Id from EmailTemplate where DeveloperName = 'Mission_Creation_Notification'];
        List<Messaging.SingleEmailMessage> masterListMails = new List<Messaging.SingleEmailMessage>();

        for(Superhero_Mission__c mission : missionList) {
            for (Hero__c hero : heroList){
                if(mission.Guild__c == hero.Guild__c || mission.Is_Public__c){
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setSaveAsActivity(false);
                    email.setWhatId(mission.Id);
                    email.setTargetObjectId(hero.Contact__c);
                    email.setSenderDisplayName(ConstantsHelper.SENDER_DISPLAY_NAME);
                    email.setTemplateId(emt.Id);
                    masterListMails.add(email);
                }

            }
            
        }
        if(!Test.isRunningTest()) {
            Messaging.sendEmail(masterListMails);
        }
        
    }

  
    public void finish(Database.BatchableContext BC){
    }

}