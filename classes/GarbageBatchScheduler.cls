/**
 * Created by Hanna_Yasko on 2/4/2020.
 */

public with sharing class GarbageBatchScheduler implements Schedulable{

    public void execute(SchedulableContext context) {
        GarbageBatch garbageBatch = new GarbageBatch();
        Database.executeBatch(garbageBatch);
    }

    /*
        to start this schedule paste it and run in anonymous apex:
        GarbageBatchScheduler gbs = new GarbageBatchScheduler();
        String cron = '0 0 0 1 * ?'; //that's mean run once a month every 1st day at 00:00
        System.schedule('Order Cleaner', cron, gbs);
    */
}