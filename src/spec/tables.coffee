# Table

factory = new ContentEdit.Factory()

describe '`Table()`', () ->

    it 'should return an instance of Table`', () ->
        table = new factory.Table()
        expect(table instanceof factory.Table).toBe true


describe '`Table.cssTypeName()`', () ->

    it 'should return \'table\'', () ->
        table = new factory.Table()
        expect(table.cssTypeName()).toBe 'table'


describe '`Table.type()`', () ->

    it 'should return \'Table\'', () ->
        table = new factory.Table()
        expect(table.type()).toBe 'Table'


describe '`Table.typeName()`', () ->

    it 'should return \'table\'', () ->
        table = new factory.Table()
        expect(table.typeName()).toBe 'Table'


describe '`Table.firstSection()`', () ->

    it 'should return the first section in the table (their position as children
        is irrelevant, the order is thead, tbody, tfoot in that order \
        ', () ->
        table = new factory.Table()
        thead = new factory.TableSection('thead')
        tbody = new factory.TableSection('tbody')
        tfoot = new factory.TableSection('tfoot')

        # Return null if there are no sections
        expect(table.firstSection()).toBe null

        # Expect the order (thead, tbody, tfoot) to be honored no matter the
        # position as a child of the table.
        table.attach(tfoot)
        expect(table.firstSection()).toBe tfoot

        table.attach(tbody)
        expect(table.firstSection()).toBe tbody

        table.attach(thead)
        expect(table.firstSection()).toBe thead


describe '`Table.lastSection()`', () ->

    it 'should return the last section in the table (their position as children
        is irrelevant, the order is thead, tbody, tfoot in that order \
        ', () ->
        table = new factory.Table()
        thead = new factory.TableSection('thead')
        tbody = new factory.TableSection('tbody')
        tfoot = new factory.TableSection('tfoot')

        # Return null if there are no sections
        expect(table.lastSection()).toBe null

        # Expect the order (thead, tbody, tfoot) to be honored no matter the
        # position as a child of the table.
        table.attach(thead)
        expect(table.lastSection()).toBe thead

        table.attach(tbody)
        expect(table.lastSection()).toBe tbody

        table.attach(tfoot)
        expect(table.lastSection()).toBe tfoot


describe '`Table.thead()`', () ->

    it 'should return the `TableSection` (thead) for the `Table` if there is \
        one', () ->

        table = new factory.Table()
        expect(table.thead()).toBe null

        tableHead = new factory.TableSection('thead')
        table.attach(tableHead)
        expect(table.thead()).toBe tableHead


describe '`Table.tbody()`', () ->

    it 'should return the `TableSection` (tbody) for the `Table` if there is \
        one', () ->

        table = new factory.Table()
        expect(table.tbody()).toBe null

        tableBody = new factory.TableSection('tbody')
        table.attach(tableBody)
        expect(table.tbody()).toBe tableBody


describe '`Table.tfoot()`', () ->

    it 'should return the `TableSection` (tfoot) for the `Table` if there is \
        one', () ->

        table = new factory.Table()
        expect(table.tfoot()).toBe null

        tableFoot = new factory.TableSection('tfoot')
        table.attach(tableFoot)
        expect(table.tfoot()).toBe tableFoot


