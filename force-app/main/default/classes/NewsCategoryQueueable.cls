/**
 * Queueable Apex class for processing News Category records with pagination support
 */
public class NewsCategoryQueueable implements Queueable, Database.AllowsCallouts {
    // Static variable for maximum pages to fetch
    private static final Integer MAX_PAGES = 3;
    
    private News_Category__c category;
    private Integer currentPage;
    
    /**
     * Constructor
     * @param category The News_Category__c record
     * @param currentPage Current page to process
     */
    public NewsCategoryQueueable(News_Category__c category, Integer currentPage) {
        this.category = category;
        this.currentPage = currentPage;
    }
    
    /**
     * Execute method for the queueable job
     * @param context The QueueableContext
     */
    public void execute(QueueableContext context) {
        News_Category__c updatedCategory = new News_Category__c(Id = category.Id);
        News_Category__c cat = [select name, last_synced__c from News_Category__c where id = :category.id];

        try {
            NewsAPIResponse response = NewsAPIService.getTopHeadlinesByCategory(category.Name, currentPage);
            List<Article__c> articlesToInsert = new List<Article__c>();
            Integer index = 1;
            for (NewsApiResponse.Article apiArticle :response.articles) {
                Article__c article = NewsApiResponse.convertToSObject(apiArticle);
                article.News_Category__c = category.Id;
                article.Category__c = category.Name;
                articlesToInsert.add(article);
            }

            if (!articlesToInsert.isEmpty() && articlesToInsert.size() > 0) {
                insert articlesToInsert;
            }
            if ((currentPage < MAX_PAGES && response.totalResults > articlesToInsert.size()) && !Test.isRunningTest()) {
                System.enqueueJob(new NewsCategoryQueueable(category, currentPage + 1));
            }
            
            updatedCategory.Last_Synced__c = System.now();
            updatedCategory.Sync__c = false;

            update updatedCategory;
        } catch (Exception e) {
            String errorMessage = 'Error syncing category ' + category.Name + ': ' + e.getMessage();
            Logger.error(errorMessage);
            Logger.saveLog();
        }
    }
}