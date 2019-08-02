chrome.runtime.onMessage.addListener(function(request,sender,sendResponse) {

  switch (request.type) {
    case "check":

      response = {
        value: undefined
      };

      results = document.querySelectorAll(request.selector);

      if (results.length > 0) {
        response = {
          value: results[0].textContent
        };
      } else {
        response = {
          value: undefined
        }
      }

      sendResponse(response);
      break;

    default:
      console.log("Received unknown message type: " + request.type);

  }

});
