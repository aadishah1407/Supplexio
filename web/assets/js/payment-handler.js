/**
 * Payment Handler Script
 * This script handles the JSON responses from the PaymentServlet
 */

$(document).ready(function() {
    // Check if we have a JSON response in the URL or page content
    function checkForJsonResponse() {
        // Get the page content
        var pageContent = document.body.textContent || document.body.innerText;
        
        // Check if the content looks like JSON
        if (pageContent.trim().startsWith('{') && pageContent.trim().endsWith('}')) {
            try {
                // Try to parse the JSON
                var jsonResponse = JSON.parse(pageContent.trim());
                
                // Clear the page content
                document.body.innerHTML = '';
                
                // Create a proper response display
                var responseDiv = document.createElement('div');
                responseDiv.className = 'container mt-5';
                
                var card = document.createElement('div');
                card.className = 'card ' + (jsonResponse.success ? 'border-success' : 'border-danger');
                
                var cardHeader = document.createElement('div');
                cardHeader.className = 'card-header ' + (jsonResponse.success ? 'bg-success' : 'bg-danger') + ' text-white';
                cardHeader.innerHTML = '<h4>' + (jsonResponse.success ? '<i class="fas fa-check-circle"></i> Success' : '<i class="fas fa-exclamation-circle"></i> Error') + '</h4>';
                
                var cardBody = document.createElement('div');
                cardBody.className = 'card-body';
                cardBody.innerHTML = '<p class="card-text">' + jsonResponse.message + '</p>';
                
                var cardFooter = document.createElement('div');
                cardFooter.className = 'card-footer';
                cardFooter.innerHTML = '<a href="/SupplexioWebApp/payment" class="btn btn-primary"><i class="fas fa-arrow-left"></i> Back to Payments</a>';
                
                // Assemble the card
                card.appendChild(cardHeader);
                card.appendChild(cardBody);
                card.appendChild(cardFooter);
                responseDiv.appendChild(card);
                
                // Add the response display to the page
                document.body.appendChild(responseDiv);
                
                // Add Bootstrap and FontAwesome
                var bootstrapLink = document.createElement('link');
                bootstrapLink.rel = 'stylesheet';
                bootstrapLink.href = 'https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css';
                document.head.appendChild(bootstrapLink);
                
                var fontAwesomeLink = document.createElement('link');
                fontAwesomeLink.rel = 'stylesheet';
                fontAwesomeLink.href = 'https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.1/css/all.min.css';
                document.head.appendChild(fontAwesomeLink);
                
                return true;
            } catch (e) {
                // Not valid JSON, ignore
                console.log('Not valid JSON:', e);
                return false;
            }
        }
        return false;
    }
    
    // Run the check when the page loads
    setTimeout(checkForJsonResponse, 100);
});
