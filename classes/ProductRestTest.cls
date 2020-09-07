@IsTest
private class ProductRestTest {

    private static final String ACCOUNT_NAME = 'Test Account Rest';
    private static final String PRODUCT_NAME = 'Test Product';
    private static final Integer NUM_OF_PRODUCTS = 200;
    private static final Integer PRODUCTS_QUANTITY = 100;
    private static final Double PRODUCTS_PRICE = 1000;

    @TestSetup
    static void setup() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Account account = Test_AccountHelper.createAccount(ACCOUNT_NAME, true);
        Test_SellingProductHelper.createListOfProducts(NUM_OF_PRODUCTS, PRODUCT_NAME,
                PRODUCTS_QUANTITY, PRODUCTS_PRICE, account.Id, true);
    }

    @IsTest
    static void saveNewProductsTest() {
        RestRequest request = new RestRequest();
        RestContext.request = request;
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(JSON.serialize([SELECT Id, Name, External_Id__c, Price__c, Quantity__c, RecordType.DeveloperName FROM Selling_Product__c]));
        Test.startTest();
        ProductRest.saveNewProducts();
        Test.stopTest();

        System.assertEquals(400, [SELECT COUNT() FROM Selling_Product__c]);
    }

    @IsTest
    static void updateProductsTest() {
        RestRequest request = new RestRequest();
        RestContext.request = request;
        request.httpMethod = 'PATCH';
        List<Selling_Product__c> products = [SELECT Id, Name, External_Id__c FROM Selling_Product__c LIMIT 50];
        for (Selling_Product__c product : products) {
            product.External_Id__c = ((String) product.Id).substring(0, 15);
        }
        update products;
        for (Selling_Product__c product : products) {
            product.Name = 'Updated products';
        }
        request.requestBody = Blob.valueOf(JSON.serialize(products));

        Test.startTest();
        ProductRest.updateProducts();
        Test.stopTest();

        System.assertEquals(50, [SELECT COUNT() FROM Selling_Product__c WHERE Name = 'Updated products']);
    }

    @IsTest
    static void deleteProductsTest() {

        RestRequest request = new RestRequest();
        RestContext.request = request;
        request.httpMethod = 'DELETE';

        List<Selling_Product__c> products = [SELECT External_Id__c FROM Selling_Product__c LIMIT 50];
        List<Id> ids = new List<Id>();
        for (Selling_Product__c product : products) {
            product.External_Id__c = ((String) product.Id).substring(0, 15);
            ids.add(product.Id);
        }
        update products;

        request.requestBody = Blob.valueOf(JSON.serialize(ids));

        Test.startTest();
        ProductRest.deleteProducts();
        Test.stopTest();

        System.assertEquals(150, [SELECT COUNT() FROM Selling_Product__c]);
    }
}