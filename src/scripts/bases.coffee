class ContentEdit.Node

    # Editable content is structured as a tree, each node in the tree is an
    # instance of a class that inherits from the base `Node` class.

    constructor: () ->

        # Event bindings for the node
        @_bindings = {}

        # The parent of the node
        @_parent = null

        # The date/time the node was last modified
        @_modified = null

    # Read-only properties

    lastModified: () ->
        # Return null if the node is not modified, else return the date/time the
        # node was last modified.
        return @_modified

    parent: () ->
        # Return the parent of the node
        return @_parent

    parents: () ->
        # Return the ancestors of the node (in ascending order)
        parents = []

        parent = @_parent
        while parent
            parents.push(parent)
            parent = parent._parent

        return parents

    type: () ->
        # Return the type of element (this should be the same as the class name)
        return 'Node'

    # Methods

    html: (indent='') ->
        # Return a HTML string for the node
        throw new Error('`html` not implemented')

    # Event methods

    bind: (eventName, callback) ->
        # Bind a callback to an event

        # Check a list has been set for the specified event
        if @_bindings[eventName] == undefined
            @_bindings[eventName] = []

        # Add the callback to list for the event
        @_bindings[eventName].push(callback)

        return callback

    trigger: (eventName, args...) ->
        # Trigger an event against the node

        # Check we have callbacks to trigger for the event
        unless @_bindings[eventName]
            return

        # Call each function bound to the event
        for callback in @_bindings[eventName]
            if not callback
                continue
            callback.call(this, args...)

    unbind: (eventName, callback) ->
        # Unbind a callback from an event

        # If no eventName is specified remove all events
        unless eventName
            @_bindings = {}
            return

        # If no callback is specified remove all callbacks for the event
        unless callback
            @_bindings[eventName] = undefined
            return

        # Check if any callbacks are bound to this event
        unless @_bindings[eventName]
            return

        # Remove the callback from the event
        for suspect, i in @_bindings[eventName]
            if suspect is callback
                @_bindings[eventName].splice(i, 1)

    # Change tracking methods

    commit: () ->
        # Mark the node as being unmodified
        @_modified = null

        ContentEdit.Root.get().trigger('commit', this)

    taint: () ->
        # Mark the node as being modified
        now = Date.now()
        @_modified = now

        # Mark ancestors as modified
        for parent in @parents()
            parent._modified = now

        # Mark the root as modified
        root = ContentEdit.Root.get()
        root._modified = now

        root.trigger('taint', this)

    # Navigation methods

    closest: (testFunc) ->
        # Find and return the first parent that meets the test condition
        parent = this.parent()
        while parent and not testFunc(parent)
            if parent.parent
                parent = parent.parent()
            else
                parent = null
        return parent

    # The next and previous methods provide a mechanism for navigating elements
    # in the editable content tree as a flat structure.

    next: () ->
        # Return the next node in the tree

        # If the node is a populated collection return the first child
        if @children and @children.length > 0
            return @children[0]

        # Look for a next sibling for this node, if we don't find one check each
        # ancestor for one.
        for node in [this].concat(@parents())

            # Check the node is part of a collection, if not there is no next
            # element.
            if not node.parent()
                return null

            children = node.parent().children
            index = children.indexOf(node)

            if index < children.length - 1
                return children[index + 1]

    nextContent: () ->
        # Return the next node that supports a content property (e.g
        # `ContentEdit.Text`).
        return @nextWithTest (node) ->
            node.content != undefined

    nextSibling: () ->
        # Return the nodes next sibling
        index = @parent().children.indexOf(this)

        # Check if this is the last node in the collection in which case there
        # is no next sibiling.
        if index == @parent().children.length - 1
            return null

        return @parent().children[index + 1]

    nextWithTest: (testFunc) ->
        # Return the next node that returns true when passed to the `testFunc`
        # function.
        node = this
        while node
            node = node.next()
            if node and testFunc(node)
                return node

    previous: () ->
        # Return the previous element in the tree

        # Check the node is part of a collection, if not there is no previous
        # element.
        if not @parent()
            return null

        # If the node doesn't have a previous sibling then the previous node is
        # the parent.
        children = @parent().children
        if children[0] is this
            return @parent()

        # If the node is a collection find the last child node that either isn't
        # a collection or is an empty collection. The last child in a collection
        # of collections is illustrated below.
        #
        # - a0 (this node)
        #   - b0
        #   - b1
        #   - b2
        #       - c0
        #       - c1 (last child)

        node = children[children.indexOf(this) - 1]
        while node.children and node.children.length
            node = node.children[node.children.length - 1]

        return node

    previousContent: () ->
        # Return the previous node that supports a content property (e.g
        # `ContentEdit.Text`).
        node = @previousWithTest (node) -> node.content != undefined

    previousSibling: () ->
        # Return the nodes previous sibling
        index = @parent().children.indexOf(this)

        # Check if this is the first node in the collection in which case there
        # is no previous sibiling.
        if index == 0
            return null

        return @parent().children[index - 1]

    previousWithTest: (testFunc) ->
        # Return the first previous node that returns true when passed to the
        # `testFunc` function.
        node = this
        while node
            node = node.previous()
            if node and testFunc(node)
                return node

    # Class methods

    @extend: (cls) ->
        # Support for extending a class with additional classes

        # Instance properties
        for key, value of cls.prototype
            if key == 'constructor'
                continue
            @::[key] = value

        # Class properties
        for key, value of cls
            if key in '__super__'
                continue
            @::[key] = value

        return this

    @fromDOMElement: (domElement) ->
        # Convert an element (DOM) to an element of this type
        throw new Error('`fromDOMElement` not implemented')


