# Add a DOM element used to anchor editable content against during the tests
testDomElement = document.createElement('div')
testDomElement.setAttribute('id', 'test')
document.body.appendChild(testDomElement)

factory = new ContentEdit.Factory()

# Node

describe 'Node()', () ->

    it 'should create `Node` instance', () ->
        node = new factory.Node()
        expect(node instanceof factory.Node).toBe true


describe 'Node.lastModified()', () ->

    it 'should return a date last modified if the node has been tainted', () ->
        node = new factory.Node()

        # Initially the node should not be marked as modified
        expect(node.lastModified()).toBe null

        # Mark the node as modified
        node.taint()

        expect(node.lastModified()).not.toBe null


describe 'Node.parent()', () ->

    it 'should return the parent node collection for the node', () ->

        # Create a collection and add a node to it
        collection = new factory.NodeCollection()
        node = new factory.Node()
        collection.attach(node)

        expect(node.parent()).toBe collection


describe 'Node.parents()', () ->

    it 'should return an ascending list of all the node\'s parents', () ->

        # Create a node with 2 parents
        grandParent = new factory.NodeCollection()
        parent = new factory.NodeCollection()
        grandParent.attach(parent)
        node = new factory.Node()
        parent.attach(node)

        expect(node.parents()).toEqual [parent, grandParent]


describe 'Node.html()', () ->

    it 'should raise a not implemented error', () ->
        node = new factory.Node()
        expect(node.html).toThrow new Error('`html` not implemented')


describe 'Node.type()', () ->

    it 'should return \'Node\'', () ->

        # Create a collection and add a node to it
        node = new factory.Node()

        expect(node.type()).toBe 'Node'


describe 'Node.bind()', () ->

    it 'should bind a function so that it\'s called whenever the event is \
        triggered', () ->

        # Create a function to call when the event is triggered
        foo = {
            handleFoo: () ->
                return
        }
        spyOn(foo, 'handleFoo')

        # Create a node and bind the function to an event
        node = new factory.Node()
        node.bind('foo', foo.handleFoo)

        # Trigger the event
        node.trigger('foo')

        expect(foo.handleFoo).toHaveBeenCalled()


describe 'Node.trigger()', () ->

    it 'should trigger an event against the node with specified \
        arguments', () ->

        # Create a function to call when the event is triggered
        foo = {
            handleFoo: () ->
                return
        }
        spyOn(foo, 'handleFoo')

        # Create a node and bind the function to an event
        node = new factory.Node()
        node.bind('foo', foo.handleFoo)

        # Trigger the event
        node.trigger('foo', 123)

        expect(foo.handleFoo).toHaveBeenCalledWith(123)


describe 'Node.unbind()', () ->

    it 'should unbind a function previously bound for an event from the \
        node', () ->

        # Create a function to call when the event is triggered
        foo = {
            handleFoo: () ->
                return
        }
        spyOn(foo, 'handleFoo')

        # Create a node and bind the function to an event
        node = new factory.Node()
        node.bind('foo', foo.handleFoo)

        # Unbind the function
        node.unbind('foo', foo.handleFoo)

        # Trigger the event
        node.trigger('foo')

        expect(foo.handleFoo).not.toHaveBeenCalled()


describe 'Node.commit()', () ->

    node = null

    beforeEach ->
        # Create a tainted node
        node = new factory.Node()
        node.taint()

    it 'should set the last modified date of the node to null', () ->
        node.commit()
        expect(node.lastModified()).toBe null

    it 'should trigger the commit event against the root', () ->

        # Create a function to call when the event is triggered
        foo = {
            handleFoo: () ->
                return
        }
        spyOn(foo, 'handleFoo')

        # Bind the function to the root for the commit event
        factory.root.bind('commit', foo.handleFoo)

        # Commit the node
        node.commit()
        expect(foo.handleFoo).toHaveBeenCalledWith(node)


describe 'Node.taint()', () ->

    it 'should set the last modified date of the node, it\'s parents and the \
        root', () ->

        # Create a collection and add a node to it
        collection = new factory.NodeCollection()
        node = new factory.Node()
        collection.attach(node)

        # Taint the node
        node.taint()

        expect(node.lastModified()).not.toBe null
        expect(node.parent().lastModified()).toBe node.lastModified()
        expect(factory.root.lastModified()).toBe node.lastModified()

    it 'should trigger the taint event against the root', () ->

        # Create a node
        node = new factory.Node()

        # Create a function to call when the event is triggered
        foo = {
            handleFoo: () ->
                return
        }
        spyOn(foo, 'handleFoo')

        # Bind the function to the root for the taint event
        factory.root.bind('taint', foo.handleFoo)

        # Commit the node
        node.taint()
        expect(foo.handleFoo).toHaveBeenCalledWith(node)


