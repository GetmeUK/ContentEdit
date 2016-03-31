# List

describe '`ContentEdit.List()`', () ->

    it 'should return an instance of List`', () ->
        list = new ContentEdit.List('ul')
        expect(list instanceof ContentEdit.List).toBe true


describe '`ContentEdit.List.cssTypeName()`', () ->

    it 'should return \'list\'', () ->
        list = new ContentEdit.List('ul')
        expect(list.cssTypeName()).toBe 'list'


describe '`ContentEdit.List.typeName()`', () ->

    it 'should return \'List\'', () ->
        list = new ContentEdit.List('ul')
        expect(list.type()).toBe 'List'


describe '`ContentEdit.List.typeName()`', () ->

    it 'should return \'List\'', () ->
        list = new ContentEdit.List('ul')
        expect(list.typeName()).toBe 'List'


describe '`ContentEdit.List.fromDOMElement()`', () ->

    it 'should convert the following DOM elements into a list element: \
        <ol>, <ul>', () ->

        INDENT = ContentEdit.INDENT

        # ol
        domOl = document.createElement('ol')
        domOl.innerHTML = '<li>foo</li>'
        ol = ContentEdit.Text.fromDOMElement(domOl)
        expect(ol.html()).toBe "<ol>\n#{ INDENT }<li>foo</li>\n</ol>"

        # ul
        domUl = document.createElement('ul')
        domUl.innerHTML = '<li>foo</li>'
        ul = ContentEdit.Text.fromDOMElement(domUl)
        expect(ul.html()).toBe "<ul>\n#{ INDENT }<li>foo</li>\n</ul>"


# Droppers

