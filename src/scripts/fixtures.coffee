class ContentEdit.Fixture extends ContentEdit.NodeCollection

    # Fixtures take a DOM element and convert it to a single editable element,
    # this allows the creation of field like regions within a page.

    constructor: (domElement) ->
        super()

        # The DOM element associated with this region of editable content
        @_domElement = domElement

        # Convert the existing contents of the DOM element to editable elements
        tagNames = ContentEdit.TagNames.get()

        # Find the class associated with this fixtures tag name
        if @_domElement.getAttribute("data-ce-tag")
            cls = tagNames.match(@_domElement.getAttribute("data-ce-tag"))
        else
            cls = tagNames.match(@_domElement.tagName)

        # Convert the node to a ContentEdit.Element
        element = cls.fromDOMElement(@_domElement)

        # Modify the mount method for the element
        @children = [element]

        element._parent = this
        element.mount()

        # Trigger a ready event for the region
        ContentEdit.Root.get().trigger('ready', this)

    # Read-only properties

    domElement: () ->
        # Return the DOM element associated with the region.
        return @_domElement

    isMounted: () ->
        # Return true if the node is mounted in the DOM.
        return true

    type: () ->
        # Return the type of element (this should be the same as the class name)
        return 'Fixture'

    # Methods

    html: (indent='') ->
        # Return a HTML string for the node
        le = ContentEdit.LINE_ENDINGS
        return (c.html(indent) for c in @children).join(le).trim()