describe '`Table.fromDOMElement()`', () ->

    it 'should convert a <table> DOM element into a table element', () ->

        I = ContentEdit.INDENT

        # Strict rows
        domTable = document.createElement('table')
        domTable.innerHTML = '''
<tbody>
    <tr>
        <td>bar</td>
        <td>zee</td>
    </tr>
</tbody>
'''

        table = factory.Table.fromDOMElement(domTable)
        expect(table.html()).toBe """
<table>
#{ I }<tbody>
#{ I }#{ I }<tr>
#{ I }#{ I }#{ I }<td>
#{ I }#{ I }#{ I }#{ I }bar
#{ I }#{ I }#{ I }</td>
#{ I }#{ I }#{ I }<td>
#{ I }#{ I }#{ I }#{ I }zee
#{ I }#{ I }#{ I }</td>
#{ I }#{ I }</tr>
#{ I }</tbody>
</table>
"""

        # Lazy rows
        domTable = document.createElement('table')
        domTable.innerHTML = '''
<tr>
    <td>bar</td>
    <td>zee</td>
</tr>
'''

        table = factory.Table.fromDOMElement(domTable)
        expect(table.html()).toBe """
<table>
#{ I }<tbody>
#{ I }#{ I }<tr>
#{ I }#{ I }#{ I }<td>
#{ I }#{ I }#{ I }#{ I }bar
#{ I }#{ I }#{ I }</td>
#{ I }#{ I }#{ I }<td>
#{ I }#{ I }#{ I }#{ I }zee
#{ I }#{ I }#{ I }</td>
#{ I }#{ I }</tr>
#{ I }</tbody>
</table>
"""


# Droppers