describe '`ContentEdit.List` drop interactions`', () ->

    list = null
    region = null

    beforeEach ->
        region = new ContentEdit.Region(document.createElement('div'))
        list = new ContentEdit.List('ul')
        region.attach(list)

    it 'should support dropping on Image', () ->
        image = new ContentEdit.Image({'src': '/bar.jpg'})
        region.attach(image)

        # Check the initial order
        expect(list.nextSibling()).toBe image

        # Check the order after dropping the element below
        list.drop(image, ['below', 'center'])
        expect(image.nextSibling()).toBe list

        # Check the order after dropping the element above
        list.drop(image, ['above', 'center'])
        expect(list.nextSibling()).toBe image

    it 'should support being dropped on by Image', () ->
        image = new ContentEdit.Image({'src': '/bar.jpg'})
        region.attach(image, 0)

        # Check the initial order
        expect(image.nextSibling()).toBe list

        # Check the order and class above dropping the element left
        image.drop(list, ['above', 'left'])
        expect(image.hasCSSClass('align-left')).toBe true
        expect(image.nextSibling()).toBe list

        # Check the order and class above dropping the element right
        image.drop(list, ['above', 'right'])
        expect(image.hasCSSClass('align-left')).toBe false
        expect(image.hasCSSClass('align-right')).toBe true
        expect(image.nextSibling()).toBe list

        # Check the order after dropping the element below
        image.drop(list, ['below', 'center'])
        expect(image.hasCSSClass('align-left')).toBe false
        expect(image.hasCSSClass('align-right')).toBe false
        expect(list.nextSibling()).toBe image

        # Check the order after dropping the element above
        image.drop(list, ['above', 'center'])
        expect(image.nextSibling()).toBe list

    it 'should support dropping on List', () ->
        otherList = new ContentEdit.Image({'src': '/bar.jpg'})
        region.attach(otherList)

        # Check the initial order
        expect(list.nextSibling()).toBe otherList

        # Check the order after dropping the element below
        list.drop(otherList, ['below', 'center'])
        expect(otherList.nextSibling()).toBe list

        # Check the order after dropping the element above
        list.drop(otherList, ['above', 'center'])
        expect(list.nextSibling()).toBe otherList

    it 'should support dropping on PreText', () ->
        preText = new ContentEdit.PreText('pre', {}, '')
        region.attach(preText)

        # Check the initial order
        expect(list.nextSibling()).toBe preText

        # Check the order after dropping the element below
        list.drop(preText, ['below', 'center'])
        expect(preText.nextSibling()).toBe list

        # Check the order after dropping the element above
        list.drop(preText, ['above', 'center'])
        expect(list.nextSibling()).toBe preText

    it 'should support being dropped on by PreText', () ->
        preText = new ContentEdit.PreText('pre', {}, '')
        region.attach(preText, 0)

        # Check the initial order
        expect(preText.nextSibling()).toBe list

        # Check the order after dropping the element below
        preText.drop(list, ['below', 'center'])
        expect(list.nextSibling()).toBe preText

        # Check the order after dropping the element above
        preText.drop(list, ['above', 'center'])
        expect(preText.nextSibling()).toBe list

    it 'should support dropping on Static', () ->
        staticElm = ContentEdit.Static.fromDOMElement(
            document.createElement('div')
            )
        region.attach(staticElm)

        # Check the initial order
        expect(list.nextSibling()).toBe staticElm

        # Check the order after dropping the element below
        list.drop(staticElm, ['below', 'center'])
        expect(staticElm.nextSibling()).toBe list

        # Check the order after dropping the element above
        list.drop(staticElm, ['above', 'center'])
        expect(list.nextSibling()).toBe staticElm

    it 'should support being dropped on by `moveable` Static', () ->
        staticElm = new ContentEdit.Static('div', {'data-ce-moveable'}, 'foo')
        region.attach(staticElm, 0)

        # Check the initial order
        expect(staticElm.nextSibling()).toBe list

        # Check the order after dropping the element below
        staticElm.drop(list, ['below', 'center'])
        expect(list.nextSibling()).toBe staticElm

        # Check the order after dropping the element above
        staticElm.drop(list, ['above', 'center'])
        expect(staticElm.nextSibling()).toBe list

    it 'should support dropping on Text', () ->
        text = new ContentEdit.Text('p')
        region.attach(text)

        # Check the initial order
        expect(list.nextSibling()).toBe text

        # Check the order after dropping the element below
        list.drop(text, ['below', 'center'])
        expect(text.nextSibling()).toBe list

        # Check the order after dropping the element above
        list.drop(text, ['above', 'center'])
        expect(list.nextSibling()).toBe text

    it 'should support being dropped on by Text', () ->
        text = new ContentEdit.Text('p')
        region.attach(text, 0)

        # Check the initial order
        expect(text.nextSibling()).toBe list

        # Check the order after dropping the element below
        text.drop(list, ['below', 'center'])
        expect(list.nextSibling()).toBe text

        # Check the order after dropping the element above
        text.drop(list, ['above', 'center'])
        expect(text.nextSibling()).toBe list

    it 'should support dropping on Video', () ->
        video = new ContentEdit.Video('iframe', {'src': '/foo.jpg'})
        region.attach(video)

        # Check the initial order
        expect(list.nextSibling()).toBe video

        # Check the order after dropping the element below
        list.drop(video, ['below', 'center'])
        expect(video.nextSibling()).toBe list

        # Check the order after dropping the element above
        list.drop(video, ['above', 'center'])
        expect(list.nextSibling()).toBe video

    it 'should support being dropped on by Video', () ->
        video = new ContentEdit.Video('iframe', {'src': '/foo.jpg'})
        region.attach(video, 0)

        # Check the initial order
        expect(video.nextSibling()).toBe list

        # Check the order and class above dropping the element left
        video.drop(list, ['above', 'left'])
        expect(video.hasCSSClass('align-left')).toBe true
        expect(video.nextSibling()).toBe list

        # Check the order and class above dropping the element right
        video.drop(list, ['above', 'right'])
        expect(video.hasCSSClass('align-left')).toBe false
        expect(video.hasCSSClass('align-right')).toBe true
        expect(video.nextSibling()).toBe list

        # Check the order after dropping the element below
        video.drop(list, ['below', 'center'])
        expect(video.hasCSSClass('align-left')).toBe false
        expect(video.hasCSSClass('align-right')).toBe false
        expect(list.nextSibling()).toBe video

        # Check the order after dropping the element above
        video.drop(list, ['above', 'center'])
        expect(video.nextSibling()).toBe list


# ListItem

describe '`ContentEdit.ListItem()`', () ->

    it 'should return an instance of ListLitem`', () ->
        listItem = new ContentEdit.ListItem()
        expect(listItem instanceof ContentEdit.ListItem).toBe true


describe '`ContentEdit.List.cssTypeName()`', () ->

    it 'should return \'list-item\'', () ->
        listItem = new ContentEdit.ListItem()
        expect(listItem.cssTypeName()).toBe 'list-item'