class ContentEdit.NodeCollection extends ContentEdit.Node

    # The `NodeCollection` class is used to implement nodes that parent a
    # collection of child nodes (for example the root or a region).

    constructor: () ->
        super()

        # The children within the collection
        @children = []

    # Read-only properties

    descendants: () ->
        # Return a (flat) list all the decendants

        # Build the list of decendants
        descendants = []
        nodeStack = @children.slice()

        while nodeStack.length > 0
            node = nodeStack.shift()
            descendants.push(node)

            # If the child is a collection add it's children to the stack
            if node.children and node.children.length > 0
                nodeStack = node.children.slice().concat(nodeStack)

        return descendants

    isMounted: () ->
        # Return true if the node is mounted in the DOM
        return false

    type: () ->
        # Return the type of element (this should be the same as the class name)
        return 'NodeCollection'

    # Methods

    attach: (node, index) ->
        # Attach a node to the collection, optionally at the specified index. If
        # no index is specified the node is appended as the last child.

        # If the node is already attached to another collection detach it
        if node.parent()
            node.parent().detach(node)

        # Set the new parent for the node as this collection
        node._parent = this

        # Insert the node into the collection
        if index != undefined
            @children.splice(index, 0, node)
        else
            @children.push(node)

        # If the node is an element mount it on the DOM
        if node.mount and @isMounted()
            node.mount()

        # Mark the colleciton as modified
        @taint()

        ContentEdit.Root.get().trigger('attach', this, node)

    commit: () ->
        # Mark the node and all of it's children as being unmodified

        # Silently mark all the children as unmodified
        for descendant in @descendants()
            descendant._modified = null

        # Commit collection
        @_modified = null

        ContentEdit.Root.get().trigger('commit', this)

    detach: (node) ->
        # Detach the specified node from the collection

        # Find the node in the collection (if not found return)
        nodeIndex = @children.indexOf(node)
        if nodeIndex == -1
            return

        # If the node is an element unmount it from the DOM
        if node.unmount and @isMounted() and node.isMounted()
            node.unmount()

        # Remove the element from the collection
        @children.splice(nodeIndex, 1)

        # Set the parent to null
        node._parent = null

        # Mark the collection as modified
        @taint()

        ContentEdit.Root.get().trigger('detach', this, node)


