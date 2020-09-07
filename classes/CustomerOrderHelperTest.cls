@IsTest
public with sharing class CustomerOrderHelperTest {
    private static final Integer ORDER_COUNT = 50;
    private static final String QUEUE = 'Queue';
    private static final String DELIVERY_TYPE_PICKUP = 'Pickup';
    private static final String DELIVERY_TYPE_DELIVERY = 'Delivery';
    private static final String STATUS_IN_PROGRESS = 'In Progress';
    private static final String STATUS_SENT_TO_CUSTOMER = 'Sent to Customer';
    private static final String STATUS_CANCELED = 'Canceled';

    @TestSetup
    static void setup() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Account account = Test_AccountHelper.createAccount('Account #1', true);
        Selling_Product__c sellingProduct = Test_SellingProductHelper.createProduct('Product #1', 10, 100, account.Id, true);
        List<Customer_s_Order__c> customerPickupOrders = Test_CustomerOrderHelper.createListOfOrders(1, DELIVERY_TYPE_PICKUP, STATUS_IN_PROGRESS, true);
        List<Order_Detail__c> orderDetails = new List<Order_Detail__c>();
        for (Customer_s_Order__c customerSOrder : customerPickupOrders) {
            orderDetails.add(Test_OrderDetailHelper.createDetail(sellingProduct.Id, customerSOrder.Id, 1, false));
        }
        insert orderDetails;
        List<Customer_s_Order__c> customerDeliveryOrders = Test_CustomerOrderHelper.createListOfOrders(1, DELIVERY_TYPE_DELIVERY, STATUS_SENT_TO_CUSTOMER, true);
        orderDetails = new List<Order_Detail__c>();
        for (Customer_s_Order__c customerSOrder : customerDeliveryOrders) {
            orderDetails.add(Test_OrderDetailHelper.createDetail(sellingProduct.Id, customerSOrder.Id, 1, false));
        }
        insert orderDetails;
    }

    @IsTest
    static void testAddingOrderToPickupQueue() {
        List<Customer_s_Order__c> customerSOrders = Test_CustomerOrderHelper.createListOfOrders(ORDER_COUNT, DELIVERY_TYPE_PICKUP, STATUS_IN_PROGRESS, false);

        Test.startTest();
        insert customerSOrders;
        Test.stopTest();

        List<Customer_s_Order__c> expectedOrders = new List<Customer_s_Order__c>();

        Set<Id> ids = new Set<Id>();
        Group pickupQueue = [
                SELECT Id, Name
                FROM Group
                WHERE Type = :QUEUE AND Name = :QUEUE + ' ' + DELIVERY_TYPE_PICKUP
                LIMIT 1
        ];

        for (Customer_s_Order__c customerSOrder : customerSOrders) {
            customerSOrder.OwnerId = pickupQueue.Id;
            ids.add(customerSOrder.Id);
            expectedOrders.add(customerSOrder);
        }

        List<Customer_s_Order__c> actualOrders = [
                SELECT Id, OwnerId, Delivery_Type__c, Status__c
                FROM Customer_s_Order__c
                WHERE Id IN :ids
                LIMIT :ORDER_COUNT
        ];

        System.assertEquals(expectedOrders, actualOrders);
    }

    @IsTest
    static void testAddingOrderToDeliveryQueue() {
        List<Customer_s_Order__c> customerSOrders = Test_CustomerOrderHelper.createListOfOrders(ORDER_COUNT, DELIVERY_TYPE_DELIVERY, STATUS_IN_PROGRESS, false);

        Test.startTest();
        insert customerSOrders;
        Test.stopTest();

        List<Customer_s_Order__c> expectedOrders = new List<Customer_s_Order__c>();

        Set<Id> ids = new Set<Id>();
        Group deliveryQueue = [
                SELECT Id, Name
                FROM Group
                WHERE Type = :QUEUE AND Name = :QUEUE + ' ' + DELIVERY_TYPE_DELIVERY
                LIMIT 1
        ];

        for (Customer_s_Order__c customerSOrder : customerSOrders) {
            customerSOrder.OwnerId = deliveryQueue.Id;
            ids.add(customerSOrder.Id);
            expectedOrders.add(customerSOrder);
        }

        List<Customer_s_Order__c> actualOrders = [
                SELECT Id, OwnerId, Delivery_Type__c, Status__c
                FROM Customer_s_Order__c
                WHERE Id IN :ids
                LIMIT :ORDER_COUNT
        ];

        System.assertEquals(expectedOrders, actualOrders);
    }

    @IsTest
    static void testUpdateStatusToCanceledFromInProgress() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        List<Customer_s_Order__c> customerSOrders = [
                SELECT Id, Name, Status__c, Delivery_Type__c, Total_Ammount__c, Total_Quantity__c
                FROM Customer_s_Order__c
                WHERE Delivery_Type__c =: DELIVERY_TYPE_PICKUP
                LIMIT 100
        ];

        for (Customer_s_Order__c customerSOrder : customerSOrders) {
            customerSOrder.Status__c = STATUS_CANCELED;
        }

        Test.startTest();
        update customerSOrders;
        Test.stopTest();

        Selling_Product__c actualProduct = [
                SELECT Id, Name, Ordered_Quantity__c, Quantity__c
                FROM Selling_Product__c
                LIMIT 1
        ];

        System.assertEquals(1, actualProduct.Ordered_Quantity__c);
    }

    @IsTest
    static void testUpdateStatusToCanceledFromSentToCustomer() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        List<Customer_s_Order__c> customerSOrders = [
                SELECT Id, Name, Status__c, Delivery_Type__c, Total_Ammount__c, Total_Quantity__c
                FROM Customer_s_Order__c
                WHERE Delivery_Type__c =: DELIVERY_TYPE_DELIVERY
                LIMIT 100
        ];

        for (Customer_s_Order__c customerSOrder : customerSOrders) {
            customerSOrder.Status__c = STATUS_CANCELED;
        }

        Test.startTest();
        update customerSOrders;
        Test.stopTest();

        Selling_Product__c actualProduct = [
                SELECT Id, Name, Quantity__c, Ordered_Quantity__c
                FROM Selling_Product__c
                LIMIT 1
        ];

        System.assertEquals(2, actualProduct.Ordered_Quantity__c);
    }

    @IsTest
    static void testUpdateStatusToSentToCustomer() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        List<Customer_s_Order__c> customerSOrders = [
                SELECT Id, Name, Status__c, Delivery_Type__c, Total_Ammount__c, Total_Quantity__c
                FROM Customer_s_Order__c
                WHERE Delivery_Type__c =: DELIVERY_TYPE_PICKUP
                LIMIT 100
        ];

        for (Customer_s_Order__c customerSOrder : customerSOrders) {
            customerSOrder.Status__c = STATUS_SENT_TO_CUSTOMER;
        }

        Test.startTest();
        update customerSOrders;
        Test.stopTest();

        Selling_Product__c actualProduct = [
                SELECT Id, Name, Ordered_Quantity__c, Quantity__c
                FROM Selling_Product__c
                LIMIT 1
        ];

        System.assertEquals(1, actualProduct.Ordered_Quantity__c);
        System.assertEquals(9, actualProduct.Quantity__c);
    }
}