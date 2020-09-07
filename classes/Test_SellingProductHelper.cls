@IsTest
public with sharing class Test_SellingProductHelper {

    public static Selling_Product__c createProduct(String name, Integer quantity,
            Double price, Id accountId, Boolean needInsert) {
        Selling_Product__c product = new Selling_Product__c();
        product.Name = name;
        product.Quantity__c = quantity;
        product.Price__c = price;
        product.Account__c = accountId;
        if (needInsert) {
            insert product;
        }
        return product;
    }

    public static List<Selling_Product__c> createListOfProducts(Integer numOfProducts,
            String nameTemplate, Integer quantity, Double price, Id accountId, Boolean needInsert) {
        List<Selling_Product__c> products = new List<Selling_Product__c>();
        for (Integer i = 0; i < numOfProducts; i++) {
            products.add(createProduct(nameTemplate + (i + 1),
                    quantity, price, accountId, false));
        }
        if (needInsert) {
            insert products;
        }
        return products;
    }
}