class ContentEdit.Element extends ContentEdit.Node

    # The `Element` class is used to implement nodes that appear as HTML
    # elements.

    constructor: (tagName, attributes) ->
        super()

        # The tag name (e.g h1 or p)
        @_tagName = tagName.toLowerCase()

        # The attributes (e.g <p id="foo" class="bar">)
        @_attributes = if attributes then attributes else {}

        # The DOM element associated with the element
        @_domElement = null

        # A dictionary of behaviour flags which can be configured to determine
        # what behaviour an element allows.
        @_behaviours = {
            drag: true,   # The element can be dragged
            drop: true,   # The element can be dropped on to
            merge: true,  # The element can be merged with another
            remove: true, # The element can be removed
            resize: true, # The element can be resized
            spawn: true   # The element can spawn new elements
        }

    # Read-only properties

    attributes: () ->
        # Return an copy of the elements attributes
        attributes = {}
        for name, value of @_attributes
            attributes[name] = value
        return attributes

    cssTypeName: () ->
        # Return the CSS type modifier name for the element
        # (e.g ce-element--type-...).
        return 'element'

    domElement: () ->
        # Return the DOM element associated with the element
        return @_domElement

    isFixed: () ->
        # Return true if the element is parented by a fixture
        return @parent() and @parent().type() == 'Fixture'

    isFocused: () ->
        # Return true if the element currently has focus
        return ContentEdit.Root.get().focused() == this

    isMounted: () ->
        # Return true if the node is mounted in the DOM
        return @_domElement != null

    type: () ->
        # Return the type of element (this should be the same as the class name)
        return 'Element'

    typeName: () ->
        # Return the name of the element type (e.g Image, List item)
        return 'Element'

    # Methods

    addCSSClass: (className) ->
        # Add a CSS class to the element

        # Check if we need to add the class
        modified = false
        unless @hasCSSClass(className)
            modified = true
            if @attr('class')
                @attr('class', "#{ @attr('class') } #{ className }")
            else
                @attr('class', className)

        # Add the CSS class to the DOM element
        @_addCSSClass(className)

        # Mark the element as modified
        if modified
            @taint()

    attr: (name, value) ->
        # Get/Set the value of an attribute for the element, the attribute is
        # only set if a value is specified.
        name = name.toLowerCase()

        # Get...
        if value == undefined
            return @_attributes[name]

        # ...or Set the attribute
        @_attributes[name] = value

        # Set the attribute against the DOM element if mounted and we're not
        # setting `class`. CSS classes should always be set using the
        # `addCSSClass` method which sets the class against the mounted
        # DOM element whilst maintaining the classes applied for editing.
        if @isMounted() and name.toLowerCase() != 'class'
            @_domElement.setAttribute(name, value)

        # Mark as modified
        @taint()

    blur: () ->
        # Remove focus from the element
        root = ContentEdit.Root.get()
        if @isFocused()
            @_removeCSSClass('ce-element--focused')
            root._focused = null
            root.trigger('blur', this)

    can: (behaviour, allowed) ->
        # Get/Set the behaviour allowed for an element

        # Get...
        if allowed == undefined
            return (not @isFixed()) and @_behaviours[behaviour]

        # ...or Set the permission
        @_behaviours[behaviour] = allowed

    createDraggingDOMElement: () ->
        # Create a DOM element that visually aids the user in dragging the
        # element to a new location in the editiable tree structure.
        unless @isMounted()
            return

        helper = document.createElement('div')
        helper.setAttribute(
            'class',
            "ce-drag-helper ce-drag-helper--type-#{ @cssTypeName() }"
            )
        helper.setAttribute('data-ce-type', ContentEdit._(@typeName()));

        return helper

    drag: (x, y) ->
        # Drag the element to a new position
        unless @isMounted() and @can('drag')
            return

        root = ContentEdit.Root.get()
        root.startDragging(this, x, y)
        root.trigger('drag', this)

    drop: (element, placement) ->
        # Drop the element into a new position in the editable structure, if no
        # element is provided, or a method to manage the drop isn't defined the
        # drop is cancelled.
        unless @can('drop')
            return

        root = ContentEdit.Root.get()
        if element
            # Remove the drop class from the element
            element._removeCSSClass('ce-element--drop')
            element._removeCSSClass("ce-element--drop-#{ placement[0] }")
            element._removeCSSClass("ce-element--drop-#{ placement[1] }")

            # Determine if either elements class supports the drop
            if @constructor.droppers[element.type()]
                @constructor.droppers[element.type()](
                    this,
                    element,
                    placement
                    )
                root.trigger('drop', this, element, placement)
                return

            else if element.constructor.droppers[@type()]
                element.constructor.droppers[@type()](
                    this,
                    element,
                    placement
                    )
                root.trigger('drop', this, element, placement)
                return

        # The drop was unsuccessful so trigger drop event without target or
        # placement.
        root.trigger('drop', this, null, null)

    focus: (supressDOMFocus) ->
        # Focus the element
        root = ContentEdit.Root.get()

        # Does this element already have focus
        if @isFocused()
            return

        # Is there an existing element with focus? If so we need to blur it
        if root.focused()
            root.focused().blur()

        # Set this element as focused
        @_addCSSClass('ce-element--focused')
        root._focused = this

        # Focus on the element
        if @isMounted() and not supressDOMFocus
            @domElement().focus()

        root.trigger('focus', this)

    hasCSSClass: (className) ->
        # Return true if the element has the specified CSS class

        if @attr('class')
            # Convert class attribute to a list of class names
            classNames = (c for c in @attr('class').split(' '))

            # If the class name isn't in the list add it
            if classNames.indexOf(className) > -1
                return true

        return false

    merge: (element) ->
        # Attempt to merge 2 elements. Elements can only merge if a merger
        # function has been defined against either merging elements `mergers`
        # class property.
        #
        # The `mergers` class property is an object mapping class names to
        # functions that handle merging element classes. Merger functions
        # handle merging in either direction.

        # A merge always results in the element being removed so merge and
        # remove must be allowed.
        unless @can('merge') and @can('remove')
            return false

        # Determine if either elements class supports the merge
        if @constructor.mergers[element.type()]
            @constructor.mergers[element.type()](element, this)

        else if element.constructor.mergers[@type()]
            element.constructor.mergers[@type()](element, this)

    mount: () ->
        # Mount the element on to the DOM, this method is not designed to be
        # called against the base `Element` class, instead it is typically
        # called using `super()` at the end of an overriding `mount` method.

        # This check enables `mount()` to be called directly against the Element
        # class, however this is not the expected behaviour.
        unless @_domElement
            @_domElement = document.createElement(@tagName())

        sibling = @nextSibling()
        if sibling
            @parent().domElement().insertBefore(
                @_domElement,
                sibling.domElement()
                )
        else
            # Check to see if the parent is a fixture, if so then the element
            # will replace the parent DOM instead of appending it.
            if @isFixed()
                @parent().domElement().parentNode.replaceChild(
                    @_domElement,
                    @parent().domElement()
                    )
                @parent()._domElement = @_domElement

            else
                @parent().domElement().appendChild(@_domElement)

        # Add interaction handlers
        @_addDOMEventListeners()

        # Add the type class
        @_addCSSClass('ce-element')
        @_addCSSClass("ce-element--type-#{ @cssTypeName() }")

        # Add the focused class if the element is focused
        if @isFocused()
            @_addCSSClass('ce-element--focused')

        ContentEdit.Root.get().trigger('mount', this)

    removeAttr: (name) ->
        # Remove an attribute from the element
        name = name.toLowerCase()

        # Remove an attribute from the element
        if not @_attributes[name]
            return

        # Remove the attribute
        delete @_attributes[name]

        # Remove the attribute from the DOM element if mounted and we're not
        # removing `class`. CSS classes should always be removed using the
        # `removeCSSClass` method which removes the class from the mounted
        # DOM element whilst maintaining the classes applied for editing.
        if @isMounted() and name.toLowerCase() != 'class'
            @_domElement.removeAttribute(name)

        # Mark as modified
        @taint()

    removeCSSClass: (className) ->
        # Remove a CSS class from the element
        if not @hasCSSClass(className)
            return

        # Remove the CSS class
        classNames = (c for c in @attr('class').split(' '))

        # If the class name is in the list remove it
        classNameIndex = classNames.indexOf(className)
        if classNameIndex > -1
            classNames.splice(classNameIndex, 1)

        # If there are not classes left remove the attribute
        if classNames.length
            @attr('class', classNames.join(' '))
        else
            @removeAttr('class')

        # Remove the CSS class from the DOM element
        @_removeCSSClass(className)

        # Mark the element as modified
        @taint()

    tagName: (name) ->
        # Get/Set the tag name for the element, the tag name is only set if a
        # value is specified.

        # Get...
        if name == undefined
            return @_tagName

        # ...or Set the tag name
        @_tagName = name.toLowerCase()

        # Re-mount the element if mounted
        if @isMounted()
            @unmount()
            @mount()

        # Mark as modified
        @taint()

    unmount: () ->
        # Unmount the element from the DOM

        # Remove event listeners
        @_removeDOMEventListeners()

        # Check if the element is a fixture in which case it cannot be unmounted
        # but instead we must remove any classes applied on mount.
        if @isFixed()
            @_removeCSSClass('ce-element')
            @_removeCSSClass("ce-element--type-#{ @cssTypeName() }")
            @_removeCSSClass('ce-element--focused')

            return

        if @_domElement.parentNode
            @_domElement.parentNode.removeChild(@_domElement)
        @_domElement = null

        # Trigger the unmount event
        ContentEdit.Root.get().trigger('unmount', this)

    # Event handlers

    _addDOMEventListeners: () ->
        # Add all event bindings for the DOM element in this method

        # Define all event listeners
        @_domEventHandlers = {
            # Drag events
            'dragstart': (ev) =>
                ev.preventDefault()

            # Focus events
            'focus': (ev) =>
                ev.preventDefault()

            # Keyboard events
            'keydown': (ev) =>
                @_onKeyDown(ev)

            'keyup': (ev) =>
                @_onKeyUp(ev)

            # Mouse events
            'mousedown':  (ev) =>
                # The editing environment only uses primary mouse button events
                if ev.button == 0
                    @_onMouseDown(ev)

            'mousemove': (ev) =>
                @_onMouseMove(ev)

            'mouseover': (ev) =>
                @_onMouseOver(ev)

            'mouseout': (ev) =>
                @_onMouseOut(ev)

            'mouseup': (ev) =>
                # The editing environment only primary left mouse button events
                if ev.button == 0
                    @_onMouseUp(ev)

            # Paste event

            'dragover': (ev) =>
                ev.preventDefault()

            'drop': (ev) =>
                @_onNativeDrop(ev)

            'paste': (ev) =>
                @_onPaste(ev)
        }

        # Add all event listeners
        for eventName, eventHandler of @_domEventHandlers
            @_domElement.addEventListener(eventName, eventHandler)

    _onKeyDown: (ev) ->
        # No default behaviour

    _onKeyUp: (ev) ->
        # No default behaviour

    _onMouseDown: (ev) ->
        # Check the element supports a `focus` method
        if @focus
            # We suppress the DOM focus that would normally be inniated as it
            # this helps prevent page jumps when selecting large blocks of
            # content.
            @focus(true)

    _onMouseMove: (ev) ->
        @_onOver(ev)

    _onMouseOver: (ev) ->
        @_onOver(ev)

    _onMouseOut: (ev) ->
        @_removeCSSClass('ce-element--over')

        # If the element is the current drop target we need to remove it
        root = ContentEdit.Root.get()
        dragging = root.dragging()
        if dragging
            @_removeCSSClass('ce-element--drop')
            @_removeCSSClass('ce-element--drop-above')
            @_removeCSSClass('ce-element--drop-below')
            @_removeCSSClass('ce-element--drop-center')
            @_removeCSSClass('ce-element--drop-left')
            @_removeCSSClass('ce-element--drop-right')
            root._dropTarget = null

    _onMouseUp: (ev) ->
        # No default behaviour
        @_ieMouseDownEchoed = false

    _onNativeDrop: (ev) ->
        # By default we don't support native drop events and external libraries
        # are expected to handle native drop support.
        ev.preventDefault()
        ev.stopPropagation()
        ContentEdit.Root.get().trigger('native-drop', this, ev)

    _onPaste: (ev) ->
        # By default we don't support paste events and external libraries
        # are expected to handle paste support.
        ev.preventDefault()
        ev.stopPropagation()
        ContentEdit.Root.get().trigger('paste', this, ev)

    _onOver: (ev) ->
        @_addCSSClass('ce-element--over')

        # Check an elment is currently being dragged
        root = ContentEdit.Root.get()
        dragging = root.dragging()
        unless dragging
            return

        # Check the dragged element isn't this element (can't drop on self)
        unless dragging != this
            return

        # Check we don't already have a drop target
        if root._dropTarget
            return

        # Check this element is allowed to receive drops
        unless @can('drop')
            return

        # Check the dragged element can be dragged on to this element
        unless (@constructor.droppers[dragging.type()] \
                or dragging.constructor.droppers[@type()])
            return

        # Mark the element as a drop target
        @_addCSSClass('ce-element--drop')
        root._dropTarget = @

    _removeDOMEventListeners: () ->
        # The method is called before the element is removed from the DOM,
        # whilst it is unnecessary to remove and event listeners bound to the
        # DOM element itself, event listners bound to associated DOM elements
        # should be removed here.

        # Remove all event listeners
        for eventName, eventHandler of @_domEventHandlers
            @_domElement.removeEventListener(eventName, eventHandler)


    # Private methods

    _addCSSClass: (className) ->
        # Add a CSS class to the DOM element (the class is only added to the DOM
        # element, not the elements `class` attribute.
        unless @isMounted()
            return

        ContentEdit.addCSSClass(@_domElement, className)

    _attributesToString: () ->
        # Return the attributes for the element as a string
        unless Object.getOwnPropertyNames(@_attributes).length > 0
            return ''

        return ' ' + ContentEdit.attributesToString(@_attributes)

    _removeCSSClass: (className) ->
        # Remove a CSS class from the DOM element (the class is only removed
        # from the DOM element, not the elements `class` attribute.
        unless @isMounted()
            return

        ContentEdit.removeCSSClass(@_domElement, className)

    # Class properties

    # Map of functions to support dropping dragged elements (see
    # `ContentEdit.Element.drop()`).
    @droppers: {}

    # Map of functions to support merging elements (see
    # `ContentEdit.Element.merge()`).
    @mergers: {}

    # List of allowed drop placements for the class, supported values are:
    #
    # - above
    # - below
    # - center
    # - left
    # - right
    #
    @placements: ['above', 'below']

    # Class methods

    @getDOMElementAttributes: (domElement) ->
        # Return a map of attributes for a DOM element

        # Check if the element has any attributes and if not return an empty map
        unless domElement.hasAttributes()
            return {}

        # Convert the DOM elements name/value attibute array to a map
        attributes = {}
        for attribute in domElement.attributes
            attributes[attribute.name.toLowerCase()] = attribute.value

        return attributes

    # Private class methods

    # The following private methods are useful when defining common drag/drop
    # behaviour for elements.

    @_dropVert: (element, target, placement) ->
        # Drop an element above or below another element

        # Remove the element from it's current parent
        element.parent().detach(element)

        # Get the position of the target element we're dropping on to
        insertIndex = target.parent().children.indexOf(target)

        # Determine which side of the target to drop the element
        if placement[0] == 'below'
            insertIndex += 1

        # Drop the element into it's new position
        target.parent().attach(element, insertIndex)

    @_dropBoth: (element, target, placement) ->
        # Drop an element above, below, left or right of another element

        # Remove the element from it's current parent
        element.parent().detach(element)

        # Get the position of the target element we're dropping on to
        insertIndex = target.parent().children.indexOf(target)

        # Determine which side of the target to drop the element
        if placement[0] == 'below' and placement[1] == 'center'
            insertIndex += 1

        # Add/Remove alignment classes
        alignLeft = ContentEdit.ALIGNMENT_CLASS_NAMES['left']
        alignRight = ContentEdit.ALIGNMENT_CLASS_NAMES['right']

        if element.a
            element._removeCSSClass(alignLeft)
            element._removeCSSClass(alignRight)

            if element.a['class']
                aClassNames = []
                for className in element.a['class'].split(' ')
                    if className == alignLeft or className == alignRight
                        continue
                    aClassNames.push(className)

                if aClassNames.length
                    element.a['class'] = aClassNames.join(' ')
                else
                    delete element.a['class']

        else
            element.removeCSSClass(alignLeft)
            element.removeCSSClass(alignRight)

        if placement[1] == 'left'
            if element.a
                if element.a['class']
                    element.a['class'] += ' ' + alignLeft
                else
                    element.a['class'] = alignLeft
                element._addCSSClass(alignLeft)
            else
                element.addCSSClass(alignLeft)

        if placement[1] == 'right'
            if element.a
                if element.a['class']
                    element.a['class'] += ' ' + alignRight
                else
                    element.a['class'] = alignRight
                element._addCSSClass(alignRight)
            else
                element.addCSSClass(alignRight)

        # Drop the element into it's new position
        target.parent().attach(element, insertIndex)


