/**
 * Created by Hanna_Yasko on 2/3/2020.
 */
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent } from 'c/pubsub';
import { LightningElement, track, wire } from 'lwc';
import searchProducts from '@salesforce/apex/CustomerController.searchProducts';
import searchCategories from '@salesforce/apex/FilterController.searchCategories';
import searchForMaxPrice from '@salesforce/apex/FilterController.searchForMaxPrice';

export default class ProductList extends LightningElement {

	@track searchTerm = '';
	@track products;
	categories;
	@track maxPrice;
	filterArray = [];
	@track maxExistingPrice;

    @wire(CurrentPageReference) pageRef;
    @wire(searchProducts, {searchTerm: '$searchTerm', maxPrice: '$maxPrice', categories: '$filterArray'})
    loadProducts(result) {
    	this.products = result;
    	if (result.data) {
    		fireEvent(this.pageRef, 'productListUpdate', result.data);
    	}
    }

    connectedCallback() {
        searchForMaxPrice().then(result => {
            this.maxPrice = result;
            this.maxExistingPrice = result;
            });
        searchCategories().then(result => {
            this.categories = result;
            result.forEach(item => this.filterArray.push(item));
            });
        }

	get hasResults() {
		return (this.products.data.length > 0);
	}

	handleProductAdding(event) {
		const product = event.detail;
        fireEvent(this.pageRef, 'productAddingToCard', product);
	}

	handleFilter(event){
	    this.maxPrice = event.detail.get('maxPrice');
	    this.searchTerm = event.detail.get('searchTerm');
	    this.filterArray = event.detail.get('filterArray');
	    console.log(this.filterArray);
	    console.log(this.maxPrice);
	    console.log(this.searchTerm);
 }
}