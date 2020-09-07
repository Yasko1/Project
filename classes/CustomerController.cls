/**
 * Created by Hanna_Yasko on 2/3/2020.
 */

public with sharing class CustomerController {

    @AuraEnabled
    public static void saveProducts(String products, String deliveryType) {
        System.debug(products);
        Map<String, Integer> productMap = (Map<String, Integer>)
                JSON.deserialize(products, Map<String, Integer>.class);

        Customer_s_Order__c order = new Customer_s_Order__c();
        order.Delivery_Type__c = deliveryType;
        insert order;

        List<Selling_Product__c> sell_products = [
                SELECT Id
                FROM Selling_Product__c
                WHERE Id IN:productMap.keySet()
        ];

        List<Order_Detail__c> orderDetails = new List<Order_Detail__c>();

        for (Selling_Product__c product : sell_products) {
            Integer quantity = productMap.get(product.Id);
            orderDetails.add(new Order_Detail__c(
                    Selling_Product__c = product.Id,
                    Quantity__c = quantity,
                    Customer_s_Order__c = order.Id));
        }
        insert orderDetails;
    }

    @AuraEnabled(Cacheable=true)
    public static List<Selling_Product__c> searchProducts(String searchTerm, Decimal maxPrice, List<String> categories){
        return Database.query('SELECT Id, Name, Price__c, RecordType.DeveloperName, Account__r.Name FROM Selling_Product__c ' +
                'WHERE Available_Quantity__c > 0 AND Price__c <= :maxPrice AND RecordType.DeveloperName IN :categories AND Name LIKE \'%' + searchTerm + '%\'');
    }
}