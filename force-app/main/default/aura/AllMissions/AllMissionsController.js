({
    init : function(component, event, helper) {
        helper.getAvailableMissions(component, event, helper);
        const empApi = component.find('empApi');
        empApi.onError($A.getCallback(error => {
            // Error can be any type of error (subscribe, unsubscribe...)
            console.error('EMP API error: ', JSON.stringify(error));
        }));
        
        const channel = '/event/Superhero_Mission__ChangeEvent';
        // Replay option to get new events
        const replayId = -1;

        // Subscribe to an event
        empApi.subscribe(channel, replayId, $A.getCallback(eventReceived => {
            console.log('Received event ', JSON.stringify(eventReceived));
        })).then(subscription => {
            // Subscription response received.
            // We haven't received an event yet.
            console.log('Subscription request sent to: ', subscription.channel);
            // Save subscription to unsubscribe later
            component.set('v.subscription', subscription);
        }).catch(error=> {
            console.log('event error', error);
        });

    },

    handleSelectMission : function(component, event, helper) {
        helper.updateMissionSelection(component, event, helper);
    }
})
