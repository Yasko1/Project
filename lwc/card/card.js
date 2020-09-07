/**
 * Created by Hanna_Yasko on 2/6/2020.
 */

import { LightningElement, api, track } from 'lwc';

export default class Card extends LightningElement {
    @api draggable;
    _order;
    @api
    get order(){
        return this._order;
    }
    set order(value){
        this._order = value;
        this.Name = value.Name;
        this.Status__c=value.Status__c;
        this.Creation_Date__c=value.Creation_Date__c;
        this.Total_Ammount__c=value.Total_Ammount__c;
        this.Total_Quantity__c=value.Total_Quantity__c;
        this.Delivery_Type__c=value.Delivery_Type__c;
    }

    @track name;

    handleClick() {
        const selectedEvent = new CustomEvent('selected', {
            detail: this.order.Id
        });
        this.dispatchEvent(selectedEvent);
    }

    handleDragStart(event) {
        event.dataTransfer.setData('order', JSON.stringify(this.order));
    }
}