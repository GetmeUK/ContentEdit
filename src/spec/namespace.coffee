# Namespace (namespace.coffee)

describe 'ContentEdit', () ->

    it 'should have correct default settings', () ->

        expect(ContentEdit.DEFAULT_MAX_ELEMENT_WIDTH).toBe 800
        expect(ContentEdit.DEFAULT_MIN_ELEMENT_WIDTH).toBe 80
        expect(ContentEdit.DRAG_HOLD_DURATION).toBe 500
        expect(ContentEdit.DROP_EDGE_SIZE).toBe 50
        expect(ContentEdit.HELPER_CHAR_LIMIT).toBe 250
        expect(ContentEdit.INDENT).toBe '    '
        expect(ContentEdit.LINE_ENDINGS).toBe '\n'
        expect(ContentEdit.LANGUAGE).toBe 'en'
        expect(ContentEdit.RESIZE_CORNER_SIZE).toBe 15
        expect(ContentEdit.TRIM_WHITESPACE).toBe true


describe 'ContentEdit._', () ->

    # Note: This covers testing the `addTranslations` method also

    it 'should return a translated string for the current language', () ->
        # Add translations for French
        ContentEdit.addTranslations('fr', {'hello': 'bonjour'})
        ContentEdit.addTranslations('de', {'hello': 'hallo'})

        # Check that the English translation is returned by default
        expect(ContentEdit._('hello')).toBe 'hello'

        # Check that the French translation is returned when the current
        # language is switched to 'fr'.
        ContentEdit.LANGUAGE = 'fr'
        expect(ContentEdit._('hello')).toBe 'bonjour'

        ContentEdit.LANGUAGE = 'de'
        expect(ContentEdit._('hello')).toBe 'hallo'

        # Check that a non translated string is returned as is
        expect(ContentEdit._('goodbye')).toBe 'goodbye'

        ContentEdit.LANGUAGE = 'en'


describe 'ContentEdit.addCSSClass()', () ->

    it 'should add a CSS class to a DOM element', () ->
        # Create a DOM element to test against
        domElement = document.createElement('div')

        # Check a single class
        ContentEdit.addCSSClass(domElement, 'foo')
        expect(domElement.getAttribute('class')).toBe 'foo'

        # Check multiple classes
        ContentEdit.addCSSClass(domElement, 'bar')
        expect(domElement.getAttribute('class')).toBe 'foo bar'


describe 'ContentEdit.attributesToString()', () ->

    it 'should convert a dictionary into a key="value" string', () ->
        attributes = {
            'id': 'foo',
            'class': 'bar'
            }
        string = ContentEdit.attributesToString(attributes)
        expect(string).toBe 'class="bar" id="foo"'


describe 'ContentEdit.removeCSSClass()', () ->

    it 'should remove a CSS class from a DOM element', () ->
        # Create a DOM element to test against
        domElement = document.createElement('div')
        ContentEdit.addCSSClass(domElement, 'foo')
        ContentEdit.addCSSClass(domElement, 'bar')

        # Remove a class
        ContentEdit.removeCSSClass(domElement, 'foo')
        expect(domElement.getAttribute('class')).toBe 'bar'

        # Remove another class (class should now be null)
        ContentEdit.removeCSSClass(domElement, 'bar')
        expect(domElement.getAttribute('class')).toBe null

    it 'should do nothing if the CSS class being removed is not set against the DOM element', () ->
        # Create a DOM element to test against
        domElement = document.createElement('div')
        ContentEdit.addCSSClass(domElement, 'foo')
        ContentEdit.addCSSClass(domElement, 'bar')

        # Remove a class that isn't defined against the DOM element (should have
        # no effect).
        ContentEdit.removeCSSClass(domElement, 'zee')
        expect(domElement.getAttribute('class')).toBe 'foo bar'