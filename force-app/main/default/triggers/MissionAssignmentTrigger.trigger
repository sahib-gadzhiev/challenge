trigger MissionAssignmentTrigger on Mission_Assignment__c (before insert, after insert,before update, after update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            MissionAssignmentTriggerHandler.onBeforeInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            MissionAssignmentTriggerHandler.onBeforeUpdate(Trigger.new, Trigger.oldMap);
        }
    } else if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            MissionAssignmentTriggerHandler.onAfterInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            MissionAssignmentTriggerHandler.onAfterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}