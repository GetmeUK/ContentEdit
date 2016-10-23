class ContentEdit.Table extends ContentEdit.ElementCollection

    # An editable table (e.g <table>)

    constructor: (attributes) ->
        super('table', attributes)

    # Read-only properties

    cssTypeName: () ->
        # Return the CSS type modifier name for the element
        # (e.g ce-element--type-table).
        return 'table'

    typeName: () ->
        # Return the name of the element type (e.g Image, List item)
        return 'Table'

    type: () ->
        # Return the type of element (this should be the same as the class name)
        return 'Table'

    firstSection: () ->
        # Return the first table section associted with the table (if there is
        # one).
        if section = @thead()
            return section
        else if section =  @tbody()
            return section
        else if section = @tfoot()
            return section
        return null

    lastSection: () ->
        # Return the last table section associted with the table (if there is
        # one).
        if section = @tfoot()
            return section
        else if section =  @tbody()
            return section
        else if section = @thead()
            return section
        return null

    tbody: () ->
        # Return the table body associated with the table (if there is one)
        return @_getChild('tbody')

    tfoot: () ->
        # Return the table footer associated with the table (if there is one)
        return @_getChild('tfoot')

    thead: () ->
        # Return the table header associated with the table (if there is one)
        return @_getChild('thead')

    # Event handlers

    _onMouseOver: (ev) ->
        super(ev)

        # Don't highlight that we're over the element
        @_removeCSSClass('ce-element--over')

    # Private methods

    _getChild: (tagName) ->
        # Return a child of the table that matches the specified tag name
        for child in @children
            if child.tagName() == tagName
                return child
        return null

    # Class properties

    @droppers:
        'Image': ContentEdit.Element._dropBoth
        'List': ContentEdit.Element._dropVert
        'PreText': ContentEdit.Element._dropVert
        'Static': ContentEdit.Element._dropVert
        'Table': ContentEdit.Element._dropVert
        'Text': ContentEdit.Element._dropVert
        'Video': ContentEdit.Element._dropBoth

    # Class methods

    @fromDOMElement: (domElement) ->
        # Convert an element (DOM) to an element of this type

        # Create the table
        table = new @(@getDOMElementAttributes(domElement))

        # Create a list if child nodes we can safely remove whilst iterating
        # through them.
        childNodes = (c for c in domElement.childNodes)

        # Parse the table for sections and rows
        orphanRows = []
        for childNode in childNodes

            # Filter out non-elements
            unless childNode.nodeType == 1 # ELEMENT_NODE
                continue

            # Don't allow duplicate sections
            tagName = childNode.tagName.toLowerCase()
            if table._getChild(tagName)
                continue

            # Convert relevent child nodes
            switch tagName

                when 'tbody', 'tfoot', 'thead'
                    section = ContentEdit.TableSection.fromDOMElement(childNode)
                    table.attach(section)

                when 'tr'
                    orphanRows.push(
                        ContentEdit.TableRow.fromDOMElement(childNode)
                        )

        # If there are orphan rows
        if orphanRows.length > 0
            if not table._getChild('tbody')
                table.attach(new ContentEdit.TableSection('tbody'))

            for row in orphanRows
                table.tbody().attach(row)

        # If the table is empty then don't create it
        if table.children.length == 0
            return null

        return table

# Register `ContentEdit.Table` the class with associated tag names
ContentEdit.TagNames.get().register(ContentEdit.Table, 'table')


