window.ST.initializeRecommendationListsOrder = function() {
  var fieldMap = $(".list-container").map(function(id, row) {
    return {
      id: $(row).data("id"),
      element: $(row),
      up: $(row).find(".list-row").find(".list-action-up"),
      down: $(row).find(".list-row").find(".list-action-down"),
    };
  }).get();

  var allChanges = window.ST.orderManager(fieldMap).order;

  var ajaxRequest = Bacon.combineAsArray(allChanges).changes()
    .debounce(800)
    .map(function(orders) {
      var onlyOrders = orders.map(function(obj) {
        return obj.order;
      });
      return _.flatten(onlyOrders);
    })
    .skipDuplicates(_.isEqual)
    .map(function(order) {
      return {
        type: "POST",
        url: ST.utils.relativeUrl("order"),
        data: { order: order }
      };
    });

  var ajaxResponse = ajaxRequest.ajax();
  var ajaxStatus = window.ST.ajaxStatusIndicator(ajaxRequest, ajaxResponse);

  ajaxStatus.loading.onValue(function() {
    $("#list-ajax-saving").show();
    $("#list-ajax-error").hide();
    $("#list-ajax-success").hide();
  });

  ajaxStatus.success.onValue(function() {
    $("#list-ajax-saving").hide();
    $("#list-ajax-success").show();
  });

  ajaxStatus.error.onValue(function() {
    $("#list-ajax-saving").hide();
    $("#list-ajax-error").show();
  });

  ajaxStatus.idle.onValue(function() {
    $("#list-ajax-success").fadeOut();
  });
};
