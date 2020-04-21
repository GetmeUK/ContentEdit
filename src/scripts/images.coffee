class ContentEdit.Image extends ContentEdit.ResizableElement

    # An editable image (e.g <image src="..." alt="foo" width="5" height="5">).
    # The `Image` element supports 2 special tags to allow the the size of the
    # image to be constrained (data-ce-min-width, data-ce--max-width).

    constructor: (attributes, a) ->
        super('img', attributes)

        # Optionally an <a> tag may be specified which will wrap the image. The
        # a tag should be specified as a dictionary of attributes.
        @a = if a then a else null

        # Set the aspect ratio for the image based on it's initial width/height
        size = @size()
        @_aspectRatio = size[1] / size[0]

        # Allow image elements to be nagivated to.
        @navigate = true

    # Read-only properties

    cssTypeName: () ->
        return 'image'

    type: () ->
        # Return the type of element (this should be the same as the class name)
        return 'Image'

    typeName: () ->
        # Return the name of the element type (e.g Image, List item)
        return 'Image'

    # Methods

    createDraggingDOMElement: () ->
        # Create a DOM element that visually aids the user in dragging the
        # element to a new location in the editiable tree structure.
        unless @isMounted()
            return

        helper = super()

        # Set the background image for the helper element
        helper.style.backgroundImage = "url('#{ @_attributes['src'] }')"

        return helper

    html: (indent='') ->
        # Return a HTML string for the node
        img = "#{ indent }<img#{ @_attributesToString() }>"
        if @a
            le = ContentEdit.LINE_ENDINGS
            attributes = ContentEdit.attributesToString(@a)
            attributes = "#{ attributes } data-ce-tag=\"img\""
            return "#{ indent }<a #{ attributes }>#{ le }" +
                "#{ ContentEdit.INDENT }#{ img }#{ le }" +
                "#{ indent }</a>"
        else
            return img

    mount: () ->
        # Mount the element on to the DOM

        # Create the DOM element to mount
        @_domElement = document.createElement('div')

        # Set the classes for the image, we combine classes from both the outer
        # link tag (if there is one) and image element.
        classes = ''
        if @a and @a['class']
            classes += ' ' + @a['class']

        if @_attributes['class']
            classes += ' ' + @_attributes['class']

        @_domElement.setAttribute('class', classes)

        # Set the background image for the
        style = if @_attributes['style'] then @_attributes['style'] else ''
        style += "background-image:url('#{ @_attributes['src'] }');"

        # Set the size using style
        if @_attributes['width']
            style += "width:#{ @_attributes['width'] }px;"

        if @_attributes['height']
            style += "height:#{ @_attributes['height'] }px;"

        @_domElement.setAttribute('style', style)

        super()

    unmount: () ->
        # Unmount the element from the DOM

        if @isFixed()
            # Revert the DOM element to an image
            wrapper = document.createElement('div')
            wrapper.innerHTML = @html()
            domElement = wrapper.querySelector('a, img')

            # Replace the current DOM element with the image
            @_domElement.parentNode.replaceChild(domElement, @_domElement)
            @_domElement = domElement

        super()

    # Class properties

    @droppers:
        'Image': ContentEdit.Element._dropBoth
        'PreText': ContentEdit.Element._dropBoth
        'Static': ContentEdit.Element._dropBoth
        'Text': ContentEdit.Element._dropBoth

    # List of allowed drop placements for the class, supported values are:
    @placements: ['above', 'below', 'left', 'right', 'center']

    # Class methods

    @fromDOMElement: (domElement) ->
        # Convert an element (DOM) to an element of this type

        # Is the image inside an <a> tag
        a = null
        if domElement.tagName.toLowerCase() == 'a'
            a = @getDOMElementAttributes(domElement)

            # Switch the DOM element to the <img> tag inside it
            childNodes = (c for c in domElement.childNodes)

            # Filter out non-elements
            for childNode in childNodes
                if childNode.nodeType == 1 \
                        and childNode.tagName.toLowerCase() == 'img'
                    domElement = childNode
                    break

            # If we didn't find an image create a blank image
            if domElement.tagName.toLowerCase() == 'a'
                domElement = document.createElement('img')

        # Convert the image
        attributes = @getDOMElementAttributes(domElement)

        # If the width and height of the image haven't been specified, we query
        # the DOM for these values.
        width = attributes['width']
        height = attributes['height']
        if attributes['width'] is undefined
            if attributes['height'] is undefined
                width = domElement.naturalWidth
            else
                width = domElement.clientWidth

        if attributes['height'] is undefined
            if attributes['width'] is undefined
                height = domElement.naturalHeight
            else
                height = domElement.clientHeight

        attributes['width'] = width
        attributes['height'] = height

        return new @(attributes, a)


# Register `ContentEdit.Image` the class with associated tag names
ContentEdit.TagNames.get().register(ContentEdit.Image, 'img')


