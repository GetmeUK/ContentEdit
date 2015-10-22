window.ContentEdit =

    # Global settings

    # The default min/max constraints (in pixels) for element that can be
    # resized (`ContentEdit.ResizableElement`). The default values are used when
    # a min/max width has not been set using the custom attributes
    # `data-ce-max-width` and `data-ce-min-width`.
    DEFAULT_MAX_ELEMENT_WIDTH: 800
    DEFAULT_MIN_ELEMENT_WIDTH: 80

    # Some elements such as images are dragged simply by clicking on them and
    # moving the mouse. Others like text handle click events differently (for
    # example focusing the element so text can be edited), these element support
    # dragging behaviour when a user clicks and holds (without moving the
    # mouse). The duration of the hold is determined in milliseconds.
    DRAG_HOLD_DURATION: 500

    # The size (in pixels) of the edges used to switch horizontal placement
    # (e.g drop left/right) when dragging an element over another (for
    # example an image being dragged to the right edge of a text element).
    DROP_EDGE_SIZE: 50

    # The maximum number of characters to insert into a helper (for example the
    # helper tool that appears when dragging elements).
    HELPER_CHAR_LIMIT: 250

    # String to use for a single indent. For example if you wanted html to
    # return HTML indented using tabs instead of spaces you could set this to
    # `\t`.
    INDENT: '    '

    # The current language. Must be a a 2 digit ISO_639-1 code.
    LANGUAGE: 'en'

    # The size (in pixels) of the corner region used to detect a resize event
    # against an element. To resize an element (for example an image or video)
    # the user must click in a corner region of an element. The size is
    # automatically reduced for small elements where the corner size represents
    # more than a 1/4 of the total size.
    RESIZE_CORNER_SIZE: 15

    # Translation - the ContentEdit library provides basic translation support
    # which is used both by the library itself and the associated ContentTools
    # library.
    _translations: {}

    _: (s) ->
        # Look for a translation of the given string and return it, or if no
        # translation is found return the string unchanged.
        lang = ContentEdit.LANGUAGE
        if ContentEdit._translations[lang] and
                ContentEdit._translations[lang][s]

            return ContentEdit._translations[lang][s]
        return s

    addTranslations: (language, translations) ->
        # Add translations where `language` is a 2 digit ISO_639-1 code and
        # `translations` is an object containing a map of English strings and
        # their translated counterparts e.g {'Hello': 'Bonjour'}.
        ContentEdit._translations[language] = translations

    # Utility functions

    addCSSClass: (domElement, className) ->
        # Add a CSS class to a DOM element
        # Convert className to array - tvaliasek
        classNameArr = className.split(' ')
        # Add the class using classList if possible
        if domElement.classList
            for _class in classNameArr
              domElement.classList.add(_class)
            return

        # As there isn't universal support for the classList attribute, fallback
        # to a more manual process if necessary.
        classAttr = domElement.getAttribute('class')
        if classAttr
            # Convert class attribute to a list of class names
            classNames = (c for c in classAttr.split(' '))

            # If the class name isn't in the list add it
            # Do it for every class in classNameArr - tvaliasek
            for _class in classNameArr
              if classNames.indexOf(_class) == -1
                  domElement.setAttribute(
                      'class',
                      "#{ classAttr } #{ _class }"
                      )

        else
            domElement.setAttribute('class', classNameArr.join(' '))

    attributesToString: (attributes) ->
        # Convert a dictionary of attributes into a string (e.g key="value")
        unless attributes
            return ''

        # Sort the attributes alphabetically
        names = (name for name of attributes)
        names.sort()

        # Convert each key, value into an attribute string
        attributeStrings = []
        for name in names
            value = attributes[name]
            if value is ''
                attributeStrings.push(name)
            else
                attributeStrings.push("#{ name }=\"#{ value }\"")

        return attributeStrings.join(' ')

    removeCSSClass: (domElement, className) ->
        # Remove a CSS class from a DOM element
        # Convert className to array - tvaliasek
        classNameArr = className.split(' ')
        # Remove the class using classList if possible
        # Do it for every className in classNameArr
        if domElement.classList
            for _class in classNameArr
              domElement.classList.remove(_class)

            if domElement.classList.length == 0
                domElement.removeAttribute('class')

            return

        # As there isn't universal support for the classList attribute, fallback
        # to a more manual process if necessary.
        classAttr = domElement.getAttribute('class')

        if classAttr
            # Convert class attribute to a list of class names
            classNames = (c for c in classAttr.split(' '))

            # If the class name is in the list remove it
            # Do it for every className in classNameArr - tvaliasek
            for _class in classNameArr
              classNameIndex = classNames.indexOf(_class)
              if classNameIndex > -1
                  classNames.splice(classNameIndex, 1)

                if classNames.length
                    domElement.setAttribute(
                        'class',
                        classNames.join(' ')
                        )
                else
                    domElement.removeAttribute('class')

        else
            domElement.setAttribute('class', classNameArr.join(' '))


# HACK: Add constructor name property to IE9+, code based on the stackoverflow
# response http://stackoverflow.com/a/17056530
if not (class C).name
    Object.defineProperty Function.prototype, 'name', {
        get: () ->
            name = @toString().match(/^\s*function\s*(\S*)\s*\(/)[1]
            # For better performance only parse once, and then cache the
            # result through a new accessor for repeated access.
            Object.defineProperty(this, 'name', { value: name })
            return name
        }
