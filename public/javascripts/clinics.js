$(function(){
  $("body").delegate("#show_map_link", "click", function(){
    show_map();
    return false;
  });

  $("#clinics").delegate(".show-on-map", "click", function(){
    show_map();
    var original_clinic = $(this).parents('.clinic'); 
    var clinic = original_clinic.clone();
    clinic = clinic[0]
    original_clinic = original_clinic[0]

    var element = $("#map_canvas").googlemap("fetch");
    var infoWindow = new google.maps.InfoWindow({content: clinic});
    infoWindow.open(element.map, original_clinic.marker);
  });

  $("#clinic_map").each(function(){
    $(this).googlemap({
      coords: $(this).data('coords')
    });
    $(this).googlemap('putMarker', $(this).data('coords'));
    $(this).googlemap('setZoom', 17).data('coords');
  });

  $(".offices .show-details").click(function() {
    console.log($(this).parents('.office').find('.specialisations'))
    if($(this).parents('.office').find('.specialisations').is(":visible")) {
      $(this).parents('.office').find('.specialisations').hide();
    } else {
      $(this).parents('.offices').find('.specialisations').hide();
      $(this).parents('.office').find('.specialisations').show();
    }
    return false;
  });

  $(".office").each(function(){
    show_highlighted(this);
  });

  $(".toggle-highlight").click(function(){
    $(".highlight").toggleClass("highlight-disabled");
    $(this).parent().toggleClass("highlight-active");
    return false;
  });

  $(".toggle-details").click(function(){
    $("#clinics").toggleClass("hide-details");
    $(this).parent().toggleClass("show-details-active");
    return false;
  });

  $("#location_options #current_location").each(function(){
    checkUpdate();
  });


  $(".map .pagination .load").click(function(){
    load_next_page();
    return false;
  });

  $("#clinics_map .find-me").click(function(event,object){
    var element = $("#map_canvas").googlemap("fetch");

    function success(position){
      coords = {
        lat: position.coords.latitude,
        lng: position.coords.longitude
      };

      findClinicsLocation(element.map, coords);
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

  $(document).endlessScroll({
    fireOnce: true,
    fireDelay: 100,
    ceaseFire: function() {
      return $("#clinics .loading").length ? false : true;
    },
    callback: function() {
      load_next_page();
    }
  });
});

var current_page = 1;

function load_next_page() {
  current_page = current_page+1;
  $.getScript(location.pathname + "?page=" + current_page, function(){
    $(".office").each(function(){
      show_highlighted(this);
    });

    if($("#clinics_map:visible").length) {
      put_markers();
    }

    var per_page = $('.map .pagination').data('per-page');
    var total_entries = $('.map .pagination').data('total-entries');
    var total;
    if (per_page * current_page > total_entries) {
      total =  total_entries;
      $('.map .pagination .load').remove();
    } else {
      total = per_page * current_page;
    }

    $('.map .pagination .on-page').html(total);
  });
}

function show_highlighted(element) {
  if($(element).find(".highlight").length) {
    $(element).show();
  }
}
var current_location;
function checkUpdate() {
  if ( ! current_location) {
    current_location = $("#location_options #current_location").html();
  }
  if ($("#location_options #current_location").html() != current_location) {
    location.reload();
  } else {
    setTimeout("checkUpdate()", 250);
  }
}

function put_markers() {
  var element = $("#map_canvas").googlemap('fetch');
  $(".clinic").not(".loaded").each(function(){
    var clinic = this;
    var clinic_data = $(clinic).data();
    clinic.marker = new google.maps.Marker({
      position: new google.maps.LatLng(clinic_data.coords.lat, clinic_data.coords.lng),
      icon: "/images/marker.png",
      map: element.map
    });

    google.maps.event.addListener(clinic.marker, 'click', function(){
      var infoWindow = new google.maps.InfoWindow({content: $(clinic)[0]});
      infoWindow.open(element.map, clinic.marker);
    });

    $(clinic).addClass('loaded');
  });
}

function findClinicsLocation(map, coords) {
    var element = $("#map_canvas").googlemap('fetch');
    $(element).data("coords", coords);
    element.map.setCenter(new google.maps.LatLng(coords.lat, coords.lng))
    element.map.setZoom(15);
    element.current_marker.setPosition(new google.maps.LatLng(coords.lat, coords.lng));
}

function show_map() {
  $("#show_map_link").remove();
  var map = $("#clinics_map");
  map.show();
  var map_canvas = $("#map_canvas");
  map_canvas.googlemap({
    coords: map_canvas.data('coords')
  });
  put_markers();

  coords = map_canvas.data("coords");

  element = map_canvas.googlemap("fetch");
  element.current_marker = new google.maps.Marker({
    position: new google.maps.LatLng(coords.lat, coords.lng),
    map: element.map,
    clickable: false,
    draggable: true,
    flat: true,
    title: "Aktualna lokalizacja",
    icon: "/images/man.png",
    zIndex: 100
  });

  google.maps.event.addListener(element.current_marker, 'dragend', function() {
    alert('juz')
  });

  $("#clinics_map").delegate("form", "submit", function(){
    search_location($(this).find(".string").val());
    this.hideIndicators();
    return false;
  });

  var content = "<a href=\"#\" class=\"set-location\">Wyszukaj dla tej lokalizacji</a>";

  $(".set-location").live('click', function(){
    alert('test');
  });

  element.location_window = new google.maps.InfoWindow({content: content });
}

function search_location(location) {
  var map_canvas = $("#map_canvas");
  context = map_canvas.googlemap("fetch");
  new google.maps.Geocoder().geocode({
    'address': location
  }, function(results, status) {
    if(status == google.maps.GeocoderStatus.OK) {
      if(context.map.location_marker) {
        context.map.location_marker.setMap(null);
      }
      context.map.setCenter(results[0].geometry.location)
      context.map.setZoom(15);

      context.map.location_marker = new google.maps.Marker({
        position: results[0].geometry.location,
        map: context.map,
        clickable: false,
        flat: true,
        title: "Aktualna lokalizacja",
        icon: "/images/man.png",
        zIndex: 1
      });

      console.log(context.location_window)

      context.location_window.open(context.map, context.current_marker)
    } else {
      //geocoding failed
    }
  });
}
