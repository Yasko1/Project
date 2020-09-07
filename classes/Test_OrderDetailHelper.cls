@IsTest
public with sharing class Test_OrderDetailHelper {

    public static Order_Detail__c createDetail(Id productId, Id orderId, Integer quantity, Boolean needInsert) {
        Order_Detail__c detail = new Order_Detail__c();
        detail.Selling_Product__c = productId;
        detail.Customer_s_Order__c = orderId;
        detail.Quantity__c = quantity;
        if (needInsert) {
            insert detail;
        }
        return detail;
    }

    public static List<Order_Detail__c> createListOfDetails(Integer numOfDetails, Id productId, Id orderId, Integer quantity, Boolean needInsert) {
        List<Order_Detail__c> details = new List<Order_Detail__c>();
        for (Integer i = 0; i < numOfDetails; i++) {
            details.add(createDetail(productId, orderId, quantity, false));
        }
        if (needInsert) {
            insert details;
        }
        return details;
    }

}