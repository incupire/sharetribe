window.ST = window.ST || {};

/**
  Maganage members in admin UI
*/
window.ST.initializeManageListing = function() {
  var DELAY = 800;

  var showUpdateNotification = function() {
    $(".ajax-update-notification").show();
    $("#admin-members-saving-posting-allowed").show();
    $("#admin-members-error-posting-allowed").hide();
    $("#admin-members-saved-posting-allowed").hide();
  };

  var showUpdateSuccess = function() {
    $("#admin-members-saving-posting-allowed").hide();
    $("#admin-members-saved-posting-allowed").show();
  };

  var showUpdateError = function() {
    $("#admin-members-saving-posting-allowed").hide();
    $("#admin-members-error-posting-allowed").show();
  };

  var showUpdateIdle = function() {
    $(".ajax-update-notification").fadeOut();
  };

  var initFeaturedToggle = function () {
    $(document).on("click", ".admin-featured-listing-toggle", function(){
      var featured = this.checked;
      var row = $(this).parent().parent()[0];
      var confirmation, url;
      if(featured) {
        url = $(this).data("featured-url");
      } else {
        url = $(this).data("non-featured-url");
      }
      showUpdateNotification();
      $.ajax({
        type: "PUT",
        url: url,
        dataType: "JSON",
        success: function(resp) {
          row.className = "member-"+resp.status;
          showUpdateSuccess();
        },
        error: showUpdateError,
        complete: _.debounce(showUpdateIdle, DELAY)
      });
    });
  };

  initFeaturedToggle();
};
