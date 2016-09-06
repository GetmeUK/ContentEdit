# Static

factory = new ContentEdit.Factory()

describe '`Static()`', () ->

    it 'should return an instance of Static`', () ->

        staticElm = new factory.Static('div', {}, '<div></div>')
        expect(staticElm instanceof factory.Static).toBe true


describe '`Static.cssTypeName()`', () ->

    it 'should return \'static\'', () ->

        staticElm = new factory.Static('div', {}, '<div></div>')
        expect(staticElm.cssTypeName()).toBe 'static'


describe '`Static.createDraggingDOMElement()`', () ->

    it 'should create a helper DOM element', () ->
        # Mount an image to a region
        staticElm = new factory.Static('div', {}, 'foo <b>bar</b>')
        region = new factory.Region(document.createElement('div'))
        region.attach(staticElm)

        # Get the helper DOM element
        helper = staticElm.createDraggingDOMElement()

        expect(helper).not.toBe null
        expect(helper.tagName.toLowerCase()).toBe 'div'
        expect(helper.innerHTML).toBe 'foo bar'


describe '`Static.type()`', () ->

    it 'should return \'Static\'', () ->
        staticElm = new factory.Static('div', {}, '<div></div>')
        expect(staticElm.type()).toBe 'Static'


describe '`Static.typeName()`', () ->

    it 'should return \'Static\'', () ->

        staticElm = new factory.Static('div', {}, '<div></div>')
        expect(staticElm.typeName()).toBe 'Static'


describe 'Static.html()', () ->

    it 'should return a HTML string for the static element', () ->
        staticElm = new factory.Static(
            'div',
            {'class': 'foo'},
            '<div><b>foo</b></div>'
            )
        expect(staticElm.html()).toBe(
            '<div class="foo"><div><b>foo</b></div></div>'
            )


describe 'Static.mount()', () ->

    region = null
    staticElm = null

    beforeEach ->
        staticElm = new factory.Static(
            'div',
            {'class': 'foo'},
            '<div><b>foo</b></div>'
            )

        # Mount the static element
        region = new factory.Region(document.createElement('div'))
        region.attach(staticElm)
        staticElm.unmount()

    it 'should mount the static element to the DOM', () ->
        staticElm.mount()
        expect(staticElm.isMounted()).toBe true
        expect(staticElm.domElement().innerHTML).toBe '<div><b>foo</b></div>'

    it 'should trigger the `mount` event against the root', () ->

        # Create a function to call when the event is triggered
        foo = {
            handleFoo: () ->
                return
        }
        spyOn(foo, 'handleFoo')

        # Bind the function to the root for the mount event
        factory.root.bind('mount', foo.handleFoo)

        # Mount the static element
        staticElm.mount()
        expect(foo.handleFoo).toHaveBeenCalledWith(staticElm)


describe '`Static.fromDOMElement()`', () ->

    it 'should convert a DOM element into an static element', () ->

        region = new factory.Region(document.createElement('div'))
        domElement = document.createElement('div')
        domElement.innerHTML = '<div><b>foo</b></div>'

        staticElm = factory.Static.fromDOMElement(domElement)
        region.attach(staticElm)

        expect(staticElm.domElement().innerHTML).toBe '<div><b>foo</b></div>'


# Droppers

describe '`Static` drop interactions if `data-ce-moveable` is
        set', () ->

    staticElm = null
    region = null

    beforeEach ->
        region = new factory.Region(document.createElement('div'))
        staticElm = new factory.Static(
            'div',
            {'data-ce-moveable': ''},
            'foo'
            )
        region.attach(staticElm)

    it 'should support dropping on Text', () ->
        otherStaticElm = new factory.Static(
            'div',
            {'data-ce-moveable': ''},
            'bar'
            )
        region.attach(otherStaticElm)

        # Check the initial order
        expect(staticElm.nextSibling()).toBe otherStaticElm

        # Check the order after dropping the element after
        staticElm.drop(otherStaticElm, ['below', 'center'])
        expect(otherStaticElm.nextSibling()).toBe staticElm

        # Check the order after dropping the element before
        staticElm.drop(otherStaticElm, ['above', 'center'])
        expect(staticElm.nextSibling()).toBe otherStaticElm
