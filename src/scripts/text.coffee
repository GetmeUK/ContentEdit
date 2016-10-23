class ContentEdit.Text extends ContentEdit.Element

    # An editable body of text (e.g <address>, <blockquote>, <h1-h6>, <p>).

    constructor: (tagName, attributes, content) ->
        super(tagName, attributes)

        # The content of the text element
        if content instanceof HTMLString.String
            @content = content
        else
            # Parse the content
            if ContentEdit.TRIM_WHITESPACE
                @content = new HTMLString.String(content).trim()
            else
                @content = new HTMLString.String(content, true)

    # Read-only properties

    cssTypeName: () ->
        # Return the CSS type modifier name for the element
        # (e.g ce-element--type-text).
        return 'text'

    type: () ->
        # Return the type of element (this should be the same as the class name)
        return 'Text'

    typeName: () ->
        # Return the name of the element type (e.g Image, List item)
        return 'Text'

    # Methods

    blur: () ->
        # Remove editing focus from this element

        # Last chance - check for changes in the content not captured before
        # this point.
        if @isMounted()
            @_syncContent()

        if @content.isWhitespace() and @can('remove')
            # Detatch element from parent if empty
            if @parent()
                @parent().detach(this)

        else if @isMounted()
            # Blur the DOM element

            # HACK: Do nothing if this in InternetExporer which doesn't allow
            # blur to be triggered against the contentediable element
            # programatically and will trigger the following error:
            #
            # `Unexpected call to method or property access.`
            #
            # Which in later versions of the browser (IE11+) cannot be captured.
            if not document.documentMode and
                    not /Edge/.test(navigator.userAgent)
                @_domElement.blur()

            # Stop the element from being editable
            @_domElement.removeAttribute('contenteditable')

        super()

    createDraggingDOMElement: () ->
        # Create a DOM element that visually aids the user in dragging the
        # element to a new location in the editiable tree structure.
        unless @isMounted()
            return

        helper = super()

        # Use the body of the node to create the helper but limit the text to
        # something sensible.
        text = HTMLString.String.encode(@_domElement.textContent)
        if text.length > ContentEdit.HELPER_CHAR_LIMIT
            text = text.substr(0, ContentEdit.HELPER_CHAR_LIMIT)

        helper.innerHTML = text

        return helper

    drag: (x, y) ->
        # Drag the element to a new position
        @storeState()

        # Prevent content editing whilst the element is being dragged
        @_domElement.removeAttribute('contenteditable')
        super(x, y)

    drop: (element, placement) ->
        # Drop the element into a new position in the editable structure
        super(element, placement)
        @restoreState()

    focus: (supressDOMFocus) ->
        # Focus this element for editing

        # Make the element editable if mounted
        if @isMounted()
            @_domElement.setAttribute('contenteditable', '')

        super(supressDOMFocus)

    html: (indent='') ->
        # Return a HTML string for the node

        # For text elements with optimized output we use a cache to improve
        # performance for repeated calls.
        if not @_lastCached or @_lastCached < @_modified

            # Copy the content so we can optimize if for output, we also trim
            # whitespace from the string (if the behaviour hasn't been
            # disabled).
            if ContentEdit.TRIM_WHITESPACE
                content = @content.copy().trim()
            else
                content = @content.copy()

            # Optimize the content for output
            content.optimize()

            @_lastCached = Date.now()
            @_cached = content.html()

        # If this is a fixed element only return the inner HTML
        if @isFixed()
            return @_cached
        else
            le = ContentEdit.LINE_ENDINGS
            attributes = @_attributesToString()
            return "#{ indent }<#{ @_tagName }#{ attributes }>#{le}" +
                "#{ indent }#{ ContentEdit.INDENT }#{ @_cached }#{le}" +
                "#{ indent }</#{ @_tagName }>"

    mount: () ->
        # Mount the element on to the DOM

        # Create the DOM element to mount
        @_domElement = document.createElement(@_tagName)

        # Set the attributes
        for name, value of @_attributes
            @_domElement.setAttribute(name, value)

        # Set the content in the document
        @updateInnerHTML()

        super()

    restoreState: () ->
        # Restore the text elements state after storeState has been called
        unless @_savedSelection
            return

        unless @isMounted() and @isFocused()
            @_savedSelection = undefined
            return

        @_domElement.setAttribute('contenteditable', '')
        @_addCSSClass('ce-element--focused')

        # If we're restoring the selection state then we need to make sure the
        # element has focus.
        if document.activeElement != @domElement()
            @domElement().focus()

        @_savedSelection.select(@_domElement)
        @_savedSelection = undefined

    selection: (selection) ->
        # Get/Set the content selection for the element
        if selection is undefined
            if @isMounted()
                return ContentSelect.Range.query(@_domElement)
            else
                return new ContentSelect.Range(0, 0)

        selection.select(@_domElement)

    storeState: () ->
        # Save the state of the text element so that it can be restored after
        # being unmounted and re-mounted.
        unless @isMounted() and @isFocused()
            return

        @_savedSelection = ContentSelect.Range.query(@_domElement)

    unmount: () ->
        # Unmount the element on from the DOM

        # Remove the contenteditable attribute
        @_domElement.removeAttribute('contenteditable')

        super()

    updateInnerHTML: () ->
        # Update the inner HTML of the DOM element with the elements content
        @_domElement.innerHTML = @content.html()
        ContentSelect.Range.prepareElement(@_domElement)
        @_flagIfEmpty()

    # Event handlers

    _onKeyDown: (ev) ->
        # Handle special key events
        switch ev.keyCode

            # Navigation
            when 40 then @_keyDown(ev)
            when 37 then @_keyLeft(ev)
            when 39 then @_keyRight(ev)
            when 38 then @_keyUp(ev)
            when 9 then @_keyTab(ev)

            # Merging
            when 8 then @_keyBack(ev)
            when 46 then @_keyDelete(ev)

            # Splitting
            when 13 then @_keyReturn(ev)

    _onKeyUp: (ev) ->
        super(ev)
        @_syncContent()

    _onMouseDown: (ev) ->
        # Give the element focus
        super(ev)

        # If the user holds the mouse down for an extended period then start
        # dragging the element.
        clearTimeout(@_dragTimeout)
        @_dragTimeout = setTimeout(
            () =>
                @drag(ev.pageX, ev.pageY)
            ContentEdit.DRAG_HOLD_DURATION
            )

        # HACK: If the content of the element is empty and it already has focus
        # then supress the event to stop odd behaviour in FireFox. See issue:
        # https://github.com/GetmeUK/ContentTools/issues/118
        #
        # Anthony Blackshaw <ant@getme.co.uk>, 2016-01-30
        if @content.length() == 0 and ContentEdit.Root.get().focused() is this
            ev.preventDefault()
            if document.activeElement != this._domElement
                this._domElement.focus()
            new ContentSelect.Range(0, 0).select(this._domElement)

    _onMouseMove: (ev) ->
        # If we're waiting to see if the user wants to drag the element, stop
        # waiting they don't.
        if @_dragTimeout
            clearTimeout(@_dragTimeout)

        super(ev)

    _onMouseOut: (ev) ->
        # If we're waiting to see if the user wants to drag the element, stop
        # waiting they don't.
        if @_dragTimeout
            clearTimeout(@_dragTimeout)

        super(ev)

    _onMouseUp: (ev) ->
        # If we're waiting to see if the user wants to drag the element, stop
        # waiting they don't.
        if @_dragTimeout
            clearTimeout(@_dragTimeout)

        super(ev)

    # Key handlers

    _keyBack: (ev) ->
        selection = ContentSelect.Range.query(@_domElement)
        unless selection.get()[0] == 0 and selection.isCollapsed()
            return

        ev.preventDefault()

        # If we're at the start of the element attempt to find the previous text
        # element and merge with it.
        previous = @previousContent()

        # We need to sync the content as this event can occur without a
        # corresponding key up event (e.g the back key was held down).
        @_syncContent()

        if previous
            previous.merge(this)

    _keyDelete: (ev) ->
        selection = ContentSelect.Range.query(@_domElement)
        unless @_atEnd(selection)and selection.isCollapsed()
            return

        ev.preventDefault()

        # If we're at the end of the element attempt to find the next text
        # element and merge with it.
        next = @nextContent()
        if next
            @merge(next)

    _keyDown: (ev) ->
        @_keyRight(ev)

    _keyLeft: (ev) ->
        selection = ContentSelect.Range.query(@_domElement)
        unless selection.get()[0] == 0 and selection.isCollapsed()
            return

        # If we're at the start of the element and the selection is collapsed we
        # should navigate to the previous text node.
        ev.preventDefault()

        # Attempt to find and select the previous content element
        previous = @previousContent()
        if previous
            previous.focus()
            selection = new ContentSelect.Range(
                previous.content.length(),
                previous.content.length()
                )
            selection.select(previous.domElement())
        else
            # If no element was found this must be the last content node found
            # so trigger an event for external code to manage a region switch.
            ContentEdit.Root.get().trigger(
                'previous-region',
                @closest (node) ->
                    node.type() is 'Fixture' or node.type() is 'Region'
                )

    _keyReturn: (ev) ->
        ev.preventDefault()

        # If the element only contains whitespace and we're not being asked to
        # insert a line break.
        if @content.isWhitespace() and
                not ev.shiftKey ^ ContentEdit.PREFER_LINE_BREAKS
            return

        # Split the element at the text caret
        selection = ContentSelect.Range.query(@_domElement)
        tip = @content.substring(0, selection.get()[0])
        tail = @content.substring(selection.get()[1])

        # If the shift key is held down or if the preference is to insert
        # line-breaks over new paragraphs then insert a line-break instead of
        # creating a new paragraph.
        if ev.shiftKey ^ ContentEdit.PREFER_LINE_BREAKS
            insertAt = selection.get()[0]

            # Check if this is the last character in the row
            lineBreakStr = '<br>'
            if @content.length() == insertAt
                # HACK: If this is the last character then we'll need to insert
                # two `<br>` if the current last character is not a `<br>`. This
                # appears to be the only way to get the browsers to consistently
                # provide the expected behaviour (see issue #101 on
                # ContentTools).
                if @content.length() == 0 or
                        not @content.characters[insertAt - 1].isTag('br')
                    lineBreakStr = '<br><br>'

            # Rejoin the content with a line-break
            @content = @content.insert(
                insertAt,
                new HTMLString.String(lineBreakStr, true),
                true
                )
            @updateInnerHTML()

            # Reset the caret's position
            insertAt += 1
            selection = new ContentSelect.Range(insertAt, insertAt)
            selection.select(@domElement())

            @taint()

            return

        # Check if we're allowed to spawn new elements
        unless @can('spawn')
            return

        # Update the contents of this element
        @content = tip.trim()
        @updateInnerHTML()

        # Attach the new element
        element = new @constructor('p', {}, tail.trim())
        @parent().attach(element, @parent().children.indexOf(this) + 1)

        # Move the focus and text caret based on the split
        if tip.length()
            element.focus()
            selection = new ContentSelect.Range(0, 0)
            selection.select(element.domElement())
        else
            selection = new ContentSelect.Range(0, tip.length())
            selection.select(@_domElement)

        @taint()

    _keyRight: (ev) ->
        selection = ContentSelect.Range.query(@_domElement)
        unless @_atEnd(selection) and selection.isCollapsed()
            return

        # If we're at the end of the element and the selection is collapsed we
        # should navigate to the next text node.
        ev.preventDefault()

        # Attempt to find and select the next text element
        next = @nextContent()
        if next
            next.focus()
            selection = new ContentSelect.Range(0, 0)
            selection.select(next.domElement())
        else
            # If no element was found this must be the last content node found
            # so trigger an event for external code to manage a region switch.
            ContentEdit.Root.get().trigger(
                'next-region',
                @closest (node) ->
                    node.type() is 'Fixture' or node.type() is 'Region'
                )

    _keyTab: (ev) ->
        ev.preventDefault()

        # If this is a fixture element then we trigger a switch region event to
        # allow external code to manage.
        if @isFixed()

            # If the shift key is held down then we reverse the switch to the
            # `previous-region` event.
            if ev.shiftKey
                ContentEdit.Root.get().trigger(
                    'previous-region',
                    @closest (node) ->
                        node.type() is 'Fixture' or node.type() is 'Region'
                    )

            else
                ContentEdit.Root.get().trigger(
                    'next-region',
                    @closest (node) ->
                        node.type() is 'Fixture' or node.type() is 'Region'
                    )

    _keyUp: (ev) ->
        @_keyLeft(ev)

    # Private methods

    _atEnd: (selection) ->
        # Determine if the cursor/caret starts at the end of the content
        return selection.get()[0] >= @content.length()

    _flagIfEmpty: () ->
        # Flag the element as empty if there's no content
        if @content.length() == 0
            @_addCSSClass('ce-element--empty')
        else
            @_removeCSSClass('ce-element--empty')

    _syncContent: (ev) ->
        # Keep the content in sync with the HTML and check if it's been modified
        # by the key events.
        snapshot = @content.html()
        @content = new HTMLString.String(
            @_domElement.innerHTML,
            @content.preserveWhitespace()
            )

        # If the snap-shot has changed mark the node as modified
        newSnapshot = @content.html()
        if snapshot != newSnapshot
            @taint()

        @_flagIfEmpty()

    # Class properties

    @droppers:
        'Static': ContentEdit.Element._dropVert
        'Text': ContentEdit.Element._dropVert

    @mergers:

        'Text': (element, target) ->

            # Remember the target's length so we can offset the text caret to
            # the merge point.
            offset = target.content.length()

            # Add the element's content to the end of the target's
            if element.content.length()
                target.content = target.content.concat(element.content)

            # Update the targets HTML
            if target.isMounted()
                target.updateInnerHTML()

            # Focus the target and set the text caret position
            target.focus()
            new ContentSelect.Range(offset, offset).select(target._domElement)

            # Remove the element
            if element.parent()
                element.parent().detach(element)

            # Taint both elements
            target.taint()

    # Class methods

    @fromDOMElement: (domElement) ->
        # Convert an element (DOM) to an element of this type
        return new @(
            domElement.tagName,
            @getDOMElementAttributes(domElement),
            domElement.innerHTML.replace(/^\s+|\s+$/g, '')
            )


