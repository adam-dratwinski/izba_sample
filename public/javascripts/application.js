$(function(){
  function split( val ) {
    return val.split( /,\s*/ );
  }

  $("#search_clinic_name").autocomplete({
    minLength: 0,
    source: "/clinics_tags",
    focus: function() {
      // prevent value inserted on focus
      return false;
    },
    select: function( event, ui ) {
      var terms = split( this.value );
      // remove the current input
      terms.pop();
      // add the selected item
      terms.push( ui.item.value );
      // add placeholder to get the comma-and-space at the end
      terms.push( "" );
      this.value = terms.join( " " );
      return false;
    }

  });

  $("#user_location .find-me").click(function(){
      self = this;
      function success(position){
        $.get(self.href, {
          lat: position.coords.latitude,
          lng: position.coords.longitude
        });
      }

      function error(){
        alert('not supported');
      }

      if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(success, error);
      } else {
        alert('not supported');
      }
      return false;
  });
});
