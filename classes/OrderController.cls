/**
 * Created by Hanna_Yasko on 2/4/2020.
 */

public with sharing class OrderController {

    @AuraEnabled(Cacheable=true)
    public static Customer_s_Order__c[] getAllOrders(){
        Id myId = UserInfo.getUserId();
        return [SELECT Id, Name, Creation_Date__c, Total_Quantity__c,
                Total_Ammount__c,Status__c, Delivery_Type__c
        FROM Customer_s_Order__c
        WHERE OwnerId != :myId
        ORDER BY Name];
    }

    @AuraEnabled(Cacheable=true)
    public static Customer_s_Order__c[] getAllAsignedOrders(){
        Id myId = UserInfo.getUserId();
        return [SELECT Id, Name, Creation_Date__c, Total_Quantity__c,
        Total_Ammount__c, Status__c, Delivery_Type__c
        FROM Customer_s_Order__c
        WHERE OwnerId=:myId
        ORDER BY Status__c];
    }

    @AuraEnabled(Cacheable=true)
    public static String getMyId () {
        Id myId = UserInfo.getUserId();
        return [SELECT Id FROM User WHERE Id=:myId].Id;
    }

    @AuraEnabled
    public static void sendOrder(Id orderId) {
        Customer_s_Order__c customerSOrder = [SELECT Status__c FROM Customer_s_Order__c WHERE Id=:orderId];
        customerSOrder.Status__c='Sent to Customer';
        update customerSOrder;
    }

    @AuraEnabled
    public static void cancelOrder(Id orderId) {
        Customer_s_Order__c customerSOrder = [SELECT Status__c FROM Customer_s_Order__c WHERE Id=:orderId];
        customerSOrder.Status__c='Canceled';
        update customerSOrder;
    }

    @AuraEnabled
    public static void handleOrder(Id orderId) {
        Id myId = UserInfo.getUserId();
        Customer_s_Order__c customerSOrder = [SELECT OwnerId FROM Customer_s_Order__c WHERE Id=:orderId];
        customerSOrder.OwnerId = myId;
        update customerSOrder;
    }
}