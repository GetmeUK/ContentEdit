# Fixture
factory = new ContentEdit.Factory()

describe '`factory.Fixture()`', () ->

    it 'should return an instance of Fixture`', () ->

        div = document.createElement('div')
        p = document.createElement('p')
        p.innerHTML = 'foo <b>bar</b>'
        div.appendChild(p)
        fixture = new factory.Fixture(p)
        expect(fixture instanceof factory.Fixture).toBe true

        # Check the child element has been correctly modified
        child = fixture.children[0]

        # The child element should state that it is fixed
        expect(child.isFixed()).toBe true

        # Th behaviour of the child element should be restricted
        expect(child.can('drag')).toBe false
        expect(child.can('drop')).toBe false
        expect(child.can('merge')).toBe false
        expect(child.can('remove')).toBe false
        expect(child.can('resize')).toBe false
        expect(child.can('spawn')).toBe false


describe '`factory.Fixture.domElement()`', () ->

    it 'should return the DOM element of the child `Element` it wraps', () ->
        div = document.createElement('div')
        p = document.createElement('p')
        p.innerHTML = 'foo <b>bar</b>'
        div.appendChild(p)
        fixture = new factory.Fixture(p)
        expect(fixture.domElement()).toBe fixture.children[0].domElement()


describe '`factory.Fixture.isMounted()`', () ->

    it 'should always return true', () ->
        div = document.createElement('div')
        p = document.createElement('p')
        p.innerHTML = 'foo <b>bar</b>'
        div.appendChild(p)
        fixture = new factory.Fixture(p)
        expect(fixture.isMounted()).toBe true


describe '`factory.Fixture.html()`', () ->

    it 'should return a HTML string for the fixture', () ->
        # The HTML output for a fixture should typically be the same as the
        # inner HTML of the `Element` it wraps (though there will be exceptions,
        # e.g `Image`s when they are available).

        # Test output for `Text` element
        div = document.createElement('div')
        p = document.createElement('p')
        p.innerHTML = 'foo <b>bar</b>'
        div.appendChild(p)
        fixture = new factory.Fixture(p)
        expect(fixture.html()).toBe("foo <b>bar</b>")


# Test specific to fixtures containing text elements

describe '`factory.Fixture` text behaviour', () ->

    it 'should return trigger next/previous-region event when tab key is
        pressed', () ->

        div = document.createElement('div')
        p = document.createElement('p')
        p.innerHTML = 'foo <b>bar</b>'
        div.appendChild(p)
        fixture = new factory.Fixture(p)
        child = fixture.children[0]

        # Create event handlers
        handlers = {
            nextRegion: () ->
                return

            previousRegion: () ->
                return
        }

        # Spy on the event handlers
        spyOn(handlers, 'nextRegion')
        spyOn(handlers, 'previousRegion')

        # Bind the event handlers to the root for the events of interest
        factory.root.bind('next-region', handlers.nextRegion)
        factory.root.bind('previous-region', handlers.previousRegion)

        # Simulate tab key being pressed
        child._keyTab({
            preventDefault: () ->
            })
        expect(handlers.nextRegion).toHaveBeenCalledWith(fixture)

        # Simulate tab and shift key being pressed
        child._keyTab({
            preventDefault: () ->,
            shiftKey: true
            })
        expect(handlers.previousRegion).toHaveBeenCalledWith(fixture)
