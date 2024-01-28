({
    init: function(component, event, helper) {
        let mission = component.get('v.mission');
        let statusBadgeClass = '';
        if(mission.Status__c === 'Available') {
            statusBadgeClass = 'green-badge';
        }
        if(mission.Status__c === 'In Progress') {
            statusBadgeClass = 'blue-badge';
        }

        if(mission.Status__c === 'Completed') {
            statusBadgeClass = 'gray-badge';
        }

        component.set('v.statusBageClass', statusBadgeClass);
    },
    
    selectMission : function(component, event, helper) {
        let mission = component.get("v.mission");
        var cmpEvent = component.getEvent("selectMission");
        cmpEvent.setParams({
            "missionId" : mission.Id 
        });
        cmpEvent.fire();
    }
})