class ContentEdit.TableSection extends ContentEdit.ElementCollection

    # An editable section of a table (e.g <thead>, <tbody>, <tfoot>)

    constructor: (tagName, attributes) ->
        super(tagName, attributes)

    # Read-only properties

    cssTypeName: () ->
        # Return the CSS type modifier name for the element
        # (e.g ce-element--type-table-section).
        return 'table-section'

    type: () ->
        # Return the type of element (this should be the same as the class name)
        return 'TableSection'

    # Event handlers

    _onMouseOver: (ev) ->
        super(ev)

        # Don't highlight that we're over the element
        @_removeCSSClass('ce-element--over')

    # Class methods

    @fromDOMElement: (domElement) ->
        # Convert an element (DOM) to an element of this type

        # Create the table section
        section = new @(
            domElement.tagName,
            @getDOMElementAttributes(domElement)
            )

        # Create a list if child nodes we can safely remove whilst iterating
        # through them.
        childNodes = (c for c in domElement.childNodes)

        # Parse the section for rows
        for childNode in childNodes

            # Filter out non-elements
            unless childNode.nodeType == 1 # ELEMENT_NODE
                continue

            # Filter out non-<tr> elements
            unless childNode.tagName.toLowerCase() == 'tr'
                continue

            section.attach(ContentEdit.TableRow.fromDOMElement(childNode))

        return section


class ContentEdit.TableRow extends ContentEdit.ElementCollection

    # An editable table row (e.g <tr>)

    constructor: (attributes) ->
        super('tr', attributes)

    # Read-only properties

    cssTypeName: () ->
        # Return the CSS type modifier name for the element
        # (e.g ce-element--type-table-row).
        return 'table-row'

    isEmpty: () ->
        # Return true if the row is empty of content
        for cell in @children
            text = cell.tableCellText()
            if text and text.content.length() > 0
                return false
        return true

    type: () ->
        # Return the type of element (this should be the same as the class name)
        return 'TableRow'

    typeName: () ->
        # Return the name of the element type (e.g Image, List item)
        return 'Table row'

    # Event handlers

    _onMouseOver: (ev) ->
        super(ev)

        # Don't highlight that we're over the element
        @_removeCSSClass('ce-element--over')

    # Class properties

    @droppers:
        'TableRow': ContentEdit.Element._dropVert

    # Class methods

    @fromDOMElement: (domElement) ->
        # Convert an element (DOM) to an element of this type

        # Create the table row
        row = new @(@getDOMElementAttributes(domElement))

        # Create a list if child nodes we can safely remove whilst iterating
        # through them.
        childNodes = (c for c in domElement.childNodes)

        # Parse the section for rows
        for childNode in childNodes

            # Filter out non-elements
            unless childNode.nodeType == 1 # ELEMENT_NODE
                continue

            # Filter out non-<td/th> elements
            tagName = childNode.tagName.toLowerCase()
            unless tagName == 'td' or tagName == 'th'
                continue

            row.attach(ContentEdit.TableCell.fromDOMElement(childNode))

        return row


class ContentEdit.TableCell extends ContentEdit.ElementCollection

    # An editable table cell (e.g <td>, <th>).

    constructor: (tagName, attributes) ->
        super(tagName, attributes)

    # Read-only properties

    cssTypeName: () ->
        return 'table-cell'

    tableCellText: () ->
        # Return the table cell text associated with this table cell (if there
        # is one).
        if @children.length > 0
            return @children[0]
        return null

    type: () ->
        # Return the type of element (this should be the same as the class name)
        return 'TableCell'

    # Methods

    html: (indent='') ->
        lines = [
            "#{ indent }<#{ @tagName() }#{ @_attributesToString() }>"
            ]
        if @tableCellText()
            lines.push(@tableCellText().html(indent + ContentEdit.INDENT))
        lines.push("#{ indent }</#{ @tagName() }>")
        return lines.join(ContentEdit.LINE_ENDINGS)

    # Event handlers

    _onMouseOver: (ev) ->
        super(ev)

        # Don't highlight that we're over the element
        @_removeCSSClass('ce-element--over')

    # Disabled methods

    _addDOMEventListeners: () ->
    _removeDOMEventListners: () ->

    # Class methods

    @fromDOMElement: (domElement) ->
        # Convert an element (DOM) to an element of this type
        tableCell = new @(
            domElement.tagName
            @getDOMElementAttributes(domElement)
            )

        # Attach a table cell text item
        tableCellText = new ContentEdit.TableCellText(
            domElement.innerHTML.replace(/^\s+|\s+$/g, '')
            )
        tableCell.attach(tableCellText)

        return tableCell


