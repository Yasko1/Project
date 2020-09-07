/**
 * Created by Hanna_Yasko on 2/3/2020.
 */
 import { LightningElement, track, wire } from 'lwc';
import searchCategories from '@salesforce/apex/FilterController.searchCategories';
import searchForMaxPrice from '@salesforce/apex/FilterController.searchForMaxPrice';

export default class ProductList extends LightningElement {

	@track searchTerm = '';
	@track categories;

	@track maxPrice;
	@track filterArray;
	@track maxExistingPrice;
	@track filterMap;

    constructor(){
        super();
        this.filterMap = new Map();
                searchForMaxPrice().then(result => {
                    this.maxPrice = result;
                    this.filterMap.set('maxPrice', this.maxPrice);
                    this.maxExistingPrice = result;
                    });
                searchCategories().then(result => {
                    this.categories = result;
                    this.filterArray = [];
                    result.forEach(item => this.filterArray.push(item));
                    this.filterMap.set('filterArray', this.filterArray);
                    });
                this.filterMap.set('searchTerm', this.searchTerm);
    }

    connectedCallback() {
        this.delayTimeout = setTimeout(() => {
                    this.filterChanging();
        		}, 300);
        }

	handleSearchTermChange(event) {
		window.clearTimeout(this.delayTimeout);
		const searchTerm = event.target.value;
		this.delayTimeout = setTimeout(() => {
			this.searchTerm = searchTerm;
			this.filterMap.set('searchTerm', this.searchTerm);
            this.filterChanging();
		}, 300);
	}

    handleCheckboxChange(event){
        if (event.target.checked) {
           if (!this.filterArray.includes(event.target.dataset.value)) {
               const checkedValue = event.target.dataset.value;
               this.filterArray = [...this.filterArray, checkedValue];
               }
         } else {
                if (this.filterArray.includes(event.target.dataset.value)) {
                this.filterArray = this.filterArray.filter(item => item !== event.target.dataset.value);
             }
         }
         this.filterMap.set('filterArray', this.filterArray);
         this.filterChanging();
    }

    handleMaxPriceChange(event){
        this.maxPrice = event.target.value;
        this.filterMap.set('maxPrice', this.maxPrice);
        this.filterChanging();
    }


    filterChanging(){
        console.log(this.filterMap);
        const filteringEvent = new CustomEvent('filtering', {
        		detail: this.filterMap
        	});
        this.dispatchEvent(filteringEvent);
    }
}