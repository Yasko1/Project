/**
 * Created by Hanna_Yasko on 2/7/2020.
 */

public with sharing class OrderDetailHandler {

    public static Boolean isFirstRun = true;

    public static void onBeforeInsert(List<Order_Detail__c> newOrder){
       OrderDetailHelper.changeAvailableQuantity(newOrder);
    }
}