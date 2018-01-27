{Component} = require 'react'
h = require 'react-hyperscript'
classNames = require 'classnames'
{query} = require '../../db'
d3 = require 'd3'

class SectionLinkOverlay extends Component
  @defaultProps: {
    width: 100
    height: 100
  }
  constructor: (props)->
    super props
    @state = {surfaces: []}

    query 'lithostratigraphy-surface', null, {baseDir: __dirname}
      .then (surfaces)=>@setState {surfaces}

    @link = d3.linkHorizontal()
      .x (d)->d.x
      .y (d)->d.y

  buildLink: (surface)=>
    {sectionPositions} = @props
    {section_height, unit_commonality} = surface
    heights = section_height.map ({section,height})->
      {bounds, padding, scale} = sectionPositions[section]
      yOffs = scale(height)
      y = bounds.top+padding.top+yOffs
      {x0: bounds.left-5, x1: bounds.left+100, y}

    heights.sort (a,b)-> a.x0 - b.x0

    return null if heights.length < 2

    pathData = d3.pairs heights, (a,b)->
      source = {x: a.x1, y: a.y}
      target = {x: b.x0, y: b.y}
      {source, target}

    context = d3.path()
    @link.context(context)
    console.log "Started path"
    for pair in pathData
        @link(pair)

    d = context.toString()
    className = classNames("section-link","commonality-#{unit_commonality}")
    h 'path', {d, className}

  render: ->
    {skeletal, sectionPositions} = @props
    {surfaces} = @state

    className = classNames {skeletal}

    __ = []
    for key, {bounds, padding} of sectionPositions
      {left, top, width, height} = bounds
      x = left
      y = top+padding.top
      width -= (padding.left+padding.right)
      height -= (padding.top+padding.bottom)
      __.push h 'rect.section-tracker', {key, x,y,width, height}

    {width, height} = @props
    h 'svg#section-link-overlay', {className, width, height}, [
      h 'g.section-trackers', __
      h 'g.section-links', surfaces.map @buildLink
    ]

module.exports = {SectionLinkOverlay}

