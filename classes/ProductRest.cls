/**
 * Created by Hanna_Yasko on 2/3/2020.
 */

@RestResource(UrlMapping='/Selling_Product__c/*')
global with sharing class ProductRest {

    @HttpPost
    global static void saveNewProducts() {
        RestRequest request = RestContext.request;
        if (request.requestBody != null){
            List<Selling_Product__c> products = (List<Selling_Product__c>) JSON.deserialize(request.requestBody.toString(), List<Selling_Product__c>.class);
            if (!products.isEmpty()) {
                Set<String> externalAccounts = new Set<String>();
                Set <String> externalRecordTypes = new Set<String>();
                for(Selling_Product__c product : products){
                    externalRecordTypes.add(product.recordType.DeveloperName);
                    product.Id = null;
                    externalAccounts.add(product.Account_External_Id__c);
                }
                Map<String, Id> internalRecordTypesMap = new Map<String, Id>();
                for (RecordType recordType : [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName IN :externalRecordTypes]){
                    internalRecordTypesMap.put(recordType.DeveloperName, recordType.Id);
                }
                Map<String, Id> accountsMap = new Map<String, Id>();
                for (Account account : [SELECT External_Id__c FROM Account WHERE External_Id__c IN :externalAccounts]){
                    accountsMap.put(account.External_Id__c, account.Id);
                }
                for (Selling_Product__c product : products){
                    product.Account__c = accountsMap.get(product.Account_External_Id__c);
                    product.RecordTypeId = internalRecordTypesMap.get(product.RecordType.DeveloperName);
                }
                insert products;
            }
        }
    }

    @HttpPatch
    global static void updateProducts(){
        RestRequest request = RestContext.request;
        if (request.requestBody != null){
            List<Selling_Product__c> products = (List<Selling_Product__c>) JSON.deserialize(request.requestBody.toString(), List<Selling_Product__c>.class);
            List<String> ids = new List<String>();
            for (Selling_Product__c product : products){
                ids.add(product.External_Id__c);
            }
            List<Selling_Product__c> productsForUpdate = [SELECT External_Id__c FROM Selling_Product__c WHERE External_Id__c IN :ids];
            Map<String, Id> productsMap = new Map<String, Id>();
            for (Selling_Product__c product : productsForUpdate){
                productsMap.put(product.External_Id__c, product.Id);
            }
            for (Selling_Product__c product : products){
                product.Id = productsMap.get(product.External_Id__c);
            }
            update products;
        }
    }


    @HttpDelete
    global static void deleteProducts() {
        RestRequest request = RestContext.request;
        if (request.requestBody != null){
            List<String> ids = (List<String>) JSON.deserialize(request.requestBody.toString(), List<String>.class);
            List<String> idList = new List<String>();
            for(String id : ids){
                if (id.length() > 15){
                    id = id.substring(0, 15);
                    idList.add(id);
                }
            }
            if (!idList.isEmpty()) {
                delete [SELECT Id FROM Selling_Product__c WHERE External_Id__c IN :idList];
            }
        }
    }
}