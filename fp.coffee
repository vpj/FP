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
   else context.attr k, v

parseElem = (elem) ->
 res =
  id: null
  tag: null
  class: ''

 for c, i in elem.split "."
  if i is 0
   if c.indexOf("#") isnt -1
    a = c.split "#"
    res.tag = a[0]
    res.id = a[1]
   else
    res.tag = c
  else if i is 1
   res.class += "#{c}"
  else
   res.class += " #{c}"

 return res

window.FP = FP = (context, elem, attrs, content) ->
 elem = parseElem elem
 if typeof attrs is 'function'
  content = attrs
  attrs = {}

 switch elem.tag
  when 'transition'
   context = context.transition()
   setAttributes context, attrs
  when 'select'
   context = context.select attrs
  when 'selectAll'
   context = context.selectAll attrs
  when 'data'
   context = context.data attrs
  when 'enter'
   context = context.enter()
  when 'exit'
   context = context.exit()
  else
   context = context.append elem.tag
   if elem.id? then context.attr "id", elem.id
   if elem.class isnt '' then context.attr "class", elem.class
   setAttributes context, attrs


 content?.call? context
 return context
