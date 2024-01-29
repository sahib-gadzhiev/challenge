import { LightningElement, wire } from 'lwc';
import { publish,subscribe,unsubscribe,createMessageContext,releaseMessageContext } from 'lightning/messageService';
import selectMissionChannel from "@salesforce/messageChannel/selectMissionChannel__c";
import updateMissionStatus from "@salesforce/messageChannel/updateMissionStatus__c";
import getMissionAssignment from '@salesforce/apex/MissionDetailController.getMissionAssignment';
import createAssignment from '@salesforce/apex/MissionDetailController.createAssignment';
import completeMission from '@salesforce/apex/MissionDetailController.completeMission';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import EMPTY_DETAILS_LABEL from "@salesforce/label/c.Empty_Detail_Label";

const MISSION_ASSIGNED_LABEL = 'Mission Assigned Successfully';
const MISSION_COMPLETED_LABEL = 'Mission Completed Successfully';
const ACCEPT_LABEL= 'Accept';
const COMPLETE_LABEL = 'Complete';
const DEADLINE_LABEL= 'Deadline';
const REWARD_LABEL = 'Reward';
const RANK_LABEL= 'Complexity Rank';
const DETAILS_LABEL = 'Details';
const SUBJECT_LABEL= 'Subject';
const ERROR_LABEL = 'Error';
const COMPLETED_STATUS = 'Completed';
const MISSION_DETAILS_LABEL = 'Mission Details';
const IN_PROGRESS_STATUS = 'In Progress';
const SUCCESS_VARIANT = 'success';
const IS_PUBLIC_LABEL = 'Is Public';

export default class MissionDetail extends LightningElement {
    objectApiName = 'Superhero_Mission__c';
    recordId;

    subscription = null;
    context = createMessageContext();
    missionAssinment;
    mission;
    isLoading = false;

    labels = {
        ACCEPT_LABEL,
        COMPLETE_LABEL,
        DEADLINE_LABEL,
        REWARD_LABEL,
        RANK_LABEL,
        DETAILS_LABEL,
        SUBJECT_LABEL,
        MISSION_DETAILS_LABEL,
        EMPTY_DETAILS_LABEL,
        IS_PUBLIC_LABEL
    }

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
        if(this.recordId !== message.recordId) {
            this.isLoading = true;
        }
        this.recordId = message.recordId;
    }

    createAssignment(event) {
        createAssignment({
            missionId : this.recordId
        }).then(result => {
            this.fireToastEvent(SUCCESS_VARIANT, MISSION_ASSIGNED_LABEL, '');
            this.missionAssinment = result;
            this.publishMC();
        }).catch(error => {
            this.fireToastEvent(ERROR_LABEL.toLowerCase(), ERROR_LABEL, error.body.message);
            console.log("error", error);
        })
    }

    completeMission(event) {
        completeMission({
            missionAssignmentId : this.missionAssinment.Id
        }).then(result => {
            this.fireToastEvent(SUCCESS_VARIANT, MISSION_COMPLETED_LABEL, '');
            this.dispatchEvent(event);
            this.missionAssinment = result;
            this.publishMC();
        }).catch(error => {
            this.fireToastEvent(ERROR_LABEL.toLowerCase(), ERROR_LABEL, error.body.message);
            console.log('error', error);
        });
    }

    publishMC() {
        const message = {
        };
        publish(this.context, updateMissionStatus, message);
    }

    fireToastEvent(variant, title, message) {
        const event = new ShowToastEvent({
            title: title,
            message : message,
            variant: variant            
        });
        this.dispatchEvent(event);
    }

    get showCreateAssignment() {
        return this.mission && !this.missionAssinment && this.mission.Status__c !== COMPLETED_STATUS; 
    }

    get showCompleteMission() {
        return  this.missionAssinment && this.missionAssinment.Status__c === IN_PROGRESS_STATUS
    }
}