describe '`ContentEdit.ListItem.list()`', () ->

    it 'should return any associated List element, or null if there isn\'t \
        one', () ->

        # Build a list item with a child text node and list
        listItem = new ContentEdit.ListItem()
        expect(listItem.list()).toBe null

        listItemText = new ContentEdit.ListItemText('foo')
        listItem.attach(listItemText)
        expect(listItem.list()).toBe null

        list = new ContentEdit.List('ul')
        listItem.attach(list)
        expect(listItem.list()).toBe list


describe '`ContentEdit.ListItem.listItemText()`', () ->

    it 'should return any associated ListItemText element, or null if there
        isn\'t one', () ->

        # Build a list item with a child text node
        listItem = new ContentEdit.ListItem()
        expect(listItem.listItemText()).toBe null

        listItemText = new ContentEdit.ListItemText('foo')
        listItem.attach(listItemText)
        expect(listItem.listItemText()).toBe listItemText


describe '`ContentEdit.ListItem.type()`', () ->

    it 'should return \'ListItem\'', () ->
        listItem = new ContentEdit.ListItem()
        expect(listItem.type()).toBe 'ListItem'


describe 'ContentEdit.ListItem.html()', () ->

    it 'should return a HTML string for the list element', () ->
        listItem = new ContentEdit.ListItem({'class': 'foo'})
        listItemText = new ContentEdit.ListItemText('bar')
        listItem.attach(listItemText)

        expect(listItem.html()).toBe '<li class="foo">\n' +
                "#{ ContentEdit.INDENT }bar\n" +
            '</li>'


describe 'ContentEdit.ListItem.indent()', () ->

    it 'should indent an item in a list by at most one level', () ->
        I = ContentEdit.INDENT

        # Build list
        domElement = document.createElement('ul')
        domElement.innerHTML = '''
            <li>One</li>
            <li>Two</li>
            <li>Three</li>
            '''
        list = ContentEdit.List.fromDOMElement(domElement)

        # Attempt to indent the first item
        list.children[0].indent()
        expect(list.html()).toBe("""
<ul>
#{ I }<li>
#{ I }#{ I }One
#{ I }</li>
#{ I }<li>
#{ I }#{ I }Two
#{ I }</li>
#{ I }<li>
#{ I }#{ I }Three
#{ I }</li>
</ul>
""")

        # Indent the 3rd item (indent of list item without children)
        list.children[2].indent()
        expect(list.html()).toBe("""
<ul>
#{ I }<li>
#{ I }#{ I }One
#{ I }</li>
#{ I }<li>
#{ I }#{ I }Two
#{ I }#{ I }<ul>
#{ I }#{ I }#{ I }<li>
#{ I }#{ I }#{ I }#{ I }Three
#{ I }#{ I }#{ I }</li>
#{ I }#{ I }</ul>
#{ I }</li>
</ul>
""")

        # Indent the 2nd item (indent of list item with children)
        list.children[1].indent()
        expect(list.html()).toBe("""
<ul>
#{ I }<li>
#{ I }#{ I }One
#{ I }#{ I }<ul>
#{ I }#{ I }#{ I }<li>
#{ I }#{ I }#{ I }#{ I }Two
#{ I }#{ I }#{ I }#{ I }<ul>
#{ I }#{ I }#{ I }#{ I }#{ I }<li>
#{ I }#{ I }#{ I }#{ I }#{ I }#{ I }Three
#{ I }#{ I }#{ I }#{ I }#{ I }</li>
#{ I }#{ I }#{ I }#{ I }</ul>
#{ I }#{ I }#{ I }</li>
#{ I }#{ I }</ul>
#{ I }</li>
</ul>
""")

    it 'should do nothing if the `indent` behavior is not allowed', () ->

        I = ContentEdit.INDENT

        # Build list
        domElement = document.createElement('ul')
        domElement.innerHTML = '''
            <li>One</li>
            <li>Two</li>
            <li>Three</li>
            '''
        list = ContentEdit.List.fromDOMElement(domElement)

        # Disallow indenting for the list item
        list.children[2].can('indent', false)

        # Attempt to indent the 3rd item (expect no change
        list.children[2].indent()
        expect(list.html()).toBe("""
<ul>
#{ I }<li>
#{ I }#{ I }One
#{ I }</li>
#{ I }<li>
#{ I }#{ I }Two
#{ I }</li>
#{ I }<li>
#{ I }#{ I }Three
#{ I }</li>
</ul>
""")


