/**
 * Wrapper class for parsing the NewsAPI response
 */
public class NewsAPIResponse {
    public String status { get; set; }
    public Integer totalResults { get; set; }
    public List<Article> articles { get; set; }
    
    /**
     * Inner class representing a news article
     */
    public class Article {
        public Source source;
        public String author;
        public String title;
        public String description;
        public String url;
        public String urlToImage;
        public DateTime publishedAt;
        public String content;
    }
    
    /**
     * Inner class representing a news source
     */
    public class Source {
        public String id;
        public String name;
    }
    
    /**
     * Static method to convert an API article to a Salesforce Article__c record
     * @param apiArticle The API article to convert
     * @return Article__c The Salesforce record
     */
    public static Article__c convertToSObject(Article apiArticle) {
        Article__c article = new Article__c();
        article.Name = apiArticle.title.left(80);
        article.Author__c = apiArticle.author;
        article.Title__c = apiArticle.title;
        article.Description__c = apiArticle.description;
        article.url__c = apiArticle.url;
        article.urlToImage__c = (apiArticle.urlToImage != null && apiArticle.urlToImage.length() > 255) ? apiArticle.urlToImage.substring(0, 255) : apiArticle.urlToImage;
        article.published_At__c = apiArticle.publishedAt;
        article.Content__c = (apiArticle.content != null && apiArticle.content.length() > 32000) ? apiArticle.content.substring(0, 32000) : apiArticle.content;
        
        return article;
    }
} 