describe 'Node.closest()', () ->

    it 'should return the first ancestor (ascending order) to match the that \
        returns true for the specified test function.', () ->

        # Create a node with 2 parents
        grandParent = new factory.NodeCollection()
        parent = new factory.NodeCollection()
        grandParent.attach(parent)
        node = new factory.Node()
        parent.attach(node)

        # Mark the parents with attributes we can test for
        grandParent.foo = true
        parent.bar = true

        expect(node.closest (node) -> return node.foo).toBe grandParent
        expect(node.closest (node) -> return node.bar).toBe parent


describe 'Node.next()', () ->

    it 'should return the node next to this node in the tree', () ->

        # Create a node tree
        collectionA = new factory.NodeCollection()
        nodeA = new factory.Node()
        collectionA.attach(nodeA)

        collectionB = new factory.NodeCollection()
        nodeB = new factory.Node()
        collectionA.attach(collectionB)
        collectionB.attach(nodeB)

        expect(nodeA.next()).toBe collectionB
        expect(nodeA.next().next()).toBe nodeB


describe 'Node.nextContent()', () ->

    it 'should return the next node in the tree that supports the `content`
        attribute', () ->

        # Create a node tree containing a text element (e.g has a `content`
        # attribute).
        collectionA = new factory.NodeCollection()
        nodeA = new factory.Node()
        collectionA.attach(nodeA)

        collectionB = new factory.NodeCollection()
        nodeB = new factory.Text('p', {}, 'testing')
        collectionA.attach(collectionB)
        collectionB.attach(nodeB)

        expect(collectionA.nextContent()).toBe nodeB


describe 'Node.nextSibling()', () ->

    it 'should return the node next to this node with the same parent', () ->

        # Create a collection with 2 child nodes
        collection = new factory.NodeCollection()
        nodeA = new factory.Node()
        collection.attach(nodeA)
        nodeB = new factory.Node()
        collection.attach(nodeB)

        expect(nodeA.nextSibling()).toBe nodeB


describe 'Node.nextWithTest()', () ->

    it 'should return the next node in the tree that matches or `undefined`
        if there are none', () ->

        # Create a node tree containing
        collectionA = new factory.NodeCollection()
        nodeA = new factory.Node()
        collectionA.attach(nodeA)

        collectionB = new factory.NodeCollection()
        nodeB = new factory.Node()
        collectionA.attach(collectionB)
        collectionB.attach(nodeB)

        # Mark the node with attributes we can test for
        nodeB.foo = true

        expect(collectionA.nextWithTest (node) -> return node.foo).toBe nodeB
        expect(
            nodeB.nextWithTest (node) -> return node.foo
            ).toBe undefined


describe 'Node.previous()', () ->

    it 'should return the node previous to this node in the tree', () ->

        # Create a node tree
        collectionA = new factory.NodeCollection()
        nodeA = new factory.Node()
        collectionA.attach(nodeA)

        collectionB = new factory.NodeCollection()
        nodeB = new factory.Node()
        collectionA.attach(collectionB)
        collectionB.attach(nodeB)

        expect(nodeB.previous()).toBe collectionB
        expect(nodeB.previous().previous()).toBe nodeA


describe 'Node.nextContent()', () ->

    it 'should return the previous node in the tree that supports the `content`
        attribute', () ->

        # Create a node tree containing a text element (e.g has a `content`
        # attribute).
        collectionA = new factory.NodeCollection()
        nodeA = new factory.Text('p', {}, 'testing')
        collectionA.attach(nodeA)

        collectionB = new factory.NodeCollection()
        nodeB = new factory.Node()
        collectionA.attach(collectionB)
        collectionB.attach(nodeB)

        expect(nodeB.previousContent()).toBe nodeA


describe 'Node.previousSibling()', () ->

    it 'should return the node previous to this node with the same parent', () ->

        # Create a collection with 2 child nodes
        collection = new factory.NodeCollection()
        nodeA = new factory.Node()
        collection.attach(nodeA)
        nodeB = new factory.Node()
        collection.attach(nodeB)

        expect(nodeB.previousSibling()).toBe nodeA


describe 'Node.previousWithTest()', () ->

    it 'should return the previous node in the tree that matches or `undefined`
        if there are none', () ->

        # Create a node tree
        collectionA = new factory.NodeCollection()
        nodeA = new factory.Node()
        collectionA.attach(nodeA)

        collectionB = new factory.NodeCollection()
        nodeB = new factory.Node()
        collectionA.attach(collectionB)
        collectionB.attach(nodeB)

        # Mark the node with attributes we can test for
        nodeA.foo = true

        expect(nodeB.previousWithTest (node) -> return node.foo).toBe nodeA
        expect(
            collectionA.previousWithTest (node) -> return node.foo
            ).toBe undefined