describe 'ContentEdit.ListItem.remove()', () ->

    it 'should remove an item from a list keeping integrity of the lists \
        structure', () ->
        I = ContentEdit.INDENT

        domElement = document.createElement('ul')
        domElement.innerHTML = '''
            <li>One</li>
            <li>Two</li>
            <li>
                Three
                <ul>
                    <li>Alpha</li>
                    <li>Beta</li>
                </ul>
            </li>
            '''
        list = ContentEdit.List.fromDOMElement(domElement)

        # Remove a sub-item with no child list from
        list.children[2].list().children[1].remove()
        expect(list.html()).toBe("""
<ul>
#{ I }<li>
#{ I }#{ I }One
#{ I }</li>
#{ I }<li>
#{ I }#{ I }Two
#{ I }</li>
#{ I }<li>
#{ I }#{ I }Three
#{ I }#{ I }<ul>
#{ I }#{ I }#{ I }<li>
#{ I }#{ I }#{ I }#{ I }Alpha
#{ I }#{ I }#{ I }</li>
#{ I }#{ I }</ul>
#{ I }</li>
</ul>
""")

        # Remove an item with a child list
        list.children[2].remove()
        expect(list.html()).toBe("""
<ul>
#{ I }<li>
#{ I }#{ I }One
#{ I }</li>
#{ I }<li>
#{ I }#{ I }Two
#{ I }</li>
#{ I }<li>
#{ I }#{ I }Alpha
#{ I }</li>
</ul>
""")

        # Remove an item with no child list
        list.children[0].remove()
        expect(list.html()).toBe("""
<ul>
#{ I }<li>
#{ I }#{ I }Two
#{ I }</li>
#{ I }<li>
#{ I }#{ I }Alpha
#{ I }</li>
</ul>
""")


