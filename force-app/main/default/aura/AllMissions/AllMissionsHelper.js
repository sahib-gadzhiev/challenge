({
    getAvailableMissions : function(component,event, helper) {
        let misisonList = [];
        var action = component.get("c.getAllMissions");
        action.setCallback(this, (response) => {
            console.log('response', response);
            let state = response.getState();
            if (state === "SUCCESS") {
                misisonList = response.getReturnValue();
                console.log('misisonList', misisonList);
                component.set("v.missionList", misisonList);
            }
            else if (state === "INCOMPLETE") {
                
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            
        });

        $A.enqueueAction(action);
    },

    updateMissionSelection : function(component,event, helper) {
        let missionList = component.get("v.missionList");
        let missionId = event.getParam("missionId");
        console.log(missionId);
        missionList.forEach(
            mission => {
                
                if(mission.Id === missionId) {
                    mission.selected = true;
                } else {
                    mission.selected = false;
                }
            }
        );
        console.log(missionList);
        component.set("v.missionList", missionList);

        var payload = {
            recordId: missionId,
        };
        component.find("selectMissionChannel").publish(payload);
    }
})
