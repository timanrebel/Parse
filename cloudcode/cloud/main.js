// Parse CloudCode
Parse.Cloud.beforeSave(Parse.Installation, function(request, response) {
  Parse.Cloud.useMasterKey();
 
  var androidId = request.object.get("androidId");
  if (androidId == null || androidId == "") {
    console.warn("No androidId found, exit");
    response.success();
  }
 
  var query = new Parse.Query(Parse.Installation);
  query.equalTo("deviceType", "android");
  query.equalTo("androidId", androidId);
  query.addAscending("createdAt");
  query.find().then(function(results) {
    for (var i = 0; i < results.length; ++i) {
      if (results[i].get("installationId") != request.object.get("installationId")) {
        console.warn("App id " + results[i].get("installationId") + ", delete!");
        results[i].destroy().then(function() {
            console.warn("Delete success");
          },
          function() {
            console.warn("Delete error");
          }
        );
      } else {
        console.warn("Current App id " + results[i].get("installationId") + ", dont delete");
      }
    }
    response.success();
    },
    function(error) {
      response.error("Can't find Installation objects");
    }
  );
});