describe 'ContentEdit.ListItem.unindent()', () ->

    it 'should indent an item in a list or remove it and convert to a text \
        element if it can\'t be unindented any further', () ->

        I = ContentEdit.INDENT

        domElement = document.createElement('ul')
        domElement.innerHTML = '''
            <li>One</li>
            <li>Two</li>
            <li>
                Three
                <ul>
                    <li>
                        Alpha
                        <ul>
                            <li>Beta</li>
                            <li>Gamma</li>
                        </ul>
                    </li>
                </ul>
            </li>
            '''
        list = ContentEdit.List.fromDOMElement(domElement)

        region = new ContentEdit.Region(document.createElement('div'))
        region.attach(list)

        # Sub-list item with siblings
        list.children[2].list().children[0].list().children[0].unindent()
        expect(region.html()).toBe("""
<ul>
#{ I }<li>
#{ I }#{ I }One
#{ I }</li>
#{ I }<li>
#{ I }#{ I }Two
#{ I }</li>
#{ I }<li>
#{ I }#{ I }Three
#{ I }#{ I }<ul>
#{ I }#{ I }#{ I }<li>
#{ I }#{ I }#{ I }#{ I }Alpha
#{ I }#{ I }#{ I }</li>
#{ I }#{ I }#{ I }<li>
#{ I }#{ I }#{ I }#{ I }Beta
#{ I }#{ I }#{ I }#{ I }<ul>
#{ I }#{ I }#{ I }#{ I }#{ I }<li>
#{ I }#{ I }#{ I }#{ I }#{ I }#{ I }Gamma
#{ I }#{ I }#{ I }#{ I }#{ I }</li>
#{ I }#{ I }#{ I }#{ I }</ul>
#{ I }#{ I }#{ I }</li>
#{ I }#{ I }</ul>
#{ I }</li>
</ul>
""")

        # Sub-list item
        list.children[2].list().children[1].list().children[0].unindent()
        expect(region.html()).toBe("""
<ul>
#{ I }<li>
#{ I }#{ I }One
#{ I }</li>
#{ I }<li>
#{ I }#{ I }Two
#{ I }</li>
#{ I }<li>
#{ I }#{ I }Three
#{ I }#{ I }<ul>
#{ I }#{ I }#{ I }<li>
#{ I }#{ I }#{ I }#{ I }Alpha
#{ I }#{ I }#{ I }</li>
#{ I }#{ I }#{ I }<li>
#{ I }#{ I }#{ I }#{ I }Beta
#{ I }#{ I }#{ I }</li>
#{ I }#{ I }#{ I }<li>
#{ I }#{ I }#{ I }#{ I }Gamma
#{ I }#{ I }#{ I }</li>
#{ I }#{ I }</ul>
#{ I }</li>
</ul>
""")

        # First top-level item item
        list.children[0].unindent()
        expect(region.html()).toBe("""
<p>
#{ I }One
</p>
<ul>
#{ I }<li>
#{ I }#{ I }Two
#{ I }</li>
#{ I }<li>
#{ I }#{ I }Three
#{ I }#{ I }<ul>
#{ I }#{ I }#{ I }<li>
#{ I }#{ I }#{ I }#{ I }Alpha
#{ I }#{ I }#{ I }</li>
#{ I }#{ I }#{ I }<li>
#{ I }#{ I }#{ I }#{ I }Beta
#{ I }#{ I }#{ I }</li>
#{ I }#{ I }#{ I }<li>
#{ I }#{ I }#{ I }#{ I }Gamma
#{ I }#{ I }#{ I }</li>
#{ I }#{ I }</ul>
#{ I }</li>
</ul>
""")

        # Last top-level item
        list.children[1].list().children[0].unindent()
        list.children[2].list().children[0].unindent()
        list.children[3].list().children[0].unindent()
        list.children[4].unindent()
        expect(region.html()).toBe("""
<p>
#{ I }One
</p>
<ul>
#{ I }<li>
#{ I }#{ I }Two
#{ I }</li>
#{ I }<li>
#{ I }#{ I }Three
#{ I }</li>
#{ I }<li>
#{ I }#{ I }Alpha
#{ I }</li>
#{ I }<li>
#{ I }#{ I }Beta
#{ I }</li>
</ul>
<p>
#{ I }Gamma
</p>
""")

        # Middle top-level item
        list.children[1].unindent()
        expect(region.html()).toBe("""
<p>
#{ I }One
</p>
<ul>
#{ I }<li>
#{ I }#{ I }Two
#{ I }</li>
</ul>
<p>
#{ I }Three
</p>
<ul>
#{ I }<li>
#{ I }#{ I }Alpha
#{ I }</li>
#{ I }<li>
#{ I }#{ I }Beta
#{ I }</li>
</ul>
<p>
#{ I }Gamma
</p>
""")

    it 'should do nothing if the `indent` behavior is not allowed', () ->

        I = ContentEdit.INDENT

        domElement = document.createElement('ul')
        domElement.innerHTML = '''
            <li>One</li>
            <li>Two</li>
            '''
        list = ContentEdit.List.fromDOMElement(domElement)

        # Disallow indent behaviour for the list item
        list.children[0].can('indent', false)

        region = new ContentEdit.Region(document.createElement('div'))
        region.attach(list)

        # Sub-list item with siblings
        list.children[0].unindent()
        expect(region.html()).toBe("""
<ul>
#{ I }<li>
#{ I }#{ I }One
#{ I }</li>
#{ I }<li>
#{ I }#{ I }Two
#{ I }</li>
</ul>
""")

describe '`ContentEdit.ListItem.fromDOMElement()`', () ->

    it 'should convert a <li> DOM element into an ListItem element', () ->
        I = ContentEdit.INDENT

        # No child list
        domLi = document.createElement('li')
        domLi.innerHTML = 'foo'
        li = ContentEdit.ListItem.fromDOMElement(domLi)
        expect(li.html()).toBe "<li>\n#{ I }foo\n</li>"

        # Child list
        domLi = document.createElement('li')
        domLi.innerHTML = '''
            foo
            <ul>
                <li>bar</li>
            </ul>
            '''
        li = ContentEdit.ListItem.fromDOMElement(domLi)
        expect(li.html()).toBe """
<li>
#{ I }foo
#{ I }<ul>
#{ I }#{ I }<li>
#{ I }#{ I }#{ I }bar
#{ I }#{ I }</li>
#{ I }</ul>
</li>
"""


# ListItemText

describe '`ContentEdit.ListItemText()`', () ->

    it 'should return an instance of ListItemText`', () ->
        listItemText = new ContentEdit.ListItemText('foo')
        expect(listItemText instanceof ContentEdit.ListItemText).toBe true


