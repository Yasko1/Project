/**
 * Created by Hanna_Yasko on 2/7/2020.
 */

trigger OrderDetailTrigger on Order_Detail__c (before insert) {

    if (Trigger.isInsert && Trigger.isBefore){
        OrderDetailHandler.isFirstRun = false;
        OrderDetailHandler.onBeforeInsert(Trigger.new);
    }
}