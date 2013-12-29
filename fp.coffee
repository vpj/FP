setStyles = (context, styles) ->
 for k, v of styles
  context.style k, v

setEvents = (context, events) ->
 for k, v of events
  context.on k, v

setAttributes = (context, attrs) ->
 for k, v of attrs
  switch k
   when 'style' then setStyles context, v
   when 'on' then setEvents context, v
   when 'call' then context.call v
   when 'text' then context.text v
   else context.attr k, v

parseIdClass = (str) ->
 res =
  id: null
  class: null

 for c, i in str.split "."
  if c.indexOf("#") is 0
   res.id = c
  else if res.class is null
   res.class = c
  else
   res.class += " #{c}"

 return res

svgElems = 'a altGlyph altGlyphDef altGlyphItem animate animateColor animateMotion
 animateTransform circle clipPath color-profile cursor defs desc ellipse
 feBlend feColorMatrix feComponentTransfer feComposite feConvolveMatrix
 feDiffuseLighting feDisplacementMap feDistantLight feFlood feFuncA feFuncB
 feFuncG feFuncR feGaussianBlur feImage feMerge feMergeNode feMorphology
 feOffset fePointLight feSpecularLighting feSpotLight feTile feTurbulence
 filter font font-face font-face-format font-face-name font-face-src
 font-face-uri foreignObject g glyph glyphRef hkern image line linearGradient
 marker mask metadata missing-glyph mpath path pattern polygon polyline
 radialGradient rect script set stop style svg symbol text textPath
 title tref tspan use view vkern'

fp =
 selection: null

helpers =
 transition: (attrs, content) ->
  selection = @selection = @selection.transition()
  if attrs.delay?
   @selection.delay attrs.delay
   delete attrs.delay
  setAttributes @selection, attrs
  content?.call? @
  return selection

 select: (str, content) ->
  selection = @selection = @selection.select str
  content?.call? @
  return selection

 selectAll: (str, content) ->
  selection = @selection = @selection.selectAll str
  content?.call? @
  return selection

 data: (data, content) ->
  selection = @selection = @selection.data data
  content?.call? @
  return selection

 enter: (content) ->
  selection = @selection = @selection.enter()
  content?.call? @
  return selection

 exit: (content) ->
  selection = @selection = @selection.exit()
  content?.call? @
  return selection

append = (name, args) ->
 elem = {}
 attrs = {}
 content = null

 for arg in args
  switch typeof arg
   when 'function' then content = arg
   when 'object' then attrs = arg
   when 'string' then elem = parseIdClass arg

 prevSelection = @selection
 selection = @selection = @selection.append name
 if elem.id? then @selection.attr 'id', elem.id
 if elem.class? then @selection.attr 'class', elem.class
 setAttributes @selection, attrs

 if typeof content is 'function'
  content.call? @

 @selection = prevSelection
 return selection

wrap = (helper) ->
 return ->
  prevSelection = @selection
  selection = helper.apply @, arguments
  @selection = prevSelection
  return selection

callAppend = (elem) ->
 return ->
  console.log elem
  append.call @, elem, arguments

setup = ->
 for elem in svgElems.split ' '
  fp[elem] = callAppend elem

 for name, helper of helpers
  fp[name] = wrap helper

setup()

window.FP = FP = (selection, content) ->
 prevSelection = fp.selection
 fp.selection = selection
 content?.call? fp
 fp.selection = prevSelection


