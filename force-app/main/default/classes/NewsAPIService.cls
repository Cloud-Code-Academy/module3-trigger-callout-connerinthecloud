/**
 * Service class to interact with the NewsAPI for fetching top headlines
 */
public with sharing class NewsAPIService {
 
    private static final String API_NAMED_CREDENTIAL = 'callout:NewsAPI'; //https://newsapi.org
    private static final String API_ENDPOINT = '/v2/top-headlines';
    
    private static final Integer PAGE_SIZE = 20; 
    
    /**
     * Fetches top headlines for a specified category with pagination support
     * @param category The news category (business, entertainment, general, health, science, sports, technology)
     * @param page Page number for pagination
     * @return NewsAPIResponse The wrapper object containing the API response
     */
    public static NewsAPIResponse getTopHeadlinesByCategory(String category, Integer page) {
        if (String.isBlank( category )) {
            throw new NewsAPIException('Invalid parameter: Category cannot be blank.');
        }

        page = (page == null || page <= 0) ? 1 : page; // default the page to 1 if it is otherwise invalid
  
        String fullendpoint = API_ENDPOINT + '?category=' + category + '&pageSize=' + PAGE_SIZE;
        HttpResponse response = makeCallout(fullendpoint);
        
        return parseResponse(response.getBody());
    }
    
    /**
     * Helper method to make the HTTP callout
     * @param endpoint The full URL with parameters
     * @return HttpResponse The HTTP response
     */
    private static HttpResponse makeCallout(String endpoint) {
        // - Handle exceptions
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(API_NAMED_CREDENTIAL + endpoint);
        request.setHeader('Content-Type', 'application/json');
        request.setMethod('GET');

        HttpResponse response = new HttpResponse();

        try {
            response = http.send(request);
            if (response.getStatusCode() < 200 || response.getStatusCode() > 299) {
 
                String errorMessage = 'Error retrieving headlines from NewsAPI:' + response.getStatusCode() + ' Message: ' + response.getBody();
                Logger.error(errorMessage);
                Logger.saveLog();
                throw new NewsAPIException(errorMessage);
            } else {

                return response;
            }

        } catch (System.CalloutException e) {
            String errorMessage = 'NewsAPI callout error: ' + e.getMessage();
            Logger.error(errorMessage);
            Logger.saveLog();

            throw new NewsAPIException(errorMessage);
        }
    }
    
    /**
     * Helper method to parse the JSON response
     * @param jsonResponse The JSON response string
     * @return NewsAPIResponse The parsed response object
     */
    private static NewsAPIResponse parseResponse(String jsonResponse) {

        return (NewsAPIResponse) System.JSON.deserialize(jsonResponse, NewsAPIResponse.class);
    }
    
    /**
     * Custom exception class for NewsAPI errors
     */
    public class NewsAPIException extends Exception {}
} 