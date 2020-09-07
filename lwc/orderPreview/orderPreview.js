/**
 * Created by Hanna_Yasko on 2/7/2020.
 */
 import { LightningElement, wire, track, api } from 'lwc';
 import { CurrentPageReference } from 'lightning/navigation';
 import { NavigationMixin } from 'lightning/navigation';
 import { getRecord } from 'lightning/uiRecordApi';
 import getMyId from '@salesforce/apex/OrderController.getMyId';
 import cancelOrder from '@salesforce/apex/OrderController.cancelOrder';
 import sendOrder from '@salesforce/apex/OrderController.sendOrder';
 import handleOrder from '@salesforce/apex/OrderController.handleOrder';
 import { registerListener, unregisterAllListeners } from 'c/pubsub';
 import Name from '@salesforce/schema/Customer_s_Order__c.Name';
 import Status from '@salesforce/schema/Customer_s_Order__c.Status__c';
 import Delivery_Type from '@salesforce/schema/Customer_s_Order__c.Delivery_Type__c';
 import Total_Ammount from '@salesforce/schema/Customer_s_Order__c.Total_Ammount__c';
 import Total_Quantity from '@salesforce/schema/Customer_s_Order__c.Total_Quantity__c';
 import OwnerId from '@salesforce/schema/Customer_s_Order__c.OwnerId';
 import Id from '@salesforce/schema/Customer_s_Order__c.Id';

 const FIELDS = [
     Name,
     Status,
     Delivery_Type,
     Total_Ammount,
     Total_Quantity,
     OwnerId,
     Id
 ];

 export default class OrderPreview extends NavigationMixin(LightningElement) {

     recordId;
     @wire(CurrentPageReference) pageRef;

     @wire (getRecord, { recordId: '$recordId', fields : FIELDS })
     order;

     @wire( getRecord, {recordId : '$recordId', fields : OwnerId})
     orderOwner;

     @wire(getMyId)
     myId;

     @track checkOwner;
     @track checkStatus;

     connectedCallback() {
         registerListener('productSelected', this.handleProductSelected, this);
         this.checkOwner=false;
         this.checkStatus=false;

         this.delayTimeout = setTimeout(() => {
                     this.checkOrderOwner();
               }, 300);
     }

     disconnectedCallback() {
         unregisterAllListeners(this);
     }

    handleProductSelected(event) {
        this.recordId = event;
        this.checkOrderOwner();
        this.checkStatusOrder();
    }

    checkOrderOwner(){
        if(this.orderOwner.data.fields.OwnerId.value==this.myId.data){
            this.checkOwner=true;
        } else {
            this.checkOwner=false;
        }
    }

    checkStatusOrder(){
        if(this.order.data.fields.Status__c.value=='In Progress'){
             this.checkStatus=true;
        } else {
              this.checkStatus=false;
        }
    }

     handleCancel(event) {
         cancelOrder({ orderId : this.recordId});
         location.reload();
     }

     handleSend(event){
         sendOrder({ orderId : this.recordId});
         location.reload();
     }

     handleClickHandle(){
         handleOrder({ orderId : this.recordId});
         location.reload();
     }

     get noData() {
         return !this.order.error && !this.order.data;
     }

  }