import CheckerTab from "./util/CheckerTab.js"
import Gmail from "./util/Gmail.js"

checkerTab = new CheckerTab()
gmail = new Gmail()

items = []

notify = (item) ->
    chrome.notifications.create({
      iconUrl: "images/Logo.png",
      type: "basic",
      title: item.settings.nickname,
      message: "Change Found!\n#{item.url}"
    });

email = (item) ->
  body ="""
  Change detected!

  #{item.settings.nickname}
  #{item.url}

  ------------------------------------------
  Current Value (#{new Date(item.history[0].timestamp).toLocaleString()})
  ------------------------------------------
  #{item.history[0].value}


  ------------------------------------------
  Last Value (#{new Date(item.history[1].timestamp).toLocaleString()})
  ------------------------------------------
  #{item.history[1].value}


  Love,
  Website Tracker Pro :)
  """
  gmail.send(item.settings.emailNotificationRecipients, "Website Tracker Pro: #{item.settings.nickname}", body)


check = ->
  now = Date.now()
  for item in items when not item.settings.paused
    if now >= item.nextCheck
      item.nextCheck = now + item.settings.interval * item.settings.timeUnit
      console.log "#{new Date(now).toLocaleString()}: Checking #{item.settings.nickname}"
      newValue = await checkerTab.check(item.url, item.settings.selector)
      if newValue isnt item.history[0].value
        console.log "Changed! Was: #{item.history[0].value}, Now: #{newValue}"
        item.history.unshift {timestamp: now, value: newValue }
        notify(item) if item.settings.desktopNotifications
        email(item) if item.settings.emailNotifications


setInterval check, 10000

chrome.runtime.onMessage.addListener (request,sender,respond) ->

  currentTabId =  ->
    new Promise (resolve, reject) ->
      chrome.tabs.query {
        active: true
        windowType: "normal"
        currentWindow: true
      }, (d) -> resolve d[0].id

  item = (id) -> (i for i in items when i.id is id)[0];

  duplicates = (i) -> (j for j in items when j.settings.selector is i.settings.selector and j.url is i.url).length > 0;

  switch request.type
      when "getItems"
        respond {items}
        return

      when "deleteItem"
        items = items.filter (item) -> item.id isnt request.id
        respond()
        return

      when "saveItem"
        items.unshift request.item unless duplicates(request.item)
        respond()
        return

      when "saveItemSettings"
        i = item(request.item.id)
        i.settings = request.item.settings
        if request.item.settings.emailNotifications is true then gmail.auth()
        respond()
        return

      when "setItemPaused"
        item(request.id).settings.paused = request.paused
        chrome.runtime.sendMessage {type: "setItems", items}
        return

      when "inject"
        id = await currentTabId()
        chrome.tabs.sendMessage id, {type: "isInjected"}, (response) ->
          if response
            console.log "Content script is already injected"
            chrome.tabs.sendMessage id, {type: "startPicking"}
          else
            chrome.runtime.lastError.message
            console.log "Injecting content script"
            chrome.tabs.executeScript({
                file: 'content.js'
                runAt: 'document_end'
              }, -> respond())
        return true
