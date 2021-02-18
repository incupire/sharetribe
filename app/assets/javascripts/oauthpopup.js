(function($){
    $.oauthpopup = function(options)
    {
        if (!options || !options.path) {
            throw new Error("options.path must not be empty");
        }


        var top = window.screen.height - 403;
            top = top > 0 ? top/2 : 0;

        var left = window.screen.width - 575;
            left = left > 0 ? left/2 : 0;


        options = $.extend({
            windowName: 'ConnectWithOAuth'
          , windowOptions: 'location=0,status=0,width=575,height=400'+ ",top=" + top + ",left=" + left
          , callback: function(){ window.location.reload(); }
        }, options);

        var oauthWindow   = window.open(options.path, options.windowName, options.windowOptions);
        var oauthInterval = window.setInterval(function(){
            if (oauthWindow.closed) {
                window.clearInterval(oauthInterval);
                options.callback();
            }
        }, 1000);
    };

    $.fn.oauthpopup = function(options) {
        $this = $(this);
        $this.click($.oauthpopup.bind(this, options));
    };
})(jQuery);