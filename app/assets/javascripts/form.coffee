$ ->
  $.get '/form', (text) ->
    $.each text, (index, value) ->
      console.log value
      $('ul').append( $("<li>").text( value ))