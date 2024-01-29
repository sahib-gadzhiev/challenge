public with sharing class MissionDetailController {

    @AuraEnabled(cacheable=true)
    public static  Map<String, SObject> getMissionAssignment(Id missionId){
        try {
            Hero__c hero = SelectorHelper.getHeroByCurrentUser();
            Superhero_Mission__c mission = WithoutSharingSelector.getHeroMissionById(missionId);
            Mission_Assignment__c assignment = SelectorHelper.getMissionAssignment(hero.Id, missionId);

            Map<String, SObject> responseMap = new Map<String, SObject>();
            //todo remove hardcode
            responseMap.put('mission',mission);
            responseMap.put('assignment',assignment);
            return responseMap;
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
}