public with sharing class MissionAssignmentTriggerHandler {
    static final Map<String, Integer> rankValueMap = new Map<String, Integer> {
        'S' => 5,
        'A' => 4,
        'B' => 3,
        'C' => 2,
        'D' => 1
    };
   
    static final String RANK_ERROR_MESSAGE = 'К сожалению вы слишком слабый на данный момент чтобы взяться за эту работку! Возвращайтесь когда достигните ранга {0}';
    public static void onBeforeInsert(List<Mission_Assignment__c> newRecordList) {
        validateAssignments(newRecordList);
        validateMissionsAccess(newRecordList);
    }

    public static void onBeforeUpdate(List<Mission_Assignment__c> updatedRecordList, Map<Id, Mission_Assignment__c> oldRecordMap) {
        
    }

    public static void onAfterInsert(List<Mission_Assignment__c> newRecordList) {
        startMissions(newRecordList);
    }

    public static void onAfterUpdate(List<Mission_Assignment__c> updatedRecordList, Map<Id, Mission_Assignment__c> oldRecordMap) {
        completeMissions(updatedRecordList, oldRecordMap);
    }

    static void validateAssignments(List<Mission_Assignment__c> recordList) {
        List<Id> heroesIdList = new List<Id>();
        Map<Id, Integer> heroMissionNumberMap = new Map<Id,Integer>();

        for(Mission_Assignment__c assignment : recordList) {
            heroesIdList.add(assignment.Hero__c);
        }

        AggregateResult[] groupedResults = [
            SELECT  Count(Id), Hero__c 
            FROM    Mission_Assignment__c 
            WHERE   Hero__c = :heroesIdList 
            AND     Status__c = :ConstantsHelper.IN_PROGRESS_STATUS 
            GROUP   BY Hero__c
        ];
        for (AggregateResult ar : groupedResults)  {
            heroMissionNumberMap.put((Id)ar.get('Hero__c'),(Integer)ar.get('expr0'));
            // System.debug('Campaign ID' + ar.get('Hero__c'));
            // System.debug('Average amount' + ar.get('expr0'));
        }

        for(Mission_Assignment__c assignment : recordList) {
            if(heroMissionNumberMap.get(assignment.Hero__c) >= ConstantsHelper.MAX_MISSION_PER_USER) {
                assignment.addError('You can\'t take more then ' + ConstantsHelper.MAX_MISSION_PER_USER + ' missions');
            }
        }

    }

    static void startMissions(List<Mission_Assignment__c> recordList) {
        List<Id> missionIdList = new List<Id>();

        for(Mission_Assignment__c assignment : recordList) {
            missionIdList.add(assignment.Mission__c);
        }
        Map<Id, Superhero_Mission__c> missionMap = new Map <Id, Superhero_Mission__c>(SelectorHelper.getHeroMissionsByIds(missionIdList));


        for(Superhero_Mission__c mission : missionMap.values()) {
            if(mission.Status__c == ConstantsHelper.AVAILABLE_STATUS) {
                mission.Status__c = ConstantsHelper.IN_PROGRESS_STATUS;
            }
        }

        update missionMap.values();
    }

    static void validateMissionsAccess(List<Mission_Assignment__c> recordList) {
        List<Id> missionIdList = new List<Id>();
        List<Id> heroIdList = new List<Id>();
        for(Mission_Assignment__c assignment : recordList) {
            missionIdList.add(assignment.Mission__c);
            heroIdList.add(assignment.Hero__c);
        }
        Map<Id, Superhero_Mission__c> missionMap = new Map <Id, Superhero_Mission__c>(SelectorHelper.getHeroMissionsByIds(missionIdList));
        Map<Id, Hero__c> heroMap = new Map <Id, Hero__c>(SelectorHelper.getHeroesByIds(heroIdList));


        
        for(Mission_Assignment__c assignment : recordList) {
            Integer rankDifference = rankValueMap.get(heroMap.get(assignment.Hero__c).Rank__c) - rankValueMap.get(missionMap.get(assignment.Mission__c).Complexity_Rank__c);
            if(Math.abs(rankDifference) > 1){
                assignment.addError(String.format(RANK_ERROR_MESSAGE, new List<string> {missionMap.get(assignment.Mission__c).Complexity_Rank__c}));
            }
        }
    }

    static void completeMissions(List<Mission_Assignment__c> recordList, Map<Id, Mission_Assignment__c> oldRecordMap) {
        List<Id> missionIdList = new List<Id>();
        List<Id> completedMissionIdList = new List<Id>();
        for(Mission_Assignment__c assignment : recordList) {
            if(oldRecordMap.get(assignment.Id).Status__c != assignment.Status__c && assignment.Status__c == ConstantsHelper.COMPLETED_STATUS) {
                missionIdList.add(assignment.Mission__c);
            }
                
        }
        Map<Id, Superhero_Mission__c> missionMap = new Map <Id, Superhero_Mission__c>(SelectorHelper.getHeroMissionsByIds(missionIdList));

        for(Superhero_Mission__c mission : missionMap.values()) {
            if(mission.Status__c == ConstantsHelper.IN_PROGRESS_STATUS) {
                mission.Status__c = ConstantsHelper.COMPLETED_STATUS;
                completedMissionIdList.add(mission.Id);
            }
        }
        update missionMap.values();

        List<Mission_Assignment__c> otherAssignmentList = [
            SELECT  Id, Status__c 
            FROM    Mission_Assignment__c 
            WHERE   Mission__c = :completedMissionIdList 
            AND     Id != :recordList
            AND     Status__c = :ConstantsHelper.IN_PROGRESS_STATUS
            LIMIT   10000  
        ];  
        
        for(Mission_Assignment__c assignment : otherAssignmentList) {
            assignment.Status__c = ConstantsHelper.FAILED_STATUS;
        }

        update otherAssignmentList;
    }
}