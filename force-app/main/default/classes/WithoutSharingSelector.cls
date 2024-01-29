public without sharing class WithoutSharingSelector {
    public static List<Superhero_Mission__c> getHeroMissionsForHero(Id heroId) {
        Hero__c hero = [SELECT Id, Guild__c FROM HERO__c WHERE Contact__c = :heroId LIMIT 1];
        return [
            SELECT  Id, 
                    Complexity_Rank__c, 
                    Name, 
                    Guild__r.Name, 
                    Status__c, 
                    Subject__c 
            FROM    Superhero_Mission__c
            WHERE   Guild__c = :hero.Guild__c
            OR      Is_Public__c = true 
            WITH    SECURITY_ENFORCED
            ORDER   BY CreatedDate
            LIMIT   50000
        ];
    }

    public static Superhero_Mission__c getHeroMissionById(Id recordId) {
        return [
            SELECT  Id, 
                    Complexity_Rank__c, 
                    Name, 
                    Guild__r.Name, 
                    Status__c, 
                    Subject__c,
                    Deadline__c,
                    Is_Public__c,
                    Reward__c,
                    Details__c 
            FROM    Superhero_Mission__c 
            WHERE   Id = :recordId
            WITH    SECURITY_ENFORCED
            LIMIT   1
        ];
    }

    public static List<Superhero_Mission__c> getHeroMissionsByIds(List<Id> idList) {
        return [
            SELECT  Id, 
                    Complexity_Rank__c, 
                    Name, 
                    Guild__r.Name, 
                    Status__c, 
                    Subject__c 
            FROM    Superhero_Mission__c 
            WHERE   Id = : idList
            WITH    SECURITY_ENFORCED
            LIMIT   50000
        ];
    }

    public static List<Mission_Assignment__c> getAssignmentsByMissionExludedIds(List<Id> completedMissionIdList, List<Id> recordIdList) {
        return [
            SELECT  Id, Status__c 
            FROM    Mission_Assignment__c 
            WHERE   Mission__c = :completedMissionIdList 
            AND     Id != :recordIdList
            AND     Status__c = :ConstantsHelper.IN_PROGRESS_STATUS
            WITH    SECURITY_ENFORCED
            LIMIT   10000  
        ];  
    }

    public static void updateRecords(List<Sobject> recordList) {
        update recordList;
    }

    public static void insertRecords(List<Sobject> recordList) {
        insert recordList;
    }

    public static void upsertRecords(List<Sobject> recordList) {
        upsert recordList;
    }

    public static void sendEmails(List<Messaging.SingleEmailMessage> masterListMails) {
        Messaging.SendEmailResult[] resultList = Messaging.sendEmail(masterListMails);
    }
}