describe '`Table` drop interactions`', () ->

    table = null
    region = null

    beforeEach ->
        region = new factory.Region(document.createElement('div'))
        table = new factory.Table()
        region.attach(table)

    it 'should support dropping on Image', () ->
        image = new factory.Image({'src': '/bar.jpg'})
        region.attach(image)

        # Check the initial order
        expect(table.nextSibling()).toBe image

        # Check the order after dropping the element below
        table.drop(image, ['below', 'center'])
        expect(image.nextSibling()).toBe table

        # Check the order after dropping the element above
        table.drop(image, ['above', 'center'])
        expect(table.nextSibling()).toBe image

    it 'should support being dropped on by Image', () ->
        image = new factory.Image({'src': '/bar.jpg'})
        region.attach(image, 0)

        # Check the initial order
        expect(image.nextSibling()).toBe table

        # Check the order and class above dropping the element left
        image.drop(table, ['above', 'left'])
        expect(image.hasCSSClass('align-left')).toBe true
        expect(image.nextSibling()).toBe table

        # Check the order and class above dropping the element right
        image.drop(table, ['above', 'right'])
        expect(image.hasCSSClass('align-left')).toBe false
        expect(image.hasCSSClass('align-right')).toBe true
        expect(image.nextSibling()).toBe table

        # Check the order after dropping the element below
        image.drop(table, ['below', 'center'])
        expect(image.hasCSSClass('align-left')).toBe false
        expect(image.hasCSSClass('align-right')).toBe false
        expect(table.nextSibling()).toBe image

        # Check the order after dropping the element above
        image.drop(table, ['above', 'center'])
        expect(image.nextSibling()).toBe table

    it 'should support dropping on List', () ->
        list = new factory.Image({'src': '/bar.jpg'})
        region.attach(list)

        # Check the initial order
        expect(table.nextSibling()).toBe list

        # Check the order after dropping the element below
        table.drop(list, ['below', 'center'])
        expect(list.nextSibling()).toBe table

        # Check the order after dropping the element above
        table.drop(list, ['above', 'center'])
        expect(table.nextSibling()).toBe list

    it 'should support being dropped on by List', () ->
        list = new factory.Text('p')
        region.attach(list, 0)

        # Check the initial order
        expect(list.nextSibling()).toBe table

        # Check the order after dropping the element below
        list.drop(table, ['below', 'center'])
        expect(table.nextSibling()).toBe list

        # Check the order after dropping the element above
        list.drop(table, ['above', 'center'])
        expect(list.nextSibling()).toBe table

    it 'should support dropping on PreText', () ->
        preText = new factory.PreText('pre', {}, '')
        region.attach(preText)

        # Check the initial order
        expect(table.nextSibling()).toBe preText

        # Check the order after dropping the element below
        table.drop(preText, ['below', 'center'])
        expect(preText.nextSibling()).toBe table

        # Check the order after dropping the element above
        table.drop(preText, ['above', 'center'])
        expect(table.nextSibling()).toBe preText

    it 'should support being dropped on by PreText', () ->
        preText = new factory.PreText('pre', {}, '')
        region.attach(preText, 0)

        # Check the initial order
        expect(preText.nextSibling()).toBe table

        # Check the order after dropping the element below
        preText.drop(table, ['below', 'center'])
        expect(table.nextSibling()).toBe preText

        # Check the order after dropping the element above
        preText.drop(table, ['above', 'center'])
        expect(preText.nextSibling()).toBe table

    it 'should support dropping on Static', () ->
        staticElm = factory.Static.fromDOMElement(
            document.createElement('div')
            )
        region.attach(staticElm)

        # Check the initial order
        expect(table.nextSibling()).toBe staticElm

        # Check the order after dropping the element below
        table.drop(staticElm, ['below', 'center'])
        expect(staticElm.nextSibling()).toBe table

        # Check the order after dropping the element above
        table.drop(staticElm, ['above', 'center'])
        expect(table.nextSibling()).toBe staticElm

    it 'should support being dropped on by `moveable` Static', () ->
        staticElm = new factory.Static('div', {'data-ce-moveable'}, 'foo')
        region.attach(staticElm, 0)

        # Check the initial order
        expect(staticElm.nextSibling()).toBe table

        # Check the order after dropping the element below
        staticElm.drop(table, ['below', 'center'])
        expect(table.nextSibling()).toBe staticElm

        # Check the order after dropping the element above
        staticElm.drop(table, ['above', 'center'])
        expect(staticElm.nextSibling()).toBe table

    it 'should support dropping on Table', () ->
        otherTable = new factory.Table()
        region.attach(otherTable)

        # Check the initial order
        expect(table.nextSibling()).toBe otherTable

        # Check the order after dropping the element below
        table.drop(otherTable, ['below', 'center'])
        expect(otherTable.nextSibling()).toBe table

        # Check the order after dropping the element above
        table.drop(otherTable, ['above', 'center'])
        expect(table.nextSibling()).toBe otherTable

    it 'should support dropping on Text', () ->
        text = new factory.Text('p')
        region.attach(text)

        # Check the initial order
        expect(table.nextSibling()).toBe text

        # Check the order after dropping the element below
        table.drop(text, ['below', 'center'])
        expect(text.nextSibling()).toBe table

        # Check the order after dropping the element above
        table.drop(text, ['above', 'center'])
        expect(table.nextSibling()).toBe text

    it 'should support being dropped on by Text', () ->
        text = new factory.Text('p')
        region.attach(text, 0)

        # Check the initial order
        expect(text.nextSibling()).toBe table

        # Check the order after dropping the element below
        text.drop(table, ['below', 'center'])
        expect(table.nextSibling()).toBe text

        # Check the order after dropping the element above
        text.drop(table, ['above', 'center'])
        expect(text.nextSibling()).toBe table

    it 'should support dropping on Video', () ->
        video = new factory.Video('iframe', {'src': '/foo.jpg'})
        region.attach(video)

        # Check the initial order
        expect(table.nextSibling()).toBe video

        # Check the order after dropping the element below
        table.drop(video, ['below', 'center'])
        expect(video.nextSibling()).toBe table

        # Check the order after dropping the element above
        table.drop(video, ['above', 'center'])
        expect(table.nextSibling()).toBe video

    it 'should support being dropped on by Video', () ->
        video = new factory.Video('iframe', {'src': '/foo.jpg'})
        region.attach(video, 0)

        # Check the initial order
        expect(video.nextSibling()).toBe table

        # Check the order and class above dropping the element left
        video.drop(table, ['above', 'left'])
        expect(video.hasCSSClass('align-left')).toBe true
        expect(video.nextSibling()).toBe table

        # Check the order and class above dropping the element right
        video.drop(table, ['above', 'right'])
        expect(video.hasCSSClass('align-left')).toBe false
        expect(video.hasCSSClass('align-right')).toBe true
        expect(video.nextSibling()).toBe table

        # Check the order after dropping the element below
        video.drop(table, ['below', 'center'])
        expect(video.hasCSSClass('align-left')).toBe false
        expect(video.hasCSSClass('align-right')).toBe false
        expect(table.nextSibling()).toBe video

        # Check the order after dropping the element above
        video.drop(table, ['above', 'center'])
        expect(video.nextSibling()).toBe table


