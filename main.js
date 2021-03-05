Parse.Cloud.job("manuallyUpdateParticipantCount", async (request) => {
    const { params, headers, log, message } = request;
    console.log("Updating participantCount for all studies...");
    const query = new Parse.Query('Study');
    const studies = await query.find();
    studies.forEach(async (study) => {
        const id = study.get("study_id");
        const query = new Parse.Query('UserStudy');
        query.equalTo('study_id', id);
        const count = await query.count();
        const title = study.get("title");
        console.log("Study " + title + ": " + count);
        const currentParticipantCount = study.get("participantCount");
        if (currentParticipantCount !== count) {
            console.log("Study " + title + ": Count changed. Updating...");
            study.set('participantCount', count);
            study.save();
            console.log('Saved');
        } else {
            console.log("Study " + title + ": Count unchanged. Skipping...");
        }
    });
});

Parse.Cloud.afterSave("UserStudy", (request) => {
    const query = new Parse.Query("Study");
    console.log(request);
    console.log(request.object);
    console.log(request.object.get("objectId"));
    query.get(request.object.get("study_id"))
      .then(function(study) {
        study.increment("participantCount");
        return study.save();
      })    
      .catch(function(error) {
        console.error("Got an error " + error.code + " : " + error.message);
      });
});