({
    init : function(component, event, helper) {
        helper.getAvailableMissions(component, event, helper);
    },

    handleSelectMission : function(component, event, helper) {
        helper.updateMissionSelection(component, event, helper);
    }
})
