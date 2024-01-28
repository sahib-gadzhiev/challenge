public without sharing class WithoutSharingSelector {
    public static List<Superhero_Mission__c> getHeroMissionsForHero(Id heroId) {
        Hero__c hero = [SELECT Id, Guild__c FROM HERO__c WHERE Id = :heroId];
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
            LIMIT   1
        ];
    }
}