describe 'Node.@fromDOMElement()', () ->

    it 'should raise a not implemented error', () ->
        expect(
            factory.Node.fromDOMElement
            ).toThrow new Error('`fromDOMElement` not implemented')


# NodeCollection

describe 'NodeCollection()', () ->

    it 'should create `NodeCollection` instance', () ->
        collection = new factory.NodeCollection()
        expect(collection instanceof factory.NodeCollection).toBe true


describe 'NodeCollection.descendants()', () ->

    it 'should return a (flat) list of all the descendants for the \
        collection', () ->

        # Create a node tree
        collectionA = new factory.NodeCollection()
        nodeA = new factory.Node()
        collectionA.attach(nodeA)

        collectionB = new factory.NodeCollection()
        nodeB = new factory.Node()
        collectionA.attach(collectionB)
        collectionB.attach(nodeB)

        expect(collectionA.descendants()).toEqual [nodeA, collectionB, nodeB]


describe 'NodeCollection.isMounted()', () ->

    it 'should always return false', () ->
        collection = new factory.NodeCollection()
        expect(collection.isMounted()).toBe false


describe 'NodeCollection.type()', () ->

    it 'should return \'NodeCollection\'', () ->

        # Create a collection and add a node to it
        collection = new factory.NodeCollection()

        expect(collection.type()).toBe 'NodeCollection'


describe 'NodeCollection.attach()', () ->

    it 'should attach a node to a node collection', () ->

        # Create a collection and add a node to it
        collection = new factory.NodeCollection()
        node = new factory.Node()
        collection.attach(node)

        expect(collection.children[0]).toBe node

    it 'should attach a node to a node collection at the specified index', () ->

        # Create a collection and add some nodes to it
        collection = new factory.NodeCollection()

        for i in [0...5]
            otherNode = new factory.Node()
            collection.attach(otherNode)

        # Inser a node at a specific index
        node = new factory.Node()
        collection.attach(node, 2)

        expect(collection.children[2]).toBe node

    it 'should trigger the attach event against the root', () ->

        # Create a function to call when the event is triggered
        foo = {
            handleFoo: () ->
                return
        }
        spyOn(foo, 'handleFoo')

        # Bind the function to the root for the attach event
        factory.root.bind('attach', foo.handleFoo)

        # Create a collection and add a node to it
        collection = new factory.NodeCollection()
        node = new factory.Node()
        collection.attach(node)

        expect(foo.handleFoo).toHaveBeenCalledWith(collection, node)


describe 'NodeCollection.commit()', () ->

    collectionA = null
    collectionB = null
    node = null

    beforeEach ->
        # Create a node tree
        collectionA = new factory.NodeCollection()
        collectionB = new factory.NodeCollection()
        node = new factory.Node()
        collectionA.attach(collectionB)
        collectionB.attach(node)

    it 'should set the last modified date of the node and it\'s descendants to
        null', () ->

        # Taint all the nodes by tainting the deepest descendent
        node.taint()
        expect(collectionA.lastModified()).not.toBe null

        node.commit()
        expect(node.lastModified()).toBe null

    it 'should trigger the commit event against the root', () ->

        # Create a function to call when the event is triggered
        foo = {
            handleFoo: () ->
                return
        }
        spyOn(foo, 'handleFoo')

        # Bind the function to the root for commit event
        factory.root.bind('commit', foo.handleFoo)

        # Commit the node
        collectionA.commit()
        expect(foo.handleFoo).toHaveBeenCalledWith(collectionA)


describe 'NodeCollection.detach()', () ->

    collection = null
    node = null

    beforeEach ->
        collection = new factory.NodeCollection()
        node = new factory.Node()
        collection.attach(node)

    it 'should detach a node from the node collection', () ->

        # Detach the node
        collection.detach(node)
        expect(collection.children.length).toBe 0
        expect(node.parent()).toBe null

    it 'should trigger the detach event against the root', () ->

        # Create a function to call when the event is triggered
        foo = {
            handleFoo: () ->
                return
        }
        spyOn(foo, 'handleFoo')

        # Bind the function to the root for the detach event
        factory.root.bind('detach', foo.handleFoo)

        # Detach the node
        collection.detach(node)
        expect(foo.handleFoo).toHaveBeenCalledWith(collection, node)


# Element

describe 'Element()', () ->

    it 'should create `Element` instance', () ->
        element = new factory.Element('div', {'class': 'foo'})
        expect(element instanceof factory.Element).toBe true


