class ContentEdit.Video extends ContentEdit.ResizableElement

    # An editable video (e.g <video><source src="..." type="..."></video>).
    # The `Video` element supports 2 special tags to allow the the size of the
    # image to be constrained (data-ce-min-width, data-ce-max-width).
    #
    # NOTE: YouTube and Vimeo provide support for embedding videos using the
    # <iframe> tag. For this reason we support both video and iframe tags.
    #
    # `sources` should be specified or set against the element as a list of
    # dictionaries containing `src` and `type` key values.

    constructor: (tagName, attributes, sources=[]) ->
        super(tagName, attributes)

        # List of sources for <video> elements
        @sources = sources

        # Set the aspect ratio for the image based on it's initial width/height
        size = @size()
        @_aspectRatio = size[1] / size[0]

    # Read-only properties

    cssTypeName: () ->
        return 'video'

    type: () ->
        # Return the type of element (this should be the same as the class name)
        return 'Video'

    typeName: () ->
        # Return the name of the element type (e.g Image, List item)
        return 'Video'

    _title: () ->
        # Return a title (based on the source) for the video. This is intended
        # for internal use only.
        src = ''
        if @attr('src')
            src = @attr('src')
        else
            if @sources.length
                src = @sources[0]['src']
        if not src
            src = 'No video source set'

        # Limit the length to something sensible
        if src.length > 80
            src = src.substr(0, 80) + '...'

        return src

    # Methods

    createDraggingDOMElement: () ->
        # Create a DOM element that visually aids the user in dragging the
        # element to a new location in the editiable tree structure.
        unless @isMounted()
            return

        helper = super()
        helper.innerHTML = @_title()
        return helper

    html: (indent='') ->
        # Return a HTML string for the node
        le = ContentEdit.LINE_ENDINGS
        if @tagName() == 'video'
            sourceStrings = []
            for source in @sources
                attributes = ContentEdit.attributesToString(source)
                sourceStrings.push(
                    "#{ indent }#{ ContentEdit.INDENT }<source #{ attributes }>"
                    )
            return "#{ indent }<video#{ @_attributesToString() }>#{ le }" +
                sourceStrings.join(le) +
                "#{ le }#{ indent }</video>"
        else
            return "#{ indent }<#{ @_tagName }#{ @_attributesToString() }>" +
                "</#{ @_tagName }>"

    mount: () ->
        # Mount the element on to the DOM

        # Create the DOM element to mount
        @_domElement = document.createElement('div')

        # Set the classes for the video, we use the wrapping <a> tag's class if
        # it exists, else we use the class applied to the image.
        if @a and @a['class']
            @_domElement.setAttribute('class', @a['class'])

        else if @_attributes['class']
            @_domElement.setAttribute('class', @_attributes['class'])

        # Set any styles for the element
        style = if @_attributes['style'] then @_attributes['style'] else ''

        # Set the size using style
        if @_attributes['width']
            style += "width:#{ @_attributes['width'] }px;"

        if @_attributes['height']
            style += "height:#{ @_attributes['height'] }px;"

        @_domElement.setAttribute('style', style)

        # Set the title of the element (for mouse over)
        @_domElement.setAttribute('data-ce-title', @_title())

        super()

    unmount: () ->
        # Unmount the element from the DOM

        if @isFixed()
            # Revert the DOM element to an iframe
            wrapper = document.createElement('div')
            wrapper.innerHTML = @html()
            domElement = wrapper.querySelector('iframe')

            # Replace the current DOM element with the iframe
            @_domElement.parentNode.replaceChild(domElement, @_domElement)
            @_domElement = domElement

        super()

    # Class properties

    @droppers:
        'Image': ContentEdit.Element._dropBoth
        'PreText': ContentEdit.Element._dropBoth
        'Static': ContentEdit.Element._dropBoth
        'Text': ContentEdit.Element._dropBoth
        'Video': ContentEdit.Element._dropBoth

    # List of allowed drop placements for the class, supported values are:
    @placements: ['above', 'below', 'left', 'right', 'center']

    # Class methods

    @fromDOMElement: (domElement) ->
        # Convert an element (DOM) to an element of this type

        # Check for source elements
        childNodes = (c for c in domElement.childNodes)
        sources = []
        for childNode in childNodes
            if childNode.nodeType == 1 \
                    and childNode.tagName.toLowerCase() == 'source'
                sources.push(@getDOMElementAttributes(childNode))

        return new @(
            domElement.tagName,
            @getDOMElementAttributes(domElement),
            sources
            )


# Register `ContentEdit.Video` the class with associated tag names
ContentEdit.TagNames.get().register(ContentEdit.Video, 'iframe', 'video')