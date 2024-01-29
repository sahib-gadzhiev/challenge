public with sharing class SelectorHelper {
    public static List<Superhero_Mission__c> getHeroMissions() {
        return [
            SELECT  Id, 
                    Complexity_Rank__c, 
                    Name, 
                    Guild__r.Name, 
                    Status__c, 
                    Subject__c 
            FROM    Superhero_Mission__c 
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
                    Subject__c 
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

    public static List<Hero__c> getHeroesByIds(List<Id> idList) {
        return [
            SELECT  Id, 
                    Rank__c, 
                    Name, 
                    Contact__c
                     
            FROM    Hero__c 
            WHERE   Id = : idList
            WITH    SECURITY_ENFORCED
            LIMIT   50000
        ];
    }

    public static Mission_Assignment__c getMissionAssignment(String contactId, String missionId) {
        List<Mission_Assignment__c> assignmentList = [
            SELECT  Id, Status__c 
            FROM    Mission_Assignment__c 
            WHERE   Hero__c = :contactId 
            AND     Mission__c = :missionId
            WITH    SECURITY_ENFORCED
            LIMIT  1
        ];

        return assignmentList.size() > 0 ? assignmentList[0] : null;
    }

    public static Mission_Assignment__c getMissionAssignment(String assignmentId) {
        List<Mission_Assignment__c> assignmentList = [
            SELECT  Id, Status__c 
            FROM    Mission_Assignment__c 
            WHERE   Id = :assignmentId
            WITH    SECURITY_ENFORCED
            LIMIT  1
        ];

        return assignmentList.size() > 0 ? assignmentList[0] : null;
    }


    public static Hero__c getHeroByCurrentUser() {
        User customerUser = [SELECT id, ContactId FROM User WHERE Id =:UserInfo.getUserId() LIMIT 1];
        Id contactId = customerUser.contactId;
        return [
            SELECT  Id, Guild__c 
            FROM    HERO__c 
            WHERE   Contact__c = :contactId  
            WITH    SECURITY_ENFORCED 
            LIMIT   1
        ];
    }
}