describe 'Element.attributes()', () ->

    it 'should return a copy of the elements attributes', () ->
        element = new factory.Element(
            'div',
            {'class': 'foo', 'data-test': ''}
            )
        expect(element.attributes()).toEqual {
            'class': 'foo',
            'data-test': ''
            }


describe 'Element.cssTypeName()', () ->

    it 'should return \'element\'', () ->
        element = new factory.Element('div', {'class': 'foo'})
        expect(element.cssTypeName()).toBe 'element'


describe 'Element.domElement()', () ->

    it 'should return a DOM element if mounted', () ->

        # We can't test this directly against an Element instance as they can't
        # be mounted so instead we use a Text element.
        element = new factory.Text('p')
        expect(element.domElement()).toBe null

        # Mount the element
        region = new factory.Region(document.createElement('div'))
        region.attach(element)

        expect(element.domElement()).not.toBe null


describe 'Element.isFocused()', () ->

    it 'should return true if element is focused', () ->

        # Create an element to give focus to
        element = new factory.Element('div')
        expect(element.isFocused()).toBe false

        # Focus on the element
        element.focus()
        expect(element.isFocused()).toBe true


describe 'Element.isMounted()', () ->

    it 'should return true if the element is mounted in the DOM', () ->

        # We can't test this directly against an Element instance as they can't
        # be mounted so instead we use a Text element.
        element = new factory.Text('p')
        expect(element.isMounted()).toBe false

        # Mount the element
        region = new factory.Region(document.createElement('div'))
        region.attach(element)

        expect(element.isMounted()).toBe true


describe 'Element.type()', () ->

    it 'should return \'Element\'', () ->

        # Create a collection and add a node to it
        element = new factory.Element('div', {'class': 'foo'})

        expect(element.type()).toBe 'Element'


describe '`Element.typeName()`', () ->

    it 'should return \'Element\'', () ->
        element = new factory.Element('div', {'class': 'foo'})
        expect(element.typeName()).toBe 'Element'


describe 'Element.addCSSClass()', () ->

    it 'should add a CSS class to the element', () ->

        # Create an element and add a CSS class to it
        element = new factory.Element('div')
        element.addCSSClass('foo')
        expect(element.hasCSSClass('foo')).toBe true

        # Add another class
        element.addCSSClass('bar')
        expect(element.hasCSSClass('bar')).toBe true


describe 'Element.attr()', () ->

    it 'should set/get an attribute for the element', () ->

        element = new factory.Element('div')
        element.attr('foo', 'bar')
        expect(element.attr('foo')).toBe 'bar'


describe 'Element.blur()', () ->

    it 'should blur an element', () ->

        # Create and focus an element
        element = new factory.Element('div')
        element.focus()
        expect(element.isFocused()).toBe true

        # Blur the element
        element.blur()
        expect(element.isFocused()).toBe false

    it 'should trigger the `blur` event against the root', () ->

        # Create a function to call when the event is triggered
        foo = {
            handleFoo: () ->
                return
        }
        spyOn(foo, 'handleFoo')

        # Bind the function to the root for the blur event
        factory.root.bind('blur', foo.handleFoo)

        # Detach the node
        element = new factory.Element('div')
        element.focus()
        element.blur()
        expect(foo.handleFoo).toHaveBeenCalledWith(element)

describe 'Element.can()', () ->

    it 'should set/get whether a behaviour is allowed for the element', () ->

        element = new factory.Element('div')

        # Expect the remove behaviour to be true initially (all behaviours are
        # are initially allowed by default against elements).
        expect(element.can('remove')).toBe true

        # Set the behaviour for remove to not allowed
        element.can('remove', false)
        expect(element.can('remove')).toBe false

describe 'Element.createDraggingDOMElement()', () ->

    it 'should create a helper DOM element', () ->
        element = new factory.Element('div')
        region = new factory.Region(document.createElement('div'))
        region.attach(element)

        # Get the helper DOM element
        helper = element.createDraggingDOMElement()

        expect(helper).not.toBe null
        expect(helper.tagName.toLowerCase()).toBe 'div'


