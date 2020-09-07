/**
 * Created by Hanna_Yasko on 2/3/2020.
 */

@RestResource(UrlMapping = '/Account/*')
global with sharing class AccountRest {

    @HttpPost
    global static void saveNewAccounts() {
        RestRequest request = RestContext.request;
        if (request.requestBody != null){
            List<Account> accounts = (List<Account>) JSON.deserialize(request.requestBody.toString(), List<Account>.class);
            if (!accounts.isEmpty()) {
                for (Account account : accounts){
                    account.Id = null;
                }
                insert accounts;
            }
        }
    }

    @HttpDelete
    global static void deleteAccounts() {
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
                delete [SELECT Id FROM Account WHERE External_Id__c IN :idList];
            }
        }
    }
}