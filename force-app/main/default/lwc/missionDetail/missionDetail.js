import { LightningElement, wire } from 'lwc';
import { publish,subscribe,unsubscribe,createMessageContext,releaseMessageContext } from 'lightning/messageService';
import selectMissionChannel from "@salesforce/messageChannel/selectMissionChannel__c";
import getMissionAssignment from '@salesforce/apex/MissionDetailController.getMissionAssignment';
import createAssignment from '@salesforce/apex/MissionDetailController.createAssignment';
import completeMission from '@salesforce/apex/MissionDetailController.completeMission';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const COMPLETED_STATUS = 'Completed';
const IN_PROGRESS_STATUS = 'In Progress';
export default class MissionDetail extends LightningElement {
    objectApiName = 'Superhero_Mission__c';
    recordId;

    subscription = null;
    context = createMessageContext();
    missionAssinment;
    isLoading = false;

    @wire(getMissionAssignment, {missionId : "$recordId"})
    wiredAssignment({ error, data }) {
        this.missionAssinment = null;
        if (data) {
            console.log('wiredAssignment', data);
            this.missionAssinment = data.assignment;
            this.mission = data.mission;
        } else if (error) {
            console.log('error', error);
        }
        this.isLoading = false;
    }

    connectedCallback() {
        this.subscribeMC();
    }

    disconnectedCallback() {
        this.unsubscribeMC();
    }

    subscribeMC() {
        if (this.subscription) {
            return;
        }
        this.subscription = subscribe(this.context, selectMissionChannel, (message) => {
            this.handleMessage(message);
        });
     }

     unsubscribeMC() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }
    

    
    handleMessage(message) {
        this.isLoading = true;
        this.recordId = message.recordId;
    }

    createAssignment(event) {
        createAssignment({
            missionId : this.recordId
        }).then(result => {
            const event = new ShowToastEvent({
                title: 'Mission Assigned Successfully',
                variant: 'success'            
            });
            this.dispatchEvent(event);
            this.missionAssinment = result;
        }).catch(error => {
            const event = new ShowToastEvent({
                title: 'Error',
                message : error.body.message,
                variant: 'error'            
            });
            this.dispatchEvent(event);
            console.log("error", error);
        })
    }

    completeMission(event) {
        completeMission({
            missionAssignmentId : this.missionAssinment.Id
        }).then(result => {
            const event = new ShowToastEvent({
                title: 'Mission Completed Successfully',
                variant: 'success'            
            });
            this.dispatchEvent(event);
            this.missionAssinment = result;
        }).catch(error => {
            const event = new ShowToastEvent({
                title: 'Error',
                message : error.body.message,
                variant: 'error'            
            });
            this.dispatchEvent(event);
            console.log('error', error);
        });
    }

    get showCreateAssignment() {
        return this.mission && !this.missionAssinment && this.mission.Status__c !== COMPLETED_STATUS; 
    }

    get showCompleteMission() {
        return  this.missionAssinment && this.missionAssinment.Status__c === IN_PROGRESS_STATUS
    }
}