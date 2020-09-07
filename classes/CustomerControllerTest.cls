@isTest
private class CustomerControllerTest {

    private static final String PRODUCT_NAME = 'Test Product';
    private static final String PRODUCT_NAME_PURCHASED = 'Test Product Purchased';
    private static final Integer NUM_OF_PRODUCTS = 100;
    private static final Integer NUM_OF_PRODUCTS_PURCHASED = 5;
    private static final Integer PRODUCT_QUANTITY = 1000;
    private static final Double PRODUCT_PRICE = 1000;

    @TestSetup static void setup() {
        Account account = Test_AccountHelper.createAccount('Test', true);
        Test_SellingProductHelper.createListOfProducts(NUM_OF_PRODUCTS,
                PRODUCT_NAME, PRODUCT_QUANTITY, PRODUCT_PRICE, account.Id, true);
        Test_SellingProductHelper.createListOfProducts(NUM_OF_PRODUCTS_PURCHASED,
                PRODUCT_NAME_PURCHASED, PRODUCT_QUANTITY, PRODUCT_PRICE, account.Id, true);
    }


    @IsTest static void saveProductsTest() {
        Map<Id, Integer> productMap = new Map<Id, Integer>();
        for (Selling_Product__c product : [
                SELECT Id
                FROM Selling_Product__c
                WHERE Name LIKE 'Test Product Purchased%'
        ]) {
            productMap.put(product.Id, 2);
        }
        String products = JSON.serialize(productMap);

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        CustomerController.saveProducts(products, 'Pickup');

        System.assertEquals(1, [SELECT COUNT() FROM Customer_s_Order__c WHERE Delivery_Type__c = 'Pickup']);
        System.assertEquals(5, [SELECT COUNT() FROM Order_Detail__c]);
        System.assertEquals(5, [SELECT COUNT() FROM Selling_Product__c WHERE Name LIKE 'Test Product Purchased%']);
        System.assertEquals(105, [SELECT COUNT() FROM Selling_Product__c]);
    }

    @IsTest static void searchProductsTest() {

        List<String> categories = new List<String>();
        categories.add('Laptop');
        System.assertEquals(0, CustomerController.searchProducts('Test Product', 1000, categories).size());
        categories.add('TV');
        System.assertEquals(5, CustomerController.searchProducts('Test Product Purchased', 1000, categories).size());
        System.assertEquals(105, CustomerController.searchProducts('Product', 1000, categories).size());
        System.assertEquals(0, CustomerController.searchProducts('Test Product', 500, categories).size());
    }
}