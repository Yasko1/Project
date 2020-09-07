/**
 * Created by Hanna_Yasko on 2/10/2020.
 */

public with sharing class OrderDetailHelper {

    public static void changeAvailableQuantity(List<Order_Detail__c> newOrder){
        Set<Id> ids = new Set<Id>();
        for(Order_Detail__c order : newOrder){
            ids.add(order.Selling_Product__c);
        }

        Map<Id, Selling_Product__c> products = new Map<Id, Selling_Product__c>(
        [SELECT Name, Available_Quantity__c, Ordered_Quantity__c
        FROM Selling_Product__c
        WHERE Id IN :ids]);
        for(Order_Detail__c order : newOrder){
            if(order.Quantity__c <= products.get(order.Selling_Product__c).Available_Quantity__c){
                if (products.get(order.Selling_Product__c).Ordered_Quantity__c != null) {
                    products.get(order.Selling_Product__c).Ordered_Quantity__c += order.Quantity__c;
                } else {
                    products.get(order.Selling_Product__c).Ordered_Quantity__c = order.Quantity__c;
                }
            } else {
                throw new NotEnoughProductsException('Not enough ' + products.get(order.Selling_Product__c).Name + ' on the warehouse!');
            }
        }
        CustomersOrderHelper.sendProductChangesToWarehouse(products.keySet());
        update products.values();
    }
}