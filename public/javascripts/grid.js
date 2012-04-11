(function($){
  $.fn.grid = function(method){

    var methods = {
      reload: function() {
        this.each(function() {
          this.load(location.pathname);
        });
      }
    }

    if (methods[method]) {
      return methods[method].apply(this);
    }

    Grid = function(context) {
      var current_url = location.pathname;

      context.load = function(url) {
        url = url || current_url;
        $(this).find('.pagination .status').show();
        $.getScript(url);
      }

      context.submitForm = function() {
        $(this).find('.form').submit();
      }

      context.bindEvents = function() {
        $(context).find('th a, .pagination a').live('click', function(){
          context.load(this.href)
          return false;
        });
        $(context).find('.grid-filters').find('input:visible, select:visible').each(function(){
          $(this).val();
        });
        $(context).find(".grid-filters input").typeWatch({
          minTextLength: 0,
          callback: function() {
            context.submitForm();
          }
        });
        $(context).find('.grid-filters').hide();
        $(context).find(".grid-filters input, .grid-filters select").change(function(){
            context.submitForm();
        });
        $(context).delegate('.icon-remove', 'ajax:beforeSend', function(){
          $(this).parents('tr').fadeOut('slow');
        });
        $(context).delegate('.icon-remove', 'ajax:complete', function(){
          context.load();
        });
        $(context).find('.grid-show-filters').click(function(){
          $(context).find('.grid-filters').fadeToggle();
          $(this).remove();
          return false;
        });
      }

      context.bindEvents();
    }

    this.each(function() {
      Grid(this);
    });
  };
})(jQuery);