class ContentEdit.ImageFixture extends ContentEdit.Element

    # Image fixtures provide a mechanism for adding images as fixtures.
    #
    # The structure of an image fixture is slightly different than you might
    # at first expect, rather than using an image element alone image fixtures
    # use a image element within a (typically) block level element, for
    # example:
    #
    # <div
    #    data-ce-tag="img-fixed"
    #    style="background-url: url('some-image.jpg');"
    #    >
    #    <img src="some-image.jpg" alt="Some image">
    # </div>
    #
    # This structure provides makes it easy to use CSS to set how the image
    # covers the fixture (typically the inner image element is hidden).

    constructor: (tagName, attributes, src) ->
        super(tagName, attributes)

        # The source of the image
        @_src = src

    # Read-only properties

    cssTypeName: () ->
        return 'image-fixture'

    type: () ->
        # Return the type of element (this should be the same as the class name)
        return 'ImageFixture'

    typeName: () ->
        # Return the name of the element type (e.g Image, List item)
        return 'ImageFixture'

    # Methods

    html: (indent='') ->
        # Return a HTML string for the node
        le = ContentEdit.LINE_ENDINGS
        attributes = @_attributesToString()
        alt = ''
        unless @_attributes['alt'] is undefined
            alt = "alt=\"#{ @_attributes['alt'] }\""
        img = "#{ indent }<img src=\"#{ @src() }\"#{ alt }>"
        return "#{ indent }<#{ @tagName() } #{ attributes }>#{ le }" +
            "#{ ContentEdit.INDENT }#{ img }#{ le }" +
            "#{ indent }</#{ @tagName() }>"

    mount: () ->
        # Mount the element on to the DOM

        # Create the DOM element to mount
        @_domElement = document.createElement(@tagName())

        # Set the attributes
        for name, value of @_attributes
            if name is 'alt' or name is 'style'
                continue
            @_domElement.setAttribute(name, value)

        # Set the classes for the image, we combine classes from both the outer
        # link tag (if there is one) and image element.
        classes = ''
        if @a and @a['class']
            classes += ' ' + @a['class']

        if @_attributes['class']
            classes += ' ' + @_attributes['class']

        @_domElement.setAttribute('class', classes)

        # Remove any existing background image from the style attribute
        style = if @_attributes['style'] then @_attributes['style'] else ''
        styleElm = document.createElement('div')
        styleElm.setAttribute('style', style.trim())
        styleElm.style.backgroundImage = null
        style = styleElm.getAttribute('style')

        # Set the background image for the element
        style = [style.trim(), "background-image:url('#{ @src() }');"].join(' ')

        @_domElement.setAttribute('style', style.trim())

        super()

    src: (src) ->
        # Get/Set the image src for the element

        # Get...
        if src == undefined
            return @_src

        # ...or set the image source
        @_src = src

        # Re-mount the element if mounted
        if @isMounted()
            @unmount()
            @mount()

        # Mark as modified
        @taint()

    unmount: () ->
        # Unmount the element from the DOM
        if @isFixed()
            # Build the DOM element
            wrapper = document.createElement('div')
            wrapper.innerHTML = @html()
            domElement = wrapper.firstElementChild

            # Replace the current DOM element
            @_domElement.parentNode.replaceChild(domElement, @_domElement)
            @_domElement = domElement
            @parent()._domElement = @_domElement

        else
            super()

    # Private methods

    _attributesToString: () ->
        # Special case handling of the background image within styles
        if @_attributes['style']
            # Remove any existing background image from the style attribute
            style = if @_attributes['style'] then @_attributes['style'] else ''
            styleElm = document.createElement('div')
            styleElm.setAttribute('style', style.trim())
            styleElm.style.backgroundImage = null
            style = styleElm.getAttribute('style')

            # Set the background image for the element
            style = [
                style.trim(),
                "background-image:url('#{ @src() }');"
            ].join(' ')
            @_attributes['style'] = style.trim()
        else
            @_attributes['style'] = "background-image:url('#{ @src() }');"

        # Build the table of attributes to compile into the string
        attributes = {}
        for k, v of @_attributes
            if k is 'alt'
                continue
            attributes[k] = v

        # Compile and return the string
        return ' ' + ContentEdit.attributesToString(attributes)

    # Class properties

    @droppers:
        'ImageFixture': ContentEdit.Element._dropVert
        'Image': ContentEdit.Element._dropVert
        'PreText': ContentEdit.Element._dropVert
        'Text': ContentEdit.Element._dropVert

    # Class methods

    @fromDOMElement: (domElement) ->
        # Convert an element (DOM) to an element of this type

        # Get the outer fixture attributes
        tagName = domElement.tagName
        attributes = @getDOMElementAttributes(domElement)

        # Get the image attributes
        src = ''
        alt = ''
        childNodes = (c for c in domElement.childNodes)
        for childNode in childNodes
            if childNode.nodeType == 1 \
                    and childNode.tagName.toLowerCase() == 'img'
                src = childNode.getAttribute('src') or ''
                alt = childNode.getAttribute('alt') or ''
                break

        attributes = @getDOMElementAttributes(domElement)
        attributes['alt'] = alt

        return new @(domElement.tagName, attributes, src)


# Register `ContentEdit.ImageFixture` the class with associated tag names
ContentEdit.TagNames.get().register(ContentEdit.ImageFixture, 'img-fixture')