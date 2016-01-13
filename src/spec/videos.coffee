# Video

describe '`ContentEdit.Video()`', () ->

    it 'should return an instance of Video`', () ->
        video = new ContentEdit.Video('video', {}, [])
        expect(video instanceof ContentEdit.Video).toBe true


describe '`ContentEdit.Video.cssTypeName()`', () ->

    it 'should return \'video\'', () ->
        video = new ContentEdit.Video('video', {}, [])
        expect(video.cssTypeName()).toBe 'video'


describe '`ContentEdit.Video.type()`', () ->

    it 'should return \'video\'', () ->
        video = new ContentEdit.Video('video', {}, [])
        expect(video.type()).toBe 'Video'


describe '`ContentEdit.Video.typeName()`', () ->

    it 'should return \'video\'', () ->
        video = new ContentEdit.Video('video', {}, [])
        expect(video.typeName()).toBe 'Video'


describe '`ContentEdit.Video.createDraggingDOMElement()`', () ->

    region = null
    beforeEach ->
        region = new ContentEdit.Region(document.createElement('div'))

    it 'should create a helper DOM element using the sources list for <video> \
        elements', () ->

        # Mount an image to a region
        video = new ContentEdit.Video('video', {}, [{'src': 'foo.mp4'}])
        region.attach(video)

        # Get the helper DOM element
        helper = video.createDraggingDOMElement()

        expect(helper).not.toBe null
        expect(helper.tagName.toLowerCase()).toBe 'div'
        expect(helper.innerHTML).toBe 'foo.mp4'

    it 'should create a helper DOM element using the src attribute for other \
        elements (e.g iframes)', () ->

        # Mount an image to a region
        video = new ContentEdit.Video('iframe', {'src': 'foo.mp4'})
        region.attach(video)

        # Get the helper DOM element
        helper = video.createDraggingDOMElement()

        expect(helper).not.toBe null
        expect(helper.tagName.toLowerCase()).toBe 'div'
        expect(helper.innerHTML).toBe 'foo.mp4'


describe '`ContentEdit.Video.html()`', () ->

    it 'should return a HTML string for the image', () ->
        INDENT = ContentEdit.INDENT

        # As a <video> element
        video = new ContentEdit.Video(
            'video',
            {'controls': ''},
            [
                {'src': 'foo.mp4', 'type': 'video/mp4'},
                {'src': 'bar.ogg', 'type': 'video/ogg'}
                ]
            )
        expect(video.html()).toBe '<video controls>\n' +
                "#{ INDENT }<source src=\"foo.mp4\" type=\"video/mp4\">\n" +
                "#{ INDENT }<source src=\"bar.ogg\" type=\"video/ogg\">\n" +
            '</video>'

        # As an <iframe> element
        video = new ContentEdit.Video(
            'iframe',
            {'src': 'foo.mp4'}
            )
        expect(video.html()).toBe '<iframe src="foo.mp4"></iframe>'


describe '`ContentEdit.Video.mount()`', () ->

    videoA = null
    videoB = null
    region = null

    beforeEach ->
        videoA = new ContentEdit.Video(
            'video',
            {'controls': ''},
            [
                {'src': 'foo.mp4', 'type': 'video/mp4'},
                {'src': 'bar.ogg', 'type': 'video/ogg'}
                ]
            )
        videoB = new ContentEdit.Video(
            'iframe',
            {'src': 'foo.mp4'}
            )

        # Mount the videos
        region = new ContentEdit.Region(document.createElement('div'))
        region.attach(videoA)
        region.attach(videoB)
        videoA.unmount()
        videoB.unmount()

    it 'should mount the image to the DOM', () ->
        videoA.mount()
        videoB.mount()
        expect(videoA.isMounted()).toBe true
        expect(videoB.isMounted()).toBe true

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
        videoA.mount()
        expect(foo.handleFoo).toHaveBeenCalledWith(videoA)


