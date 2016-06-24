#Factory

Factory = ContentEdit.Factory
factory = new Factory()

describe 'ContentEdit.Factory', ->

    it 'should be instance of Factory', ->
        expect(factory instanceof Factory).toBe true

    it 'instance should modify classes', ->
        expect(factory.Root is Factory.class('Root')).toBe false
        expect(factory.classByTag('p') is Factory.classByTag('p')).toBe false

    it 'modified classes must have link to factory in static parameter and in instance parameter', ->
        expect(factory.Node._factory is factory).toBe true, ->
        node = new factory.Node()
        expect(node._factory is factory).toBe true

    it 'origin classes must haven\'t link to factory', ->
        expect(Factory.class('Node')._factory is undefined).toBe true
        node = new (Factory.class('Node'))()
        expect(node._factory is undefined).toBe true

    it 'should initialize and store Root instance', ->
        Root = Factory.class('Root')
        expect(factory.root instanceof Root).toBe true
        expect(factory.root instanceof factory.Root).toBe false
