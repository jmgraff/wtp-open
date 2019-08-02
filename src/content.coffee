console.log "content.coffee"

import 'jquery/src/jquery.js'
import 'semantic-ui-css/semantic.min.js'

import './content.css'

import semanticContents from '!!raw-loader!semantic-ui-css/semantic.min.css'
import styleContents from '!!raw-loader!./content-components/ContentScriptMenu.css'

import Vue from 'vue'
import SuiVue from 'semantic-ui-vue'
import UUID from 'vue-uuid'
import ContentScriptMenu from './content-components/ContentScriptMenu.vue'

import Simmer from 'simmerjs'

el = document.createElement('div')
document.body.appendChild el
el.attachShadow({mode: 'open'})

vueRoot = document.createElement('div')

semantic = document.createElement('style')
semantic.innerHTML = semanticContents

style = document.createElement('style')
style.innerHTML = styleContents

el.shadowRoot.appendChild(style)
el.shadowRoot.appendChild(semantic)
el.shadowRoot.appendChild(vueRoot)

Vue.use SuiVue
Vue.use UUID

picking = true

v = new Vue
  el: vueRoot
  data: ->
    open: false
    nickname: undefined
    selector: undefined
    value: undefined
    interval: 10
  render: (h) -> h ContentScriptMenu

simmer = new Simmer(window, {depth: 10})

$currElement = undefined
$prevElement = undefined

hoverClass = "WebCheckerProHover"

document.onmousemove = (e) ->
  return unless picking
  $currElement = e.target || e.srcElement;
  $prevElement.classList.remove hoverClass if $prevElement
  $prevElement.onclick = undefined if $prevElement
  $currElement.classList.add hoverClass
  $prevElement = $currElement
  $currElement.onclick = (f) ->
    queryString = "h1,h2,h3,h4,h5,h6,label"
    closest = $($currElement).parent().find(queryString)[0] or $($currElement).parent().parent().find(queryString)[0] or $($currElement).parent().parent().parent().find(queryString)[0]
    f.preventDefault()
    f.stopPropagation()
    $currElement.classList.remove hoverClass
    $currElement.onclick = undefined
    v.nickname = if closest then $(closest).text() else document.title
    v.selector = simmer($currElement)
    v.value = $currElement.textContent
    picking = false
    v.open = true
    return false

document.onkeyup = (e) ->
  if picking && e.key == 'Escape'
    picking = false
    v.open = false
    $prevElement.classList.remove hoverClass if $prevElement
    $currElement.classList.remove hoverClass

chrome.runtime.onMessage.addListener (request, sender, respond) ->
  switch request.type
    when "isInjected" then respond true
    when "startPicking" then picking = true