class ContentEdit.ElementCollection extends ContentEdit.Element

    # The `ElementCollection` class is used to implement elements that parent
    # a collection of child elements (for example a list or a table row).

    @extend ContentEdit.NodeCollection

    constructor: (tagName, attributes) ->
        super(tagName, attributes)
        ContentEdit.NodeCollection::constructor.call(this)

    # Read-only properties

    cssTypeName: () ->
        # Return the CSS type modifier name for the element
        # (e.g ce-element--type-...).
        return 'element-collection'

    isMounted: () ->
        # Return true if the element collection is mounted
        return @_domElement != null

    type: () ->
        # Return the type of element (this should be the same as the class name)
        return 'ElementCollection'

    # Methods

    createDraggingDOMElement: () ->
        # Create a DOM element that visually aids the user in dragging the
        # collection to a new location in the editable tree structure.
        unless @isMounted()
            return

        helper = super()

        # Use the body of the node to create the helper but limit the text to
        # something sensible.
        text = @_domElement.textContent
        if text.length > ContentEdit.HELPER_CHAR_LIMIT
            text = text.substr(0, ContentEdit.HELPER_CHAR_LIMIT)

        helper.innerHTML = text

        return helper

    detach: (element) ->
        # Detach the specified element from the collection
        ContentEdit.NodeCollection::detach.call(this, element)

        # Remove the collection if it's empty
        if @children.length == 0 and @parent()
            @parent().detach(this)

    html: (indent='') ->
        # Return a HTML string for the node
        children = (c.html(indent + ContentEdit.INDENT) for c in @children)

        le = ContentEdit.LINE_ENDINGS
        if @isFixed()
            return children.join(le)

        else
            attributes = @_attributesToString()
            return "#{ indent }<#{ @tagName() }#{ attributes }>#{ le }" +
                "#{ children.join(le) }#{ le }" +
                "#{ indent }</#{ @tagName() }>"

    mount: () ->
        # Mount the element on to the DOM

        # Create the DOM element to mount
        @_domElement = document.createElement(@_tagName)

        # Set the attributes
        for name, value of @_attributes
            @_domElement.setAttribute(name, value)

        super()

        # Mount all the children
        for child in @children
            child.mount()

    unmount: () ->
        # Unmount the element from the DOM

        # Unmount all the children
        for child in @children
            child.unmount()

        super()

    # NOTE: Collections cannot receive focus.
    blur: undefined
    focus: undefined


