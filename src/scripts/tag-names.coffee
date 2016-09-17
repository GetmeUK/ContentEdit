class _TagNames

    # The `_TagNames` class allows DOM element tag names to be associated with
    # `ContentEdit.Element` classes. When a region is initialized it uses this
    # association to determine how best to handle each DOM element child.
    #
    # DOM element tag names are associated with element classes through the
    # `register()` method. To handle cases where the same tag name is used for
    # more than one element class the `data-ce-tag` attribute can be used to
    # specify a tag name. This is also useful when you want to specify a tag
    # name that isn't valid in HTML (e.g <foo>...</foo> could be specified as
    # <p data-ce-tag="foo">...</p>).

    constructor: () ->
        # Map of tag names and their associated element classes
        @_tagNames = {}

    register: (cls, tagNames...) ->
        # Register an element class with one or more tag names
        for tagName in tagNames
            @_tagNames[tagName.toLowerCase()] = cls

    match: (tagName) ->
        # Return an element class for the specified tag name (case insensitive),
        # if we can't find an associated class return `ContentEdit.Static`.
        tagName = tagName.toLowerCase()
        if @_tagNames[tagName]
            return @_tagNames[tagName]

        return ContentEdit.Static


class ContentEdit.TagNames

    # The `ContentEdit.TagNames` class is a singleton, this code provides access
    # to the singleton instance of the protected `_TagNames` class which is
    # initialized the first time the class method `get` is called.

    instance = null

    @get: () ->
        instance ?= new _TagNames()