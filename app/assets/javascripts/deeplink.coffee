launchiOSApp = (url) ->
  appleAppStoreLink = 'https://itunes.apple.com/us/app/MY-APP/APPID'
  now = (new Date).valueOf()
  setTimeout (->
    if (new Date).valueOf() - now > 500
      return
    window.location = appleAppStoreLink
    return
  ), 100
  window.location = url
  return

$ ->
  $('.deep-link').click ->
    launchiOSApp $('.deep-link').data('url')
    return
  return
