/**
 * Created by Hanna_Yasko on 1/31/2020.
 */

public with sharing class OrderCalloutClass {

    static Creds__mdt credentials =
    [SELECT Endpoint__c,
            Security_token__c
    FROM Creds__mdt
    WHERE DeveloperName = 'Warehouse_creds'
    LIMIT 1];

    public static HttpResponse patchProductsToWarehouse(List<Selling_Product__c> products){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setEndpoint(credentials.Endpoint__c + 'Selling_Product__c/?_HttpMethod=PATCH');
        request.setHeader('Authorization','Bearer '+ credentials.Security_token__c);
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setBody(JSON.serialize(products));
        HttpResponse response = http.send(request);
        return response;
    }
}