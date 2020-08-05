$.fn.responsiveTabs = function() {
    this.addClass('responsive-tabs');
    this.append($('<span class="glyphicon glyphicon-triangle-bottom"></span>'));
    this.append($('<span class="glyphicon glyphicon-triangle-top"></span>'));

    this.on('click', 'li.active > a, span.glyphicon', function(event) {
        $(event.target.parentElement).toggleClass('open');
    }.bind(this));

    this.on('click', 'li:not(.active) > a', function() {
        this.removeClass('open');
    }.bind(this));
};


(function() {
    var ready;

    if (!Turbolinks.supported) {
        $(document).ready(function() {
            return ready();
        });
    }

    $(document).on('turbolinks:load', function() {
        return ready();
    });

    ready = function() {
        $('.nav.nav-tabs.drop-on-responsive').responsiveTabs();
        return
    };

}).call(this);