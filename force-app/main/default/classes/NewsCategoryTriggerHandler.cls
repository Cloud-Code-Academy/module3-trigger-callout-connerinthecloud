/**
 * Handler class for NewsCategoryTrigger
 */
public with sharing class NewsCategoryTriggerHandler {

    private static List<News_Category__c> categoriesToSync;

    private static List<String> validCategories = new List<String>{'business', 'entertainment', 'general', 'health', 'science', 'sports', 'technology'};
    
    /**
     * Handles after insert events for News_Category__c
     * Uses Queueable for callouts when Sync__c is true
     * @param newRecords List of newly inserted News_Category__c records
     */
    public static void handleInsert(List<News_Category__c> newRecords) {
        categoriesToSync = new List<News_Category__c>();
        for (News_Category__c category : newRecords) {
            if (isCategoryValid(category.Name) && category.Sync__c) {
                categoriesToSync.add(category);
            }
        }

        if (!categoriesToSync.isEmpty() && categoriesToSync.size() > 0) {
            syncCategoriesWithQueueable(categoriesToSync);
        }
    }
    
    /**
     * Handles after update events for News_Category__c
     * Uses Queueable Apex for callouts when Sync__c is true
     * @param newRecords List of updated News_Category__c records
     * @param oldMap Map of old record states
     */
    public static void handleUpdate(List<News_Category__c> newRecords, Map<Id, News_Category__c> oldMap) {
        categoriesToSync = new List<News_Category__c>();

        for (News_Category__c category : newRecords) {
            if (isCategoryValid(category.Name) && category.Sync__c && !oldMap.get( category.Id ).Sync__c) {
                categoriesToSync.add( category );
            }
        }
 
        if (!categoriesToSync.isEmpty() && categoriesToSync.size() > 0) {
            syncCategoriesWithQueueable( categoriesToSync );
        }
    }
    
    /**
     * Queueable method to sync categories using the NewsAPI
     * @param categoriesToSync List of News_Category__c records to sync
     */
    private static void syncCategoriesWithQueueable(List<News_Category__c> categoriesToSync) {
        for (News_Category__c category : categoriesToSync) {
            System.enqueueJob(new NewsCategoryQueueable( category, 1 ));
        }
    }

    /**
     * Helper method to check if the category is valid
     * @param categoryName Name of the category to validate
     * @return True if the category is valid, false otherwise
     */
    private static Boolean isCategoryValid(String categoryName) {
        if (String.isNotBlank(categoryName) && validCategories.contains(categoryName.toLowerCase())) {
            return true;
        } else {
            Logger.error('Invalid category ' + categoryName);
            Logger.saveLog();
            return false;
        }
    }
} 