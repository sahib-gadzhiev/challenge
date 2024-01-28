public with sharing class AllMissionsController {
    @AuraEnabled
    public static List<Superhero_Mission__c> getAllMissions(){
        try {
            return WithoutSharingSelector.getHeroMissionsForHero(MissionDetailController.contactId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}