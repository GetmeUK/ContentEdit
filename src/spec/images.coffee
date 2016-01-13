# Image

describe '`ContentEdit.Image()`', () ->

    it 'should return an instance of Image`', () ->

        # Wihtout a link
        image = new ContentEdit.Image({'src': '/foo.jpg'})
        expect(image instanceof ContentEdit.Image).toBe true

        # With a link
        image = new ContentEdit.Image({'src': '/foo.jpg'}, {'href': 'bar'})
        expect(image instanceof ContentEdit.Image).toBe true


describe '`ContentEdit.Image.cssTypeName()`', () ->

    it 'should return \'image\'', () ->
        image = new ContentEdit.Image({'src': '/foo.jpg'})
        expect(image.cssTypeName()).toBe 'image'


describe '`ContentEdit.Image.type()`', () ->

    it 'should return \'Image\'', () ->
        image = new ContentEdit.Image({'src': '/foo.jpg'})
        expect(image.type()).toBe 'Image'


describe '`ContentEdit.Image.typeName()`', () ->

    it 'should return \'Image\'', () ->
        image = new ContentEdit.Image({'src': '/foo.jpg'})
        expect(image.typeName()).toBe 'Image'


describe '`ContentEdit.Image.createDraggingDOMElement()`', () ->

    it 'should create a helper DOM element', () ->
        # Mount an image to a region
        image = new ContentEdit.Image({'src': 'http://getme.co.uk/foo.jpg'})
        region = new ContentEdit.Region(document.createElement('div'))
        region.attach(image)

        # Get the helper DOM element
        helper = image.createDraggingDOMElement()

        expect(helper).not.toBe null
        expect(helper.tagName.toLowerCase()).toBe 'div'
        expect(
            helper.style.backgroundImage.replace(/"/g, '')
            ).toBe 'url(http://getme.co.uk/foo.jpg)'


describe '`ContentEdit.Image.html()`', () ->

    it 'should return a HTML string for the image', () ->

        # Without a link
        image = new ContentEdit.Image({'src': '/foo.jpg'})
        expect(image.html()).toBe '<img src="/foo.jpg">'

        # With a link
        image = new ContentEdit.Image({'src': '/foo.jpg'}, {'href': 'bar'})
        expect(image.html()).toBe(
            '<a href="bar" data-ce-tag="img">\n' +
                "#{ ContentEdit.INDENT }<img src=\"/foo.jpg\">\n" +
            '</a>'
            )

describe '`ContentEdit.Image.mount()`', () ->

    imageA = null
    imageB = null
    region = null

    beforeEach ->
        imageA = new ContentEdit.Image({'src': '/foo.jpg'})
        imageB = new ContentEdit.Image({'src': '/foo.jpg'}, {'href': 'bar'})

        # Mount the images
        region = new ContentEdit.Region(document.createElement('div'))
        region.attach(imageA)
        region.attach(imageB)
        imageA.unmount()
        imageB.unmount()

    it 'should mount the image to the DOM', () ->
        imageA.mount()
        imageB.mount()
        expect(imageA.isMounted()).toBe true
        expect(imageB.isMounted()).toBe true

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

        # Mount the image
        imageA.mount()
        expect(foo.handleFoo).toHaveBeenCalledWith(imageA)


describe '`ContentEdit.Image.fromDOMElement()`', () ->

    it 'should convert a <img> DOM element into an image element', () ->
        # Create <img> DOM element
        domImg = document.createElement('img')
        domImg.setAttribute('src', '/foo.jpg')
        domImg.setAttribute('width', '400')
        domImg.setAttribute('height', '300')

        # Convert the DOM element into an image element
        img = ContentEdit.Image.fromDOMElement(domImg)

        expect(img.html()).toBe '<img height="300" src="/foo.jpg" width="400">'

    it 'should read the natural width of the image if not supplied as an
        attribute', () ->

        # Create <img> DOM element (with inline source so we can test querying
        # the size of the image, inline images are loaded as soon as the source
        # is set).
        domImg = document.createElement('img')
        domImg.setAttribute(
            'src',
            'data:image/gif;' +
            'base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw=='
            )

        # Convert the DOM element into an image element
        img = ContentEdit.Image.fromDOMElement(domImg)

        expect(img.size()).toEqual [1, 1]

    it 'should convert a wrapped <a><img></a> DOM element into an image \
        element', () ->

        # Create <a> DOM element
        domA = document.createElement('a')
        domA.setAttribute('href', 'test')

        # Create <img> DOM element
        domImg = document.createElement('img')
        domImg.setAttribute('src', '/foo.jpg')
        domImg.setAttribute('width', '400')
        domImg.setAttribute('height', '300')
        domA.appendChild(domImg)

        # Convert the DOM element into an image element
        img = ContentEdit.Image.fromDOMElement(domA)

        expect(img.html()).toBe(
            '<a href="test" data-ce-tag="img">\n' +
                "#{ ContentEdit.INDENT }" +
                '<img height="300" src="/foo.jpg" width="400">\n' +
            '</a>'
            )


# Droppers

describe '`ContentEdit.Image` drop interactions', () ->

    image = null
    region = null

    beforeEach ->
        region = new ContentEdit.Region(document.createElement('div'))
        image = new ContentEdit.Image({'src': '/foo.jpg'})
        region.attach(image)

    it 'should support dropping on Image', () ->
        otherImage = new ContentEdit.Image({'src': '/bar.jpg'})
        region.attach(otherImage)

        # Check the initial order
        expect(image.nextSibling()).toBe otherImage

        # Check the order and class above dropping the element left
        image.drop(otherImage, ['above', 'left'])
        expect(image.hasCSSClass('align-left')).toBe true
        expect(image.nextSibling()).toBe otherImage

        # Check the order and class above dropping the element right
        image.drop(otherImage, ['above', 'right'])
        expect(image.hasCSSClass('align-left')).toBe false
        expect(image.hasCSSClass('align-right')).toBe true
        expect(image.nextSibling()).toBe otherImage

        # Check the order after dropping the element below
        image.drop(otherImage, ['below', 'center'])
        expect(image.hasCSSClass('align-left')).toBe false
        expect(image.hasCSSClass('align-right')).toBe false
        expect(otherImage.nextSibling()).toBe image

        # Check the order after dropping the element above
        image.drop(otherImage, ['above', 'center'])
        expect(image.nextSibling()).toBe otherImage

    it 'should support dropping on PreText', () ->
        preText = new ContentEdit.PreText('pre', {}, '')
        region.attach(preText)

        # Check the initial order
        expect(image.nextSibling()).toBe preText

        # Check the order and class above dropping the element left
        image.drop(preText, ['above', 'left'])
        expect(image.hasCSSClass('align-left')).toBe true
        expect(image.nextSibling()).toBe preText

        # Check the order and class above dropping the element right
        image.drop(preText, ['above', 'right'])
        expect(image.hasCSSClass('align-left')).toBe false
        expect(image.hasCSSClass('align-right')).toBe true
        expect(image.nextSibling()).toBe preText

        # Check the order after dropping the element below
        image.drop(preText, ['below', 'center'])
        expect(image.hasCSSClass('align-left')).toBe false
        expect(image.hasCSSClass('align-right')).toBe false
        expect(preText.nextSibling()).toBe image

        # Check the order after dropping the element above
        image.drop(preText, ['above', 'center'])
        expect(image.nextSibling()).toBe preText

    it 'should support being dropped on by PreText', () ->
        preText = new ContentEdit.PreText('pre', {}, '')
        region.attach(preText, 0)

        # Check the initial order
        expect(preText.nextSibling()).toBe image

        # Check the order after dropping the element below
        preText.drop(image, ['below', 'center'])
        expect(image.nextSibling()).toBe preText

        # Check the order after dropping the element above
        preText.drop(image, ['above', 'center'])
        expect(preText.nextSibling()).toBe image

    it 'should support dropping on Static', () ->
        staticElm = ContentEdit.Static.fromDOMElement(
            document.createElement('div')
            )
        region.attach(staticElm)

        # Check the initial order
        expect(image.nextSibling()).toBe staticElm

        # Check the order and class above dropping the element left
        image.drop(staticElm, ['above', 'left'])
        expect(image.hasCSSClass('align-left')).toBe true
        expect(image.nextSibling()).toBe staticElm

        # Check the order and class above dropping the element right
        image.drop(staticElm, ['above', 'right'])
        expect(image.hasCSSClass('align-left')).toBe false
        expect(image.hasCSSClass('align-right')).toBe true
        expect(image.nextSibling()).toBe staticElm

        # Check the order after dropping the element below
        image.drop(staticElm, ['below', 'center'])
        expect(image.hasCSSClass('align-left')).toBe false
        expect(image.hasCSSClass('align-right')).toBe false
        expect(staticElm.nextSibling()).toBe image

        # Check the order after dropping the element above
        image.drop(staticElm, ['above', 'center'])
        expect(image.nextSibling()).toBe staticElm

    it 'should support being dropped on by `moveable` Static', () ->
        staticElm = new ContentEdit.Static('div', {'data-ce-moveable'}, 'foo')
        region.attach(staticElm, 0)

        # Check the initial order
        expect(staticElm.nextSibling()).toBe image

        # Check the order after dropping the element below
        staticElm.drop(image, ['below', 'center'])
        expect(image.nextSibling()).toBe staticElm

        # Check the order after dropping the element above
        staticElm.drop(image, ['above', 'center'])
        expect(staticElm.nextSibling()).toBe image

    it 'should support dropping on Text', () ->
        text = new ContentEdit.Text('p')
        region.attach(text)

        # Check the initial order
        expect(image.nextSibling()).toBe text

        # Check the order and class above dropping the element left
        image.drop(text, ['above', 'left'])
        expect(image.hasCSSClass('align-left')).toBe true
        expect(image.nextSibling()).toBe text

        # Check the order and class above dropping the element right
        image.drop(text, ['above', 'right'])
        expect(image.hasCSSClass('align-left')).toBe false
        expect(image.hasCSSClass('align-right')).toBe true
        expect(image.nextSibling()).toBe text

        # Check the order after dropping the element below
        image.drop(text, ['below', 'center'])
        expect(image.hasCSSClass('align-left')).toBe false
        expect(image.hasCSSClass('align-right')).toBe false
        expect(text.nextSibling()).toBe image

        # Check the order after dropping the element above
        image.drop(text, ['above', 'center'])
        expect(image.nextSibling()).toBe text

    it 'should support being dropped on by Text', () ->
        text = new ContentEdit.Text('p')
        region.attach(text, 0)

        # Check the initial order
        expect(text.nextSibling()).toBe image

        # Check the order after dropping the element below
        text.drop(image, ['below', 'center'])
        expect(image.nextSibling()).toBe text

        # Check the order after dropping the element above
        text.drop(image, ['above', 'center'])
        expect(text.nextSibling()).toBe image
