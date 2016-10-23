# Text

describe '`ContentEdit.Text()`', () ->

    afterEach ->
        ContentEdit.TRIM_WHITESPACE = true

    it 'should return an instance of Text`', () ->
        text = new ContentEdit.Text('p', {}, 'foo <b>bar</b>')
        expect(text instanceof ContentEdit.Text).toBe true

    it 'should trim whitespace by default`', () ->
        text = new ContentEdit.Text('p', {}, '&nbsp;foo <b>bar</b><br>')
        expect(text.html()).toBe '<p class="foo">\n' +
                "#{ ContentEdit.INDENT }bar <b>var</b>\n" +
            '</p>'

    it 'should preserve whitespace if `TRIM_WHITESPACE` is false`', () ->
        ContentEdit.TRIM_WHITESPACE = false
        text = new ContentEdit.Text('p', {}, '&nbsp;foo <b>bar</b><br>')
        expect(text.html()).toBe '<p class="foo">\n' +
                "#{ ContentEdit.INDENT }&nbsp;bar <b>var</b><br>\n" +
            '</p>'


describe '`ContentEdit.Text.cssTypeName()`', () ->

    it 'should return \'text\'', () ->
        text = new ContentEdit.Text('p', {}, 'foo')
        expect(text.cssTypeName()).toBe 'text'


describe '`ContentEdit.Text.type()`', () ->

    it 'should return \'Text\'', () ->
        text = new ContentEdit.Text('p', {}, 'foo <b>bar</b>')
        expect(text.type()).toBe 'Text'


describe '`ContentEdit.Text.typeName()`', () ->

    it 'should return \'Text\'', () ->
        text = new ContentEdit.Text('p', {}, 'foo <b>bar</b>')
        expect(text.typeName()).toBe 'Text'


describe 'ContentEdit.Text.blur()', () ->

    root = ContentEdit.Root.get()
    text = null
    region = null

    beforeEach ->
        # Mount a text element to a region
        text = new ContentEdit.Text('p', {}, 'foo')
        region = new ContentEdit.Region(document.getElementById('test'))
        region.attach(text)
        text.focus()

    afterEach ->
        region.detach(text)

    it 'should blur the text element', () ->
        text.blur()
        expect(text.isFocused()).toBe false

    it 'should remove the text element if it\'s just whitespace', () ->
        text.domElement().innerHTML = ''
        text.content = new HTMLString.String('')
        text.blur()
        expect(text.parent()).toBe null

    it 'should trigger the `blur` event against the root', () ->

        # Create a function to call when the event is triggered
        foo = {
            handleFoo: () ->
                return
        }
        spyOn(foo, 'handleFoo')

        # Bind the function to the root for the blur event
        root.bind('blur', foo.handleFoo)

        # Detach the node
        text.blur()
        expect(foo.handleFoo).toHaveBeenCalledWith(text)

    it 'should not remove the text element if it\'s just whitespace but remove
        behaviour is disallowed', () ->

        # Disallow remove
        text.can('remove', false)

        text.domElement().innerHTML = ''
        text.content = new HTMLString.String('')
        text.blur()
        expect(text.parent()).not.toBe null


describe '`ContentEdit.Text.createDraggingDOMElement()`', () ->

    it 'should create a helper DOM element', () ->
        # Mount an image to a region
        text = new ContentEdit.Text('p', {}, 'foo <b>bar</b>')
        region = new ContentEdit.Region(document.createElement('div'))
        region.attach(text)

        # Get the helper DOM element
        helper = text.createDraggingDOMElement()

        expect(helper).not.toBe null
        expect(helper.tagName.toLowerCase()).toBe 'div'
        expect(helper.innerHTML).toBe 'foo bar'


