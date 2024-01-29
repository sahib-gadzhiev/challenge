@isTest
public with sharing class MissionAssignmentTriggerHandlerTest {
    @TestSetup
    static void makeData(){
        TestHelper.generateData();
    }

    @isTest 
    static void testValidateAssignments() {
        User testUser = [SELECT Id, ContactId FROM User WHERE UserName = 'yourusername@gmail.com' LIMIT 1];
        PermissionSet ps = [SELECT Id 
                    FROM PermissionSet 
                    WHERE Name = 'Hero_User'];
        insert new PermissionSetAssignment(AssigneeId = testUser.Id, PermissionSetId = ps.Id);
        System.runAs(testUser) {
            System.assertEquals(testUser.Id, UserInfo.getUserId(), 'User ID should match');
            Hero__c hero = SelectorHelper.getHeroByCurrentUser();
            List<Superhero_Mission__c> missionList = WithoutSharingSelector.getHeroMissionsForHero(testUser.ContactId);
            System.debug(missionList);
            System.assert(missionList.size() == TestHelper.MISSION_NUMBER_FOR_INSERT);

            //add first three missions
            MissionDetailController.createAssignment(missionList[0].Id);
            MissionDetailController.createAssignment(missionList[1].Id);
            MissionDetailController.createAssignment(missionList[2].Id);
            List<Mission_Assignment__c> assignmentList = [SELECT Id FROM Mission_Assignment__c WHERE Hero__c = :hero.Id];
            System.assert(assignmentList.size() == ConstantsHelper.MAX_MISSION_PER_USER);

            //add 4 mission should exeption
            try {
                MissionDetailController.createAssignment(missionList[3].Id);
                System.assert(false);
            } catch(Exception e) {
                System.assert(true);
            }

            
        }
    }

    @isTest 
    static void testNegtiveValidateMissionsAccess() {
        User testUser = [SELECT Id, ContactId FROM User WHERE UserName = 'yourusername@gmail.com' LIMIT 1];
        PermissionSet ps = [SELECT Id 
                    FROM PermissionSet 
                    WHERE Name = 'Hero_User'];
        insert new PermissionSetAssignment(AssigneeId = testUser.Id, PermissionSetId = ps.Id);
        System.runAs(testUser) {
            System.assertEquals(testUser.Id, UserInfo.getUserId(), 'User ID should match');
            //by default Hero has A rank
            Hero__c hero = SelectorHelper.getHeroByCurrentUser();
            hero.Rank__c = 'D';
            WithoutSharingSelector.updateRecords(new List<SObject> {hero});
            //by default Mission has B rank
            List<Superhero_Mission__c> missionList = WithoutSharingSelector.getHeroMissionsForHero(testUser.ContactId);
            System.assert(missionList.size() == TestHelper.MISSION_NUMBER_FOR_INSERT);
            //Becouse User has low rank He isn't able to take mission with B rank
            try {
                MissionDetailController.createAssignment(missionList[0].Id);
                System.assert(false);
            } catch(Exception e) {
                System.assert(true);
            }

            
        }
    }

    @isTest 
    static void testCompleteMissionWithOherUsers() {
        User testUser = [SELECT Id, ContactId FROM User WHERE UserName = 'yourusername@gmail.com' LIMIT 1];
        PermissionSet ps = [SELECT Id 
                    FROM PermissionSet 
                    WHERE Name = 'Hero_User'];
        insert new PermissionSetAssignment(AssigneeId = testUser.Id, PermissionSetId = ps.Id);
        System.runAs(testUser) {
            System.assertEquals(testUser.Id, UserInfo.getUserId(), 'User ID should match');
            Hero__c hero = SelectorHelper.getHeroByCurrentUser();
            List<Superhero_Mission__c> missionList = WithoutSharingSelector.getHeroMissionsForHero(testUser.ContactId);

            System.assert(missionList.size() == TestHelper.MISSION_NUMBER_FOR_INSERT);           

            Mission_Assignment__c assignment = MissionDetailController.createAssignment(missionList[0].Id);

            MissionDetailController.completeMission(assignment.Id);
            
            assignment = SelectorHelper.getMissionAssignment(assignment.Id);

            System.assert(assignment.Status__c == ConstantsHelper.COMPLETED_STATUS);

            Superhero_Mission__c mission = WithoutSharingSelector.getHeroMissionById(missionList[0].Id);

            System.assert(mission.Status__c == ConstantsHelper.COMPLETED_STATUS);


            
        }
    }

    @isTest 
    static void testCompleteMissions() {
        User testUser = [SELECT Id, ContactId FROM User WHERE UserName = 'yourusername@gmail.com' LIMIT 1];
        PermissionSet ps = [SELECT Id 
                    FROM PermissionSet 
                    WHERE Name = 'Hero_User'];
        insert new PermissionSetAssignment(AssigneeId = testUser.Id, PermissionSetId = ps.Id);
        System.runAs(testUser) {
            System.assertEquals(testUser.Id, UserInfo.getUserId(), 'User ID should match');
            Hero__c hero = SelectorHelper.getHeroByCurrentUser();
            List<Superhero_Mission__c> missionList = WithoutSharingSelector.getHeroMissionsForHero(testUser.ContactId);
            System.assert(missionList.size() == TestHelper.MISSION_NUMBER_FOR_INSERT);           

            Mission_Assignment__c assignment = MissionDetailController.createAssignment(missionList[0].Id);
            Hero__c otherHero = [SELECT Id FROM Hero__c WHERE Id != :hero.Id LIMIT 1];
            Mission_Assignment__c assignmentForOtherHero = new Mission_Assignment__c();
            assignmentForOtherHero.Hero__c = otherHero.Id;
            assignmentForOtherHero.Mission__c = missionList[0].Id;
            WithoutSharingSelector.insertRecords(new List<SObject> {assignmentForOtherHero});

            MissionDetailController.completeMission(assignment.Id);
            assignment = SelectorHelper.getMissionAssignment(assignment.Id);
            System.assert(assignment.Status__c == ConstantsHelper.COMPLETED_STATUS);
            Superhero_Mission__c mission = WithoutSharingSelector.getHeroMissionById(missionList[0].Id);
            System.assert(mission.Status__c == ConstantsHelper.COMPLETED_STATUS);
            
            assignmentForOtherHero = SelectorHelper.getMissionAssignment(assignmentForOtherHero.Id);
            System.assert(assignmentForOtherHero.Status__c == ConstantsHelper.FAILED_STATUS);

            
        }
    }
}