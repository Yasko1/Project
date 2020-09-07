@IsTest
private class AccountRestTest {

    @IsTest
    static void accountDeleteTest() {
        Test_AccountHelper.createListOfAccounts(200, 'testAcc', true);

        RestRequest request = new RestRequest();
        request.requestURI = 'pum.purum/';
        request.httpMethod = 'DELETE';

        List<Id> ids = new List<Id>();
        List<Account> accounts = [SELECT External_Id__c FROM Account];
        for(Account account : accounts){
            account.External_Id__c = ((String)account.Id).substring(0, 15);
            ids.add(account.Id);
        }
        update accounts;

        request.requestBody = Blob.valueOf(JSON.serialize(ids));
        RestContext.request = request;

        AccountRest.deleteAccounts();

        System.assert([SELECT Id FROM Account].size() == 0);
    }

    @IsTest
    static void accountCreateTest() {
        RestRequest request = new RestRequest();
        request.requestURI = 'pum.purum/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(JSON.serialize(Test_AccountHelper.createListOfAccounts(200, 'testAcc', false)));
        RestContext.request = request;

        AccountRest.saveNewAccounts();

        System.assert([SELECT Id FROM Account].size() == 200);
    }
}