describe 'ContentEdit.Text.drag()', () ->

    root = ContentEdit.Root.get()
    text = null

    beforeEach ->
        # Mount a text element
        text = new ContentEdit.Text('p', {}, 'foo')
        region = new ContentEdit.Region(document.createElement('div'))
        region.attach(text)

    afterEach ->
        root.cancelDragging()

    it 'should call `storeState` against the text element', () ->
        # Spy on the storeState method of root
        spyOn(text, 'storeState')

        # Drag the text element
        text.drag(0, 0)

        expect(text.storeState).toHaveBeenCalled()

    it 'should call `startDragging` against the root element', () ->
        # Spy on the startDragging method of root
        spyOn(root, 'startDragging')

        # Drag the text element
        text.drag(0, 0)

        expect(root.startDragging).toHaveBeenCalledWith(text, 0, 0)


describe 'ContentEdit.Text.drop()', () ->

    it 'should call the `restoreState` against the text element', () ->
        # Mount a text element
        textA = new ContentEdit.Text('p', {}, 'foo')
        textB = new ContentEdit.Text('p', {}, 'bar')
        region = new ContentEdit.Region(document.createElement('div'))
        region.attach(textA)
        region.attach(textB)

        # Spy on the startDragging method of root
        spyOn(textA, 'restoreState')

        # Drag the text element
        textA.storeState()
        textA.drop(textB, ['above', 'center'])

        expect(textA.restoreState).toHaveBeenCalled()


describe 'ContentEdit.Text.focus()', () ->

    root = ContentEdit.Root.get()
    text = null
    region = null

    beforeEach ->
        # Mount a text element to a region
        text = new ContentEdit.Text('p', {}, 'foo')
        region = new ContentEdit.Region(document.getElementById('test'))
        region.attach(text)
        text.blur()

    afterEach ->
        region.detach(text)

    it 'should focus the text element', () ->
        text.focus()
        expect(text.isFocused()).toBe true

    it 'should trigger the `focus` event against the root', () ->

        # Create a function to call when the event is triggered
        foo = {
            handleFoo: () ->
                return
        }
        spyOn(foo, 'handleFoo')

        # Bind the function to the root for the focus event
        root.bind('focus', foo.handleFoo)

        # Detach the node
        text.focus()
        expect(foo.handleFoo).toHaveBeenCalledWith(text)


describe 'ContentEdit.Text.html()', () ->

    it 'should return a HTML string for the text element', () ->
        text = new ContentEdit.Text('p', {'class': 'foo'}, 'bar <b>zee</b>')
        expect(text.html()).toBe '<p class="foo">\n' +
                "#{ ContentEdit.INDENT }bar <b>zee</b>\n" +
            '</p>'


describe 'ContentEdit.Text.mount()', () ->

    text = null
    region = null

    beforeEach ->
        text = new ContentEdit.Text('p', {}, 'foo')

        # Mount the text element
        region = new ContentEdit.Region(document.createElement('div'))
        region.attach(text)
        text.unmount()

    it 'should mount the text element to the DOM', () ->
        text.mount()
        expect(text.isMounted()).toBe true

    it 'should call `updateInnerHTML` against the text element', () ->
        # Spy on the startDragging method of root
        spyOn(text, 'updateInnerHTML')
        text.mount()

        expect(text.updateInnerHTML).toHaveBeenCalled()

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

        # Mount the text element
        text.mount()
        expect(foo.handleFoo).toHaveBeenCalledWith(text)


describe 'ContentEdit.Text.restoreState()', () ->

    it 'should restore a text elements state after it has been \
        remounted', () ->

        # Mount a text element to a region
        text = new ContentEdit.Text('p', {}, 'foo')
        region = new ContentEdit.Region(document.getElementById('test'))
        region.attach(text)

        # Select some text
        text.focus()
        new ContentSelect.Range(1, 2).select(text.domElement())

        # Store the text elements state and unmount it
        text.storeState()
        text.unmount()

        # Remount and restore the state
        text.mount()
        text.restoreState()

        selection = ContentSelect.Range.query(text.domElement())
        expect(selection.get()).toEqual [1, 2]

        # Clean up
        region.detach(text)


describe 'ContentEdit.Text.selection()', () ->

    it 'should get/set the content selection for the element', () ->

        # Mount a text element to a region
        text = new ContentEdit.Text('p', {}, 'foobar')
        region = new ContentEdit.Region(document.getElementById('test'))
        region.attach(text)

        # Set/Get the content selection for the text element
        text.selection(new ContentSelect.Range(1, 2))
        expect(text.selection().get()).toEqual [1, 2]

        # Clean up
        region.detach(text)