describe 'Element.drag()', () ->

    it 'should call `startDragging` against the root element', () ->

        element = new factory.Element('div')

        # Mount the element
        region = new factory.Region(document.createElement('div'))
        region.attach(element)

        # Spy on the startDragging method of root
        spyOn(factory.root, 'startDragging')

        # Drag the element
        element.drag(0, 0)

        expect(factory.root.startDragging).toHaveBeenCalledWith(element, 0, 0)
        factory.root.cancelDragging()

    it 'should trigger the `drag` event against the root', () ->

        element = new factory.Element('div')

        # Mount the element
        region = new factory.Region(document.createElement('div'))
        region.attach(element)

        # Create a function to call when the event is triggered
        foo = {
            handleFoo: () ->
                return
        }
        spyOn(foo, 'handleFoo')

        # Bind the function to the root for the unmount event
        factory.root.bind('drag', foo.handleFoo)

        # Mount the element
        element.drag(0, 0)
        expect(foo.handleFoo).toHaveBeenCalledWith(element)
        factory.root.cancelDragging()

    it 'should do nothing if the `drag` behavior is not allowed', () ->

        element = new factory.Element('div')

        # Disallow dragging of the element
        element.can('drag', false)

        # Mount the element
        region = new factory.Region(document.createElement('div'))
        region.attach(element)

        # Spy on the startDragging method of root
        spyOn(factory.root, 'startDragging')

        # Attempt to drag the element
        element.drag(0, 0)

        expect(factory.root.startDragging).not.toHaveBeenCalled()


describe 'Element.drop()', () ->

    it 'should select a function from the elements droppers map for the element
        being dropped on to this element', () ->

        # Mount the element
        region = new factory.Region(document.createElement('div'))

        # Create 2 elements that can be dropped on each other (we can't use
        # Element instances so we use Image elements instead).
        imageA = new factory.Image()
        region.attach(imageA)

        imageB = new factory.Image()
        region.attach(imageB)

        # Spy on the dropper function
        spyOn(factory.Image.droppers, 'Image')

        # Drop the image
        imageA.drop(imageB, ['below', 'center'])
        expect(
            factory.Image.droppers['Image']
            ).toHaveBeenCalledWith(imageA, imageB, ['below', 'center'])

    it 'should trigger the `drop` event against the root', () ->

        # Mount the element
        region = new factory.Region(document.createElement('div'))

        # Create 2 elements that can be dropped on each other (we can't use
        # Element instances so we use Image elements instead).
        imageA = new factory.Image()
        region.attach(imageA)

        imageB = new factory.Image()
        region.attach(imageB)

        # Create a function to call when the event is triggered
        foo = {
            handleFoo: () ->
                return
        }
        spyOn(foo, 'handleFoo')

        # Bind the function to the root for the unmount event
        factory.root.bind('drop', foo.handleFoo)

        # Drop the image on valid target
        imageA.drop(imageB, ['below', 'center'])
        expect(foo.handleFoo).toHaveBeenCalledWith(
            imageA,
            imageB,
            ['below', 'center']
            )

        # Drop the image on invalid target
        imageA.drop(null, ['below', 'center'])
        expect(foo.handleFoo).toHaveBeenCalledWith(imageA, null, null)

    it 'should do nothing if the `drop` behavior is not allowed', () ->

        # Mount the element
        region = new factory.Region(document.createElement('div'))

        # Create 2 elements that can be dropped on each other (we can't use
        # Element instances so we use Image elements instead).
        imageA = new factory.Image()
        region.attach(imageA)

        imageB = new factory.Image()
        region.attach(imageB)

        # Disallow imageA accepting drops
        imageA.can('drop', false)

        # Spy on the dropper function
        spyOn(factory.Image.droppers, 'Image')

        # Drop the image
        imageA.drop(imageB, ['below', 'center'])
        expect(factory.Image.droppers['Image']).not.toHaveBeenCalled()


describe 'Element.focus()', () ->

    it 'should focus an element', () ->

        # Create and focus an element
        element = new factory.Element('div')
        element.focus()
        expect(element.isFocused()).toBe true

    it 'should trigger the `focus` event against the root', () ->

        # Create a function to call when the event is triggered
        foo = {
            handleFoo: () ->
                return
        }
        spyOn(foo, 'handleFoo')

        # Bind the function to the root for the focus event
        factory.root.bind('focus', foo.handleFoo)

        # Detach the node
        element = new factory.Element('div')
        element.focus()
        expect(foo.handleFoo).toHaveBeenCalledWith(element)


describe 'Element.hasCSSClass()', () ->

    it 'should return true if the element has the specified class', () ->

        # Create an element and add some classes
        element = new factory.Element('div')
        element.addCSSClass('foo')
        element.addCSSClass('bar')

        expect(element.hasCSSClass('foo')).toBe true
        expect(element.hasCSSClass('bar')).toBe true


