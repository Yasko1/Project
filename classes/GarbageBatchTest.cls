@IsTest
private class GarbageBatchTest {

    @TestSetup
    private static void setUp(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Account account = Test_AccountHelper.createAccount('testAcc', true);
        Selling_Product__c product = Test_SellingProductHelper.createProduct('testProd', 500, 10, account.Id, true);
        List<Customer_s_Order__c> orders = Test_CustomerOrderHelper.createListOfOrders(200, 'Pickup', 'Completed', true);
        List<Order_Detail__c> details = new List<Order_Detail__c>();
        for (Customer_s_Order__c order : orders){
            details.add(Test_OrderDetailHelper.createDetail(product.Id, order.Id, 1, false));
        }
        insert details;
    }

    @IsTest
    static void testBatch() {
        List<Customer_s_Order__c> orders = [SELECT Status__c, CreatedDate FROM Customer_s_Order__c LIMIT 100];
        Integer daysToDelete = (Integer) [SELECT Days_to_Clean__c FROM Cleaning_Days__mdt LIMIT 1].Days_to_Clean__c;
        Date fakeDate = Date.today() - daysToDelete - 1;
        for (Customer_s_Order__c order : orders){
            Test.setCreatedDate(order.Id, fakeDate);
        }
        update orders;
        System.debug(orders);
        Test.startTest();
        GarbageBatch garbageBatch = new GarbageBatch();
        Database.executeBatch(garbageBatch);
        Test.stopTest();

        System.assert([SELECT Status__c, CreatedDate FROM Customer_s_Order__c].size() == 100);
    }
}