describe 'ContentEdit.Text.storeState()', () ->

    it 'should store the text elements state so it can be restored', () ->

        # Mount a text element to a region
        text = new ContentEdit.Text('p', {}, 'foo')
        region = new ContentEdit.Region(document.getElementById('test'))
        region.attach(text)

        # Select some text
        text.focus()
        new ContentSelect.Range(1, 2).select(text.domElement())

        # Store the text elements state and unmount it
        text.storeState()
        expect(text._savedSelection.get()).toEqual [1, 2]

        text.unmount()

        # Remount and restore the state
        text.mount()
        text.restoreState()

        selection = ContentSelect.Range.query(text.domElement())
        expect(selection.get()).toEqual [1, 2]

        # Clean up
        region.detach(text)


describe 'ContentEdit.Text.updateInnerHTML()', () ->

    it 'should update the contents of the text elements related DOM \
        element', () ->

        # Mount a text element to a region
        text = new ContentEdit.Text('p', {}, 'foo')
        region = new ContentEdit.Region(document.getElementById('test'))
        region.attach(text)

        text.content = text.content.concat(' bar')
        text.updateInnerHTML()

        # Check the text elements DOM elements content was updated
        expect(text.domElement().innerHTML).toBe 'foo bar'

        # Clean up
        region.detach(text)


describe '`ContentEdit.Text.fromDOMElement()`', () ->

    it 'should convert the following DOM elements into a text element: \
        <address>, <h1>, <h2>, <h3>, <h4>, <h5>, <h6>, <p>', () ->

        INDENT = ContentEdit.INDENT

        # address
        domAddress = document.createElement('address')
        domAddress.innerHTML = 'foo'
        address = ContentEdit.Text.fromDOMElement(domAddress)
        expect(address.html()).toBe "<address>\n#{ INDENT }foo\n</address>"

        # h1
        for i in [1...7]
            domH = document.createElement("h#{ i }")
            domH.innerHTML = 'foo'
            h = ContentEdit.Text.fromDOMElement(domH)
            expect(h.html()).toBe "<h#{ i }>\n#{ INDENT }foo\n</h#{ i }>"

        # p
        domP = document.createElement('p')
        domP.innerHTML = 'foo'
        p = ContentEdit.Text.fromDOMElement(domP)
        expect(p.html()).toBe "<p>\n#{ INDENT }foo\n</p>"


# Key events

describe '`ContentEdit.Text` key events`', () ->

    INDENT = ContentEdit.INDENT
    ev = {preventDefault: () -> return}
    region = null
    root = ContentEdit.Root.get()

    beforeEach ->
        region = new ContentEdit.Region(document.getElementById('test'))
        for content in ['foo', 'bar', 'zee']
            region.attach(new ContentEdit.Text('p', {}, content))

    afterEach ->
        for child in region.children.slice()
            region.detach(child)

    it 'should support down arrow nav to next content element', () ->
        text = region.children[0]
        text.focus()
        new ContentSelect.Range(3, 3).select(text.domElement())
        text._keyDown(ev)

        expect(root.focused()).toBe region.children[1]

    it 'should support left arrow nav to previous content element', () ->
        text = region.children[1]
        text.focus()
        new ContentSelect.Range(0, 0).select(text.domElement())
        text._keyLeft(ev)

        expect(root.focused()).toBe region.children[0]

    it 'should support right arrow nav to next content element', () ->
        text = region.children[0]
        text.focus()
        new ContentSelect.Range(3, 3).select(text.domElement())
        text._keyRight(ev)

        expect(root.focused()).toBe region.children[1]

    it 'should support up arrow nav to previous content element', () ->
        text = region.children[1]
        text.focus()
        new ContentSelect.Range(0, 0).select(text.domElement())
        text._keyUp(ev)

        expect(root.focused()).toBe region.children[0]

    it 'should support delete merge with next content element', () ->
        text = region.children[0]
        text.focus()
        new ContentSelect.Range(3, 3).select(text.domElement())
        text._keyDelete(ev)

        expect(text.content.text()).toBe 'foobar'

    it 'should support backspace merge with previous content element', () ->
        text = region.children[1]
        text.focus()
        new ContentSelect.Range(0, 0).select(text.domElement())
        text._keyBack(ev)

        expect(region.children[0].content.text()).toBe 'foobar'

    it 'should support return splitting the element into 2', () ->
        text = region.children[0]
        text.focus()
        new ContentSelect.Range(2, 2).select(text.domElement())
        text._keyReturn(ev)

        expect(region.children[0].content.text()).toBe 'fo'
        expect(region.children[1].content.text()).toBe 'o'

    it 'should support shift+return inserting a line break', () ->
        text = region.children[0]
        text.focus()
        new ContentSelect.Range(2, 2).select(text.domElement())
        ev.shiftKey = true
        text._keyReturn(ev)

        expect(region.children[0].content.html()).toBe 'fo<br>o'

    it 'should not split the element into 2 on return if spawn is
        disallowed', () ->

        childCount = region.children.length
        text = region.children[0]

        # Disallow spawning of new elements
        text.can('spawn', false)

        text.focus()
        new ContentSelect.Range(2, 2).select(text.domElement())
        text._keyReturn(ev)

        expect(region.children.length).toBe childCount