describe 'Element.merge()', () ->

    it 'should select a function from the elements mergers map for the element
        being merged with this element', () ->

        # Mount the element
        region = new factory.Region(document.createElement('div'))

        # Create 2 elements that can be merged with each other (we can't use
        # Element instances so we use text elements instead).
        textA = new factory.Text('p', {}, 'a')
        region.attach(textA)

        textB = new factory.Text('p', {}, 'b')
        region.attach(textB)

        # Spy on the merger function
        spyOn(factory.Text.mergers, 'Text')

        # Drop the image
        textA.merge(textB)

        expect(
            factory.Text.mergers['Text']
            ).toHaveBeenCalledWith(textB, textA)

    it 'should do nothing if the `merge` behavior is not allowed', () ->

        # Mount the element
        region = new factory.Region(document.createElement('div'))

        # Create 2 elements that can be merged with each other (we can't use
        # Element instances so we use text elements instead).
        textA = new factory.Text('p', {}, 'a')
        region.attach(textA)

        textB = new factory.Text('p', {}, 'b')
        region.attach(textB)

        # Disallow merge for textA
        textA.can('merge', false)

        # Spy on the merger function
        spyOn(factory.Text.mergers, 'Text')

        # Drop the image
        textA.merge(textB)

        expect(factory.Text.mergers['Text']).not.toHaveBeenCalled()


describe 'Element.mount()', () ->

    element = null
    region = null

    beforeEach ->
        element = new factory.Element('p')

        # Mount the element
        region = new factory.Region(document.createElement('div'))
        region.attach(element)
        element.unmount()

    it 'should mount the element to the DOM', () ->
        element.mount()
        expect(element.isMounted()).toBe true

    it 'should trigger the `mount` event against the root', () ->

        # Create a function to call when the event is triggered
        foo = {
            handleFoo: () ->
                return
        }
        spyOn(foo, 'handleFoo')

        # Bind the function to the root for the mount event
        factory.root.bind('mount', foo.handleFoo)

        # Mount the element
        element.mount()
        expect(foo.handleFoo).toHaveBeenCalledWith(element)


describe 'Element.removeAttr()', () ->

    it 'should remove an attribute from the element', () ->
        # Create a node and set an attribute against it
        element = new factory.Element('div')
        element.attr('foo', 'bar')
        expect(element.attr('foo')).toBe 'bar'

        element.removeAttr('foo')
        expect(element.attr('foo')).toBe undefined


describe 'Element.removeCSSClass()', () ->

    it 'should remove a CSS class from the element', () ->

        # Create an element and add CSS classes to it
        element = new factory.Element('div')
        element.addCSSClass('foo')
        element.addCSSClass('bar')
        expect(element.hasCSSClass('foo')).toBe true
        expect(element.hasCSSClass('bar')).toBe true

        # Remove the classes from the element
        element.removeCSSClass('foo')
        element.hasCSSClass('foo')

        element.removeCSSClass('bar')
        expect(element.hasCSSClass('bar')).toBe false


describe 'Element.tagName()', () ->

    it 'should set/get the tag name for the element', () ->

        element = new factory.Element('div')
        expect(element.tagName()).toBe 'div'

        # Change the tag name
        element.tagName('dt')
        expect(element.tagName()).toBe 'dt'


describe 'Element.unmount()', () ->

    element = null
    region = null

    beforeEach ->
        element = new factory.Element('p')

        # Mount the element
        region = new factory.Region(document.createElement('div'))
        region.attach(element)

    it 'should unmount the element from the DOM', () ->
        element.unmount()
        expect(element.isMounted()).toBe false

    it 'should trigger the `unmount` event against the root', () ->

        # Create a function to call when the event is triggered
        foo = {
            handleFoo: () ->
                return
        }
        spyOn(foo, 'handleFoo')

        # Bind the function to the root for the unmount event
        factory.root.bind('unmount', foo.handleFoo)

        # Mount the element
        element.unmount()
        expect(foo.handleFoo).toHaveBeenCalledWith(element)


describe 'Element.@getDOMElementAttributes()', () ->

    it 'should return attributes from a DOM element as a dictionary', () ->

        # Create a DOM element and set a number of attributes
        domElement = document.createElement('div')
        domElement.setAttribute('class', 'foo')
        domElement.setAttribute('id', 'bar')
        domElement.setAttribute('contenteditable', '')

        attributes = factory.Element.getDOMElementAttributes(domElement)
        expect(attributes).toEqual {
            'class': 'foo',
            'id': 'bar',
            'contenteditable': ''
            }


# ElementCollection

describe 'ElementCollection()', () ->

    it 'should create `ElementCollection` instance`', () ->
        collection = new factory.ElementCollection('dl', {'class': 'foo'})
        expect(collection instanceof factory.ElementCollection).toBe true