class ContentEdit.TableCellText extends ContentEdit.Text

    # An editable table cell (e.g <td>, <th> -> TEXT_NODE).

    constructor: (content) ->
        super('div', {}, content)

    # Read-only properties

    cssTypeName: () ->
        # Return the CSS type modifier name for the element
        # (e.g ce-element--type-table-cell-text).
        return 'table-cell-text'

    type: () ->
        # Return the type of element (this should be the same as the class name)
        return 'TableCellText'

    _isInFirstRow: () ->
        cell = @parent()
        row = cell.parent()
        section = row.parent()
        table = section.parent()

        if section != table.firstSection()
            return false

        return row == section.children[0]

    _isInLastRow: () ->
        cell = @parent()
        row = cell.parent()
        section = row.parent()
        table = section.parent()

        if section != table.lastSection()
            return false

        return row == section.children[section.children.length - 1]

    _isLastInSection: () ->
        cell = @parent()
        row = cell.parent()
        section = row.parent()
        if row != section.children[section.children.length - 1]
            return false
        return cell == row.children[row.children.length - 1]

    # Methods

    blur: () ->
        # Remove focus from the element

        if @isMounted()

            # Blur the DOM element
            @_domElement.blur()

            # Stop the element from being editable
            @_domElement.removeAttribute('contenteditable')

        # Remove editing focus from this element
        ContentEdit.Element::blur.call(this)

    can: (behaviour, allowed) ->
        # The allowed behaviour for a TableCellText instance reflects its parent
        # TableCell and can not be set directly.
        if allowed
            throw new Error('Cannot set behaviour for ListItemText')

        return @parent().can(behaviour)

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

        return "#{ indent }#{ @_cached }"

    # Event handlers

    _onMouseDown: (ev) ->
        # Give the element focus
        ContentEdit.Element::_onMouseDown.call(this, ev)

        # Tables support dragging of individual rows or the table. The drag is
        # initialized by clicking and holding the mouse down on a cell, how long
        # the user holds the mouse down determines which element is dragged (the
        # parent row or table).
        initDrag = () =>
            cell = @parent()
            if ContentEdit.Root.get().dragging() == cell.parent()
                # We're currently dragging the row so switch to dragging the
                # parent table.

                # Cancel dragging the row
                ContentEdit.Root.get().cancelDragging()

                # Find the table and start dragging it
                table = cell.parent().parent().parent()
                table.drag(ev.pageX, ev.pageY)

            else
                # We're not currently dragging anything so start dragging the
                # parent row.
                cell.parent().drag(ev.pageX, ev.pageY)

                # Reset a timeout for this function so that if the user
                # continues to hold down the mouse we can switch to the list
                # root.
                @_dragTimeout = setTimeout(
                    initDrag,
                    ContentEdit.DRAG_HOLD_DURATION * 2
                    )

        clearTimeout(@_dragTimeout)
        @_dragTimeout = setTimeout(initDrag, ContentEdit.DRAG_HOLD_DURATION)

    # Key handlers

    _keyBack: (ev) ->
        selection = ContentSelect.Range.query(@_domElement)
        unless selection.get()[0] == 0 and selection.isCollapsed()
            return

        ev.preventDefault()

        # If this is the first cell in the row and the user the cell is empty
        # check to see if the whole row is empty and if so remove it.
        cell = @parent()
        row = cell.parent()

        # Check we're allowed to delete the row
        if not (row.isEmpty() and row.can('remove'))
            return

        if @content.length() == 0 and row.children.indexOf(cell) == 0

            # Move the focus to the previous text element
            previous = @previousContent()
            if previous
                previous.focus()
                selection = new ContentSelect.Range(
                    previous.content.length(),
                    previous.content.length()
                    )
                selection.select(previous.domElement())

            # If this is the last row check we're allowed to
            row.parent().detach(row)

    _keyDelete: (ev) ->
        # Check if the row is empty and if it is delete it
        row = @parent().parent()

        # Check we're allowed to delete the row
        if not (row.isEmpty() and row.can('remove'))
            return

        ev.preventDefault()

        # Move the cursor to either the next row (if available) or the
        # next content element.
        lastChild = row.children[row.children.length - 1]
        nextElement = lastChild.tableCellText().nextContent()

        if nextElement
            nextElement.focus()
            selection = new ContentSelect.Range(0, 0)
            selection.select(nextElement.domElement())

        row.parent().detach(row)

    _keyDown: (ev) ->
        selection = ContentSelect.Range.query(@_domElement)
        unless @_atEnd(selection) and selection.isCollapsed()
            return

        ev.preventDefault()
        cell = @parent()

        # If this is the last row in the table move out of the section...
        if @_isInLastRow()
            row = cell.parent()
            lastCell = row.children[row.children.length - 1].tableCellText()
            next = lastCell.nextContent()

            if next
                next.focus()
            else
                # If no next element was found this must be the last content
                # node found so trigger an event for external code to manage a
                # region switch.
                ContentEdit.Root.get().trigger(
                    'next-region',
                    @closest (node) ->
                        node.type() is 'Fixture' or node.type() is 'Region'
                    )

        # ...else move down vertically
        else
            nextRow = cell.parent().nextWithTest (node) ->
                return node.type() is 'TableRow'

            cellIndex = cell.parent().children.indexOf(cell)
            cellIndex = Math.min(cellIndex, nextRow.children.length)

            nextRow.children[cellIndex].tableCellText().focus()

    _keyReturn: (ev) ->
        ev.preventDefault()
        @_keyTab({'shiftKey': false, 'preventDefault': () ->})

    _keyTab: (ev) ->
        ev.preventDefault()
        cell = @parent()

        if ev.shiftKey
            # If this is the first child in the first row of the table stop
            if @_isInFirstRow() and cell.parent().children[0] is cell
                return

            # Else move to the previous table cell
            @previousContent().focus()

        else
            # Check if this is the last table cell in a tbody, if it is add
            # another row.
            unless @can('spawn')
                return

            grandParent = cell.parent().parent()
            if grandParent.tagName() == 'tbody' and @_isLastInSection()
                row = new ContentEdit.TableRow()

                # Copy the structure of this row
                for child in cell.parent().children
                    newCell = new ContentEdit.TableCell(
                            child.tagName(),
                            child._attributes
                            )
                    newCellText = new ContentEdit.TableCellText('')
                    newCell.attach(newCellText)
                    row.attach(newCell)

                # Add the new row to the section
                section = @closest (node) ->
                    return node.type() is 'TableSection'
                section.attach(row)

                # Move the focus to the first cell in the new row
                row.children[0].tableCellText().focus()

            # If not the last table cell navigate to the next cell
            else
                @nextContent().focus()

    _keyUp: (ev) ->
        selection = ContentSelect.Range.query(@_domElement)
        unless selection.get()[0] == 0 and selection.isCollapsed()
            return

        ev.preventDefault()
        cell = @parent()

        # If this is the first row in the table move out of the section...
        if @_isInFirstRow()
            row = cell.parent()
            previous = row.children[0].previousContent()

            if previous
                previous.focus()
            else
                # If no previous element was found this must be the first
                # content node found so trigger an event for external code to
                # manage a region switch.
                ContentEdit.Root.get().trigger(
                    'previous-region',
                    @closest (node) ->
                        node.type() is 'Fixture' or node.type() is 'Region'
                    )

        # ...else move up vertically
        else
            previousRow = cell.parent().previousWithTest (node) ->
                return node.type() is 'TableRow'

            cellIndex = cell.parent().children.indexOf(cell)
            cellIndex = Math.min(cellIndex, previousRow.children.length)

            previousRow.children[cellIndex].tableCellText().focus()

    # Class properties

    @droppers: {}

    @mergers: {}