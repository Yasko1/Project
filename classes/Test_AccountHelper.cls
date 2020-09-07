@IsTest
public class Test_AccountHelper {

    public static Account createAccount(String name, Boolean needInsert) {
        Account account = new Account();
        account.Name = name;
        if (needInsert) {
            insert account;
        }
        return account;
    }

    public static List<Account> createListOfAccounts(Integer numOfAccounts, String nameTemplate, Boolean needInsert) {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < numOfAccounts; i++) {
            accounts.add(createAccount(nameTemplate + (i + 1), false));
        }
        if (needInsert) {
            insert accounts;
        }
        return accounts;
    }
}