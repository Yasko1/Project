/**
 * Created by Hanna_Yasko on 2/5/2020.
 */

import { LightningElement, api, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { registerListener, unregisterAllListeners, fireEvent } from 'c/pubsub';
import getAllAsignedOrders from '@salesforce/apex/OrderController.getAllAsignedOrders'

export default class AssigneOrderCard extends LightningElement {

    @api order;
    @track orders;
    @track error;
    @wire(CurrentPageReference) pageRef;

    connectedCallback() {
        		this.loadOrders();
    }
    loadOrders() {
        		getAllAsignedOrders()
        		.then(result =>
        		{
        			this.orders = result;
        		}).catch(error => {
        				this.error = error;
        			});
    }

    handleProductSelected(event) {
               fireEvent(this.pageRef, 'productSelected', event.detail);
    }
}