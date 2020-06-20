window.ST = window.ST || {};

/**
  Maganage members in admin UI
*/
window.ST.initializeManageMembers = function() {
  var DELAY = 800;

  function createCheckboxAjaxRequest(streams, url, allowedKey, disallowedKey) {
    var ajaxRequest = Bacon.combineAsArray(streams).changes().debounce(DELAY).skipDuplicates(_.isEqual).map(function(valueObjects) {
      var data = {};
      if (url == 'promote_admin' || url == 'set_level'){
        data[allowedKey] = valueObjects[0].value
        data[disallowedKey] = valueObjects[0].dataset.userId

      }else{
        function isValueTrue(valueObject) {
          return valueObject.checked;
        }
        data[allowedKey] = _.filter(valueObjects, isValueTrue).map(function(input){ return input.value; });
        data[disallowedKey] = _.reject(valueObjects, isValueTrue).map(function(input){ return input.value; });
     }

      return {
        type: "POST",
        url: ST.utils.relativeUrl(url),
        data: data
      };
    });

    return ajaxRequest;
  }

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

  var initBanToggle = function () {
    $(document).on("click", ".admin-members-ban-toggle", function(){
      var banned = this.checked;
      var row = $(this).parent().parent()[0];
      var confirmation, url;
      if(banned) {
        confirmation = ST.t('admin.communities.manage_members.ban_user_confirmation');
        url = $(this).data("ban-url");
      } else {
        confirmation = ST.t('admin.communities.manage_members.unban_user_confirmation');
        url = $(this).data("unban-url");
      }
      if(confirm(confirmation)) {
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
      } else {
        this.checked = !banned;
      }
    });
  };

  var adminStreams = $(".admin-members-is-admin").asEventStream('change').map(function (ev) {
      return ev.target;
    }).filter(function (target) {
      if (target.value == 'Manager' || target.value == 'Admin') {
        if (confirm(ST.t('admin.communities.manage_members.this_makes_the_user_an_admin'))) {
          return true;
        }
        target.value = target.dataset.currentRole
        // target.checked = !target.checked;
        return false;
      }
      return true;
    });

  var postingAllowedStreams = $(".admin-members-can-post-listings").asEventStream('change')
    .map(function (ev) {
      return ev.target;
    });

  var requestAllowedStreams = $(".admin-members-can-post-request").asEventStream('change')
    .map(function (ev) {
      return ev.target;
    });

  var dmsAllowedStreams = $(".admin-members-can-post-dms").asEventStream('change')
    .map(function (ev) {
      return ev.target;
    });


  var verifiedAllowedStreams = $(".admin-members-verified-toggle").asEventStream('change')
    .map(function (ev) {
      return ev.target;
    });

  var activateAllowedStreams = $(".admin-members-active-toggle").asEventStream('change')
    .map(function (ev) {
      return ev.target;
    });

  var levelAllowedStreams = $(".admin-members-user-level").asEventStream('change')
    .map(function (ev) {
      return ev.target;
    });

  var postingAllowed = createCheckboxAjaxRequest(postingAllowedStreams, "posting_allowed", "allowed_to_post", "disallowed_to_post");
  var requestAllowed = createCheckboxAjaxRequest(requestAllowedStreams, "post_requests_allowed", "allowed_to_request", "disallowed_to_request");
  var dmsAllowed = createCheckboxAjaxRequest(dmsAllowedStreams, "dms_allowed", "allowed_to_dms", "disallowed_to_dms");
  var isAdmin = createCheckboxAjaxRequest(adminStreams, "promote_admin", "add_admin", "remove_admin");
  var isActive = createCheckboxAjaxRequest(activateAllowedStreams, "set_activated", "allowed_to_active", "disallowed_to_active");
  var isVerified = createCheckboxAjaxRequest(verifiedAllowedStreams, "set_verified", "allowed_to_verified", "disallowed_to_verified");
  var userLevel = createCheckboxAjaxRequest(levelAllowedStreams, "set_level", "user_role", "user_id");
  var ajaxRequest = postingAllowed.merge(isAdmin).merge(requestAllowed).merge(dmsAllowed).merge(isActive).merge(isVerified).merge(userLevel);
  var ajaxResponse = ajaxRequest.ajax().endOnError();

  var ajaxStatus = window.ST.ajaxStatusIndicator(ajaxRequest, ajaxResponse);

  ajaxStatus.loading.onValue(showUpdateNotification);
  ajaxStatus.success.onValue(showUpdateSuccess);
  ajaxStatus.error.onValue(showUpdateError);
  ajaxStatus.idle.onValue(showUpdateIdle);

  // Attach analytics click handler for CSV export
  $(".js-users-csv-export").click(function(){
    window.ST.analytics.logEvent('admin', 'export', 'users');
  });

  initBanToggle();
};
