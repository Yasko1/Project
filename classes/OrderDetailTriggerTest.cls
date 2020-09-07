@IsTest
private class OrderDetailTriggerTest {

    @TestSetup
    static void setUp(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        List<Customer_s_Order__c> orders = Test_CustomerOrderHelper.createListOfOrders(200, 'Pickup', 'In Progress', true);
        Account account = Test_AccountHelper.createAccount('testAcc', true);
        Selling_Product__c product = Test_SellingProductHelper.createProduct('testProd', 500, 50, account.Id,true);
    }

    @IsTest
    static void orderDetailCreationTest() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Test.startTest();
        insert getDetails();
        Test.stopTest();

        Selling_Product__c controlProduct = [SELECT Available_Quantity__c, Ordered_Quantity__c, Quantity__c
                                            FROM Selling_Product__c
                                            WHERE Name = 'testProd' LIMIT 1];
        System.assert(controlProduct.Available_Quantity__c == 100);
        System.assert(controlProduct.Ordered_Quantity__c == 400);
        System.assert(controlProduct.Quantity__c == 500);
    }

    @IsTest
    static void orderDetailCreationFailTest() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Boolean isFail = false;
        Selling_Product__c product = [SELECT Quantity__c FROM Selling_Product__c WHERE Name = 'testProd'LIMIT 1];
        product.Quantity__c = 1;
        update product;

        Test.startTest();
        try {
            insert getDetails();
        } catch(Exception e){
            isFail = true;
        }
        Test.stopTest();

        Selling_Product__c controlProduct = [SELECT Available_Quantity__c, Ordered_Quantity__c, Quantity__c
                                            FROM Selling_Product__c
                                            WHERE Name = 'testProd'LIMIT 1];
        System.assert(controlProduct.Available_Quantity__c == 1);
        System.assert(controlProduct.Ordered_Quantity__c == null);
        System.assert(controlProduct.Quantity__c == 1);
        System.assert(isFail);
    }

    private static List<Order_Detail__c> getDetails(){
        Selling_Product__c product = [SELECT Id FROM Selling_Product__c LIMIT 1];
        List<Order_Detail__c> details = new List<Order_Detail__c>();
        for (Customer_s_Order__c order : [SELECT Id FROM Customer_s_Order__c]) {
            details.add(Test_OrderDetailHelper.createDetail(product.Id, order.Id, 2, false));
        }
        return details;
    }
}