# Register `ContentEdit.Text` the class with associated tag names
ContentEdit.TagNames.get().register(
    ContentEdit.Text,
    'address',
    'blockquote',
    'h1',
    'h2',
    'h3',
    'h4',
    'h5',
    'h6',
    'p'
    )


class ContentEdit.PreText extends ContentEdit.Text

    # An editable body of preserved text (e.g <pre>).

    @TAB_INDENT: '    '

    constructor: (tagName, attributes, content) ->
        # The content of the text element
        if content instanceof HTMLString.String
            @content = content
        else
            @content = new HTMLString.String(content, true)

        ContentEdit.Element.call(this, tagName, attributes)

    # Read-only properties

    cssTypeName: () ->
        # Return the CSS type modifier name for the element
        # (e.g ce-element--type-text).
        return 'pre-text'

    type: () ->
        # Return the type of element (this should be the same as the class name)
        return 'PreText'

    typeName: () ->
        # Return the name of the element type (e.g Image, List item)
        return 'Preformatted'

    # Methods

    blur: () ->
        if @isMounted()
            @_domElement.innerHTML = @content.html()

        super()

    html: (indent='') ->
        # Return a HTML string for the node

        # For text elements with optimized output we use a cache to improve
        # performance for repeated calls.
        if not @_lastCached or @_lastCached < @_modified

            # Optimize the content for output
            content = @content.copy()
            content.optimize()

            @_lastCached = Date.now()
            @_cached = content.html()

        return "#{ indent }<#{ @_tagName }#{ @_attributesToString() }>" +
            "#{ @_cached }</#{ @_tagName }>"

    updateInnerHTML: () ->
        # Update the inner HTML of the DOM element with the elements content
        html = @content.html()
        @_domElement.innerHTML = html
        @_ensureEndZWS()
        ContentSelect.Range.prepareElement(@_domElement)
        @_flagIfEmpty()

    # Event handlers

    _keyBack: (ev) ->

        # If the selection is within the known content behave as normal...
        selection = ContentSelect.Range.query(@_domElement)
        if selection.get()[0] <= @content.length()
            return super(ev)

        # ...if not set the selection to the end of the string (not the
        # contents).
        selection.set(@content.length(), @content.length())
        selection.select(@_domElement)

    # Key events

    _keyReturn: (ev) ->
        ev.preventDefault()

        # Insert a `\n` character at the current position
        selection = ContentSelect.Range.query(@_domElement)
        cursor = selection.get()[0] + 1

        # Depending on the selection determine how best to insert the content
        if selection.get()[0] == 0 and selection.isCollapsed()
            @content = new HTMLString.String('\n', true).concat(@content)

        else if @_atEnd(selection) and selection.isCollapsed()
            @content = @content.concat(new HTMLString.String('\n', true))

        else if selection.get()[0] == 0 and
                    selection.get()[1] == @content.length()
            @content = new HTMLString.String('\n', true)
            cursor = 0

        else
            tip = @content.substring(0, selection.get()[0])
            tail = @content.substring(selection.get()[1])
            @content = tip.concat(new HTMLString.String('\n', true), tail)

        @updateInnerHTML()

        # Restore the selection
        selection.set(cursor, cursor)
        selection.select(@_domElement)

        @taint()

    _keyTab: (ev) ->
        ev.preventDefault()

        # Measure the length of the block before the indentation
        blockLength = @content.length()

        # Indent/Unindent the selected block of text
        indentText = ContentEdit.PreText.TAB_INDENT
        indentLength = indentText.length

        # Split the current content into lines
        lines = @content.split('\n')

        # Determine the first and last line within the selection
        selection = @selection().get()

        # Ensure the selection doesn't overshoot the block content
        selection[0] = Math.min(selection[0], blockLength)
        selection[1] = Math.min(selection[1], blockLength)

        charIndex = 0
        startLine = -1
        endLine = -1
        for line, i in lines
            # We add +1 to the line length to account for the new line character
            lineLength = (line.length() + 1)

            if selection[0] < charIndex + lineLength
                if startLine == -1
                    startLine = i

            if selection[1] < charIndex + lineLength
                if endLine == -1
                    endLine = i

            if startLine > -1 and endLine > -1
                break

            charIndex += lineLength

        if startLine == endLine
            # If a single line is selected then indent from the start of the
            # current selection to the nearest indent multiple.

            # Modify the indent length to indent the line to the next indent
            # point.
            indentLength -= (selection[0] - charIndex) % indentLength
            indentHTML = new HTMLString.String(
                Array(indentLength + 1).join(' '),
                true
                )

            # Insert the indent within the string
            tip = lines[startLine].substring(0, selection[0] - charIndex)
            tail = lines[startLine].substring(selection[1] - charIndex)
            lines[startLine] = tip.concat(indentHTML, tail)

            # Set the selection offset to the full/partial indent length
            selectionOffset = indentLength

        else
            # If multiple lines are selected then indent/unindent the start of
            # each line.
            if ev.shiftKey
                # Remove a tab indent worth of spaces from the start of each
                # line.
                firstLineShift = 0
                for i in [startLine..endLine]
                    for c, j in lines[i].characters.slice()
                        if j > (indentLength - 1)
                            break
                        if not c.isWhitespace()
                            break

                        # Not strictly a nice approach but it's more efficient
                        # than using `substring`.
                        lines[i].characters.shift()

                    # Store the indent applied to the first line as we need it
                    # to determine the selection start shift.
                    if i == startLine
                        firstLineShift = j

                # Flip the `indentLength` to reverse the change in selection
                # direction.
                selectionOffset = Math.max(-indentLength, -firstLineShift)

            else
                # Add a tab indent worth of spaces to the start of each line
                indentHTML = new HTMLString.String(indentText, true)
                for i in [startLine..endLine]
                    lines[i] = indentHTML.concat(lines[i])

                # Set the selection offset to the full indent length
                selectionOffset = indentLength

        # Update the content in the DOM
        @content = HTMLString.String.join(
            new HTMLString.String('\n', true),
            lines
            )
        @updateInnerHTML()

        # Restore the selection
        selectionLength = @content.length() - blockLength
        new ContentSelect.Range(
            selection[0] + selectionOffset,
            selection[1] + selectionLength
            ).select(@_domElement)

    # Private methods

    _syncContent: (ev) ->
        @_ensureEndZWS()

        # Keep the content in sync with the HTML and check if it's been modified
        # by the key events.
        snapshot = @content.html()
        @content = new HTMLString.String(
            @_domElement.innerHTML.replace(/\u200B$/g, ''),
            @content.preserveWhitespace()
            )

        # If the snap-shot has changed mark the node as modified
        newSnapshot = @content.html()
        if snapshot != newSnapshot
            @taint()

        @_flagIfEmpty()

    _ensureEndZWS: () ->
        # HACK: Append an zero-width-space (ZWS) character to the DOM elements
        # inner HTML to ensure the caret position moves when a newline is added
        # to the end of the content (e.g if the user hits the return key - see
        # issue #54).

        # Check we need to add the ZWS
        if not @_domElement.lastChild
            return

        html = @_domElement.innerHTML
        if html[html.length - 1] == '\u200B'
            if html.indexOf('\u200B') < html.length - 1
                return

        # Add the ZWS and restore the state (only if the state isn't already
        # set).
        _addZWS = () =>
            # Clear any erroneous ZWS characters
            if html.indexOf('\u200B') > -1
                @_domElement.innerHTML = html.replace(/\u200B/g, '')

            # Add the ZWS character as a text node to the end of the element's
            # HTML.
            @_domElement.lastChild.textContent += '\u200B'

        # Check to see if the state of the element has already been captured or
        # if we need to capture it before updating the the contents.
        if this._savedSelection
            _addZWS()

        else
            @storeState()
            _addZWS()
            @restoreState()

    # Class properties

    @droppers:
        'PreText': ContentEdit.Element._dropVert
        'Static': ContentEdit.Element._dropVert
        'Text': ContentEdit.Element._dropVert

    @mergers: {}

    # Class methods

    @fromDOMElement: (domElement) ->
        # Convert an element (DOM) to an element of this type
        return new @(
            domElement.tagName,
            @getDOMElementAttributes(domElement),
            domElement.innerHTML
            )


# Register `ContentEdit.PreText` the class with associated tag names
ContentEdit.TagNames.get().register(ContentEdit.PreText, 'pre')
