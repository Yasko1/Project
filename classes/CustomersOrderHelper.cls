public with sharing class CustomersOrderHelper {

    private static final String QUEUE = 'Queue';
    private static final String DELIVERY = 'Delivery';
    private static final String PICKUP = 'Pickup';

    @Future(callout=true)
    public static void sendProductChangesToWarehouse(Set<Id> ids) {
        List<Selling_Product__c> sellingProducts = [
                SELECT Id, Name, Quantity__c, Ordered_Quantity__c, External_Id__c
                FROM Selling_Product__c
                WHERE Id IN :ids
        ];
        System.debug('RESULT ========= ' + sellingProducts);
        OrderCalloutClass.patchProductsToWarehouse(sellingProducts);
    }

    public static void updateStatusToCanceledFromInProgress(Set<Id> ids) {
        if (!ids.isEmpty()) {
            List<Selling_Product__c> sellingProducts = removeOrderedQuantityProducts(ids);
            System.debug('######## removeOrderedQuantityProducts ######### ' + sellingProducts);
            sendProductChangesToWarehouse(getProductsIds(sellingProducts));
        }
    }

    public static void updateStatusToCanceledFromSentToCustomer(Set<Id> ids) {
        if (!ids.isEmpty()) {
            List<Selling_Product__c> sellingProducts = addQuantityProducts(ids);
            System.debug('######## addQuantityProducts ######### ' + sellingProducts);
            sendProductChangesToWarehouse(getProductsIds(sellingProducts));
        }
    }

    public static void updateStatusToSentToCustomer(Set<Id> ids) {
        if (!ids.isEmpty()) {
            List<Selling_Product__c> sellingProducts = removeQuantityProducts(ids);
            System.debug('######## removeQuantityProducts ######### ' + sellingProducts);
            sendProductChangesToWarehouse(getProductsIds(sellingProducts));
        }
    }

    public static void addOrderToQueue(Set<Id> ids) {
        List<Customer_s_Order__c> customerSOrders = new List<Customer_s_Order__c>();

        if (!ids.isEmpty()) {
            customerSOrders = [
                    SELECT Id, OwnerId, Delivery_Type__c
                    FROM Customer_s_Order__c
                    WHERE Id IN :ids
            ];
            if (!customerSOrders.isEmpty()) {
                Group queueDelivery = [
                        SELECT Id, Name
                        FROM Group
                        WHERE Name = :QUEUE + ' ' + DELIVERY AND Type = :QUEUE
                ];
                Group queuePickup = [
                        SELECT Id, Name
                        FROM Group
                        WHERE Name = :QUEUE + ' ' + PICKUP AND Type = :QUEUE
                ];

                if (queuePickup != null && queueDelivery != null) {
                    for(Customer_s_Order__c customerSOrder : customerSOrders) {
                        if (customerSOrder.Delivery_Type__c.equals(DELIVERY)) {
                            customerSOrder.OwnerId = queueDelivery.Id;
                        } else if (customerSOrder.Delivery_Type__c.equals(PICKUP)) {
                            customerSOrder.OwnerId = queuePickup.Id;
                        }
                    }
                }
                update customerSOrders;
            }
        }
    }

    private static Set<Id> getProductsIds(List<Selling_Product__c> sellingProducts) {
        Set<Id> ids = new Set<Id>();
        for (Selling_Product__c sellingProduct : sellingProducts) {
            ids.add(sellingProduct.Id);
        }
        return ids;
    }

    private static List<Selling_Product__c> addQuantityProducts(Set<Id> ids) {
        List<Selling_Product__c> sellingProducts = new List<Selling_Product__c>();

        if (!ids.isEmpty()) {
            List<Order_Detail__c> orderDetails = [
                    SELECT Quantity__c, Selling_Product__r.Id, Customer_s_Order__r.Id
                    FROM Order_Detail__c
                    WHERE Customer_s_Order__r.Id IN :ids
            ];

            Map<Id, Decimal> products = new Map<Id, Decimal>();

            Set<Id> productIds = new Set<Id>();
            for (Order_Detail__c orderDetail : orderDetails) {
                productIds.add(orderDetail.Selling_Product__r.Id);
            }
            sellingProducts = [SELECT Id, Name, Quantity__c, Ordered_Quantity__c FROM Selling_Product__c WHERE Id IN :productIds];

            for (Integer i = 0; i < sellingProducts.size(); i++) {
                Decimal quantity = 0;
                for (Integer j = 0; j < orderDetails.size(); j++) {
                    if ((sellingProducts[i].Id).equals(orderDetails[j].Selling_Product__r.Id)) {
                        quantity += orderDetails[j].Quantity__c;
                    }
                }
                sellingProducts[i].Quantity__c += quantity;
            }
            update sellingProducts;
        }

        return sellingProducts;
    }

    private static List<Selling_Product__c> removeQuantityProducts(Set<Id> ids) {
        List<Selling_Product__c> sellingProducts = new List<Selling_Product__c>();

        if (!ids.isEmpty()) {
            List<Order_Detail__c> orderDetails = [
                    SELECT Quantity__c, Selling_Product__r.Id, Customer_s_Order__r.Id
                    FROM Order_Detail__c
                    WHERE Customer_s_Order__r.Id IN :ids
            ];

            Map<Id, Decimal> products = new Map<Id, Decimal>();

            Set<Id> productIds = new Set<Id>();
            for (Order_Detail__c orderDetail : orderDetails) {
                productIds.add(orderDetail.Selling_Product__r.Id);
            }
            sellingProducts = [SELECT Id, Name, Quantity__c, Ordered_Quantity__c FROM Selling_Product__c WHERE Id IN :productIds];

            for (Integer i = 0; i < sellingProducts.size(); i++) {
                Decimal quantity = 0;
                for (Integer j = 0; j < orderDetails.size(); j++) {
                    if ((sellingProducts[i].Id).equals(orderDetails[j].Selling_Product__r.Id)) {
                        quantity += orderDetails[j].Quantity__c;
                    }
                }
                sellingProducts[i].Quantity__c -= quantity;
                sellingProducts[i].Ordered_Quantity__c -= quantity;
            }
            update sellingProducts;
        }

        return sellingProducts;
    }

    private static List<Selling_Product__c> removeOrderedQuantityProducts(Set<Id> ids) {
        List<Selling_Product__c> sellingProducts = new List<Selling_Product__c>();

        if (!ids.isEmpty()) {
            List<Order_Detail__c> orderDetails = [
                    SELECT Quantity__c, Selling_Product__r.Id, Customer_s_Order__r.Id
                    FROM Order_Detail__c
                    WHERE Customer_s_Order__r.Id IN :ids
            ];
            Map<Id, Decimal> products = new Map<Id, Decimal>();

            Set<Id> productIds = new Set<Id>();
            for (Order_Detail__c orderDetail : orderDetails) {
                productIds.add(orderDetail.Selling_Product__r.Id);
            }
            sellingProducts = [SELECT Id, Name, Quantity__c, Ordered_Quantity__c FROM Selling_Product__c WHERE Id IN :productIds];

            for (Integer i = 0; i < sellingProducts.size(); i++) {
                Decimal quantity = 0;
                for (Integer j = 0; j < orderDetails.size(); j++) {
                    if ((sellingProducts[i].Id).equals(orderDetails[j].Selling_Product__r.Id)) {
                        quantity += orderDetails[j].Quantity__c;
                    }
                }
                sellingProducts[i].Ordered_Quantity__c -= quantity;
            }
            update sellingProducts;
        }
        return sellingProducts;
    }
}