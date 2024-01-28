trigger SuperheroMissionTrigger on Superhero_Mission__c (before insert, after insert,before update, after update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            MissionTriggerHandler.onBeforeInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            MissionTriggerHandler.onBeforeUpdate(Trigger.new, Trigger.oldMap);
        }
    } else if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            MissionTriggerHandler.onAfterInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            MissionTriggerHandler.onAfterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}