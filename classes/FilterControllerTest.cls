@IsTest
public class FilterControllerTest {

    private static final String PRODUCT_NAME = 'Test Product';
    private static final Integer PRODUCT_QUANTITY = 10;
    private static final Double PRODUCT_PRICE = 1000;
    private static final Double PRODUCT_MAX_PRICE = 1500;

    @TestSetup static void setup() {
        Account account = Test_AccountHelper.createAccount('Test', true);
        List<Selling_Product__c> products = new List<Selling_Product__c>();
        products.add(Test_SellingProductHelper.createProduct(PRODUCT_NAME,
                PRODUCT_QUANTITY, PRODUCT_MAX_PRICE / 2, account.Id, false));
        products.add(Test_SellingProductHelper.createProduct(PRODUCT_NAME,
                PRODUCT_QUANTITY, PRODUCT_PRICE, account.Id, false));
        products.add(Test_SellingProductHelper.createProduct(PRODUCT_NAME,
                PRODUCT_QUANTITY, PRODUCT_MAX_PRICE, account.Id, false));
        insert products;

    }

    @IsTest static void searchCategoriesTest() {
        System.assertEquals(4, FilterController.searchCategories().size());
        System.assert(FilterController.searchCategories().contains('TV'));
        System.assert(FilterController.searchCategories().contains('Laptop'));
        System.assert(FilterController.searchCategories().contains('Smartwatch'));
        System.assert(FilterController.searchCategories().contains('Smartphone'));
    }

    @IsTest static void searchForMaxPriceTest() {
        System.assertEquals(PRODUCT_MAX_PRICE, FilterController.searchForMaxPrice());
    }
}