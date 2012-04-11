$(function() {
  function setPlaceholders() {
    $('*[data-placeholder]').each(function() {
      if ($(this).val() && $(this).val() != $(this).attr('data-placeholder')) return null;
      $(this).val($(this).attr('data-placeholder'));
      $(this).addClass('placeholder');
    });
  }
  function setSubmitForms() {
    $('.form').submit(function() {
      $(this.elements).each(function(){
        if ($(this).hasClass('placeholder')) {
          $(this).val('');
        }
      });
      this.showIndicators();
    });
  }
  setPlaceholders();
  setSubmitForms();
  $('body').delegate('*[data-placeholder]', 'focus', function() {
    if ($(this).hasClass('placeholder')) {
      $(this).val('');
      $(this).removeClass('placeholder');
    }
  });
  $('body').delegate('*[data-placeholder]', 'blur', function() {
    if (!$(this).val()) {
      $(this).addClass('placeholder');
      $(this).val($(this).attr('data-placeholder'));
    }
    $(this).find('hint').hide();
  });
  $('body').delegate('input', 'focus', function() {
    $(this).parents('.form-row').find('.hint').show();
  });
  $('body').delegate('input', 'blur', function() {
    $(this).parents('.form-row').find('.hint').hide();
  });

  $('.form').each(function() {
    this.send = function() {
      form = this;
      $.get(form.action, $(this).serialize(), function(){
        form.hideIndicators();
      }, "script");
      return false;
    }
    this.showIndicators = function() {
      $(this).find('button').addClass('button-loading');
    }
    this.hideIndicators = function() {
      $(this).find('button').removeClass('button-loading');
    }
  });

  $.fn.rails_autocomplete = function() {
    AutocompleteClass = function(context) {
      var autocomplete_element = context;
      var id_holder_element = context;

      var dependent = {
        on: context.attr('data-autocomplete-dependent-on'),
        message: context.attr('data-autocomplete-dependent-message'),
        name: context.attr('data-autocomplete-dependent-name')
      }
      var dependent_element;
      var id_holder = context.attr('data-autocomplete-id-holder');
      var is_required = context.attr('data-autocomplete-required');
      var name = context.attr('data-autocomplete-name');
      var source;

      if (context.attr('data-autocomplete') == 'true') {
        var source = new Array();
        var type = "collection";
        context.children().each(function(key) {
          source.push({
            id: $(this).val(),
            label: $(this).html(),
          });
        });
      } else {
        var type = "text_field";
        var source_link = context.attr('data-autocomplete');
        source = function(term, callback) {
          $.getJSON(source_link, "search["+name+"]="+term.term, callback);
        };
      }

      if (type == "collection" && context.parent().find('.autocomplete-search').length == 0) {
        var autocomplete_element = $('<input type="text" class="autocomplete-search"/>');
        context.after(autocomplete_element);
        id_holder_element.val(id_holder_element.find('[selected="selected"]').val()); //html ignoruje posta i ustawia swoje wartośći po twardym resecie
      }

      if (id_holder) {
        var id_holder_element = $("#autocomplete_holder_" + id_holder);
      }

      if (dependent && dependent.on) {
        dependent_element = $(dependent.on);
        require_dependent_field();
        dependent_element.change(function() {
          require_dependent_field();
          bind_autocomplete();
          autocomplete_element.val('');
          id_holder_element.val('');
        });
      }

      function require_dependent_field() {
        if (!dependent_element) return false;

        if (!dependent_element.val()) {
          autocomplete_element.attr('disabled', 'disabled');
          autocomplete_element.val(dependent.message);
          source = function(term, callback) {
            $.getJSON(source_link, "search["+name+"]="+term.term, callback);
          };
        } else {
          autocomplete_element.attr('disabled', '');
          source_link = context.attr('data-autocomplete') + '?search['+dependent.name+']=' + dependent_element.val();
          source = function(term, callback) {
            $.getJSON(source_link, "search["+name+"]="+term.term, callback);
          };
        }
      }

      function bind_autocomplete() {
        autocomplete_element.autocomplete({
          selectFirst: true,
          source: source,
          select: function(event, ui) {
            if (ui.item) {
              if (type == 'collection') {
                ui.item.value = '';
              }
              id_holder_element.val(ui.item.id);
            } else {
              id_holder_element.val('');
            }
            id_holder_element.change();
          },
          change: function(event, ui) {
            if (!ui.item) {
              var matcher = new RegExp("^" + $.ui.autocomplete.escapeRegex($(this).val()) + "$", "i"),
              valid = false;
              autocomplete_element.children("option").each(function() {
                if ($(this).text().match(matcher)) {
                  this.selected = valid = true;
                  return false;
                }
              });
              if (!valid && is_required) {
                // remove invalid value, as it didn't match anything
                $(this).val("");
                id_holder_element.val("");
                autocomplete_element.data("autocomplete").term = "";
                return false;
              }
            }
          },

        });
      }

      id_holder_element.addClass('autocomplete-element');

      bind_autocomplete();
    }

    this.each(function() {
      AutocompleteClass($(this));
    });
  }

  $('*[data-autocomplete]').rails_autocomplete();

  $('body').delegate('.form', 'ajax:complete', function(){
    $(this).find('*[data-autocomplete]').each(function(){
        $(this).rails_autocomplete();
    });
    setPlaceholders();
    setSubmitForms();
    this.hideIndicators();
  });

  $(".ui-autocomplete-input").live("autocompleteopen", function() {
    var autocomplete = $(this).data("autocomplete"),
    menu = autocomplete.menu;

    if (!autocomplete.options.selectFirst) {
      return;
    }
    menu.activate($.Event({
      type: "mouseenter"
    }), menu.element.children().first());
  });
});

