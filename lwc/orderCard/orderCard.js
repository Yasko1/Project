/**
 * Created by Hanna_Yasko on 2/4/2020.
 */


import { LightningElement, wire, api, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { registerListener, unregisterAllListeners, fireEvent } from 'c/pubsub';
import getAllOrders from '@salesforce/apex/OrderController.getAllOrders'

export default class OrderCard extends LightningElement {
    @api order;
    @track orders;
    @track error;

    @wire(CurrentPageReference) pageRef;

    @wire(getAllOrders)
    loadOrders() {
        		getAllOrders()
        		.then(result =>
        		{
        			this.orders = result;
        		}).catch(error => {
        				this.error = error;
        			});
        }

    connectedCallback() {
    		this.loadOrders();
    }

    handleProductSelected(event) {
           fireEvent(this.pageRef, 'productSelected', event.detail);
    }

    handlePreviousPage() {
            this.pageNumber = this.pageNumber - 1;
    }

    handleNextPage() {
            this.pageNumber = this.pageNumber + 1;
    }

}