# Test the behaviour of the return key if the `PREFER_LINE_BREAKS` has been
# set to true.

describe '`ContentEdit.Text` key events with prefer line breaks`', () ->

    INDENT = ContentEdit.INDENT
    ev = {preventDefault: () -> return}
    region = null
    root = ContentEdit.Root.get()

    beforeEach ->
        ContentEdit.PREFER_LINE_BREAKS = true
        region = new ContentEdit.Region(document.getElementById('test'))
        for content in ['foo', 'bar', 'zee']
            region.attach(new ContentEdit.Text('p', {}, content))

    afterEach ->
        ContentEdit.PREFER_LINE_BREAKS = false
        for child in region.children.slice()
            region.detach(child)

    it 'should support return inserting a line break', () ->
        text = region.children[0]
        text.focus()
        new ContentSelect.Range(2, 2).select(text.domElement())
        text._keyReturn(ev)

        expect(region.children[0].content.html()).toBe 'fo<br>o'

    it 'should support shift+return splitting the element into 2', () ->
        text = region.children[0]
        text.focus()
        new ContentSelect.Range(2, 2).select(text.domElement())
        ev.shiftKey = true
        text._keyReturn(ev)

        expect(region.children[0].content.text()).toBe 'fo'
        expect(region.children[1].content.text()).toBe 'o'


# Droppers

describe '`ContentEdit.Text` drop interactions`', () ->

    region = null
    text = null

    beforeEach ->
        region = new ContentEdit.Region(document.createElement('div'))
        text = new ContentEdit.Text('p', {}, 'foo')
        region.attach(text)

    it 'should support dropping on Text', () ->
        otherText = new ContentEdit.Text('p', {}, 'bar')
        region.attach(otherText)

        # Check the initial order
        expect(text.nextSibling()).toBe otherText

        # Check the order after dropping the element after
        text.drop(otherText, ['below', 'center'])
        expect(otherText.nextSibling()).toBe text

        # Check the order after dropping the element before
        text.drop(otherText, ['above', 'center'])
        expect(text.nextSibling()).toBe otherText

    it 'should support dropping on Static', () ->
        staticElm = ContentEdit.Static.fromDOMElement(
            document.createElement('div')
            )
        region.attach(staticElm)

        # Check the initial order
        expect(text.nextSibling()).toBe staticElm

        # Check the order after dropping the element after
        text.drop(staticElm, ['below', 'center'])
        expect(staticElm.nextSibling()).toBe text

        # Check the order after dropping the element before
        text.drop(staticElm, ['above', 'center'])
        expect(text.nextSibling()).toBe staticElm

    it 'should support being dropped on by `moveable` Static', () ->
        staticElm = new ContentEdit.Static('div', {'data-ce-moveable'}, 'foo')
        region.attach(staticElm, 0)

        # Check the initial order
        expect(staticElm.nextSibling()).toBe text

        # Check the order after dropping the element below
        staticElm.drop(text, ['below', 'center'])
        expect(text.nextSibling()).toBe staticElm

        # Check the order after dropping the element above
        staticElm.drop(text, ['above', 'center'])
        expect(staticElm.nextSibling()).toBe text