# TableSection

describe '`TableSection()`', () ->

    it 'should return an instance of TableSection`', () ->
        tableSection = new factory.TableSection('tbody', {})
        expect(tableSection instanceof factory.TableSection).toBe true


describe '`TableSection.cssTypeName()`', () ->

    it 'should return \'table-section\'', () ->
        tableSection = new factory.TableSection('tbody', {})
        expect(tableSection.cssTypeName()).toBe 'table-section'


describe '`TableSection.type()`', () ->

    it 'should return \'TableSection\'', () ->
        tableSection = new factory.TableSection('tbody', {})
        expect(tableSection.type()).toBe 'TableSection'


describe '`TableSection.fromDOMElement()`', () ->

    it 'should convert a <tbody>, <tfoot> or <thead> DOM element into a table \
        section element', () ->

        I = ContentEdit.INDENT

        for sectionName in ['tbody', 'tfoot', 'thead']
            domTableSection = document.createElement(sectionName)
            domTableSection.innerHTML = '''
<tr>
    <td>foo</td>
    <td>bar</td>
</tr>
'''

            tableSection = factory.TableSection.fromDOMElement(
                domTableSection
                )
            expect(tableSection.html()).toBe """
<#{ sectionName }>
#{ I }<tr>
#{ I }#{ I }<td>
#{ I }#{ I }#{ I }foo
#{ I }#{ I }</td>
#{ I }#{ I }<td>
#{ I }#{ I }#{ I }bar
#{ I }#{ I }</td>
#{ I }</tr>
</#{ sectionName }>
"""


# TableRow

describe '`TableRow()`', () ->

    it 'should return an instance of TableRow`', () ->
        tableRow = new factory.TableRow()
        expect(tableRow instanceof factory.TableRow).toBe true


describe '`TableRow.cssTypeName()`', () ->

    it 'should return \'table-row\'', () ->
        tableRow = new factory.TableRow()
        expect(tableRow.cssTypeName()).toBe 'table-row'


describe '`TableRow.isEmpty()`', () ->

    it 'should return true if the table row is empty', () ->

        # tr
        domTableRow = document.createElement('tr')
        domTableRow.innerHTML = '<td></td><td></td>'
        tableRow = factory.TableRow.fromDOMElement(domTableRow)

        expect(tableRow.isEmpty()).toBe true

    it 'should return true false the table contains content', () ->

        # tr
        domTableRow = document.createElement('tr')
        domTableRow.innerHTML = '<td>foo</td><td></td>'
        tableRow = factory.TableRow.fromDOMElement(domTableRow)

        expect(tableRow.isEmpty()).toBe false


describe '`TableRow.type()`', () ->

    it 'should return \'TableRow\'', () ->
        tableRow = new factory.TableRow()
        expect(tableRow.type()).toBe 'TableRow'


describe '`TableRow.typeName()`', () ->

    it 'should return \'Table row\'', () ->
        tableRow = new factory.TableRow()
        expect(tableRow.typeName()).toBe 'Table row'


describe '`TableRow.fromDOMElement()`', () ->

    it 'should convert a <tr> DOM element into a table row element', () ->

        I = ContentEdit.INDENT

        # tr
        domTableRow = document.createElement('tr')
        domTableRow.innerHTML = '''
<td>foo</td>
<td>bar</td>
'''

        tableRow = factory.TableRow.fromDOMElement(domTableRow)
        expect(tableRow.html()).toBe """
<tr>
#{ I }<td>
#{ I }#{ I }foo
#{ I }</td>
#{ I }<td>
#{ I }#{ I }bar
#{ I }</td>
</tr>
"""

