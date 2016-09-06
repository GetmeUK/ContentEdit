# Root

factory = new ContentEdit.Factory()

describe '`Root.focused()`', () ->

    it 'should return the currently focused element or null if no element has
        focus', () ->

        # Create a region and mount an element
        region = new factory.Region(document.createElement('div'))
        element = new factory.Element('div')
        region.attach(element)

        # Clear any existing focused element
        if factory.root.focused()
            factory.root.focused().blur()

        expect(factory.root.focused()).toBe null

        # Give focus to the element
        element.focus()
        expect(factory.root.focused()).toBe element


describe '`Root.dragging()`', () ->

    it 'should return the element currently being dragged or null if no element
        is being dragged', () ->

        # Create a region and mount an element
        region = new factory.Region(document.createElement('div'))
        element = new factory.Element('div')
        region.attach(element)

        # Start dragging the element
        element.drag(0, 0)
        expect(factory.root.dragging()).toBe element

        # Cancel the drag (dragging element should return to null)
        factory.root.cancelDragging()
        expect(factory.root.dragging()).toBe null


describe '`Root.dropTarget()`', () ->

    it 'should return the element the dragging element is currently over', () ->

        # Create a region and mount two text elements
        region = new factory.Region(document.getElementById('test'))
        elementA = new factory.Text('p')
        region.attach(elementA)

        elementB = new factory.Text('p')
        region.attach(elementB)

        # Start dragging element A
        elementA.drag(0, 0)

        # Fake a drag over element B
        elementB._onMouseOver({})

        expect(factory.root.dropTarget()).toBe elementB

        # Cancel the drag (drop target should return to null)
        factory.root.cancelDragging()
        expect(factory.root.dropTarget()).toBe null

        # Clean up
        region.detach(elementA)
        region.detach(elementB)


describe '`Root.type()`', () ->

    it 'should return \'Root\'', () ->
        expect(factory.root.type()).toBe 'Root'


describe '`Root.startDragging()`', () ->

    it 'should start a drag interaction', () ->

        # Create a region and mount an element
        region = new factory.Region(document.getElementById('test'))
        element = new factory.Text('p')
        region.attach(element)

        # Start dragging the element
        factory.root.startDragging(element, 0, 0)

        # Check the element has being marked as dragging
        expect(factory.root.dragging()).toBe element
        cssClasses = element.domElement().getAttribute('class').split(' ')
        expect(cssClasses.indexOf('ce-element--dragging') > -1).toBe true

        # Check the body has been marked
        cssClasses = document.body.getAttribute('class').split(' ')
        expect(cssClasses.indexOf('ce--dragging') > -1).toBe true

        # Check a helper element has been created
        expect(factory.root._draggingDOMElement).not.toBe null

        # Clean up
        factory.root.cancelDragging()
        region.detach(element)


describe '`Root.cancelDragging()`', () ->

    it 'should cancel a drag interaction', () ->

        # Create a region and mount an element
        region = new factory.Region(document.createElement('div'))
        element = new factory.Element('div')
        region.attach(element)

        if factory.root.dragging()
            factory.root.cancelDragging()

        # Start dragging the element
        element.drag(0, 0)
        expect(factory.root.dragging()).toBe element

        # Cancel the drag
        factory.root.cancelDragging()
        expect(factory.root.dragging()).toBe null


describe '`Root.resizing()`', () ->

    it 'should return the element currently being resized or null if no element
        is being resized', () ->

        # Create a region and mount an element
        region = new factory.Region(document.createElement('div'))
        element = new factory.ResizableElement('div')
        region.attach(element)

        # Start resizing the element
        element.resize(['top', 'left'], 0, 0)
        expect(factory.root.resizing()).toBe element

        # Clean up
        factory.root._onStopResizing()


describe '`Root.startResizing()`', () ->

    it 'should start a resize interaction', () ->

        # Create a region and mount an element
        region = new factory.Region(document.getElementById('test'))
        element = new factory.ResizableElement('div')
        region.attach(element)

        # Start dragging the element
        factory.root.startResizing(element, ['top', 'left'], 0, 0, true)

        # Check the element has being marked as
        expect(factory.root.resizing()).toBe element
        cssClasses = element.domElement().getAttribute('class').split(' ')
        expect(cssClasses.indexOf('ce-element--resizing') > -1).toBe true

        # Check the body has been marked
        cssClasses = document.body.getAttribute('class').split(' ')
        expect(cssClasses.indexOf('ce--resizing') > -1).toBe true

        # Clean up
        factory.root._onStopResizing()
        region.detach(element)
