public with sharing class MissionDetailController {
    public static String contactId = 'a01Qy000009TWP7IAO';

    @AuraEnabled(cacheable=true)
    public static  Map<String, SObject> getMissionAssignment(Id missionId){
        try {
            // User customerUser = [SELECT id, ContactId FROM User WHERE ContactId =:contactIdList];
            // contactId = customerUser.contactId;
            Superhero_Mission__c mission = WithoutSharingSelector.getHeroMissionById(missionId);
            Mission_Assignment__c assignment = SelectorHelper.getMissionAssignment(contactId, missionId);

            Map<String, SObject> responseMap = new Map<String, SObject>();
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
            Mission_Assignment__c missionAssignment = new Mission_Assignment__c();
            missionAssignment.Hero__c = contactId;
            missionAssignment.Mission__c = missionId;
            insert missionAssignment;

            return SelectorHelper.getMissionAssignment(contactId, missionId);
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