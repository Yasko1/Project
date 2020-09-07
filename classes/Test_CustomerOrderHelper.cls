@IsTest
public class Test_CustomerOrderHelper {

    public static Customer_s_Order__c createOrder(String deliveryType, String status, Boolean needInsert) {
        Customer_s_Order__c order = new Customer_s_Order__c();
        order.Delivery_Type__c = deliveryType;
        order.Status__c = status;
        if (needInsert) {
            insert order;
        }
        return order;
    }

    public static List<Customer_s_Order__c> createListOfOrders(Integer numOfOrders, String deliveryType, String status, Boolean needInsert) {
        List<Customer_s_Order__c> orders = new List<Customer_s_Order__c>();
        for (Integer i = 0; i < numOfOrders; i++) {
            orders.add(createOrder(deliveryType, status, false));
        }
        if (needInsert) {
            insert orders;
        }
        return orders;
    }

}