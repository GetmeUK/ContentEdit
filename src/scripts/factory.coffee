class ContentEdit.Factory

    # class methods
    @_classes = {}
    @_tags = {}

    @register: (classInstance, className, tagNames...)->
        @_classes[className] = classInstance
        for tagName in tagNames
            @_tags[tagName.toLowerCase()] = className

    @class: (className)->
        unless @_classes[className]
            console.error("Expected class names: #{Object.keys(@_classes).join(', ')}")
            throw new Error("Unexpect class name: #{className}")

        return @_classes[className]

    @classNameByTag: (tagName)->
        tagName = tagName.toLowerCase()
        unless @_tags[tagName]
            console.error("Expected tag names: #{Object.keys(@_tags).join(', ')}")
            throw new Error("Unexpect tag name: #{tagName}")

        return @_tags[tagName]

    @classByTag: (tagName)->
        return @class(@classNameByTag(tagName))

    # instance methods

    constructor: ->
        Root = ContentEdit.Factory.class('Root')
        @root = new Root()
        for className, classInstance of ContentEdit.Factory._classes
            @[className] = ((classInstance, factory)->
                class Wrapper extends classInstance
                    constructor: (args...)->
                        @_factory = factory
                        classInstance::constructor.apply(@, args)

                Wrapper._factory = factory
                return Wrapper

            )(classInstance, @)

    classByTag: (tagName)->
        className = ContentEdit.Factory.classNameByTag(tagName)
        return @[className]
