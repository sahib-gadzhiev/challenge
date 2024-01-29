public with sharing class AllMissionsController {
    @AuraEnabled
    public static List<Superhero_Mission__c> getAllMissions(){
        try {
            User customerUser = [SELECT id, ContactId FROM User WHERE Id =:UserInfo.getUserId() LIMIT 1];
            Id contactId = customerUser.contactId;
            return WithoutSharingSelector.getHeroMissionsForHero(contactId);
        } catch (Exception e) {
           throw new AuraHandledException(e.getMessage());
        }
    }
}