# Mergers

describe '`ContentEdit.Text` merge interactions`', () ->

    text = null
    region = null

    beforeEach ->
        region = new ContentEdit.Region(document.getElementById('test'))
        text = new ContentEdit.Text('p', {}, 'foo')
        region.attach(text)

    afterEach ->
        for child in region.children.slice()
            region.detach(child)

    it 'should support merging with Text', () ->
        otherText = new ContentEdit.Text('p', {}, 'bar')
        region.attach(otherText)

        # Merge the text
        text.merge(otherText)
        expect(text.html()).toBe "<p>\n#{ ContentEdit.INDENT }foobar\n</p>"
        expect(otherText.parent()).toBe null


# PreText

describe '`ContentEdit.PreText()`', () ->

    it 'should return an instance of PreText`', () ->
        preText = new ContentEdit.PreText('pre', {}, 'foo <b>bar</b>')
        expect(preText instanceof ContentEdit.PreText).toBe true


describe '`ContentEdit.PreText.cssTypeName()`', () ->

    it 'should return \'pre-text\'', () ->
        preText = new ContentEdit.PreText('pre', {}, 'foo <b>bar</b>')
        expect(preText.cssTypeName()).toBe 'pre-text'


describe '`ContentEdit.PreText.type()`', () ->

    it 'should return \'PreText\'', () ->
        preText = new ContentEdit.PreText('pre', {}, 'foo <b>bar</b>')
        expect(preText.type()).toBe 'PreText'


describe '`ContentEdit.PreText.typeName()`', () ->

    it 'should return \'Preformatted\'', () ->
        preText = new ContentEdit.PreText('pre', {}, 'foo <b>bar</b>')
        expect(preText.typeName()).toBe 'Preformatted'


describe 'ContentEdit.PreText.html()', () ->

    it 'should return a HTML string for the pre-text element', () ->
        I = ContentEdit.INDENT

        preText = new ContentEdit.PreText(
            'pre',
            {'class': 'foo'}, """
&lt;div&gt;
    test &amp; test
&lt;/div&gt;
""")

        expect(preText.html()).toBe """<pre class="foo">&lt;div&gt;
#{ ContentEdit.INDENT }test &amp; test
&lt;/div&gt;</pre>"""

describe '`ContentEdit.PreText.fromDOMElement()`', () ->

    it 'should convert a <pre> DOM element into a preserved text element', () ->
        I = ContentEdit.INDENT

        # pre
        domDiv = document.createElement('div')
        domDiv.innerHTML = """<pre>&lt;div&gt;
#{ ContentEdit.INDENT }test &amp; test
&lt;/div&gt;</pre>"""

        preText = ContentEdit.PreText.fromDOMElement(domDiv.childNodes[0])

        expect(preText.html()).toBe """<pre>&lt;div&gt;
#{ ContentEdit.INDENT }test &amp; test
&lt;/div&gt;</pre>"""


# Key events