class ContentEdit.ResizableElement extends ContentEdit.Element

    # The `ResizableElement` class is used to implement elements that can be
    # resized (for example an image or video).

    constructor: (tagName, attributes) ->
        super(tagName, attributes)

        # The DOM element used to display size information for the element
        @_domSizeInfoElement = null

        # The aspect ratio of the element
        @_aspectRatio = 1

    # Read-only properties

    aspectRatio: () ->
        # Return the aspect ratio of the element (ratio = height / width)
        #
        # NOTE: The aspect ratio is typically set when the element is
        # constructed, it is down to the inheriting element to determine if,
        # when and how it may be updated after that. It is not safe to calculate
        # the aspect ratio on the fly as casting the width/height of the element
        # to an integer (for example when resizing) can alter the ratio.

        return @_aspectRatio

    maxSize: () ->
        # Return the maximum size the element can be set to (use the
        # `data-ce-max-width` attribute to set this).
        #
        # NOTE: By default `maxSize` only considers the width and calculates the
        # height based on the elements aspect ratio. For elements that support a
        # non-fixed aspect ratio this method should be overridden to support
        # querying for a maximum height.

        # Determine the maximum width allowed for the element
        maxWidth = parseInt(@attr('data-ce-max-width') or 0)
        if not maxWidth
            maxWidth = ContentEdit.DEFAULT_MAX_ELEMENT_WIDTH

        # The maximum width cannot be less than the current width
        maxWidth = Math.max(maxWidth, @size()[0])

        return [maxWidth, maxWidth * @aspectRatio()]

    minSize: () ->
        # Return the minimum size the element can be set to (use the
        # `data-ce-min-width` attribute to set this).
        #
        # NOTE: By default `minSize` only considers the width and calculates the
        # height based on the elements aspect ratio. For elements that support a
        # non-fixed aspect ratio this method should be overridden to support
        # querying for a minimum height.

        # Determine the minimum width allowed for the element
        minWidth = parseInt(@attr('data-ce-min-width') or 0)
        if not minWidth
            minWidth = ContentEdit.DEFAULT_MIN_ELEMENT_WIDTH

        # The minimum width cannot be greater than the current width
        minWidth = Math.min(minWidth, @size()[0])

        return [minWidth, minWidth * @aspectRatio()]

    type: () ->
        # Return the type of element (this should be the same as the class name)
        return 'ResizableElement'

    # Methods

    mount: () ->
        # Mount the element on to the DOM
        super()

        # Add the size info DOM element
        @_domElement.setAttribute('data-ce-size', @_getSizeInfo())

    resize: (corner, x, y) ->
        # Resize the element
        unless @isMounted() and @can('resize')
            return

        ContentEdit.Root.get().startResizing(this, corner, x, y, true)

    size: (newSize) ->
        # Get/Set the size of the element

        # If a new size hasn't been provided return the size of the element
        if not newSize
            width = parseInt(@attr('width') or 1)
            height = parseInt(@attr('height') or 1)
            return [width, height]

        # Ensure the elements size is set as whole pixels
        newSize[0] = parseInt(newSize[0])
        newSize[1] = parseInt(newSize[1])

        # Apply min/max size constraints

        # Min
        minSize = @minSize()
        newSize[0] = Math.max(newSize[0], minSize[0])
        newSize[1] = Math.max(newSize[1], minSize[1])

        # Max
        maxSize = @maxSize()
        newSize[0] = Math.min(newSize[0], maxSize[0])
        newSize[1] = Math.min(newSize[1], maxSize[1])

        # Set the size of the element as attributes
        @attr('width', parseInt(newSize[0]))
        @attr('height', parseInt(newSize[1]))

        if @isMounted()

            # Set the size of the element using style
            @_domElement.style.width = "#{ newSize[0] }px"
            @_domElement.style.height = "#{ newSize[1] }px"

            # Update the size info
            @_domElement.setAttribute('data-ce-size', @_getSizeInfo())

    # Event handlers

    _onMouseDown: (ev) ->
        super(ev)

        # Drag or Resize the element
        corner = @_getResizeCorner(ev.clientX, ev.clientY)
        if corner
            @resize(corner, ev.clientX, ev.clientY)
        else
            # We add a small delay to prevent drag engaging instantly
            clearTimeout(@_dragTimeout)
            @_dragTimeout = setTimeout(
                () =>
                    @drag(ev.pageX, ev.pageY)
                150
                )

    _onMouseMove: (ev) ->
        super()

        unless @can('resize')
            return

        # Add/Remove any resize classes
        @_removeCSSClass('ce-element--resize-top-left')
        @_removeCSSClass('ce-element--resize-top-right')
        @_removeCSSClass('ce-element--resize-bottom-left')
        @_removeCSSClass('ce-element--resize-bottom-right')

        corner = @_getResizeCorner(ev.clientX, ev.clientY)
        if corner
            @_addCSSClass("ce-element--resize-#{ corner[0] }-#{ corner[1] }")

    _onMouseOut: (ev) ->
        super()

        # Remove any resize classes
        @_removeCSSClass('ce-element--resize-top-left')
        @_removeCSSClass('ce-element--resize-top-right')
        @_removeCSSClass('ce-element--resize-bottom-left')
        @_removeCSSClass('ce-element--resize-bottom-right')

    _onMouseUp: (ev) ->
        super()

        # If we're waiting to see if the user wants to drag the element, stop
        # waiting they don't.
        if @_dragTimeout
            clearTimeout(@_dragTimeout)

    # Private methods

    _getResizeCorner: (x, y) ->
        # If the cursor is in the corner of the element such that it would
        # trigger a resize return the corner as 'top/bottom-left/right'.

        # Calculate the relative position of the cursor to the element
        rect = @_domElement.getBoundingClientRect()
        [x, y] = [x - rect.left, y - rect.top]

        # Determine the size of the corner region, whilst there is a default
        # size we must also ensure that for small elements the default doesn't
        # make it impossible to interact with the element
        size = @size()
        cornerSize = ContentEdit.RESIZE_CORNER_SIZE
        cornerSize = Math.min(cornerSize, Math.max(parseInt(size[0] / 4), 1))
        cornerSize = Math.min(cornerSize, Math.max(parseInt(size[1] / 4), 1))

        # Determine if the user has clicked in a corner of the element, and if
        # so which corner.
        corner = null
        if x < cornerSize
            if y < cornerSize
                corner = ['top', 'left']
            else if y > rect.height - cornerSize
                corner = ['bottom', 'left']

        else if x > rect.width - cornerSize
            if y < cornerSize
                corner = ['top', 'right']
            else if y > rect.height - cornerSize
                corner = ['bottom', 'right']

        return corner

    _getSizeInfo: () ->
        # Return a string that should be displayed inside the size info element
        size = @size()
        return "w #{ size[0] } × h #{ size[1] }"