describe '`TableRow` key events`', () ->

    ev = {preventDefault: () -> return}
    emptyTableRow = null
    region = null
    tableRow = null

    beforeEach ->
        domElement = document.createElement('div')
        document.body.appendChild(domElement)
        region = new factory.Region(domElement)

        domTable = document.createElement('table')
        domTable.innerHTML = '''<tbody>
            <tr><td></td><td>foo</td></tr>
            <tr><td></td><td></td></tr>
            </tbody>'''
        table = factory.Table.fromDOMElement(domTable)
        tableRow = table.children[0].children[0]
        emptyTableRow = table.children[0].children[1]
        region.attach(table)

    afterEach ->
        for child in region.children.slice()
            region.detach(child)
        document.body.removeChild(region.domElement())

    it 'should support delete removing empty rows', () ->
        # Remove empty rows
        text = emptyTableRow.children[1].tableCellText()
        text.focus()
        text._keyDelete(ev)

        expect(emptyTableRow.parent()).toBe null

        # Retain populated rows
        parent = tableRow.parent()
        text = tableRow.children[1].tableCellText()
        text.focus()
        text._keyDelete(ev)

        expect(parent).toBe tableRow.parent()

    it 'should support backspace in first cell removing empty rows', () ->
        # Remove empty rows
        text = emptyTableRow.children[0].tableCellText()
        text.focus()
        text._keyBack(ev)

        expect(emptyTableRow.parent()).toBe null

        # Retain populated rows
        parent = tableRow.parent()
        text = tableRow.children[0].tableCellText()
        text.focus()
        text._keyBack(ev)

        expect(parent).toBe tableRow.parent()

    it 'should not allow a row to be deleted with backspace or delete if remove
        behaviour is disallowed', () ->

        # Disallow the removal of the table row
        emptyTableRow.can('remove', false)

        # Attempt to delete using the backspace key
        text = emptyTableRow.children[0].tableCellText()
        text.focus()
        text._keyBack(ev)

        expect(emptyTableRow.parent()).not.toBe null


# Droppers

describe '`TableRow` drop interactions`', () ->

    region = null
    table = null

    beforeEach ->
        region = new factory.Region(document.createElement('div'))
        domTable = document.createElement('table')
        domTable.innerHTML = '''
<tbody>
    <tr>
        <td>foo</td>
    </tr>
    <tr>
        <td>bar</td>
    </tr>
    <tr>
        <td>zee</td>
    </tr>
    <tr>
        <td>umm</td>
    </tr>
</tbody>
'''
        table = factory.Table.fromDOMElement(domTable)
        region.attach(table)

    it 'should support dropping on TableRow', () ->
        tableRowA = table.tbody().children[1]
        tableRowB = table.tbody().children[2]

        # Check the initial order
        expect(tableRowA.nextSibling()).toBe tableRowB

        # Check the order after dropping the element after
        tableRowA.drop(tableRowB, ['below', 'center'])
        expect(tableRowB.nextSibling()).toBe tableRowA

        # Check the order after dropping the element before
        tableRowA.drop(tableRowB, ['above', 'center'])
        expect(tableRowA.nextSibling()).toBe tableRowB


# TableCell

describe '`TableCell()`', () ->

    it 'should return an instance of `TableCell`', () ->
        tableCell = new factory.TableCell('td', {})
        expect(tableCell instanceof factory.TableCell).toBe true


describe '`TableCell.cssTypeName()`', () ->

    it 'should return \'table-cell\'', () ->
        tableCell = new factory.TableCell('td', {})
        expect(tableCell.cssTypeName()).toBe 'table-cell'


