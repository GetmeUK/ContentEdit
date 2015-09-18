# Static

describe '`ContentEdit.Static()`', () ->

    it 'should return an instance of Static`', () ->

        staticElm = new ContentEdit.Static('div', {}, '<div></div>')
        expect(staticElm instanceof ContentEdit.Static).toBe true


describe '`ContentEdit.Static.cssTypeName()`', () ->

    it 'should return \'static\'', () ->

        staticElm = new ContentEdit.Static('div', {}, '<div></div>')
        expect(staticElm.cssTypeName()).toBe 'static'


describe '`ContentEdit.Static.typeName()`', () ->

    it 'should return \'Static\'', () ->

        staticElm = new ContentEdit.Static('div', {}, '<div></div>')
        expect(staticElm.typeName()).toBe 'Static'


describe 'ContentEdit.Static.html()', () ->

    it 'should return a HTML string for the static element', () ->
        staticElm = new ContentEdit.Static(
            'div',
            {'class': 'foo'},
            '<div><b>foo</b></div>'
            )
        expect(staticElm.html()).toBe(
            '<div class="foo"><div><b>foo</b></div></div>'
            )


describe 'ContentEdit.Static.mount()', () ->

    region = null
    staticElm = null

    beforeEach ->
        staticElm = new ContentEdit.Static(
            'div',
            {'class': 'foo'},
            '<div><b>foo</b></div>'
            )

        # Mount the static element
        region = new ContentEdit.Region(document.createElement('div'))
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
        root = ContentEdit.Root.get()
        root.bind('mount', foo.handleFoo)

        # Mount the static element
        staticElm.mount()
        expect(foo.handleFoo).toHaveBeenCalledWith(staticElm)


describe '`ContentEdit.Static.fromDOMElement()`', () ->

    it 'should convert a DOM element into an static element', () ->

        region = new ContentEdit.Region(document.createElement('div'))
        domElement = document.createElement('div')
        domElement.innerHTML = '<div><b>foo</b></div>'
        staticElm = ContentEdit.Static.fromDOMElement(domElement)
        region.attach(staticElm)

        expect(staticElm.domElement().innerHTML).toBe '<div><b>foo</b></div>'