describe '`ContentEdit.PreText` key events`', () ->

    I = ContentEdit.INDENT
    ev = {preventDefault: () -> return}
    region = null
    preText = null
    root = ContentEdit.Root.get()

    beforeEach ->
        region = new ContentEdit.Region(document.getElementById('test'))
        preText = new ContentEdit.PreText(
            'pre',
            {'class': 'foo'}, """&lt;div&gt;
#{ ContentEdit.INDENT }test &amp; test
&lt;/div&gt;"""
            )
        region.attach(preText)

    afterEach ->
        for child in region.children.slice()
            region.detach(child)

    it 'should support return adding a newline', () ->
        preText.focus()
        new ContentSelect.Range(13, 13).select(preText.domElement())
        preText._keyReturn(ev)

        expect(preText.html()).toBe  """<pre class="foo">&lt;div&gt;
#{ ContentEdit.INDENT }tes
t &amp; test
&lt;/div&gt;</pre>"""

    it 'should support tab indenting a single line', () ->
        preText.focus()
        new ContentSelect.Range(10, 10).select(preText.domElement())
        preText._keyTab(ev)

        expect(preText.html()).toBe  """<pre class="foo">&lt;div&gt;
#{ ContentEdit.INDENT }#{ ContentEdit.PreText.TAB_INDENT }test &amp; test
&lt;/div&gt;</pre>"""

    it 'should support tab indenting multiple lines', () ->
        preText.focus()
        new ContentSelect.Range(10, 24).select(preText.domElement())
        preText._keyTab(ev)

        expect(preText.html()).toBe  """<pre class="foo">&lt;div&gt;
#{ ContentEdit.INDENT }#{ ContentEdit.PreText.TAB_INDENT }test &amp; test
#{ ContentEdit.PreText.TAB_INDENT }&lt;/div&gt;</pre>"""

    it 'should support tab unindenting multiple lines', () ->
        preText.focus()
        new ContentSelect.Range(10, 24).select(preText.domElement())
        ev.shiftKey = true
        preText._keyTab(ev)

        expect(preText.html()).toBe  """<pre class="foo">&lt;div&gt;
test &amp; test
&lt;/div&gt;</pre>"""


# Droppers

describe '`ContentEdit.PreText` drop interactions`', () ->

    region = null
    preText = null

    beforeEach ->
        region = new ContentEdit.Region(document.createElement('div'))
        preText = new ContentEdit.PreText('p', {}, 'foo')
        region.attach(preText)

    it 'should support dropping on PreText', () ->
        otherPreText = new ContentEdit.PreText('pre', {}, '')
        region.attach(otherPreText)

        # Check the initial order
        expect(preText.nextSibling()).toBe otherPreText

        # Check the order after dropping the element after
        preText.drop(otherPreText, ['below', 'center'])
        expect(otherPreText.nextSibling()).toBe preText

        # Check the order after dropping the element before
        preText.drop(otherPreText, ['above', 'center'])
        expect(preText.nextSibling()).toBe otherPreText

    it 'should support dropping on Static', () ->
        staticElm = ContentEdit.Static.fromDOMElement(
            document.createElement('div')
            )
        region.attach(staticElm)

        # Check the initial order
        expect(preText.nextSibling()).toBe staticElm

        # Check the order after dropping the element after
        preText.drop(staticElm, ['below', 'center'])
        expect(staticElm.nextSibling()).toBe preText

        # Check the order after dropping the element before
        preText.drop(staticElm, ['above', 'center'])
        expect(preText.nextSibling()).toBe staticElm

    it 'should support being dropped on by `moveable` Static', () ->
        staticElm = new ContentEdit.Static('div', {'data-ce-moveable'}, 'foo')
        region.attach(staticElm, 0)

        # Check the initial order
        expect(staticElm.nextSibling()).toBe preText

        # Check the order after dropping the element below
        staticElm.drop(preText, ['below', 'center'])
        expect(preText.nextSibling()).toBe staticElm

        # Check the order after dropping the element above
        staticElm.drop(preText, ['above', 'center'])
        expect(staticElm.nextSibling()).toBe preText

    it 'should support dropping on Text', () ->
        text = new ContentEdit.Text('p')
        region.attach(text)

        # Check the initial order
        expect(preText.nextSibling()).toBe text

        # Check the order after dropping the element below
        preText.drop(text, ['below', 'center'])
        expect(text.nextSibling()).toBe preText

        # Check the order after dropping the element above
        preText.drop(text, ['above', 'center'])
        expect(preText.nextSibling()).toBe text

    it 'should support being dropped on by Text', () ->
        text = new ContentEdit.Text('p')
        region.attach(text, 0)

        # Check the initial order
        expect(text.nextSibling()).toBe preText

        # Check the order after dropping the element below
        text.drop(preText, ['below', 'center'])
        expect(preText.nextSibling()).toBe text

        # Check the order after dropping the element above
        text.drop(preText, ['above', 'center'])
        expect(text.nextSibling()).toBe preText