public with sharing class AllMissionsController {
    @AuraEnabled
    public static List<Superhero_Mission__c> getAllMissions(){
        try {
            User customerUser = SelectorHelper.getCurrentUser();
            Id contactId = customerUser.contactId;
            return WithoutSharingSelector.getHeroMissionsForHero(contactId);
        } catch (Exception e) {
           throw new AuraHandledException(e.getMessage());
        }
    }
}