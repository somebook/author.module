#= require jquery
#= require jquery-ui
#= require jquery_ujs
#= require bootstrap-dropdown
#= require bootstrap-tab
#= require bootstrap-datepicker
#= require bootstrap-button
#= require bootstrap-collapse
#= require bootstrap-modal
#= require bootstrap-alert
#= require bootstrap-tooltip
#= require jquery.maskedinput.min
#= require chosen-jquery
#= require jquery-tagselector
#= require audiojs/audio.min
#= require highcharts
#= require_self

jQuery ->
  $('.dropdown-toggle').dropdown()
  window.setTimeout ->
    $('.alert.alert-success').fadeOut(300)
  , 2000

  $('.date-input').mask('99.99.9999')
  $('.time-input').mask('99:99')
  $('select').chosen()
  
  $('*').tooltip({
    selector: "a[rel=tooltip]"
  })
  $('.content').tooltip()
  
  false