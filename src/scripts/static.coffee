class ContentEdit.Static extends ContentEdit.Element

    # A non-editable (static) HTML element.

    # REVIEW: The primary purpose of static elements is to provide a fallback
    # for when a DOM element in an editable region has not been mapped to an
    # editable `ContentEdit.Element` class.
    #
    # To keep the code small we don't preventively override all the various
    # `ContentEdit.Element` methods, but they can't safely be called and as it
    # stands `ContentEdit.Static` elements should not be interacted with.
    #
    # The only interaction currently supported is dropping other elements on to
    # a static element, without support for this interaction static elements
    # could make it impossible to move a static element from the start or end of
    # a region.
    #
    # A known problem with the content of static elements is that we rely on the
    # browser's interpretation of the content (because we use innerHTML), this
    # can lead to differences is the output as well as inconsistencies between
    # browsers.

    constructor: (tagName, attributes, content) ->
        super(tagName, attributes)

        # The associated DOM element
        @_content = content

    # Read-only properties

    cssTypeName: () ->
        return 'static'

    type: () ->
        # Return the type of element (this should be the same as the class name)
        return 'Static'

    typeName: () ->
        # Return the name of the element type (e.g Image, List item)
        return 'Static'

    # Methods

    createDraggingDOMElement: () ->
        # Create a DOM element that visually aids the user in dragging the
        # element to a new location in the editiable tree structure.
        unless @isMounted()
            return

        helper = super()

        # Use the body of the node to create the helper but limit the text to
        # something sensible.

        # HACK: This is really a best guess at displaying something appropriate
        # in the helper since we have no idea what's contained in a static
        # element.
        text = @_domElement.textContent
        if text.length > ContentEdit.HELPER_CHAR_LIMIT
            text = text.substr(0, ContentEdit.HELPER_CHAR_LIMIT)

        helper.innerHTML = text

        return helper

    html: (indent='') ->
        # Return a HTML string for the node

        # Check if element is a self closing tag
        if HTMLString.Tag.SELF_CLOSING[@_tagName]
            return "#{ indent }<#{ @_tagName }#{ @_attributesToString() }>"

        return "#{ indent }<#{ @_tagName }#{ @_attributesToString() }>" +
            "#{ @_content }" +
            "#{ indent }</#{ @_tagName }>"

    mount: () ->
        # Mount the element on to the DOM

        # Create the DOM element to mount
        @_domElement = document.createElement(@_tagName)

        # Set the attributes
        for name, value of @_attributes
            @_domElement.setAttribute(name, value)

        # Set the content in the document
        @_domElement.innerHTML = @_content

        super()

    # NOTE: Static elements cannot receive focus.
    blur: undefined
    focus: undefined

    # Event handlers

    _onMouseDown: (ev) ->
        # Give the element focus
        super(ev)

        # If the static element has the moveable flag set then allow it to be
        # dragged to a new position.
        if @attr('data-ce-moveable') != undefined

            # We add a small delay to prevent drag engaging instantly
            clearTimeout(@_dragTimeout)
            @_dragTimeout = setTimeout(
                () =>
                    @drag(ev.pageX, ev.pageY)
                150
                )

    _onMouseOver: (ev) ->
        super(ev)

        # Don't highlight that we're over the element
        @_removeCSSClass('ce-element--over')

    _onMouseUp: (ev) ->
        super(ev)

        # If we're waiting to see if the user wants to drag the element, stop
        # waiting they don't.
        if @_dragTimeout
            clearTimeout(@_dragTimeout)

    # Class properties

    @droppers:
        'Static': ContentEdit.Element._dropVert

    # Class methods

    @fromDOMElement: (domElement) ->
        # Convert an element (DOM) to an element of this type
        return new @(
            domElement.tagName,
            @getDOMElementAttributes(domElement),
            domElement.innerHTML
            )


# Register `ContentEdit.Static` the class with associated tag names
ContentEdit.TagNames.get().register(ContentEdit.Static, 'static')