describe 'ElementCollection.cssTypeName()', () ->

    it 'should return \'element-collection\'', () ->
        element = new factory.ElementCollection('div', {'class': 'foo'})
        expect(element.cssTypeName()).toBe 'element-collection'


describe 'ElementCollection.isMounted()', () ->

    it 'should return true if the element is mounted in the DOM', () ->

        # We can't test this directly against an ElementColleciton instance as
        # they can't be mounted so instead we use a List element.
        collection = new factory.List('ul')
        expect(collection.isMounted()).toBe false

        # Mount the element
        region = new factory.Region(document.createElement('div'))
        region.attach(collection)

        expect(collection.isMounted()).toBe true


describe 'ElementCollection.html()', () ->

    it 'should return a HTML string for the collection', () ->

        collection = new factory.ElementCollection('div', {'class': 'foo'})
        text = new factory.Text('p', {}, 'test')
        collection.attach(text)

        expect(collection.html()).toBe(
            '<div class="foo">\n' +
                "#{ ContentEdit.INDENT }<p>\n" +
                    "#{ ContentEdit.INDENT }#{ ContentEdit.INDENT }test\n" +
                "#{ ContentEdit.INDENT }</p>\n" +
            '</div>'
            )


describe '`ElementCollection.type()`', () ->

    it 'should return \'ElementCollection\'', () ->
        collection = new factory.ElementCollection('div', {'class': 'foo'})
        expect(collection.type()).toBe 'ElementCollection'


describe 'ElementCollection.createDraggingDOMElement()', () ->

    it 'should create a helper DOM element', () ->
        # Mount a collection and text element
        collection = new factory.ElementCollection('div')
        element = new factory.Element('p')
        collection.attach(element)

        region = new factory.Region(document.createElement('div'))
        region.attach(collection)

        # Get the helper DOM element
        helper = collection.createDraggingDOMElement()

        expect(helper).not.toBe null
        expect(helper.tagName.toLowerCase()).toBe 'div'


describe 'ElementCollection.detach()', () ->

    collection = null
    elementA = null
    elementB = null
    region = null

    beforeEach ->
        region = new factory.Region(document.createElement('div'))

        collection = new factory.ElementCollection('div')
        region.attach(collection)

        elementA = new factory.Element('p')
        collection.attach(elementA)

        elementB = new factory.Element('p')
        collection.attach(elementB)

    it 'should detach an element from the element collection', () ->

        # Detach an element
        collection.detach(elementA)
        expect(collection.children.length).toBe 1

    it 'should remove the collection if it becomes empty', () ->

        # Detach both elements
        collection.detach(elementA)
        collection.detach(elementB)
        expect(region.children.length).toBe 0

    it 'should trigger the detach event against the root', () ->

        # Create a function to call when the event is triggered
        foo = {
            handleFoo: () ->
                return
        }
        spyOn(foo, 'handleFoo')

        # Bind the function to the root for the detach event
        factory.root.bind('detach', foo.handleFoo)

        # Detach the node
        collection.detach(elementA)
        expect(foo.handleFoo).toHaveBeenCalledWith(collection, elementA)


describe 'ElementCollection.mount()', () ->

    collection = null
    element = null
    region = null

    beforeEach ->
        collection = new factory.ElementCollection('div')
        element = new factory.Element('p')
        collection.attach(element)

        # Mount the element
        region = new factory.Region(document.createElement('div'))
        region.attach(collection)
        element.unmount()

    it 'should mount the collection and it\'s children to the DOM', () ->
        collection.mount()
        expect(collection.isMounted()).toBe true
        expect(element.isMounted()).toBe true

    it 'should trigger the `mount` event against the root', () ->

        # Create a function to call when the event is triggered
        foo = {
            handleFoo: () ->
                return
        }
        spyOn(foo, 'handleFoo')

        # Bind the function to the root for the mount event
        factory.root.bind('mount', foo.handleFoo)

        # Mount the element
        collection.mount()
        expect(foo.handleFoo).toHaveBeenCalledWith(collection)
        expect(foo.handleFoo).toHaveBeenCalledWith(element)


describe 'ElementCollection.unmount()', () ->

    collection = null
    element = null
    region = null

    beforeEach ->
        collection = new factory.ElementCollection('div')
        element = new factory.Element('p')
        collection.attach(element)

        # Mount the element
        region = new factory.Region(document.createElement('div'))
        region.attach(collection)

    it 'should unmount the collection and it\'s children from the DOM', () ->
        collection.unmount()
        expect(collection.isMounted()).toBe false
        expect(element.isMounted()).toBe false

    it 'should trigger the `unmount` event against the root', () ->

        # Create a function to call when the event is triggered
        foo = {
            handleFoo: () ->
                return
        }
        spyOn(foo, 'handleFoo')

        # Bind the function to the root for the unmount event
        factory.root.bind('unmount', foo.handleFoo)

        # Mount the element
        collection.unmount()
        expect(foo.handleFoo).toHaveBeenCalledWith(collection)
        expect(foo.handleFoo).toHaveBeenCalledWith(element)