describe '`TableCell.tableCellText()`', () ->

    it 'should return any associated TableCellText element, or null if there
        isn\'t one', () ->

        # Build a table cell with a child text node
        tableCell = new factory.TableCell('td')
        expect(tableCell.tableCellText()).toBe null

        tableCellText = new factory.TableCellText('foo')
        tableCell.attach(tableCellText)
        expect(tableCell.tableCellText()).toBe tableCellText


describe '`TableCell.type()`', () ->

    it 'should return \'table-cell\'', () ->
        tableCell = new factory.TableCell('td', {})
        expect(tableCell.type()).toBe 'TableCell'


describe '`TableCell.html()`', () ->

    it 'should return a HTML string for the table cell element', () ->
        tableCell = new factory.TableCell('td', {'class': 'foo'})
        tableCellText = new factory.TableCellText('bar')
        tableCell.attach(tableCellText)

        expect(tableCell.html()).toBe '<td class="foo">\n' +
                "#{ ContentEdit.INDENT }bar\n" +
            '</td>'


describe '`TableCell.fromDOMElement()`', () ->

    it 'should convert a <td> or <th> DOM element into a table cell \
        element', () ->

        I = ContentEdit.INDENT

        # td
        domTableCell= document.createElement('td')
        domTableCell.innerHTML = 'foo'

        tableCell = factory.TableCell.fromDOMElement(domTableCell)
        expect(tableCell.html()).toBe """
<td>
#{ I }foo
</td>
"""

        # th
        domTableCell= document.createElement('th')
        domTableCell.innerHTML = 'bar'

        tableCell = factory.TableCell.fromDOMElement(domTableCell)
        expect(tableCell.html()).toBe """
<th>
#{ I }bar
</th>
"""


# TableCellText

describe '`TableCellText()`', () ->

    it 'should return an instance of TableCellText', () ->
        tableCellText = new factory.TableCellText('foo')
        expect(tableCellText instanceof factory.TableCellText).toBe true


describe '`TableCellText.cssTypeName()`', () ->

    it 'should return \'table-cell-text\'', () ->
        tableCellText = new factory.TableCellText('foo')
        expect(tableCellText.cssTypeName()).toBe 'table-cell-text'


describe '`TableCellText.type()`', () ->

    it 'should return \'TableCellText\'', () ->
        tableCellText = new factory.TableCellText('foo')
        expect(tableCellText.type()).toBe 'TableCellText'


describe 'TableCellText.blur()', () ->

    region = null
    table = null
    tableCell = null
    tableCellText = null

    beforeEach ->
        # Mount a table element to a region
        domTable = document.createElement('table')
        domTable.innerHTML = '''
<tbody>
    <tr>
        <td>bar</td>
        <td>zee</td>
    </tr>
</tbody>
'''

        table = factory.Table.fromDOMElement(domTable)
        region = new factory.Region(document.getElementById('test'))
        region.attach(table)
        tableCell = table.tbody().children[0].children[0]
        tableCellText = tableCell.tableCellText()
        tableCellText.focus()

    afterEach ->
        region.detach(table)

    it 'should blur the text element', () ->
        tableCellText.blur()
        expect(tableCellText.isFocused()).toBe false

    it 'should not remove the table cell text element if it\'s just \
        whitespace', () ->

        parent = tableCellText.parent()
        tableCellText.content = new HTMLString.String('')
        tableCellText.blur()
        expect(tableCellText.parent()).toBe parent

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
        tableCellText.blur()
        expect(foo.handleFoo).toHaveBeenCalledWith(tableCellText)


describe 'ContentEdit.TableCellText.html()', () ->

    it 'should return a HTML string for the table cell text element', () ->
        tableCellText = new factory.TableCellText('bar <b>zee</b>')
        expect(tableCellText.html()).toBe 'bar <b>zee</b>'


# Key events