describe '`ContentEdit.ListItemText.cssTypeName()`', () ->

    it 'should return \'list-item-text\'', () ->
        listItemText = new ContentEdit.ListItemText('foo')
        expect(listItemText.cssTypeName()).toBe 'list-item-text'


describe '`ContentEdit.ListItemText.type()`', () ->

    it 'should return \'ListItemText\'', () ->
        listItemText = new ContentEdit.ListItemText()
        expect(listItemText.type()).toBe 'ListItemText'


describe '`ContentEdit.ListItemText.typeName()`', () ->

    it 'should return \'List item\'', () ->
        listItemText = new ContentEdit.ListItemText('foo')
        expect(listItemText.typeName()).toBe 'List item'


describe '`ContentEdit.ListItemText.blur()`', () ->

    root = ContentEdit.Root.get()
    region = null

    beforeEach ->
        document.getElementById('test').innerHTML = '''
<ul>
    <li>foo</li>
    <li>bar</li>
    <li>zee</li>
</ul>
        '''
        region = new ContentEdit.Region(document.getElementById('test'))
        region.children[0].children[1].listItemText().focus()

    afterEach ->
        for child in region.children.slice()
            region.detach(child)

    it 'should blur the list item text element', () ->
        listItemText = region.children[0].children[1].listItemText()
        listItemText.blur()
        expect(listItemText.isFocused()).toBe false

    it 'should remove the list item text element if it\'s just \
        whitespace', () ->
        listItemText = region.children[0].children[1].listItemText()
        listItemText.content = new HTMLString.String('')
        listItemText.blur()
        expect(listItemText.parent().parent()).toBe null

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
        listItemText = region.children[0].children[1].listItemText()
        listItemText.blur()
        expect(foo.handleFoo).toHaveBeenCalledWith(listItemText)

    it 'should not remove the list element if it\'s just whitespace but remove
        behaviour is disallowed for the parent list item', () ->

        listItem = region.children[0].children[1]

        # Disallow remove
        listItem.can('remove', false)

        listItemText = listItem.listItemText()
        listItemText.content = new HTMLString.String('')
        listItemText.blur()
        expect(listItemText.parent().parent()).not.toBe null


describe 'ContentEdit.Text.html()', () ->

    it 'should return a HTML string for the list item text element', () ->
        listItemText = new ContentEdit.ListItemText('bar <b>zee</b>')
        expect(listItemText.html()).toBe 'bar <b>zee</b>'


# Key events

describe '`ContentEdit.ListItemText` key events`', () ->

    ev = null
    list = null
    listItem = null
    listItemText = null
    region = null
    root = ContentEdit.Root.get()

    beforeEach ->
        ev = {preventDefault: () -> return}
        document.getElementById('test').innerHTML = '''
<ul>
    <li>foo</li>
    <li>bar</li>
    <li>zee</li>
</ul>
        '''
        region = new ContentEdit.Region(document.getElementById('test'))
        list = region.children[0]
        listItem = list.children[1]
        listItemText = listItem.listItemText()

    afterEach ->
        for child in region.children.slice()
            region.detach(child)

    it 'should support return splitting the element into 2', () ->
        listItemText.focus()
        new ContentSelect.Range(2, 2).select(listItemText.domElement())
        listItemText._keyReturn(ev)

        expect(listItemText.content.text()).toBe 'ba'
        expect(listItemText.nextContent().content.text()).toBe 'r'

    it 'should support using tab to indent', () ->
        spyOn(listItem, 'indent')

        listItemText.focus()
        listItemText._keyTab(ev)

        expect(listItem.indent).toHaveBeenCalled()

    it 'should support using shift-tab to unindent', () ->
        spyOn(listItem, 'unindent')

        ev.shiftKey = true
        listItemText.focus()
        listItemText._keyTab(ev)

        expect(listItem.unindent).toHaveBeenCalled()

    it 'should not split the element into 2 on return if spawn is
        disallowed', () ->

        # Disallow spawning of new elements
        listItemCount = list.children.length
        listItem.can('spawn', false)

        listItemText.focus()
        new ContentSelect.Range(2, 2).select(listItemText.domElement())
        listItemText._keyReturn(ev)

        expect(list.children.length).toBe listItemCount


