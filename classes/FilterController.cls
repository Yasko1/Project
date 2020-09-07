/**
 * Created by Hanna_Yasko on 2/5/2020.
 */

public with sharing class FilterController {

    @AuraEnabled(Cacheable=true)
    public static List<String> searchCategories(){
        List<RecordType> types = [SELECT RecordType.DeveloperName FROM RecordType Where SobjectType = 'Selling_Product__c'];
        List<String> availableCategories = new List<String>();
        for(RecordType type : types){
            availableCategories.add(type.DeveloperName);
        }
        return availableCategories;
    }

    @AuraEnabled(Cacheable=true)
    public static Decimal searchForMaxPrice(){
        return (Decimal)[SELECT MAX(Price__c) maxPrice FROM Selling_Product__c ].get(0).get('maxPrice');
    }
}