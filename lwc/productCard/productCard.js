/**
 * Created by Hanna_Yasko on 2/3/2020.
 */
 import { LightningElement, api } from 'lwc';

export default class ProductCard extends LightningElement {
	@api product;

	handleAddToCartClick() {
    	const addEvent = new CustomEvent('productadding', {
    		detail: this.product
    	});
    	this.dispatchEvent(addEvent);
    }
}