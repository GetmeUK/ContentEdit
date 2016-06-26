# Region

factory = new ContentEdit.Factory()

describe '`Region()`', () ->

    it 'should return an instance of Region`', () ->
        region = new factory.Region(document.createElement('div'))
        expect(region instanceof factory.Region).toBe true


describe '`Region.domElement()`', () ->

    it 'should return the DOM element the region was initialized with', () ->
        domElement = document.createElement('div')
        region = new factory.Region(domElement)
        expect(region.domElement()).toBe domElement


describe '`Region.isMounted()`', () ->

    it 'should always return true', () ->
        region = new factory.Region(document.createElement('div'))
        expect(region.isMounted()).toBe true


describe '`Region.type()`', () ->

    it 'should return \'Region\'', () ->
        region = new factory.Region(document.createElement('div'))
        expect(region.type()).toBe 'Region'


describe '`Region.html()`', () ->

    it 'should return a HTML string for the region', () ->
        region = new factory.Region(document.createElement('div'))

        # Add a set of elements to the region
        region.attach(new factory.Text('p', {}, 'one'))
        region.attach(new factory.Text('p', {}, 'two'))
        region.attach(new factory.Text('p', {}, 'three'))

        expect(region.html()).toBe(
            '<p>\n' +
            "#{ ContentEdit.INDENT }one\n" +
            '</p>\n' +
            '<p>\n' +
            "#{ ContentEdit.INDENT }two\n" +
            '</p>\n' +
            '<p>\n' +
            "#{ ContentEdit.INDENT }three\n" +
            '</p>'
            )
