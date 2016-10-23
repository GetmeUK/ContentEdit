class ContentEdit.Region extends ContentEdit.NodeCollection

    # Regions take a DOM element and convert the child DOM elements to other
    # editable elements. Regions acts as a root collection of the editable
    # elements.

    constructor: (domElement) ->
        super()

        # The DOM element associated with this region of editable content
        @_domElement = domElement

        # Set the content for the region to match the DOM element
        @setContent(domElement)

    # Read-only properties

    domElement: () ->
        # Return the DOM element associated with the region.
        return @_domElement

    isMounted: () ->
        # Return true if the node is mounted in the DOM.
        return true

    type: () ->
        # Return the type of element (this should be the same as the class name)
        return 'Region'

    # Methods

    html: (indent='') ->
        # Return a HTML string for the node
        le = ContentEdit.LINE_ENDINGS
        return (c.html(indent) for c in @children).join(le).trim()

    setContent: (domElementOrHTML) ->
        # Set the contents of the region using a DOM element or HTML string
        domElement = domElementOrHTML
        if domElementOrHTML.childNodes == undefined

            # Convert the HTML string to DOM elements we can pass
            wrapper = document.createElement('div')
            wrapper.innerHTML = domElementOrHTML
            domElement = wrapper

        # Unattach any existing elements
        for child in @children.slice()
            @detach(child)

        # Build and attach new content

        # Convert the existing contents of the DOM element to editable elements
        tagNames = ContentEdit.TagNames.get()

        # Create a list if child nodes we can safely remove whilst iterating
        # through them.
        childNodes = (c for c in domElement.childNodes)

        for childNode in childNodes

            # Filter out non-elements
            unless childNode.nodeType == 1 # ELEMENT_NODE
                continue

            # Find the class associated with this node's tag name
            if childNode.getAttribute('data-ce-tag')
                cls = tagNames.match(childNode.getAttribute('data-ce-tag'))
            else
                cls = tagNames.match(childNode.tagName)

            # Convert the node to a ContentEdit.Element
            element = cls.fromDOMElement(childNode)

            # Remove the node from the DOM
            domElement.removeChild(childNode)

            # Attach the element to the region
            if element
                @attach(element)

        # Trigger a ready event for the region
        ContentEdit.Root.get().trigger('ready', this)