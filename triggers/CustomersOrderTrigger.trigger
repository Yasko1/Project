/**
 * Created by Hanna_Yasko on 1/30/2020.
 */
trigger CustomersOrderTrigger on Customer_s_Order__c (after update, after insert) {
    if (CustomersOrderHandler.isFirstRun) {
        /* After Update */
        if (Trigger.isUpdate && Trigger.isAfter) {
            CustomersOrderHandler.isFirstRun = false;
            CustomersOrderHandler.onAfterUpdate(Trigger.oldMap, Trigger.newMap);
        }

        /* After Insert */
        if (Trigger.isInsert && Trigger.isAfter){
            CustomersOrderHandler.isFirstRun = false;
            CustomersOrderHandler.onAfterInsert(Trigger.newMap);
        }
    }
}