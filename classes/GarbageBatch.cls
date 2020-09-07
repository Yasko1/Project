/**
 * Created by Hanna_Yasko on 2/4/2020.
 */

public with sharing class GarbageBatch implements Database.Batchable<SObject>{

    public Database.QueryLocator start(Database.BatchableContext context) {
        Integer daysToDelete = (Integer) [SELECT Days_to_Clean__c FROM Cleaning_Days__mdt LIMIT 1].Days_to_Clean__c;
        Date deletionDate = Date.today() - daysToDelete;
        return Database.getQueryLocator('SELECT Id FROM Customer_s_Order__c ' +
                            + 'WHERE (Status__c = \'Canceled\' OR Status__c = \'Completed\') ' +
                            + 'AND CreatedDate < :deletionDate');
    }

    public void execute(Database.BatchableContext context, List<SObject> orders) {
        delete orders;
    }

    public void finish(Database.BatchableContext context) {
        System.debug('Old orders was removed!');
    }
}