# Droppers

describe '`ContentEdit.ListItemText` drop interactions`', () ->
    I = ContentEdit.INDENT
    listItemText = null
    region = null

    beforeEach ->
        domElement = document.createElement('div')
        domElement.innerHTML = '''
<ul>
    <li>foo</li>
    <li>bar</li>
</ul>
<p>zee</p>
        '''
        region = new ContentEdit.Region(domElement)
        listItemText = region.children[0].children[0].listItemText()

    it 'should support dropping on ListItemText', () ->
        otherListItemText = region.children[0].children[1].listItemText()

        # Check the initial order
        expect(listItemText.parent().nextSibling()).toBe(
            otherListItemText.parent()
            )

        # Check the order after dropping the element below
        listItemText.drop(otherListItemText, ['below', 'center'])
        expect(otherListItemText.parent().nextSibling()).toBe(
            listItemText.parent()
            )

        # Check the order after dropping the element above
        listItemText.drop(otherListItemText, ['above', 'center'])
        expect(listItemText.parent().nextSibling()).toBe(
            otherListItemText.parent()
            )

    it 'should support dropping on Text', () ->
        text = region.children[1]

        # Check the order after dropping the element below
        listItemText.drop(text, ['below', 'center'])
        expect(region.html()).toBe """
<ul>
#{ I }<li>
#{ I }#{ I }bar
#{ I }</li>
</ul>
<p>
#{ I }zee
</p>
<p>
#{ I }foo
</p>
"""

        # Check the order after dropping the element above
        listItemText = region.children[0].children[0].listItemText()
        listItemText.drop(text, ['above', 'center'])
        expect(region.html()).toBe """
<p>
#{ I }bar
</p>
<p>
#{ I }zee
</p>
<p>
#{ I }foo
</p>
"""

    it 'should support being dropped on by Text', () ->

        # Check the order after dropping the element below
        text = region.children[1]
        text.drop(listItemText, ['below', 'center'])
        expect(region.html()).toBe """
<ul>
#{ I }<li>
#{ I }#{ I }foo
#{ I }</li>
#{ I }<li>
#{ I }#{ I }zee
#{ I }</li>
#{ I }<li>
#{ I }#{ I }bar
#{ I }</li>
</ul>
"""

        # Check the order after dropping the element above
        text = new ContentEdit.Text('p', {}, 'umm')
        region.attach(text, 0)
        text.drop(listItemText, ['above', 'center'])
        expect(region.html()).toBe """
<ul>
#{ I }<li>
#{ I }#{ I }umm
#{ I }</li>
#{ I }<li>
#{ I }#{ I }foo
#{ I }</li>
#{ I }<li>
#{ I }#{ I }zee
#{ I }</li>
#{ I }<li>
#{ I }#{ I }bar
#{ I }</li>
</ul>
"""


# Mergers

describe '`ContentEdit.Text` merge interactions`', () ->

    I = ContentEdit.INDENT
    region = null

    beforeEach ->
        domElement = document.getElementById('test')
        domElement.innerHTML = '''
<p>foo</p>
<ul>
    <li>bar</li>
    <li>zee</li>
</ul>
<p>umm</p>
        '''
        region = new ContentEdit.Region(domElement)

    afterEach ->
        for child in region.children.slice()
            region.detach(child)

    it 'should support merging with ListItemText', () ->

        listItemTextA = region.children[1].children[0].listItemText()
        listItemTextB = region.children[1].children[1].listItemText()

        # Merge the text
        listItemTextA.merge(listItemTextB)
        expect(listItemTextA.html()).toBe 'barzee'

    it 'should support merging with Text', () ->

        text = region.children[2]
        listItemText = region.children[1].children[1].listItemText()

        # Merge the text
        listItemText.merge(text)
        expect(region.html()).toBe """
<p>
#{ I }foo
</p>
<ul>
#{ I }<li>
#{ I }#{ I }bar
#{ I }</li>
#{ I }<li>
#{ I }#{ I }zeeumm
#{ I }</li>
</ul>
"""

        text = region.children[0]
        listItemText = region.children[1].children[0].listItemText()
        text.merge(listItemText)
        expect(region.html()).toBe """
<p>
#{ I }foobar
</p>
<ul>
#{ I }<li>
#{ I }#{ I }zeeumm
#{ I }</li>
</ul>
"""
