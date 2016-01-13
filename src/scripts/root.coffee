class _Root extends ContentEdit.Node

    # The root node manages state and listens for events for all nodes. However
    # it is not the root of the tree, individual editable regions within the
    # HTML each have their own tree structure that is rooted to a
    # `ContentEdit.Region` instance.
    #
    # The root node actually has no specific knowledge of any other node and in
    # this respect it is perhaps more useful to visualise it as a floating node
    # that all other nodes talk to (and through).

    constructor: () ->
        super()

        # The currently focused element
        @_focused = null

        # The currently dragging and dropping elements
        @_dragging = null
        @_dropTarget = null

        # A helper DOM element used when dragging an element
        @_draggingDOMElement = null

        # The currently resizing element
        @_resizing = null
        @_resizingInit = null

    # Read-only properties

    dragging: () ->
        # Return the element that currently is being dragged (if any)
        return @_dragging

    dropTarget: () ->
        # Return the element that is the dragging element is currently over
        return @_dropTarget

    focused: () ->
        # Return the element that currently has focus (if any)
        return @_focused

    resizing: () ->
        # Return the element that currently is being resized (if any)
        return @_resizing

    type: () ->
        # Return the type of element (this should be the same as the class name)
        return 'Root'

    # Dragging methods

    cancelDragging: () ->
        # Cancel the current dragging interaction

        # Check there's a dragging interaction to cancel
        unless @_dragging
            return

        # Remove dragging helper
        document.body.removeChild(@_draggingDOMElement)

        # Remove dragging behaviour
        document.removeEventListener('mousemove', @_onDrag)
        document.removeEventListener('mouseup', @_onStopDragging)

        # Mark the element as no longer being dragged
        @_dragging._removeCSSClass('ce-element--dragging')
        @_dragging = null
        @_dropTarget = null

        # Remove dragging class from body
        ContentEdit.removeCSSClass(document.body, 'ce--dragging')

    startDragging: (element, x, y) ->
        # Set an element as dragging (only one element can be dragged at any one
        # time).
        if @_dragging
            return

        # Set this element as dragging
        @_dragging = element

        # Mark the elment as being dragged
        @_dragging._addCSSClass('ce-element--dragging')

        # Add a helper class for the element
        @_draggingDOMElement = @_dragging.createDraggingDOMElement()
        document.body.appendChild(@_draggingDOMElement)

        # Position the drag helper at the mouse cursor
        @_draggingDOMElement.style.left = "#{ x }px"
        @_draggingDOMElement.style.top = "#{ y }px"

        # Setup dragging behaviour for the element
        document.addEventListener('mousemove', @_onDrag)
        document.addEventListener('mouseup', @_onStopDragging)

        # Add dragging class to body
        ContentEdit.addCSSClass(document.body, 'ce--dragging')

    _getDropPlacement: (x, y) ->
        # Return the vertical and horizonal placement of a dragged element over
        # the current drop target element.
        unless @_dropTarget
            return null

        # Calculate the cursors position relative to the drop target
        rect = @_dropTarget.domElement().getBoundingClientRect()
        [x, y] = [x - rect.left, y - rect.top]

        # Determine the placement of the element
        horz = 'center'
        if x < ContentEdit.DROP_EDGE_SIZE
            horz = 'left'
        else if x > rect.width - ContentEdit.DROP_EDGE_SIZE
            horz = 'right'

        vert = 'above'
        if y > rect.height / 2
            vert = 'below';

        return [vert, horz]

    _onDrag: (ev) =>
        # Prevent content selection while dragging elements
        ContentSelect.Range.unselectAll()

        # Position the drag helper at the mouse cursor
        @_draggingDOMElement.style.left = "#{ ev.pageX }px"
        @_draggingDOMElement.style.top = "#{ ev.pageY }px"

        # Set classes
        if @_dropTarget
            placement = @_getDropPlacement(ev.clientX, ev.clientY)

            # Clear existing placement classes
            @_dropTarget._removeCSSClass('ce-element--drop-above')
            @_dropTarget._removeCSSClass('ce-element--drop-below')
            @_dropTarget._removeCSSClass('ce-element--drop-center')
            @_dropTarget._removeCSSClass('ce-element--drop-left')
            @_dropTarget._removeCSSClass('ce-element--drop-right')

            # Set current placement classes
            if placement[0] in @_dragging.constructor.placements
                @_dropTarget._addCSSClass("ce-element--drop-#{ placement[0] }")

            if placement[1] in @_dragging.constructor.placements
                @_dropTarget._addCSSClass("ce-element--drop-#{ placement[1] }")

    _onStopDragging: (ev) =>
        # Looking into how we can detect the region the cursor is in for the
        # element.
        placement = @_getDropPlacement(ev.clientX, ev.clientY)

        # Drop the dragging element
        @_dragging.drop(@_dropTarget, placement)

        # Reset the dragging interactions
        @cancelDragging()

    # Resizing methods

    startResizing: (element, corner, x, y, fixed) ->
        # Set an element as resizing (only one element can be resized at any one
        # time).
        if @_resizing
            return

        # Set this element as resizing
        @_resizing = element

        # Remember the initial starting point and the elements size at the point
        # the user started to resize it.
        @_resizingInit = {
            corner: corner,
            fixed: fixed,
            origin: [x, y],
            size: element.size()
            }

        # Mark the elment as being dragged
        @_resizing._addCSSClass('ce-element--resizing')

        # Measure the width of the parent element we're resizing within so we
        # can constrain the resize to fit.
        parentDom = @_resizing.parent().domElement()

        # To measure the parent's width exluding padding we add a block element
        # and measure it's width before removing.
        measureDom = document.createElement('div')
        measureDom.setAttribute('class', 'ce-measure')
        parentDom.appendChild(measureDom)
        @_resizingParentWidth = measureDom.getBoundingClientRect().width
        parentDom.removeChild(measureDom)

        # Setup dragging behaviour for the element
        document.addEventListener('mousemove', @_onResize)
        document.addEventListener('mouseup', @_onStopResizing)

        # Add resizing class to body
        ContentEdit.addCSSClass(document.body, 'ce--resizing')

    _onResize: (ev) =>
        # Prevent content selection while resizing elements
        ContentSelect.Range.unselectAll()

        # Calculate the 'x' size change that needs to be applied
        x = @_resizingInit.origin[0] - ev.clientX

        # Use the anchor to determine which direction increases/decreases the
        # 'x' size.
        if @_resizingInit.corner[1] == 'right'
            x = -x

        # Calculate the width and height
        width = @_resizingInit.size[0] + x

        # The width cannot be greater that the parent containers width
        width = Math.min(width, @_resizingParentWidth)

        # If the aspect ratio is fixed use the width to generate the height...
        if @_resizingInit.fixed
            height = width * @_resizing.aspectRatio()

        # ...else adjust the height based on the y distance.
        else

            # Calculate the 'y' size change that needs to be applied
            y = @_resizingInit.origin[1] - ev.clientY

            # Use the anchor to determine which direction increases/decreases
            # the 'y' size.
            if @_resizingInit.corner[0] == 'bottom'
                y = -y

            height = @_resizingInit.size[1] + y

        # Set the new size for the element
        @_resizing.size([width, height])

    _onStopResizing: (ev) =>
        # Reset the resizing interactions

        # Remove resizing behaviour
        document.removeEventListener('mousemove', @_onResize)
        document.removeEventListener('mouseup', @_onStopResizing)

        # Mark the element as no longer being resized
        # Mark the elment as being dragged
        @_resizing._removeCSSClass('ce-element--resizing')
        @_resizing = null
        @_resizingInit = null
        @_resizingParentWidth = null

        # Remove resizing class from body
        ContentEdit.removeCSSClass(document.body, 'ce--resizing')


class ContentEdit.Root

    # The `ContentEdit.Root` class is a singleton, this code provides access to
    # the singleton instance of the protected `_Root` class which is initialized
    # the first time the class method `get` is called.

    instance = null

    @get: () ->
        instance ?= new _Root()