(function() {
  this.events = [];
  this.addEvent = function(selector, callback) {
    var event_object;
    event_object = {
      selector: selector,
      callback: callback,
      event_id: this.events.length + 1
    };
    this.events.push(event_object);
    return this.callEvent(event_object);
  };
  this.callEvent = function(event_object) {
    return $(event_object.selector).each(function() {
      var called_events, object;
      object = this;
      called_events = $(object).data("bui-events") || [];
      if ($.inArray(event_object.event_id, called_events) === -1) {
        event_object.callback(object);
        called_events.push(event_object.event_id);
        return $(object).data("bui-events", called_events);
      }
    });
  };
  return this.callEvents = function() {
    return $(this.events).each(function() {
      return callEvent(this);
    });
  };
}).call(this);

$(function() {
  $('*[data-toggle]').click(function() {
    $('#' + $(this).attr('data-toggle')).slideToggle();
    return false;
  });
  $('*[data-show-and-hide]').click(function() {
    $('#' + $(this).attr('data-show-and-hide')).show();
    $(this).hide();
    return false;
  });
  $('*[data-toggle-show]').click(function() {
    $('#' + $(this).attr('data-toggle-show')).toggle();
    return false;
  });
  $('*[data-toggle-show]').each(function(){
    $('#' + $(this).attr('data-toggle-show')).hide();
  });
  $('*[data-toggle-slide]').click(function() {
    $('#' + $(this).attr('data-toggle-slide')).slideToggle();
    return false;
  });
  $('.autocomplete-input').focus(function() {
    $('.autocomplete-list').show();
  });
  $('.autocomplete-input').blur(function() {
    $('.autocomplete-list').hide();
  });
  $('.flash-messages').delegate('.close', "click", function(){
    $(this).parent().fadeOut();
  });
  $('body').delegate('.panel-button', 'click', function() {
    var indicator = $('<span class="loading"></span>');
    $(this).append(indicator);
    $('body').delegate('.panel-button', 'ajax:complete', function(){
      indicator.remove();
    });
  });

  $(function() {
    return addEvent("*[data-hint]", function(element) {
      $(element).tipsy();
    });
  });

});


function charcode(char) {
  alphabet.indexOf(char);
}

utf8Sorter = function(dir, caseSensitive) {
  var alphabet = 'AĄBCĆDEĘFGHIJKLŁMNŃOÓPRSŚTUWXYZŹŻaąbcćdeęfghijklłmnńoóprsśtuwxyzźż';
  return function(a,b) {
    var pos = 0;
    var min = Math.min(a.length, b.length);
    dir = dir || 1;
    caseSensitive = caseSensitive || false;

    if(!caseSensitive) {
      a = a.toLowerCase();
      b = b.toLowerCase();
    }
    
    while(a.charAt(pos) === b.charAt(pos) && pos < min) { pos++; }
    return alphabet.indexOf(a.charAt(pos)) > alphabet.indexOf(b.charAt(pos)) ? dir : -dir;
  }
}