# ResizableElement

describe 'ResizableElement()', () ->

    it 'should create `ResizableElement` instance`', () ->
        element = new factory.ResizableElement('div', {'class': 'foo'})
        expect(element instanceof factory.ResizableElement).toBe true


describe 'ResizableElement.aspectRatio()', () ->

    it 'should return the 1', () ->
        element = new factory.ResizableElement('div')
        expect(element.aspectRatio()).toBe 1


describe 'ResizableElement.maxSize()', () ->

    element = null
    beforeEach ->
        element = new factory.ResizableElement('div', {
            'height': 200,
            'width': 200
            })

    it 'should return the default maximum element size for an element', () ->
        expect(element.maxSize()).toEqual [
            ContentEdit.DEFAULT_MAX_ELEMENT_WIDTH,
            ContentEdit.DEFAULT_MAX_ELEMENT_WIDTH
            ]

    it 'should return the specified maximum element size for an element', () ->
        element.attr('data-ce-max-width', 1000)
        expect(element.maxSize()).toEqual [1000, 1000]


describe 'ResizableElement.minSize()', () ->

    element = null
    beforeEach ->
        element = new factory.ResizableElement('div', {
            'height': 200,
            'width': 200
            })

    it 'should return the default minimum element size for an element', () ->
        expect(element.minSize()).toEqual [
            ContentEdit.DEFAULT_MIN_ELEMENT_WIDTH,
            ContentEdit.DEFAULT_MIN_ELEMENT_WIDTH
            ]

    it 'should return the specified minimum element size for an element', () ->
        element.attr('data-ce-min-width', 100)
        expect(element.minSize()).toEqual [100, 100]


describe '`ResizableElement.type()`', () ->

    it 'should return \'ResizableElement\'', () ->
        element = new factory.ResizableElement('div', {'class': 'foo'})
        expect(element.type()).toBe 'ResizableElement'


describe 'ResizableElement.mount()', () ->

    element = null
    region = null

    beforeEach ->
        element = new factory.ResizableElement('div', {
            'height': 200,
            'width': 200
            })

        # Mount the element
        region = new factory.Region(document.createElement('div'))
        region.attach(element)
        element.unmount()

    it 'should mount the element to the DOM and set the size attribute', () ->
        element.mount()
        expect(element.isMounted()).toBe true

        size = element.domElement().getAttribute('data-ce-size')
        expect(size).toBe 'w 200 × h 200'

    it 'should trigger the `mount` event against the root', () ->

        # Create a function to call when the event is triggered
        foo = {
            handleFoo: () ->
                return
        }
        spyOn(foo, 'handleFoo')

        # Bind the function to the root for the mount event
        factory.root.bind('mount', foo.handleFoo)

        # Mount the element
        element.mount()
        expect(foo.handleFoo).toHaveBeenCalledWith(element)


describe 'Element.resize()', () ->

    it 'should call `startResizing` against the root element', () ->

        element = new factory.ResizableElement('div', {
            'height': 200,
            'width': 200
            })

        # Mount the element
        region = new factory.Region(document.createElement('div'))
        region.attach(element)

        # Spy on the startDragging method of root
        spyOn(factory.root, 'startResizing')

        # Drag the element
        element.resize(['top', 'left'], 0, 0)

        expect(factory.root.startResizing).toHaveBeenCalledWith(
            element,
            ['top', 'left']
            0,
            0,
            true # Fixed aspect ratio
            )

    it 'should do nothing if the `resize` behavior is not allowed', () ->

        element = new factory.ResizableElement('div', {
            'height': 200,
            'width': 200
            })

        # Disallow resizing of the element
        element.can('resize', false)

        # Mount the element
        region = new factory.Region(document.createElement('div'))
        region.attach(element)

        # Spy on the startDragging method of root
        spyOn(factory.root, 'startResizing')

        # Drag the element
        element.resize(['top', 'left'], 0, 0)

        expect(factory.root.startResizing).not.toHaveBeenCalled()


describe 'Element.size()', () ->

    it 'should set/get the size of the element', () ->

        element = new factory.ResizableElement('div', {
            'height': 200,
            'width': 200
            })

        # Get the size
        expect(element.size()).toEqual [200, 200]

        # Set the size of the element
        element.size([100, 100])
        expect(element.size()).toEqual [100, 100]