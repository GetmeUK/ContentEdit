class ContentEdit.Region extends ContentEdit.NodeCollection

    # Regions take a DOM element and convert the child DOM elements to other
    # editable elements. Regions acts as a root collection of the editable
    # elements.

    constructor: (domElement, root) ->
        super(root)

        # The DOM element associated with this region of editable content
        @_domElement = domElement

        # Convert the existing contents of the DOM element to editable elements
        tagNames = ContentEdit.TagNames.get()

        # Create a list if child nodes we can safely remove whilst iterating
        # through them.
        childNodes = (c for c in @_domElement.childNodes)

        for childNode in childNodes

            # Filter out non-elements
            unless childNode.nodeType == 1 # ELEMENT_NODE
                continue

            # Find the class associated with this node's tag name
            if childNode.getAttribute("data-ce-tag")
                cls = tagNames.match(childNode.getAttribute("data-ce-tag"))
            else
                cls = tagNames.match(childNode.tagName)

            # Convert the node to a ContentEdit.Element
            element = cls.fromDOMElement(childNode)

            # Remove the node from the DOM
            @_domElement.removeChild(childNode)

            # Attach the element to the region
            if element
                @attach(element)

            # Trigger a ready event for the region
            @_root.trigger('ready', this)

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
        return (c.html(indent) for c in @children).join('\n').trim()
