/**
 * Trigger for News_Category__c object to sync news from API when Sync__c field is true
 */
trigger NewsCategoryTrigger on News_Category__c (after insert, after update) {

    switch on Trigger.operationType {
        when AFTER_INSERT {
            NewsCategoryTriggerHandler.handleInsert(Trigger.new);
        }
        when AFTER_UPDATE {
            NewsCategoryTriggerHandler.handleUpdate(Trigger.new, Trigger.oldMap);
        }
    }
} 