describe '`ContentEdit.Video.fromDOMElement()`', () ->

    INDENT = ContentEdit.INDENT

    it 'should convert a <video> DOM element into a video element', () ->
        # Create <video> DOM element
        domVideo = document.createElement('video')
        domVideo.setAttribute('controls', '')
        domVideo.innerHTML += '<source src="foo.mp4" type="video/mp4">'
        domVideo.innerHTML += '<source src="bar.ogg" type="video/ogg">'

        # Convert the DOM element into an video element
        video = ContentEdit.Video.fromDOMElement(domVideo)
        expect(video.html()).toBe '<video controls>\n' +
                "#{ INDENT }<source src=\"foo.mp4\" type=\"video/mp4\">\n" +
                "#{ INDENT }<source src=\"bar.ogg\" type=\"video/ogg\">\n" +
            '</video>'

    it 'should convert an iframe <iframe> DOM element into a video \
        element', () ->

        domVideo = document.createElement('iframe')
        domVideo.setAttribute('src', 'foo.mp4')

        # Convert the DOM element into an video element
        video = ContentEdit.Video.fromDOMElement(domVideo)
        expect(video.html()).toBe '<iframe src="foo.mp4"></iframe>'


# Droppers

describe '`ContentEdit.Video` drop interactions`', () ->

    video = null
    region = null

    beforeEach ->
        region = new ContentEdit.Region(document.createElement('div'))
        video = new ContentEdit.Video('iframe', {'src': '/foo.jpg'})
        region.attach(video)

    it 'should support dropping on Image', () ->
        image = new ContentEdit.Image({'src': '/bar.jpg'})
        region.attach(image)

        # Check the initial order
        expect(video.nextSibling()).toBe image

        # Check the order and class above dropping the element left
        video.drop(image, ['above', 'left'])
        expect(video.hasCSSClass('align-left')).toBe true
        expect(video.nextSibling()).toBe image

        # Check the order and class above dropping the element right
        video.drop(image, ['above', 'right'])
        expect(video.hasCSSClass('align-left')).toBe false
        expect(video.hasCSSClass('align-right')).toBe true
        expect(video.nextSibling()).toBe image

        # Check the order after dropping the element below
        video.drop(image, ['below', 'center'])
        expect(video.hasCSSClass('align-left')).toBe false
        expect(video.hasCSSClass('align-right')).toBe false
        expect(image.nextSibling()).toBe video

        # Check the order after dropping the element above
        video.drop(image, ['above', 'center'])
        expect(video.nextSibling()).toBe image

    it 'should support being dropped on by Image', () ->
        image = new ContentEdit.Image({'src': '/bar.jpg'})
        region.attach(image, 0)

        # Check the initial order
        expect(image.nextSibling()).toBe video

        # Check the order and class above dropping the element left
        image.drop(video, ['above', 'left'])
        expect(image.hasCSSClass('align-left')).toBe true
        expect(image.nextSibling()).toBe video

        # Check the order and class above dropping the element right
        image.drop(video, ['above', 'right'])
        expect(image.hasCSSClass('align-left')).toBe false
        expect(image.hasCSSClass('align-right')).toBe true
        expect(image.nextSibling()).toBe video

        # Check the order after dropping the element below
        image.drop(video, ['below', 'center'])
        expect(image.hasCSSClass('align-left')).toBe false
        expect(image.hasCSSClass('align-right')).toBe false
        expect(video.nextSibling()).toBe image

        # Check the order after dropping the element above
        image.drop(video, ['above', 'center'])
        expect(image.nextSibling()).toBe video

    it 'should support dropping on PreText', () ->
        preText = new ContentEdit.PreText('pre', {}, '')
        region.attach(preText)

        # Check the initial order
        expect(video.nextSibling()).toBe preText

        # Check the order and class above dropping the element left
        video.drop(preText, ['above', 'left'])
        expect(video.hasCSSClass('align-left')).toBe true
        expect(video.nextSibling()).toBe preText

        # Check the order and class above dropping the element right
        video.drop(preText, ['above', 'right'])
        expect(video.hasCSSClass('align-left')).toBe false
        expect(video.hasCSSClass('align-right')).toBe true
        expect(video.nextSibling()).toBe preText

        # Check the order after dropping the element below
        video.drop(preText, ['below', 'center'])
        expect(video.hasCSSClass('align-left')).toBe false
        expect(video.hasCSSClass('align-right')).toBe false
        expect(preText.nextSibling()).toBe video

        # Check the order after dropping the element above
        video.drop(preText, ['above', 'center'])
        expect(video.nextSibling()).toBe preText

    it 'should support being dropped on by PreText', () ->
        preText = new ContentEdit.PreText('pre', {}, '')
        region.attach(preText, 0)

        # Check the initial order
        expect(preText.nextSibling()).toBe video

        # Check the order after dropping the element below
        preText.drop(video, ['below', 'center'])
        expect(video.nextSibling()).toBe preText

        # Check the order after dropping the element above
        preText.drop(video, ['above', 'center'])
        expect(preText.nextSibling()).toBe video

    it 'should support dropping on Static', () ->
        staticElm = ContentEdit.Static.fromDOMElement(
            document.createElement('div')
            )
        region.attach(staticElm)

        # Check the initial order
        expect(video.nextSibling()).toBe staticElm

        # Check the order and class above dropping the element left
        video.drop(staticElm, ['above', 'left'])
        expect(video.hasCSSClass('align-left')).toBe true
        expect(video.nextSibling()).toBe staticElm

        # Check the order and class above dropping the element right
        video.drop(staticElm, ['above', 'right'])
        expect(video.hasCSSClass('align-left')).toBe false
        expect(video.hasCSSClass('align-right')).toBe true
        expect(video.nextSibling()).toBe staticElm

        # Check the order after dropping the element below
        video.drop(staticElm, ['below', 'center'])
        expect(video.hasCSSClass('align-left')).toBe false
        expect(video.hasCSSClass('align-right')).toBe false
        expect(staticElm.nextSibling()).toBe video

        # Check the order after dropping the element above
        video.drop(staticElm, ['above', 'center'])
        expect(video.nextSibling()).toBe staticElm

    it 'should support being dropped on by `moveable` Static', () ->
        staticElm = new ContentEdit.Static('div', {'data-ce-moveable'}, 'foo')
        region.attach(staticElm, 0)

        # Check the initial order
        expect(staticElm.nextSibling()).toBe video

        # Check the order after dropping the element below
        staticElm.drop(video, ['below', 'center'])
        expect(video.nextSibling()).toBe staticElm

        # Check the order after dropping the element above
        staticElm.drop(video, ['above', 'center'])
        expect(staticElm.nextSibling()).toBe video

    it 'should support dropping on Text', () ->
        text = new ContentEdit.Text('p')
        region.attach(text)

        # Check the initial order
        expect(video.nextSibling()).toBe text

        # Check the order and class above dropping the element left
        video.drop(text, ['above', 'left'])
        expect(video.hasCSSClass('align-left')).toBe true
        expect(video.nextSibling()).toBe text

        # Check the order and class above dropping the element right
        video.drop(text, ['above', 'right'])
        expect(video.hasCSSClass('align-left')).toBe false
        expect(video.hasCSSClass('align-right')).toBe true
        expect(video.nextSibling()).toBe text

        # Check the order after dropping the element below
        video.drop(text, ['below', 'center'])
        expect(video.hasCSSClass('align-left')).toBe false
        expect(video.hasCSSClass('align-right')).toBe false
        expect(text.nextSibling()).toBe video

        # Check the order after dropping the element above
        video.drop(text, ['above', 'center'])
        expect(video.nextSibling()).toBe text

    it 'should support being dropped on by Text', () ->
        text = new ContentEdit.Text('p')
        region.attach(text, 0)

        # Check the initial order
        expect(text.nextSibling()).toBe video

        # Check the order after dropping the element below
        text.drop(video, ['below', 'center'])
        expect(video.nextSibling()).toBe text

        # Check the order after dropping the element above
        text.drop(video, ['above', 'center'])
        expect(text.nextSibling()).toBe video

    it 'should support dropping on Video', () ->
        otherVideo = new ContentEdit.Video('iframe', {'src': '/foo.jpg'})
        region.attach(otherVideo)

        # Check the initial order
        expect(video.nextSibling()).toBe otherVideo

        # Check the order and class above dropping the element left
        video.drop(otherVideo, ['above', 'left'])
        expect(video.hasCSSClass('align-left')).toBe true
        expect(video.nextSibling()).toBe otherVideo

        # Check the order and class above dropping the element right
        video.drop(otherVideo, ['above', 'right'])
        expect(video.hasCSSClass('align-left')).toBe false
        expect(video.hasCSSClass('align-right')).toBe true
        expect(video.nextSibling()).toBe otherVideo

        # Check the order after dropping the element below
        video.drop(otherVideo, ['below', 'center'])
        expect(video.hasCSSClass('align-left')).toBe false
        expect(video.hasCSSClass('align-right')).toBe false
        expect(otherVideo.nextSibling()).toBe video

        # Check the order after dropping the element above
        video.drop(otherVideo, ['above', 'center'])
        expect(video.nextSibling()).toBe otherVideo