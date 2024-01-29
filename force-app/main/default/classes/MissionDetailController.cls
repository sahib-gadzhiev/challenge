public with sharing class MissionDetailController {

    @AuraEnabled(cacheable=true)
    public static ResponseWrapper getMissionAssignment(Id missionId){
        try {
            Hero__c hero = SelectorHelper.getHeroByCurrentUser();
            Superhero_Mission__c mission = WithoutSharingSelector.getHeroMissionById(missionId);
            Mission_Assignment__c assignment = SelectorHelper.getMissionAssignment(hero.Id, missionId);

            ResponseWrapper response = new ResponseWrapper();
            response.mission = mission;
            response.assignment = assignment;
            return response;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Mission_Assignment__c createAssignment(String missionId){
        try {
            Hero__c hero = SelectorHelper.getHeroByCurrentUser();
            Mission_Assignment__c missionAssignment = new Mission_Assignment__c();
            missionAssignment.Hero__c = hero.Id;
            missionAssignment.Mission__c = missionId;
            WithoutSharingSelector.insertRecords(new List<SObject> {missionAssignment});
            return SelectorHelper.getMissionAssignment(hero.Id, missionId);
        } catch (Exception e) {
           throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Mission_Assignment__c completeMission(String missionAssignmentId){
        try {
            Mission_Assignment__c missionAssignment = new Mission_Assignment__c();
            missionAssignment.Id = missionAssignmentId;
            missionAssignment.Status__c = ConstantsHelper.COMPLETED_STATUS;
            update missionAssignment;
            return missionAssignment;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class ResponseWrapper {
        @AuraEnabled public Superhero_Mission__c mission;
        @AuraEnabled public Mission_Assignment__c assignment;
    }
}