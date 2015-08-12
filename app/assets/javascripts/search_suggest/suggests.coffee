index = 1
$progress_bar = null

ready = ->
  dispatcher.on_open = () ->
    $('form#search_suggest_request input[type=submit]').removeAttr 'disabled'

  $(document).on 'ajax:success', 'form#search_suggest_request', (e, data, status, r) ->
    prepare_action data

  $(document).on 'click', 'td span.keywords', (e) ->
    copy_to_clipboard this


success = (r) ->
  process_suggestions_display(r)


failure = (r) ->
  stop_action()
  console.log "Fail: "
  console.log r
  process_messages r.messages


process_suggestions_display = (data) ->
  console.log data # TODO:  удалить всё отладочное

  $('form#search_suggest_request input#request').val data.query
  if data.iteration == 1
    $.rails.disableFormElement $('form#search_suggest_request input[type=submit]')
    $('.place-for-table').html '<div class="data"><div class="table-responsive"><table class="table"><thead><tr><th></th><th></th></tr></thead><tbody></tbody></table></div></div><div class="nav"><a href="#top" class="to-top">^</a></div>'

  $table_body = $('.place-for-table table tbody')
  if $table_body.size() and data.suggestions.length
    for value in data.suggestions
      $table_body.append '<tr data-id="' + index + '"><td class="num">' + index + '</td><td><span class="keywords" titile="Кликните на фразу чтобы скопировать">' + value + '</span><span class="lint-to-se"><a title="Смотреть результаты в поисковой системе" href="http://yandex.ru/search/?text=' + value + '" class="yandex" target="_blank">Я</a></span></td></tr>'
      index++

  $progress_panel = $('form .status')
  if $progress_panel.size()
    $progress_panel.removeClass 'hidden'
    $progress_panel.find('.count').html data.count
    $progress_panel.find('.iterations').html data.iteration
    progress_bar data.count, data.max_results

  if data.count < data.max_results
    processed_data = data
    processed_data.suggestions = []
    dispatcher.trigger 'request.start', processed_data, success, failure
  else
    stop_action()
    console.log 'finished'


prepare_action = (response) ->
  if response.allow
    start_action()
    dispatcher.trigger 'request.start', response, success, failure
    $('.place-for-table').html ''
    index = 1
  process_messages response.messages


start_action = () ->
  $form = $('form#search_suggest_request')
  if $form.size() > 0
    console.log 'started'
    $form.find('.status').addClass 'active'
    progress_bar(0, 100)


stop_action = () ->
  $form = $('form#search_suggest_request')
  if $form.size() > 0
    $.rails.enableFormElement $('form#search_suggest_request input[type=submit]')
    $form.find('.status').removeClass 'active'


progress_bar = (current, total) ->
  if !$progress_bar
    $progress_bar = $('.search-suggests .progress')

  if $progress_bar and $progress_bar.size() > 0
    current_percent_value = Math.round(current * 100 / total)
    if current_percent_value >= 100
      current_percent_value = 100
      $progress_bar.find('.progress-bar').removeClass('active')
    else
      $progress_bar.find('.progress-bar').addClass('active')
    $progress_bar.find('.progress-bar').attr('aria-valuenow', current_percent_value).css('width', current_percent_value + '%')
    $progress_bar.find('.progress-bar span').html(current_percent_value + '%')



process_messages = (msgs) ->
  $placeholder = $('.place-for-messages')
  if $placeholder.size() == 1
    if msgs and !jQuery.isEmptyObject(msgs)
      for status, messages of msgs
        if Object.prototype.toString.call( messages ) == '[object Array]' and messages.length
          for message in messages
            $placeholder.append '<div class="alert alert-' + status + '" role="alert"><button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button>' + message + '</div>'
    else
      $placeholder.html ''


copy_to_clipboard = (el) ->
  range = document.createRange()
  range.selectNode el
  window.getSelection().addRange(range)
  try
    successful = document.execCommand 'copy'
    $(el).effect 'highlight'
  catch err
    console.error 'Copy to clipbord fail'
  window.getSelection().removeAllRanges()


$(document).ready(ready)
$(document).on('page:load', ready)