describe '`TableCellText` key events`', () ->

    INDENT = ContentEdit.INDENT
    ev = {preventDefault: () -> return}
    region = null
    table = null
    tbody = null

    beforeEach ->
        # Mount a text element to a region
        document.getElementById('test').innerHTML = '''
<p>foo</p>
<table>
    <tbody>
        <tr>
            <td>foo</td>
            <td>bar</td>
        </tr>
        <tr>
            <td>zee</td>
            <td>umm</td>
        </tr>
    </tbody>
</table>
<p>bar</p>
'''

        region = new factory.Region(document.getElementById('test'))
        table = region.children[1]
        tbody = table.tbody()

    afterEach ->
        for child in region.children.slice()
            region.detach(child)

    it 'should support down arrow nav to table cell below or next content \
        element if we\'re in the last row', () ->

        # Next cell down
        tableCellText = tbody.children[0].children[0].tableCellText()
        tableCellText.focus()
        new ContentSelect.Range(3, 3).select(tableCellText.domElement())
        tableCellText._keyDown(ev)

        otherTableCellText = tbody.children[1].children[0].tableCellText()
        expect(factory.root.focused()).toBe otherTableCellText

        # Next content element
        new ContentSelect.Range(3, 3).select(otherTableCellText.domElement())
        factory.root.focused()._keyDown(ev)
        expect(factory.root.focused()).toBe region.children[2]

    it 'should support up arrow nav to table cell below or previous content \
        element if we\'re in the first row', () ->

        # Previous cell up
        tableCellText = tbody.children[1].children[0].tableCellText()
        tableCellText.focus()
        new ContentSelect.Range(0, 0).select(tableCellText.domElement())
        tableCellText._keyUp(ev)

        otherTableCellText = tbody.children[0].children[0].tableCellText()
        expect(factory.root.focused()).toBe otherTableCellText

        # Previous content element
        factory.root.focused()._keyUp(ev)
        expect(factory.root.focused()).toBe region.children[0]

    it 'should support return nav to next content element', () ->
        tableCellText = tbody.children[0].children[0].tableCellText()
        tableCellText.focus()
        new ContentSelect.Range(3, 3).select(tableCellText.domElement())
        tableCellText._keyReturn(ev)

        otherTableCellText = tbody.children[0].children[1].tableCellText()
        expect(factory.root.focused()).toBe otherTableCellText

    it 'should support using tab to nav to next table cell', () ->
        tableCellText = tbody.children[0].children[0].tableCellText()
        tableCellText.focus()
        new ContentSelect.Range(3, 3).select(tableCellText.domElement())
        tableCellText._keyTab(ev)

        otherTableCellText = tbody.children[0].children[1].tableCellText()
        expect(factory.root.focused()).toBe otherTableCellText

    it 'should support tab creating a new body row if last table cell in last \
        row of the table body focused', () ->

        rows = tbody.children.length
        tableCellText = tbody.children[1].children[1].tableCellText()
        tableCellText.focus()
        new ContentSelect.Range(3, 3).select(tableCellText.domElement())
        tableCellText._keyTab(ev)

        expect(tbody.children.length).toBe rows + 1
        otherTableCellText = tbody.children[rows].children[0].tableCellText()
        expect(factory.root.focused()).toBe otherTableCellText

    it 'should support using shift-tab to nav to previous table cell', () ->
        tableCellText = tbody.children[1].children[0].tableCellText()
        tableCellText.focus()
        new ContentSelect.Range(3, 3).select(tableCellText.domElement())

        ev.shiftKey = true
        tableCellText._keyTab(ev)

        otherTableCellText = tbody.children[0].children[1].tableCellText()
        expect(factory.root.focused()).toBe otherTableCellText

    it 'should not create an new body row on tab if spawn is disallowed', () ->

        rows = tbody.children.length
        tableCell = tbody.children[1].children[1]

        # Disallow spawning of new rows
        tableCell.can('spawn', false)

        tableCellText = tableCell.tableCellText()
        tableCellText.focus()
        new ContentSelect.Range(3, 3).select(tableCellText.domElement())
        tableCellText._keyTab(ev)

        expect(tbody.children.length).toBe rows
