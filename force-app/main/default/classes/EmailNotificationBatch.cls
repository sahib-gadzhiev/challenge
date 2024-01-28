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
        // List<String> contactIdList = new List<String>();
        // List<Superhero_Mission__Share> missionShrList = new List<Superhero_Mission__Share>();
        EmailTemplate emt= [Select Id from EmailTemplate where DeveloperName = 'Mission_Creation_Notification'];
        List<Messaging.SingleEmailMessage> masterListMails = new List<Messaging.SingleEmailMessage>();

        // for (Hero__c hero : heroList){
        //     contactIdList.add(hero.Contact__c);
        // }

        // List<User> customerUserList = [SELECT id, ContactId FROM User WHERE ContactId =:contactIdList];
        // Map<Id, User> userMapByContact = new Map<Id, User>();
        // for(User usr : customerUserList) {
        //     userMapByContact.put(usr.ContactId, usr);
        // }
        for(Superhero_Mission__c mission : missionList) {
            for (Hero__c hero : heroList){
                if(mission.Guild__c == hero.Guild__c || mission.Is_Public__c){
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setSaveAsActivity(false);
                    email.setWhatId(mission.Id);
                    email.setTargetObjectId(hero.Contact__c);
                    email.setSenderDisplayName('Guild Master');
                    email.setTemplateId(emt.Id);
                    masterListMails.add(email);
                }

                // if(mission.Guild__c == hero.Guild__c && userMapByContact.get(hero.Contact__c)!= null) {
                //     missionShrList.add(createAssignments(mission.Id, userMapByContact.get(hero.Contact__c).Id));
                // }
            }
            
        }
        Messaging.sendEmail(masterListMails);
        // insert missionShrList;
    }

    // static Superhero_Mission__Share createAssignments(Id recordId, Id userId) {
    //     Superhero_Mission__Share missionShr  = new Superhero_Mission__Share();
   
    //     missionShr.ParentId = recordId;
            
    //     missionShr.UserOrGroupId = userId;
            
    //     missionShr.AccessLevel = 'Read';
            
    //     missionShr.RowCause = Schema.Superhero_Mission__Share.RowCause.Manual;
    //     return missionShr;

    // }
  
    public void finish(Database.BatchableContext BC){
    }

}