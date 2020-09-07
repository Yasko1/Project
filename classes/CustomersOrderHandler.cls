public with sharing class CustomersOrderHandler {
    public static Boolean isFirstRun = true;

    private static final String IN_PROGRESS_STATUS = 'In Progress';
    private static final String SENT_TO_CUSTOMER_STATUS = 'Sent to Customer';
    private static final String CANCELED_STATUS = 'Canceled';

    public static void onAfterUpdate(Map<Id, Customer_s_Order__c> oldMap, Map<Id, Customer_s_Order__c> newMap) {
        CustomersOrderHelper.updateStatusToCanceledFromInProgress(findOrderIdsWithChangedStatusFromInProgressToCanceled(oldMap, newMap));
        CustomersOrderHelper.updateStatusToCanceledFromSentToCustomer(findOrderIdsWithChangedStatusFromSentToCustomerToCanceled(oldMap, newMap));
        CustomersOrderHelper.updateStatusToSentToCustomer(findOrderIdsWithChangedStatusFromInProgressToSentToCustomer(oldMap, newMap));
    }

    public static void onAfterInsert(Map<Id, Customer_s_Order__c> newMap){
        CustomersOrderHelper.addOrderToQueue(newMap.keySet());
    }

    private static Set<Id> findOrderIdsWithChangedStatusFromInProgressToCanceled(Map<Id, Customer_s_Order__c> oldMap,
            Map<Id, Customer_s_Order__c> newMap) {
        Set<Id> oldIds = new Set<Id>();
        for (Customer_s_Order__c customerSOrder : oldMap.values()) {
            if (customerSOrder.Status__c.equals(IN_PROGRESS_STATUS)) {
                oldIds.add(customerSOrder.Id);
            }
        }
        Set<Id> newIds = new Set<Id>();
        for (Customer_s_Order__c customerSOrder : newMap.values()) {
            if (customerSOrder.Status__c.equals(CANCELED_STATUS) && oldIds.contains(customerSOrder.Id)) {
                newIds.add(customerSOrder.Id);
            }
        }
        return newIds;
    }

    private static Set<Id> findOrderIdsWithChangedStatusFromSentToCustomerToCanceled(Map<Id, Customer_s_Order__c> oldMap,
            Map<Id, Customer_s_Order__c> newMap) {
        Set<Id> oldIds = new Set<Id>();
        for (Customer_s_Order__c customerSOrder : oldMap.values()) {
            if (customerSOrder.Status__c.equals(SENT_TO_CUSTOMER_STATUS)) {
                oldIds.add(customerSOrder.Id);
            }
        }
        Set<Id> newIds = new Set<Id>();
        for (Customer_s_Order__c customerSOrder : newMap.values()) {
            if (customerSOrder.Status__c.equals(CANCELED_STATUS) && oldIds.contains(customerSOrder.Id)) {
                newIds.add(customerSOrder.Id);
            }
        }
        return newIds;
    }

    private static Set<Id> findOrderIdsWithChangedStatusFromInProgressToSentToCustomer(Map<Id, Customer_s_Order__c> oldMap,
            Map<Id, Customer_s_Order__c> newMap) {
        Set<Id> oldIds = new Set<Id>();
        for (Customer_s_Order__c customerSOrder : oldMap.values()) {
            if (customerSOrder.Status__c.equals(IN_PROGRESS_STATUS)) {
                oldIds.add(customerSOrder.Id);
            }
        }
        Set<Id> newIds = new Set<Id>();
        for (Customer_s_Order__c customerSOrder : newMap.values()) {
            if (customerSOrder.Status__c.equals(SENT_TO_CUSTOMER_STATUS) && oldIds.contains(customerSOrder.Id)) {
                newIds.add(customerSOrder.Id);
            }
        }
        return newIds;
    }
}