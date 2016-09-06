(function() {
  var Factory, factory, testDomElement;

  describe('ContentEdit', function() {
    return it('should have correct default settings', function() {
      expect(ContentEdit.DEFAULT_MAX_ELEMENT_WIDTH).toBe(800);
      expect(ContentEdit.DEFAULT_MIN_ELEMENT_WIDTH).toBe(80);
      expect(ContentEdit.DRAG_HOLD_DURATION).toBe(500);
      expect(ContentEdit.DROP_EDGE_SIZE).toBe(50);
      expect(ContentEdit.HELPER_CHAR_LIMIT).toBe(250);
      expect(ContentEdit.INDENT).toBe('    ');
      expect(ContentEdit.LANGUAGE).toBe('en');
      return expect(ContentEdit.RESIZE_CORNER_SIZE).toBe(15);
    });
  });

  describe('ContentEdit._', function() {
    return it('should return a translated string for the current language', function() {
      ContentEdit.addTranslations('fr', {
        'hello': 'bonjour'
      });
      ContentEdit.addTranslations('de', {
        'hello': 'hallo'
      });
      expect(ContentEdit._('hello')).toBe('hello');
      ContentEdit.LANGUAGE = 'fr';
      expect(ContentEdit._('hello')).toBe('bonjour');
      ContentEdit.LANGUAGE = 'de';
      expect(ContentEdit._('hello')).toBe('hallo');
      expect(ContentEdit._('goodbye')).toBe('goodbye');
      return ContentEdit.LANGUAGE = 'en';
    });
  });

  describe('ContentEdit.addCSSClass()', function() {
    return it('should add a CSS class to a DOM element', function() {
      var domElement;
      domElement = document.createElement('div');
      ContentEdit.addCSSClass(domElement, 'foo');
      expect(domElement.getAttribute('class')).toBe('foo');
      ContentEdit.addCSSClass(domElement, 'bar');
      return expect(domElement.getAttribute('class')).toBe('foo bar');
    });
  });

  describe('ContentEdit.attributesToString()', function() {
    return it('should convert a dictionary into a key="value" string', function() {
      var attributes, string;
      attributes = {
        'id': 'foo',
        'class': 'bar'
      };
      string = ContentEdit.attributesToString(attributes);
      return expect(string).toBe('class="bar" id="foo"');
    });
  });

  describe('ContentEdit.removeCSSClass()', function() {
    it('should remove a CSS class from a DOM element', function() {
      var domElement;
      domElement = document.createElement('div');
      ContentEdit.addCSSClass(domElement, 'foo');
      ContentEdit.addCSSClass(domElement, 'bar');
      ContentEdit.removeCSSClass(domElement, 'foo');
      expect(domElement.getAttribute('class')).toBe('bar');
      ContentEdit.removeCSSClass(domElement, 'bar');
      return expect(domElement.getAttribute('class')).toBe(null);
    });
    return it('should do nothing if the CSS class being removed is not set against the DOM element', function() {
      var domElement;
      domElement = document.createElement('div');
      ContentEdit.addCSSClass(domElement, 'foo');
      ContentEdit.addCSSClass(domElement, 'bar');
      ContentEdit.removeCSSClass(domElement, 'zee');
      return expect(domElement.getAttribute('class')).toBe('foo bar');
    });
  });

  Factory = ContentEdit.Factory;

  factory = new Factory();

  describe('ContentEdit.Factory', function() {
    it('should be instance of Factory', function() {
      return expect(factory instanceof Factory).toBe(true);
    });
    it('instance should modify classes', function() {
      expect(factory.Root === Factory["class"]('Root')).toBe(false);
      return expect(factory.classByTag('p') === Factory.classByTag('p')).toBe(false);
    });
    it('modified classes must have link to factory in static parameter and in instance parameter', function() {
      var node;
      expect(factory.Node._factory === factory).toBe(true, function() {});
      node = new factory.Node();
      return expect(node._factory === factory).toBe(true);
    });
    it('origin classes must haven\'t link to factory', function() {
      var node;
      expect(Factory["class"]('Node')._factory === void 0).toBe(true);
      node = new (Factory["class"]('Node'))();
      return expect(node._factory === void 0).toBe(true);
    });
    return it('should initialize and store Root instance', function() {
      var Root;
      Root = Factory["class"]('Root');
      expect(factory.root instanceof Root).toBe(true);
      return expect(factory.root instanceof factory.Root).toBe(false);
    });
  });

  testDomElement = document.createElement('div');

  testDomElement.setAttribute('id', 'test');

  document.body.appendChild(testDomElement);

  factory = new ContentEdit.Factory();

  describe('Node()', function() {
    return it('should create `Node` instance', function() {
      var node;
      node = new factory.Node();
      return expect(node instanceof factory.Node).toBe(true);
    });
  });

  describe('Node.lastModified()', function() {
    return it('should return a date last modified if the node has been tainted', function() {
      var node;
      node = new factory.Node();
      expect(node.lastModified()).toBe(null);
      node.taint();
      return expect(node.lastModified()).not.toBe(null);
    });
  });

  describe('Node.parent()', function() {
    return it('should return the parent node collection for the node', function() {
      var collection, node;
      collection = new factory.NodeCollection();
      node = new factory.Node();
      collection.attach(node);
      return expect(node.parent()).toBe(collection);
    });
  });

  describe('Node.parents()', function() {
    return it('should return an ascending list of all the node\'s parents', function() {
      var grandParent, node, parent;
      grandParent = new factory.NodeCollection();
      parent = new factory.NodeCollection();
      grandParent.attach(parent);
      node = new factory.Node();
      parent.attach(node);
      return expect(node.parents()).toEqual([parent, grandParent]);
    });
  });

  describe('Node.html()', function() {
    return it('should raise a not implemented error', function() {
      var node;
      node = new factory.Node();
      return expect(node.html).toThrow(new Error('`html` not implemented'));
    });
  });

  describe('Node.type()', function() {
    return it('should return \'Node\'', function() {
      var node;
      node = new factory.Node();
      return expect(node.type()).toBe('Node');
    });
  });

  describe('Node.bind()', function() {
    return it('should bind a function so that it\'s called whenever the event is triggered', function() {
      var foo, node;
      foo = {
        handleFoo: function() {}
      };
      spyOn(foo, 'handleFoo');
      node = new factory.Node();
      node.bind('foo', foo.handleFoo);
      node.trigger('foo');
      return expect(foo.handleFoo).toHaveBeenCalled();
    });
  });

  describe('Node.trigger()', function() {
    return it('should trigger an event against the node with specified arguments', function() {
      var foo, node;
      foo = {
        handleFoo: function() {}
      };
      spyOn(foo, 'handleFoo');
      node = new factory.Node();
      node.bind('foo', foo.handleFoo);
      node.trigger('foo', 123);
      return expect(foo.handleFoo).toHaveBeenCalledWith(123);
    });
  });

  describe('Node.unbind()', function() {
    return it('should unbind a function previously bound for an event from the node', function() {
      var foo, node;
      foo = {
        handleFoo: function() {}
      };
      spyOn(foo, 'handleFoo');
      node = new factory.Node();
      node.bind('foo', foo.handleFoo);
      node.unbind('foo', foo.handleFoo);
      node.trigger('foo');
      return expect(foo.handleFoo).not.toHaveBeenCalled();
    });
  });

  describe('Node.commit()', function() {
    var node;
    node = null;
    beforeEach(function() {
      node = new factory.Node();
      return node.taint();
    });
    it('should set the last modified date of the node to null', function() {
      node.commit();
      return expect(node.lastModified()).toBe(null);
    });
    return it('should trigger the commit event against the root', function() {
      var foo;
      foo = {
        handleFoo: function() {}
      };
      spyOn(foo, 'handleFoo');
      factory.root.bind('commit', foo.handleFoo);
      node.commit();
      return expect(foo.handleFoo).toHaveBeenCalledWith(node);
    });
  });

  describe('Node.taint()', function() {
    it('should set the last modified date of the node, it\'s parents and the root', function() {
      var collection, node;
      collection = new factory.NodeCollection();
      node = new factory.Node();
      collection.attach(node);
      node.taint();
      expect(node.lastModified()).not.toBe(null);
      expect(node.parent().lastModified()).toBe(node.lastModified());
      return expect(factory.root.lastModified()).toBe(node.lastModified());
    });
    return it('should trigger the taint event against the root', function() {
      var foo, node;
      node = new factory.Node();
      foo = {
        handleFoo: function() {}
      };
      spyOn(foo, 'handleFoo');
      factory.root.bind('taint', foo.handleFoo);
      node.taint();
      return expect(foo.handleFoo).toHaveBeenCalledWith(node);
    });
  });

  describe('Node.closest()', function() {
    return it('should return the first ancestor (ascending order) to match the that returns true for the specified test function.', function() {
      var grandParent, node, parent;
      grandParent = new factory.NodeCollection();
      parent = new factory.NodeCollection();
      grandParent.attach(parent);
      node = new factory.Node();
      parent.attach(node);
      grandParent.foo = true;
      parent.bar = true;
      expect(node.closest(function(node) {
        return node.foo;
      })).toBe(grandParent);
      return expect(node.closest(function(node) {
        return node.bar;
      })).toBe(parent);
    });
  });

  describe('Node.next()', function() {
    return it('should return the node next to this node in the tree', function() {
      var collectionA, collectionB, nodeA, nodeB;
      collectionA = new factory.NodeCollection();
      nodeA = new factory.Node();
      collectionA.attach(nodeA);
      collectionB = new factory.NodeCollection();
      nodeB = new factory.Node();
      collectionA.attach(collectionB);
      collectionB.attach(nodeB);
      expect(nodeA.next()).toBe(collectionB);
      return expect(nodeA.next().next()).toBe(nodeB);
    });
  });

  describe('Node.nextContent()', function() {
    return it('should return the next node in the tree that supports the `content` attribute', function() {
      var collectionA, collectionB, nodeA, nodeB;
      collectionA = new factory.NodeCollection();
      nodeA = new factory.Node();
      collectionA.attach(nodeA);
      collectionB = new factory.NodeCollection();
      nodeB = new factory.Text('p', {}, 'testing');
      collectionA.attach(collectionB);
      collectionB.attach(nodeB);
      return expect(collectionA.nextContent()).toBe(nodeB);
    });
  });

  describe('Node.nextSibling()', function() {
    return it('should return the node next to this node with the same parent', function() {
      var collection, nodeA, nodeB;
      collection = new factory.NodeCollection();
      nodeA = new factory.Node();
      collection.attach(nodeA);
      nodeB = new factory.Node();
      collection.attach(nodeB);
      return expect(nodeA.nextSibling()).toBe(nodeB);
    });
  });

  describe('Node.nextWithTest()', function() {
    return it('should return the next node in the tree that matches or `undefined` if there are none', function() {
      var collectionA, collectionB, nodeA, nodeB;
      collectionA = new factory.NodeCollection();
      nodeA = new factory.Node();
      collectionA.attach(nodeA);
      collectionB = new factory.NodeCollection();
      nodeB = new factory.Node();
      collectionA.attach(collectionB);
      collectionB.attach(nodeB);
      nodeB.foo = true;
      expect(collectionA.nextWithTest(function(node) {
        return node.foo;
      })).toBe(nodeB);
      return expect(nodeB.nextWithTest(function(node) {
        return node.foo;
      })).toBe(void 0);
    });
  });

  describe('Node.previous()', function() {
    return it('should return the node previous to this node in the tree', function() {
      var collectionA, collectionB, nodeA, nodeB;
      collectionA = new factory.NodeCollection();
      nodeA = new factory.Node();
      collectionA.attach(nodeA);
      collectionB = new factory.NodeCollection();
      nodeB = new factory.Node();
      collectionA.attach(collectionB);
      collectionB.attach(nodeB);
      expect(nodeB.previous()).toBe(collectionB);
      return expect(nodeB.previous().previous()).toBe(nodeA);
    });
  });

  describe('Node.nextContent()', function() {
    return it('should return the previous node in the tree that supports the `content` attribute', function() {
      var collectionA, collectionB, nodeA, nodeB;
      collectionA = new factory.NodeCollection();
      nodeA = new factory.Text('p', {}, 'testing');
      collectionA.attach(nodeA);
      collectionB = new factory.NodeCollection();
      nodeB = new factory.Node();
      collectionA.attach(collectionB);
      collectionB.attach(nodeB);
      return expect(nodeB.previousContent()).toBe(nodeA);
    });
  });

  describe('Node.previousSibling()', function() {
    return it('should return the node previous to this node with the same parent', function() {
      var collection, nodeA, nodeB;
      collection = new factory.NodeCollection();
      nodeA = new factory.Node();
      collection.attach(nodeA);
      nodeB = new factory.Node();
      collection.attach(nodeB);
      return expect(nodeB.previousSibling()).toBe(nodeA);
    });
  });

  describe('Node.previousWithTest()', function() {
    return it('should return the previous node in the tree that matches or `undefined` if there are none', function() {
      var collectionA, collectionB, nodeA, nodeB;
      collectionA = new factory.NodeCollection();
      nodeA = new factory.Node();
      collectionA.attach(nodeA);
      collectionB = new factory.NodeCollection();
      nodeB = new factory.Node();
      collectionA.attach(collectionB);
      collectionB.attach(nodeB);
      nodeA.foo = true;
      expect(nodeB.previousWithTest(function(node) {
        return node.foo;
      })).toBe(nodeA);
      return expect(collectionA.previousWithTest(function(node) {
        return node.foo;
      })).toBe(void 0);
    });
  });

  describe('Node.@fromDOMElement()', function() {
    return it('should raise a not implemented error', function() {
      return expect(factory.Node.fromDOMElement).toThrow(new Error('`fromDOMElement` not implemented'));
    });
  });

  describe('NodeCollection()', function() {
    return it('should create `NodeCollection` instance', function() {
      var collection;
      collection = new factory.NodeCollection();
      return expect(collection instanceof factory.NodeCollection).toBe(true);
    });
  });

  describe('NodeCollection.descendants()', function() {
    return it('should return a (flat) list of all the descendants for the collection', function() {
      var collectionA, collectionB, nodeA, nodeB;
      collectionA = new factory.NodeCollection();
      nodeA = new factory.Node();
      collectionA.attach(nodeA);
      collectionB = new factory.NodeCollection();
      nodeB = new factory.Node();
      collectionA.attach(collectionB);
      collectionB.attach(nodeB);
      return expect(collectionA.descendants()).toEqual([nodeA, collectionB, nodeB]);
    });
  });

  describe('NodeCollection.isMounted()', function() {
    return it('should always return false', function() {
      var collection;
      collection = new factory.NodeCollection();
      return expect(collection.isMounted()).toBe(false);
    });
  });

  describe('NodeCollection.type()', function() {
    return it('should return \'NodeCollection\'', function() {
      var collection;
      collection = new factory.NodeCollection();
      return expect(collection.type()).toBe('NodeCollection');
    });
  });

  describe('NodeCollection.attach()', function() {
    it('should attach a node to a node collection', function() {
      var collection, node;
      collection = new factory.NodeCollection();
      node = new factory.Node();
      collection.attach(node);
      return expect(collection.children[0]).toBe(node);
    });
    it('should attach a node to a node collection at the specified index', function() {
      var collection, i, node, otherNode, _i;
      collection = new factory.NodeCollection();
      for (i = _i = 0; _i < 5; i = ++_i) {
        otherNode = new factory.Node();
        collection.attach(otherNode);
      }
      node = new factory.Node();
      collection.attach(node, 2);
      return expect(collection.children[2]).toBe(node);
    });
    return it('should trigger the attach event against the root', function() {
      var collection, foo, node;
      foo = {
        handleFoo: function() {}
      };
      spyOn(foo, 'handleFoo');
      factory.root.bind('attach', foo.handleFoo);
      collection = new factory.NodeCollection();
      node = new factory.Node();
      collection.attach(node);
      return expect(foo.handleFoo).toHaveBeenCalledWith(collection, node);
    });
  });

  describe('NodeCollection.commit()', function() {
    var collectionA, collectionB, node;
    collectionA = null;
    collectionB = null;
    node = null;
    beforeEach(function() {
      collectionA = new factory.NodeCollection();
      collectionB = new factory.NodeCollection();
      node = new factory.Node();
      collectionA.attach(collectionB);
      return collectionB.attach(node);
    });
    it('should set the last modified date of the node and it\'s descendants to null', function() {
      node.taint();
      expect(collectionA.lastModified()).not.toBe(null);
      node.commit();
      return expect(node.lastModified()).toBe(null);
    });
    return it('should trigger the commit event against the root', function() {
      var foo;
      foo = {
        handleFoo: function() {}
      };
      spyOn(foo, 'handleFoo');
      factory.root.bind('commit', foo.handleFoo);
      collectionA.commit();
      return expect(foo.handleFoo).toHaveBeenCalledWith(collectionA);
    });
  });

  describe('NodeCollection.detach()', function() {
    var collection, node;
    collection = null;
    node = null;
    beforeEach(function() {
      collection = new factory.NodeCollection();
      node = new factory.Node();
      return collection.attach(node);
    });
    it('should detach a node from the node collection', function() {
      collection.detach(node);
      expect(collection.children.length).toBe(0);
      return expect(node.parent()).toBe(null);
    });
    return it('should trigger the detach event against the root', function() {
      var foo;
      foo = {
        handleFoo: function() {}
      };
      spyOn(foo, 'handleFoo');
      factory.root.bind('detach', foo.handleFoo);
      collection.detach(node);
      return expect(foo.handleFoo).toHaveBeenCalledWith(collection, node);
    });
  });

  describe('Element()', function() {
    return it('should create `Element` instance', function() {
      var element;
      element = new factory.Element('div', {
        'class': 'foo'
      });
      return expect(element instanceof factory.Element).toBe(true);
    });
  });

  describe('Element.attributes()', function() {
    return it('should return a copy of the elements attributes', function() {
      var element;
      element = new factory.Element('div', {
        'class': 'foo',
        'data-test': ''
      });
      return expect(element.attributes()).toEqual({
        'class': 'foo',
        'data-test': ''
      });
    });
  });

  describe('Element.cssTypeName()', function() {
    return it('should return \'element\'', function() {
      var element;
      element = new factory.Element('div', {
        'class': 'foo'
      });
      return expect(element.cssTypeName()).toBe('element');
    });
  });

  describe('Element.domElement()', function() {
    return it('should return a DOM element if mounted', function() {
      var element, region;
      element = new factory.Text('p');
      expect(element.domElement()).toBe(null);
      region = new factory.Region(document.createElement('div'));
      region.attach(element);
      return expect(element.domElement()).not.toBe(null);
    });
  });

  describe('Element.isFocused()', function() {
    return it('should return true if element is focused', function() {
      var element;
      element = new factory.Element('div');
      expect(element.isFocused()).toBe(false);
      element.focus();
      return expect(element.isFocused()).toBe(true);
    });
  });

  describe('Element.isMounted()', function() {
    return it('should return true if the element is mounted in the DOM', function() {
      var element, region;
      element = new factory.Text('p');
      expect(element.isMounted()).toBe(false);
      region = new factory.Region(document.createElement('div'));
      region.attach(element);
      return expect(element.isMounted()).toBe(true);
    });
  });

  describe('Element.type()', function() {
    return it('should return \'Element\'', function() {
      var element;
      element = new factory.Element('div', {
        'class': 'foo'
      });
      return expect(element.type()).toBe('Element');
    });
  });

  describe('`Element.typeName()`', function() {
    return it('should return \'Element\'', function() {
      var element;
      element = new factory.Element('div', {
        'class': 'foo'
      });
      return expect(element.typeName()).toBe('Element');
    });
  });

  describe('Element.addCSSClass()', function() {
    return it('should add a CSS class to the element', function() {
      var element;
      element = new factory.Element('div');
      element.addCSSClass('foo');
      expect(element.hasCSSClass('foo')).toBe(true);
      element.addCSSClass('bar');
      return expect(element.hasCSSClass('bar')).toBe(true);
    });
  });

  describe('Element.attr()', function() {
    return it('should set/get an attribute for the element', function() {
      var element;
      element = new factory.Element('div');
      element.attr('foo', 'bar');
      return expect(element.attr('foo')).toBe('bar');
    });
  });

  describe('Element.blur()', function() {
    it('should blur an element', function() {
      var element;
      element = new factory.Element('div');
      element.focus();
      expect(element.isFocused()).toBe(true);
      element.blur();
      return expect(element.isFocused()).toBe(false);
    });
    return it('should trigger the `blur` event against the root', function() {
      var element, foo;
      foo = {
        handleFoo: function() {}
      };
      spyOn(foo, 'handleFoo');
      factory.root.bind('blur', foo.handleFoo);
      element = new factory.Element('div');
      element.focus();
      element.blur();
      return expect(foo.handleFoo).toHaveBeenCalledWith(element);
    });
  });

  describe('Element.can()', function() {
    return it('should set/get whether a behaviour is allowed for the element', function() {
      var element;
      element = new factory.Element('div');
      expect(element.can('remove')).toBe(true);
      element.can('remove', false);
      return expect(element.can('remove')).toBe(false);
    });
  });

  describe('Element.createDraggingDOMElement()', function() {
    return it('should create a helper DOM element', function() {
      var element, helper, region;
      element = new factory.Element('div');
      region = new factory.Region(document.createElement('div'));
      region.attach(element);
      helper = element.createDraggingDOMElement();
      expect(helper).not.toBe(null);
      return expect(helper.tagName.toLowerCase()).toBe('div');
    });
  });

  describe('Element.drag()', function() {
    it('should call `startDragging` against the root element', function() {
      var element, region;
      element = new factory.Element('div');
      region = new factory.Region(document.createElement('div'));
      region.attach(element);
      spyOn(factory.root, 'startDragging');
      element.drag(0, 0);
      expect(factory.root.startDragging).toHaveBeenCalledWith(element, 0, 0);
      return factory.root.cancelDragging();
    });
    it('should trigger the `drag` event against the root', function() {
      var element, foo, region;
      element = new factory.Element('div');
      region = new factory.Region(document.createElement('div'));
      region.attach(element);
      foo = {
        handleFoo: function() {}
      };
      spyOn(foo, 'handleFoo');
      factory.root.bind('drag', foo.handleFoo);
      element.drag(0, 0);
      expect(foo.handleFoo).toHaveBeenCalledWith(element);
      return factory.root.cancelDragging();
    });
    return it('should do nothing if the `drag` behavior is not allowed', function() {
      var element, region;
      element = new factory.Element('div');
      element.can('drag', false);
      region = new factory.Region(document.createElement('div'));
      region.attach(element);
      spyOn(factory.root, 'startDragging');
      element.drag(0, 0);
      return expect(factory.root.startDragging).not.toHaveBeenCalled();
    });
  });

  describe('Element.drop()', function() {
    it('should select a function from the elements droppers map for the element being dropped on to this element', function() {
      var imageA, imageB, region;
      region = new factory.Region(document.createElement('div'));
      imageA = new factory.Image();
      region.attach(imageA);
      imageB = new factory.Image();
      region.attach(imageB);
      spyOn(factory.Image.droppers, 'Image');
      imageA.drop(imageB, ['below', 'center']);
      return expect(factory.Image.droppers['Image']).toHaveBeenCalledWith(imageA, imageB, ['below', 'center']);
    });
    it('should trigger the `drop` event against the root', function() {
      var foo, imageA, imageB, region;
      region = new factory.Region(document.createElement('div'));
      imageA = new factory.Image();
      region.attach(imageA);
      imageB = new factory.Image();
      region.attach(imageB);
      foo = {
        handleFoo: function() {}
      };
      spyOn(foo, 'handleFoo');
      factory.root.bind('drop', foo.handleFoo);
      imageA.drop(imageB, ['below', 'center']);
      expect(foo.handleFoo).toHaveBeenCalledWith(imageA, imageB, ['below', 'center']);
      imageA.drop(null, ['below', 'center']);
      return expect(foo.handleFoo).toHaveBeenCalledWith(imageA, null, null);
    });
    return it('should do nothing if the `drop` behavior is not allowed', function() {
      var imageA, imageB, region;
      region = new factory.Region(document.createElement('div'));
      imageA = new factory.Image();
      region.attach(imageA);
      imageB = new factory.Image();
      region.attach(imageB);
      imageA.can('drop', false);
      spyOn(factory.Image.droppers, 'Image');
      imageA.drop(imageB, ['below', 'center']);
      return expect(factory.Image.droppers['Image']).not.toHaveBeenCalled();
    });
  });

  describe('Element.focus()', function() {
    it('should focus an element', function() {
      var element;
      element = new factory.Element('div');
      element.focus();
      return expect(element.isFocused()).toBe(true);
    });
    return it('should trigger the `focus` event against the root', function() {
      var element, foo;
      foo = {
        handleFoo: function() {}
      };
      spyOn(foo, 'handleFoo');
      factory.root.bind('focus', foo.handleFoo);
      element = new factory.Element('div');
      element.focus();
      return expect(foo.handleFoo).toHaveBeenCalledWith(element);
    });
  });

  describe('Element.hasCSSClass()', function() {
    return it('should return true if the element has the specified class', function() {
      var element;
      element = new factory.Element('div');
      element.addCSSClass('foo');
      element.addCSSClass('bar');
      expect(element.hasCSSClass('foo')).toBe(true);
      return expect(element.hasCSSClass('bar')).toBe(true);
    });
  });

  describe('Element.merge()', function() {
    it('should select a function from the elements mergers map for the element being merged with this element', function() {
      var region, textA, textB;
      region = new factory.Region(document.createElement('div'));
      textA = new factory.Text('p', {}, 'a');
      region.attach(textA);
      textB = new factory.Text('p', {}, 'b');
      region.attach(textB);
      spyOn(factory.Text.mergers, 'Text');
      textA.merge(textB);
      return expect(factory.Text.mergers['Text']).toHaveBeenCalledWith(textB, textA);
    });
    return it('should do nothing if the `merge` behavior is not allowed', function() {
      var region, textA, textB;
      region = new factory.Region(document.createElement('div'));
      textA = new factory.Text('p', {}, 'a');
      region.attach(textA);
      textB = new factory.Text('p', {}, 'b');
      region.attach(textB);
      textA.can('merge', false);
      spyOn(factory.Text.mergers, 'Text');
      textA.merge(textB);
      return expect(factory.Text.mergers['Text']).not.toHaveBeenCalled();
    });
  });

  describe('Element.mount()', function() {
    var element, region;
    element = null;
    region = null;
    beforeEach(function() {
      element = new factory.Element('p');
      region = new factory.Region(document.createElement('div'));
      region.attach(element);
      return element.unmount();
    });
    it('should mount the element to the DOM', function() {
      element.mount();
      return expect(element.isMounted()).toBe(true);
    });
    return it('should trigger the `mount` event against the root', function() {
      var foo;
      foo = {
        handleFoo: function() {}
      };
      spyOn(foo, 'handleFoo');
      factory.root.bind('mount', foo.handleFoo);
      element.mount();
      return expect(foo.handleFoo).toHaveBeenCalledWith(element);
    });
  });

  describe('Element.removeAttr()', function() {
    return it('should remove an attribute from the element', function() {
      var element;
      element = new factory.Element('div');
      element.attr('foo', 'bar');
      expect(element.attr('foo')).toBe('bar');
      element.removeAttr('foo');
      return expect(element.attr('foo')).toBe(void 0);
    });
  });

  describe('Element.removeCSSClass()', function() {
    return it('should remove a CSS class from the element', function() {
      var element;
      element = new factory.Element('div');
      element.addCSSClass('foo');
      element.addCSSClass('bar');
      expect(element.hasCSSClass('foo')).toBe(true);
      expect(element.hasCSSClass('bar')).toBe(true);
      element.removeCSSClass('foo');
      element.hasCSSClass('foo');
      element.removeCSSClass('bar');
      return expect(element.hasCSSClass('bar')).toBe(false);
    });
  });

  describe('Element.tagName()', function() {
    return it('should set/get the tag name for the element', function() {
      var element;
      element = new factory.Element('div');
      expect(element.tagName()).toBe('div');
      element.tagName('dt');
      return expect(element.tagName()).toBe('dt');
    });
  });

  describe('Element.unmount()', function() {
    var element, region;
    element = null;
    region = null;
    beforeEach(function() {
      element = new factory.Element('p');
      region = new factory.Region(document.createElement('div'));
      return region.attach(element);
    });
    it('should unmount the element from the DOM', function() {
      element.unmount();
      return expect(element.isMounted()).toBe(false);
    });
    return it('should trigger the `unmount` event against the root', function() {
      var foo;
      foo = {
        handleFoo: function() {}
      };
      spyOn(foo, 'handleFoo');
      factory.root.bind('unmount', foo.handleFoo);
      element.unmount();
      return expect(foo.handleFoo).toHaveBeenCalledWith(element);
    });
  });

  describe('Element.@getDOMElementAttributes()', function() {
    return it('should return attributes from a DOM element as a dictionary', function() {
      var attributes, domElement;
      domElement = document.createElement('div');
      domElement.setAttribute('class', 'foo');
      domElement.setAttribute('id', 'bar');
      domElement.setAttribute('contenteditable', '');
      attributes = factory.Element.getDOMElementAttributes(domElement);
      return expect(attributes).toEqual({
        'class': 'foo',
        'id': 'bar',
        'contenteditable': ''
      });
    });
  });

  describe('ElementCollection()', function() {
    return it('should create `ElementCollection` instance`', function() {
      var collection;
      collection = new factory.ElementCollection('dl', {
        'class': 'foo'
      });
      return expect(collection instanceof factory.ElementCollection).toBe(true);
    });
  });

  describe('ElementCollection.cssTypeName()', function() {
    return it('should return \'element-collection\'', function() {
      var element;
      element = new factory.ElementCollection('div', {
        'class': 'foo'
      });
      return expect(element.cssTypeName()).toBe('element-collection');
    });
  });

  describe('ElementCollection.isMounted()', function() {
    return it('should return true if the element is mounted in the DOM', function() {
      var collection, region;
      collection = new factory.List('ul');
      expect(collection.isMounted()).toBe(false);
      region = new factory.Region(document.createElement('div'));
      region.attach(collection);
      return expect(collection.isMounted()).toBe(true);
    });
  });

  describe('ElementCollection.html()', function() {
    return it('should return a HTML string for the collection', function() {
      var collection, text;
      collection = new factory.ElementCollection('div', {
        'class': 'foo'
      });
      text = new factory.Text('p', {}, 'test');
      collection.attach(text);
      return expect(collection.html()).toBe('<div class="foo">\n' + ("" + ContentEdit.INDENT + "<p>\n") + ("" + ContentEdit.INDENT + ContentEdit.INDENT + "test\n") + ("" + ContentEdit.INDENT + "</p>\n") + '</div>');
    });
  });

  describe('`ElementCollection.type()`', function() {
    return it('should return \'ElementCollection\'', function() {
      var collection;
      collection = new factory.ElementCollection('div', {
        'class': 'foo'
      });
      return expect(collection.type()).toBe('ElementCollection');
    });
  });

  describe('ElementCollection.createDraggingDOMElement()', function() {
    return it('should create a helper DOM element', function() {
      var collection, element, helper, region;
      collection = new factory.ElementCollection('div');
      element = new factory.Element('p');
      collection.attach(element);
      region = new factory.Region(document.createElement('div'));
      region.attach(collection);
      helper = collection.createDraggingDOMElement();
      expect(helper).not.toBe(null);
      return expect(helper.tagName.toLowerCase()).toBe('div');
    });
  });

  describe('ElementCollection.detach()', function() {
    var collection, elementA, elementB, region;
    collection = null;
    elementA = null;
    elementB = null;
    region = null;
    beforeEach(function() {
      region = new factory.Region(document.createElement('div'));
      collection = new factory.ElementCollection('div');
      region.attach(collection);
      elementA = new factory.Element('p');
      collection.attach(elementA);
      elementB = new factory.Element('p');
      return collection.attach(elementB);
    });
    it('should detach an element from the element collection', function() {
      collection.detach(elementA);
      return expect(collection.children.length).toBe(1);
    });
    it('should remove the collection if it becomes empty', function() {
      collection.detach(elementA);
      collection.detach(elementB);
      return expect(region.children.length).toBe(0);
    });
    return it('should trigger the detach event against the root', function() {
      var foo;
      foo = {
        handleFoo: function() {}
      };
      spyOn(foo, 'handleFoo');
      factory.root.bind('detach', foo.handleFoo);
      collection.detach(elementA);
      return expect(foo.handleFoo).toHaveBeenCalledWith(collection, elementA);
    });
  });

  describe('ElementCollection.mount()', function() {
    var collection, element, region;
    collection = null;
    element = null;
    region = null;
    beforeEach(function() {
      collection = new factory.ElementCollection('div');
      element = new factory.Element('p');
      collection.attach(element);
      region = new factory.Region(document.createElement('div'));
      region.attach(collection);
      return element.unmount();
    });
    it('should mount the collection and it\'s children to the DOM', function() {
      collection.mount();
      expect(collection.isMounted()).toBe(true);
      return expect(element.isMounted()).toBe(true);
    });
    return it('should trigger the `mount` event against the root', function() {
      var foo;
      foo = {
        handleFoo: function() {}
      };
      spyOn(foo, 'handleFoo');
      factory.root.bind('mount', foo.handleFoo);
      collection.mount();
      expect(foo.handleFoo).toHaveBeenCalledWith(collection);
      return expect(foo.handleFoo).toHaveBeenCalledWith(element);
    });
  });

  describe('ElementCollection.unmount()', function() {
    var collection, element, region;
    collection = null;
    element = null;
    region = null;
    beforeEach(function() {
      collection = new factory.ElementCollection('div');
      element = new factory.Element('p');
      collection.attach(element);
      region = new factory.Region(document.createElement('div'));
      return region.attach(collection);
    });
    it('should unmount the collection and it\'s children from the DOM', function() {
      collection.unmount();
      expect(collection.isMounted()).toBe(false);
      return expect(element.isMounted()).toBe(false);
    });
    return it('should trigger the `unmount` event against the root', function() {
      var foo;
      foo = {
        handleFoo: function() {}
      };
      spyOn(foo, 'handleFoo');
      factory.root.bind('unmount', foo.handleFoo);
      collection.unmount();
      expect(foo.handleFoo).toHaveBeenCalledWith(collection);
      return expect(foo.handleFoo).toHaveBeenCalledWith(element);
    });
  });

  describe('ResizableElement()', function() {
    return it('should create `ResizableElement` instance`', function() {
      var element;
      element = new factory.ResizableElement('div', {
        'class': 'foo'
      });
      return expect(element instanceof factory.ResizableElement).toBe(true);
    });
  });

  describe('ResizableElement.aspectRatio()', function() {
    return it('should return the 1', function() {
      var element;
      element = new factory.ResizableElement('div');
      return expect(element.aspectRatio()).toBe(1);
    });
  });

  describe('ResizableElement.maxSize()', function() {
    var element;
    element = null;
    beforeEach(function() {
      return element = new factory.ResizableElement('div', {
        'height': 200,
        'width': 200
      });
    });
    it('should return the default maximum element size for an element', function() {
      return expect(element.maxSize()).toEqual([ContentEdit.DEFAULT_MAX_ELEMENT_WIDTH, ContentEdit.DEFAULT_MAX_ELEMENT_WIDTH]);
    });
    return it('should return the specified maximum element size for an element', function() {
      element.attr('data-ce-max-width', 1000);
      return expect(element.maxSize()).toEqual([1000, 1000]);
    });
  });

  describe('ResizableElement.minSize()', function() {
    var element;
    element = null;
    beforeEach(function() {
      return element = new factory.ResizableElement('div', {
        'height': 200,
        'width': 200
      });
    });
    it('should return the default minimum element size for an element', function() {
      return expect(element.minSize()).toEqual([ContentEdit.DEFAULT_MIN_ELEMENT_WIDTH, ContentEdit.DEFAULT_MIN_ELEMENT_WIDTH]);
    });
    return it('should return the specified minimum element size for an element', function() {
      element.attr('data-ce-min-width', 100);
      return expect(element.minSize()).toEqual([100, 100]);
    });
  });

  describe('`ResizableElement.type()`', function() {
    return it('should return \'ResizableElement\'', function() {
      var element;
      element = new factory.ResizableElement('div', {
        'class': 'foo'
      });
      return expect(element.type()).toBe('ResizableElement');
    });
  });

  describe('ResizableElement.mount()', function() {
    var element, region;
    element = null;
    region = null;
    beforeEach(function() {
      element = new factory.ResizableElement('div', {
        'height': 200,
        'width': 200
      });
      region = new factory.Region(document.createElement('div'));
      region.attach(element);
      return element.unmount();
    });
    it('should mount the element to the DOM and set the size attribute', function() {
      var size;
      element.mount();
      expect(element.isMounted()).toBe(true);
      size = element.domElement().getAttribute('data-ce-size');
      return expect(size).toBe('w 200 × h 200');
    });
    return it('should trigger the `mount` event against the root', function() {
      var foo;
      foo = {
        handleFoo: function() {}
      };
      spyOn(foo, 'handleFoo');
      factory.root.bind('mount', foo.handleFoo);
      element.mount();
      return expect(foo.handleFoo).toHaveBeenCalledWith(element);
    });
  });

  describe('Element.resize()', function() {
    it('should call `startResizing` against the root element', function() {
      var element, region;
      element = new factory.ResizableElement('div', {
        'height': 200,
        'width': 200
      });
      region = new factory.Region(document.createElement('div'));
      region.attach(element);
      spyOn(factory.root, 'startResizing');
      element.resize(['top', 'left'], 0, 0);
      return expect(factory.root.startResizing).toHaveBeenCalledWith(element, ['top', 'left'], 0, 0, true);
    });
    return it('should do nothing if the `resize` behavior is not allowed', function() {
      var element, region;
      element = new factory.ResizableElement('div', {
        'height': 200,
        'width': 200
      });
      element.can('resize', false);
      region = new factory.Region(document.createElement('div'));
      region.attach(element);
      spyOn(factory.root, 'startResizing');
      element.resize(['top', 'left'], 0, 0);
      return expect(factory.root.startResizing).not.toHaveBeenCalled();
    });
  });

  describe('Element.size()', function() {
    return it('should set/get the size of the element', function() {
      var element;
      element = new factory.ResizableElement('div', {
        'height': 200,
        'width': 200
      });
      expect(element.size()).toEqual([200, 200]);
      element.size([100, 100]);
      return expect(element.size()).toEqual([100, 100]);
    });
  });

  factory = new ContentEdit.Factory();

  describe('`Region()`', function() {
    return it('should return an instance of Region`', function() {
      var region;
      region = new factory.Region(document.createElement('div'));
      return expect(region instanceof factory.Region).toBe(true);
    });
  });

  describe('`Region.domElement()`', function() {
    return it('should return the DOM element the region was initialized with', function() {
      var domElement, region;
      domElement = document.createElement('div');
      region = new factory.Region(domElement);
      return expect(region.domElement()).toBe(domElement);
    });
  });

  describe('`Region.isMounted()`', function() {
    return it('should always return true', function() {
      var region;
      region = new factory.Region(document.createElement('div'));
      return expect(region.isMounted()).toBe(true);
    });
  });

  describe('`Region.type()`', function() {
    return it('should return \'Region\'', function() {
      var region;
      region = new factory.Region(document.createElement('div'));
      return expect(region.type()).toBe('Region');
    });
  });

  describe('`Region.html()`', function() {
    return it('should return a HTML string for the region', function() {
      var region;
      region = new factory.Region(document.createElement('div'));
      region.attach(new factory.Text('p', {}, 'one'));
      region.attach(new factory.Text('p', {}, 'two'));
      region.attach(new factory.Text('p', {}, 'three'));
      return expect(region.html()).toBe('<p>\n' + ("" + ContentEdit.INDENT + "one\n") + '</p>\n' + '<p>\n' + ("" + ContentEdit.INDENT + "two\n") + '</p>\n' + '<p>\n' + ("" + ContentEdit.INDENT + "three\n") + '</p>');
    });
  });

  describe('`ContentEdit.Region.setContent()`', function() {
    return it('should set content for the region', function() {
      var domContent, htmlContent, region;
      region = new factory.Region(document.createElement('div'));
      domContent = document.createElement('div');
      domContent.innerHTML = '<h1>test with DOM</h1>';
      htmlContent = '<h2>test with HTML</h2>';
      region.setContent(domContent);
      expect(region.html()).toBe('<h1>\n' + ("" + ContentEdit.INDENT + "test with DOM\n") + '</h1>');
      region.setContent(htmlContent);
      return expect(region.html()).toBe('<h2>\n' + ("" + ContentEdit.INDENT + "test with HTML\n") + '</h2>');
    });
  });

  factory = new ContentEdit.Factory();

  describe('`factory.Fixture()`', function() {
    return it('should return an instance of Fixture`', function() {
      var child, div, fixture, p;
      div = document.createElement('div');
      p = document.createElement('p');
      p.innerHTML = 'foo <b>bar</b>';
      div.appendChild(p);
      fixture = new factory.Fixture(p);
      expect(fixture instanceof factory.Fixture).toBe(true);
      child = fixture.children[0];
      expect(child.isFixed()).toBe(true);
      expect(child.can('drag')).toBe(false);
      expect(child.can('drop')).toBe(false);
      expect(child.can('merge')).toBe(false);
      expect(child.can('remove')).toBe(false);
      expect(child.can('resize')).toBe(false);
      return expect(child.can('spawn')).toBe(false);
    });
  });

  describe('`factory.Fixture.domElement()`', function() {
    return it('should return the DOM element of the child `Element` it wraps', function() {
      var div, fixture, p;
      div = document.createElement('div');
      p = document.createElement('p');
      p.innerHTML = 'foo <b>bar</b>';
      div.appendChild(p);
      fixture = new factory.Fixture(p);
      return expect(fixture.domElement()).toBe(fixture.children[0].domElement());
    });
  });

  describe('`factory.Fixture.isMounted()`', function() {
    return it('should always return true', function() {
      var div, fixture, p;
      div = document.createElement('div');
      p = document.createElement('p');
      p.innerHTML = 'foo <b>bar</b>';
      div.appendChild(p);
      fixture = new factory.Fixture(p);
      return expect(fixture.isMounted()).toBe(true);
    });
  });

  describe('`factory.Fixture.html()`', function() {
    return it('should return a HTML string for the fixture', function() {
      var div, fixture, p;
      div = document.createElement('div');
      p = document.createElement('p');
      p.innerHTML = 'foo <b>bar</b>';
      div.appendChild(p);
      fixture = new factory.Fixture(p);
      return expect(fixture.html()).toBe("foo <b>bar</b>");
    });
  });

  describe('`factory.Fixture` text behaviour', function() {
    return it('should return trigger next/previous-region event when tab key is pressed', function() {
      var child, div, fixture, handlers, p;
      div = document.createElement('div');
      p = document.createElement('p');
      p.innerHTML = 'foo <b>bar</b>';
      div.appendChild(p);
      fixture = new factory.Fixture(p);
      child = fixture.children[0];
      handlers = {
        nextRegion: function() {},
        previousRegion: function() {}
      };
      spyOn(handlers, 'nextRegion');
      spyOn(handlers, 'previousRegion');
      factory.root.bind('next-region', handlers.nextRegion);
      factory.root.bind('previous-region', handlers.previousRegion);
      child._keyTab({
        preventDefault: function() {}
      });
      expect(handlers.nextRegion).toHaveBeenCalledWith(fixture);
      child._keyTab({
        preventDefault: function() {},
        shiftKey: true
      });
      return expect(handlers.previousRegion).toHaveBeenCalledWith(fixture);
    });
  });

  factory = new ContentEdit.Factory();

  describe('`Root.focused()`', function() {
    return it('should return the currently focused element or null if no element has focus', function() {
      var element, region;
      region = new factory.Region(document.createElement('div'));
      element = new factory.Element('div');
      region.attach(element);
      if (factory.root.focused()) {
        factory.root.focused().blur();
      }
      expect(factory.root.focused()).toBe(null);
      element.focus();
      return expect(factory.root.focused()).toBe(element);
    });
  });

  describe('`Root.dragging()`', function() {
    return it('should return the element currently being dragged or null if no element is being dragged', function() {
      var element, region;
      region = new factory.Region(document.createElement('div'));
      element = new factory.Element('div');
      region.attach(element);
      element.drag(0, 0);
      expect(factory.root.dragging()).toBe(element);
      factory.root.cancelDragging();
      return expect(factory.root.dragging()).toBe(null);
    });
  });

  describe('`Root.dropTarget()`', function() {
    return it('should return the element the dragging element is currently over', function() {
      var elementA, elementB, region;
      region = new factory.Region(document.getElementById('test'));
      elementA = new factory.Text('p');
      region.attach(elementA);
      elementB = new factory.Text('p');
      region.attach(elementB);
      elementA.drag(0, 0);
      elementB._onMouseOver({});
      expect(factory.root.dropTarget()).toBe(elementB);
      factory.root.cancelDragging();
      expect(factory.root.dropTarget()).toBe(null);
      region.detach(elementA);
      return region.detach(elementB);
    });
  });

  describe('`Root.type()`', function() {
    return it('should return \'Root\'', function() {
      return expect(factory.root.type()).toBe('Root');
    });
  });

  describe('`Root.startDragging()`', function() {
    return it('should start a drag interaction', function() {
      var cssClasses, element, region;
      region = new factory.Region(document.getElementById('test'));
      element = new factory.Text('p');
      region.attach(element);
      factory.root.startDragging(element, 0, 0);
      expect(factory.root.dragging()).toBe(element);
      cssClasses = element.domElement().getAttribute('class').split(' ');
      expect(cssClasses.indexOf('ce-element--dragging') > -1).toBe(true);
      cssClasses = document.body.getAttribute('class').split(' ');
      expect(cssClasses.indexOf('ce--dragging') > -1).toBe(true);
      expect(factory.root._draggingDOMElement).not.toBe(null);
      factory.root.cancelDragging();
      return region.detach(element);
    });
  });

  describe('`Root.cancelDragging()`', function() {
    return it('should cancel a drag interaction', function() {
      var element, region;
      region = new factory.Region(document.createElement('div'));
      element = new factory.Element('div');
      region.attach(element);
      if (factory.root.dragging()) {
        factory.root.cancelDragging();
      }
      element.drag(0, 0);
      expect(factory.root.dragging()).toBe(element);
      factory.root.cancelDragging();
      return expect(factory.root.dragging()).toBe(null);
    });
  });

  describe('`Root.resizing()`', function() {
    return it('should return the element currently being resized or null if no element is being resized', function() {
      var element, region;
      region = new factory.Region(document.createElement('div'));
      element = new factory.ResizableElement('div');
      region.attach(element);
      element.resize(['top', 'left'], 0, 0);
      expect(factory.root.resizing()).toBe(element);
      return factory.root._onStopResizing();
    });
  });

  describe('`Root.startResizing()`', function() {
    return it('should start a resize interaction', function() {
      var cssClasses, element, region;
      region = new factory.Region(document.getElementById('test'));
      element = new factory.ResizableElement('div');
      region.attach(element);
      factory.root.startResizing(element, ['top', 'left'], 0, 0, true);
      expect(factory.root.resizing()).toBe(element);
      cssClasses = element.domElement().getAttribute('class').split(' ');
      expect(cssClasses.indexOf('ce-element--resizing') > -1).toBe(true);
      cssClasses = document.body.getAttribute('class').split(' ');
      expect(cssClasses.indexOf('ce--resizing') > -1).toBe(true);
      factory.root._onStopResizing();
      return region.detach(element);
    });
  });

  factory = new ContentEdit.Factory();

  describe('`Static()`', function() {
    return it('should return an instance of Static`', function() {
      var staticElm;
      staticElm = new factory.Static('div', {}, '<div></div>');
      return expect(staticElm instanceof factory.Static).toBe(true);
    });
  });

  describe('`Static.cssTypeName()`', function() {
    return it('should return \'static\'', function() {
      var staticElm;
      staticElm = new factory.Static('div', {}, '<div></div>');
      return expect(staticElm.cssTypeName()).toBe('static');
    });
  });

  describe('`Static.createDraggingDOMElement()`', function() {
    return it('should create a helper DOM element', function() {
      var helper, region, staticElm;
      staticElm = new factory.Static('div', {}, 'foo <b>bar</b>');
      region = new factory.Region(document.createElement('div'));
      region.attach(staticElm);
      helper = staticElm.createDraggingDOMElement();
      expect(helper).not.toBe(null);
      expect(helper.tagName.toLowerCase()).toBe('div');
      return expect(helper.innerHTML).toBe('foo bar');
    });
  });

  describe('`Static.type()`', function() {
    return it('should return \'Static\'', function() {
      var staticElm;
      staticElm = new factory.Static('div', {}, '<div></div>');
      return expect(staticElm.type()).toBe('Static');
    });
  });

  describe('`Static.typeName()`', function() {
    return it('should return \'Static\'', function() {
      var staticElm;
      staticElm = new factory.Static('div', {}, '<div></div>');
      return expect(staticElm.typeName()).toBe('Static');
    });
  });

  describe('Static.html()', function() {
    return it('should return a HTML string for the static element', function() {
      var staticElm;
      staticElm = new factory.Static('div', {
        'class': 'foo'
      }, '<div><b>foo</b></div>');
      return expect(staticElm.html()).toBe('<div class="foo"><div><b>foo</b></div></div>');
    });
  });

  describe('Static.mount()', function() {
    var region, staticElm;
    region = null;
    staticElm = null;
    beforeEach(function() {
      staticElm = new factory.Static('div', {
        'class': 'foo'
      }, '<div><b>foo</b></div>');
      region = new factory.Region(document.createElement('div'));
      region.attach(staticElm);
      return staticElm.unmount();
    });
    it('should mount the static element to the DOM', function() {
      staticElm.mount();
      expect(staticElm.isMounted()).toBe(true);
      return expect(staticElm.domElement().innerHTML).toBe('<div><b>foo</b></div>');
    });
    return it('should trigger the `mount` event against the root', function() {
      var foo;
      foo = {
        handleFoo: function() {}
      };
      spyOn(foo, 'handleFoo');
      factory.root.bind('mount', foo.handleFoo);
      staticElm.mount();
      return expect(foo.handleFoo).toHaveBeenCalledWith(staticElm);
    });
  });

  describe('`Static.fromDOMElement()`', function() {
    return it('should convert a DOM element into an static element', function() {
      var domElement, region, staticElm;
      region = new factory.Region(document.createElement('div'));
      domElement = document.createElement('div');
      domElement.innerHTML = '<div><b>foo</b></div>';
      staticElm = factory.Static.fromDOMElement(domElement);
      region.attach(staticElm);
      return expect(staticElm.domElement().innerHTML).toBe('<div><b>foo</b></div>');
    });
  });

  describe('`Static` drop interactions if `data-ce-moveable` is set', function() {
    var region, staticElm;
    staticElm = null;
    region = null;
    beforeEach(function() {
      region = new factory.Region(document.createElement('div'));
      staticElm = new factory.Static('div', {
        'data-ce-moveable': ''
      }, 'foo');
      return region.attach(staticElm);
    });
    return it('should support dropping on Text', function() {
      var otherStaticElm;
      otherStaticElm = new factory.Static('div', {
        'data-ce-moveable': ''
      }, 'bar');
      region.attach(otherStaticElm);
      expect(staticElm.nextSibling()).toBe(otherStaticElm);
      staticElm.drop(otherStaticElm, ['below', 'center']);
      expect(otherStaticElm.nextSibling()).toBe(staticElm);
      staticElm.drop(otherStaticElm, ['above', 'center']);
      return expect(staticElm.nextSibling()).toBe(otherStaticElm);
    });
  });

  factory = new ContentEdit.Factory();

  describe('`Text()`', function() {
    return it('should return an instance of Text`', function() {
      var text;
      text = new factory.Text('p', {}, 'foo <b>bar</b>');
      return expect(text instanceof factory.Text).toBe(true);
    });
  });

  describe('`Text.cssTypeName()`', function() {
    return it('should return \'text\'', function() {
      var text;
      text = new factory.Text('p', {}, 'foo');
      return expect(text.cssTypeName()).toBe('text');
    });
  });

  describe('`Text.type()`', function() {
    return it('should return \'Text\'', function() {
      var text;
      text = new factory.Text('p', {}, 'foo <b>bar</b>');
      return expect(text.type()).toBe('Text');
    });
  });

  describe('`Text.typeName()`', function() {
    return it('should return \'Text\'', function() {
      var text;
      text = new factory.Text('p', {}, 'foo <b>bar</b>');
      return expect(text.typeName()).toBe('Text');
    });
  });

  describe('Text.blur()', function() {
    var region, text;
    text = null;
    region = null;
    beforeEach(function() {
      text = new factory.Text('p', {}, 'foo');
      region = new factory.Region(document.getElementById('test'));
      region.attach(text);
      return text.focus();
    });
    afterEach(function() {
      return region.detach(text);
    });
    it('should blur the text element', function() {
      text.blur();
      return expect(text.isFocused()).toBe(false);
    });
    it('should remove the text element if it\'s just whitespace', function() {
      text.domElement().innerHTML = '';
      text.content = new HTMLString.String('');
      text.blur();
      return expect(text.parent()).toBe(null);
    });
    it('should trigger the `blur` event against the root', function() {
      var foo;
      foo = {
        handleFoo: function() {}
      };
      spyOn(foo, 'handleFoo');
      factory.root.bind('blur', foo.handleFoo);
      text.blur();
      return expect(foo.handleFoo).toHaveBeenCalledWith(text);
    });
    return it('should not remove the text element if it\'s just whitespace but remove behaviour is disallowed', function() {
      text.can('remove', false);
      text.domElement().innerHTML = '';
      text.content = new HTMLString.String('');
      text.blur();
      return expect(text.parent()).not.toBe(null);
    });
  });

  describe('`Text.createDraggingDOMElement()`', function() {
    return it('should create a helper DOM element', function() {
      var helper, region, text;
      text = new factory.Text('p', {}, 'foo <b>bar</b>');
      region = new factory.Region(document.createElement('div'));
      region.attach(text);
      helper = text.createDraggingDOMElement();
      expect(helper).not.toBe(null);
      expect(helper.tagName.toLowerCase()).toBe('div');
      return expect(helper.innerHTML).toBe('foo bar');
    });
  });

  describe('Text.drag()', function() {
    var text;
    text = null;
    beforeEach(function() {
      var region;
      text = new factory.Text('p', {}, 'foo');
      region = new factory.Region(document.createElement('div'));
      return region.attach(text);
    });
    afterEach(function() {
      return factory.root.cancelDragging();
    });
    it('should call `storeState` against the text element', function() {
      spyOn(text, 'storeState');
      text.drag(0, 0);
      return expect(text.storeState).toHaveBeenCalled();
    });
    return it('should call `startDragging` against the root element', function() {
      spyOn(factory.root, 'startDragging');
      text.drag(0, 0);
      return expect(factory.root.startDragging).toHaveBeenCalledWith(text, 0, 0);
    });
  });

  describe('ContentEdit.Text.drop()', function() {
    return it('should call the `restoreState` against the text element', function() {
      var region, textA, textB;
      textA = new factory.Text('p', {}, 'foo');
      textB = new factory.Text('p', {}, 'bar');
      region = new factory.Region(document.createElement('div'));
      region.attach(textA);
      region.attach(textB);
      spyOn(textA, 'restoreState');
      textA.storeState();
      textA.drop(textB, ['above', 'center']);
      return expect(textA.restoreState).toHaveBeenCalled();
    });
  });

  describe('Text.focus()', function() {
    var region, text;
    text = null;
    region = null;
    beforeEach(function() {
      text = new factory.Text('p', {}, 'foo');
      region = new factory.Region(document.getElementById('test'));
      region.attach(text);
      return text.blur();
    });
    afterEach(function() {
      return region.detach(text);
    });
    it('should focus the text element', function() {
      text.focus();
      return expect(text.isFocused()).toBe(true);
    });
    return it('should trigger the `focus` event against the root', function() {
      var foo;
      foo = {
        handleFoo: function() {}
      };
      spyOn(foo, 'handleFoo');
      factory.root.bind('focus', foo.handleFoo);
      text.focus();
      return expect(foo.handleFoo).toHaveBeenCalledWith(text);
    });
  });

  describe('Text.html()', function() {
    return it('should return a HTML string for the text element', function() {
      var text;
      text = new factory.Text('p', {
        'class': 'foo'
      }, 'bar <b>zee</b>');
      return expect(text.html()).toBe('<p class="foo">\n' + ("" + ContentEdit.INDENT + "bar <b>zee</b>\n") + '</p>');
    });
  });

  describe('Text.mount()', function() {
    var region, text;
    text = null;
    region = null;
    beforeEach(function() {
      text = new factory.Text('p', {}, 'foo');
      region = new factory.Region(document.createElement('div'));
      region.attach(text);
      return text.unmount();
    });
    it('should mount the text element to the DOM', function() {
      text.mount();
      return expect(text.isMounted()).toBe(true);
    });
    it('should call `updateInnerHTML` against the text element', function() {
      spyOn(text, 'updateInnerHTML');
      text.mount();
      return expect(text.updateInnerHTML).toHaveBeenCalled();
    });
    return it('should trigger the `mount` event against the root', function() {
      var foo;
      foo = {
        handleFoo: function() {}
      };
      spyOn(foo, 'handleFoo');
      factory.root.bind('mount', foo.handleFoo);
      text.mount();
      return expect(foo.handleFoo).toHaveBeenCalledWith(text);
    });
  });

  describe('Text.restoreState()', function() {
    return it('should restore a text elements state after it has been remounted', function() {
      var region, selection, text;
      text = new factory.Text('p', {}, 'foo');
      region = new factory.Region(document.getElementById('test'));
      region.attach(text);
      text.focus();
      new ContentSelect.Range(1, 2).select(text.domElement());
      text.storeState();
      text.unmount();
      text.mount();
      text.restoreState();
      selection = ContentSelect.Range.query(text.domElement());
      expect(selection.get()).toEqual([1, 2]);
      return region.detach(text);
    });
  });

  describe('Text.selection()', function() {
    return it('should get/set the content selection for the element', function() {
      var region, text;
      text = new factory.Text('p', {}, 'foobar');
      region = new factory.Region(document.getElementById('test'));
      region.attach(text);
      text.selection(new ContentSelect.Range(1, 2));
      expect(text.selection().get()).toEqual([1, 2]);
      return region.detach(text);
    });
  });

  describe('Text.storeState()', function() {
    return it('should store the text elements state so it can be restored', function() {
      var region, selection, text;
      text = new factory.Text('p', {}, 'foo');
      region = new factory.Region(document.getElementById('test'));
      region.attach(text);
      text.focus();
      new ContentSelect.Range(1, 2).select(text.domElement());
      text.storeState();
      expect(text._savedSelection.get()).toEqual([1, 2]);
      text.unmount();
      text.mount();
      text.restoreState();
      selection = ContentSelect.Range.query(text.domElement());
      expect(selection.get()).toEqual([1, 2]);
      return region.detach(text);
    });
  });

  describe('Text.updateInnerHTML()', function() {
    return it('should update the contents of the text elements related DOM element', function() {
      var region, text;
      text = new factory.Text('p', {}, 'foo');
      region = new factory.Region(document.getElementById('test'));
      region.attach(text);
      text.content = text.content.concat(' bar');
      text.updateInnerHTML();
      expect(text.domElement().innerHTML).toBe('foo bar');
      return region.detach(text);
    });
  });

  describe('`Text.fromDOMElement()`', function() {
    return it('should convert the following DOM elements into a text element: <address>, <h1>, <h2>, <h3>, <h4>, <h5>, <h6>, <p>', function() {
      var INDENT, address, domAddress, domH, domP, h, i, p, _i;
      INDENT = ContentEdit.INDENT;
      domAddress = document.createElement('address');
      domAddress.innerHTML = 'foo';
      address = factory.Text.fromDOMElement(domAddress);
      expect(address.html()).toBe("<address>\n" + INDENT + "foo\n</address>");
      for (i = _i = 1; _i < 7; i = ++_i) {
        domH = document.createElement("h" + i);
        domH.innerHTML = 'foo';
        h = factory.Text.fromDOMElement(domH);
        expect(h.html()).toBe("<h" + i + ">\n" + INDENT + "foo\n</h" + i + ">");
      }
      domP = document.createElement('p');
      domP.innerHTML = 'foo';
      p = factory.Text.fromDOMElement(domP);
      return expect(p.html()).toBe("<p>\n" + INDENT + "foo\n</p>");
    });
  });

  describe('`ContentEdit.Text` key events`', function() {
    var INDENT, ev, region;
    INDENT = ContentEdit.INDENT;
    ev = {
      preventDefault: function() {}
    };
    region = null;
    beforeEach(function() {
      var content, _i, _len, _ref, _results;
      region = new factory.Region(document.getElementById('test'));
      _ref = ['foo', 'bar', 'zee'];
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        content = _ref[_i];
        _results.push(region.attach(new factory.Text('p', {}, content)));
      }
      return _results;
    });
    afterEach(function() {
      var child, _i, _len, _ref, _results;
      _ref = region.children.slice();
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        child = _ref[_i];
        _results.push(region.detach(child));
      }
      return _results;
    });
    it('should support down arrow nav to next content element', function() {
      var text;
      text = region.children[0];
      text.focus();
      new ContentSelect.Range(3, 3).select(text.domElement());
      text._keyDown(ev);
      return expect(factory.root.focused()).toBe(region.children[1]);
    });
    it('should support left arrow nav to previous content element', function() {
      var text;
      text = region.children[1];
      text.focus();
      new ContentSelect.Range(0, 0).select(text.domElement());
      text._keyLeft(ev);
      return expect(factory.root.focused()).toBe(region.children[0]);
    });
    it('should support right arrow nav to next content element', function() {
      var text;
      text = region.children[0];
      text.focus();
      new ContentSelect.Range(3, 3).select(text.domElement());
      text._keyRight(ev);
      return expect(factory.root.focused()).toBe(region.children[1]);
    });
    it('should support up arrow nav to previous content element', function() {
      var text;
      text = region.children[1];
      text.focus();
      new ContentSelect.Range(0, 0).select(text.domElement());
      text._keyUp(ev);
      return expect(factory.root.focused()).toBe(region.children[0]);
    });
    it('should support delete merge with next content element', function() {
      var text;
      text = region.children[0];
      text.focus();
      new ContentSelect.Range(3, 3).select(text.domElement());
      text._keyDelete(ev);
      return expect(text.content.text()).toBe('foobar');
    });
    it('should support backspace merge with previous content element', function() {
      var text;
      text = region.children[1];
      text.focus();
      new ContentSelect.Range(0, 0).select(text.domElement());
      text._keyBack(ev);
      return expect(region.children[0].content.text()).toBe('foobar');
    });
    it('should support return splitting the element into 2', function() {
      var text;
      text = region.children[0];
      text.focus();
      new ContentSelect.Range(2, 2).select(text.domElement());
      text._keyReturn(ev);
      expect(region.children[0].content.text()).toBe('fo');
      return expect(region.children[1].content.text()).toBe('o');
    });
    it('should support shift+return inserting a line break', function() {
      var text;
      text = region.children[0];
      text.focus();
      new ContentSelect.Range(2, 2).select(text.domElement());
      ev.shiftKey = true;
      text._keyReturn(ev);
      return expect(region.children[0].content.html()).toBe('fo<br>o');
    });
    return it('should not split the element into 2 on return if spawn is disallowed', function() {
      var childCount, text;
      childCount = region.children.length;
      text = region.children[0];
      text.can('spawn', false);
      text.focus();
      new ContentSelect.Range(2, 2).select(text.domElement());
      text._keyReturn(ev);
      return expect(region.children.length).toBe(childCount);
    });
  });

  describe('`ContentEdit.Text` key events with prefer line breaks`', function() {
    var INDENT, ev, region;
    INDENT = ContentEdit.INDENT;
    ev = {
      preventDefault: function() {}
    };
    region = null;
    beforeEach(function() {
      var content, _i, _len, _ref, _results;
      ContentEdit.PREFER_LINE_BREAKS = true;
      region = new factory.Region(document.getElementById('test'));
      _ref = ['foo', 'bar', 'zee'];
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        content = _ref[_i];
        _results.push(region.attach(new factory.Text('p', {}, content)));
      }
      return _results;
    });
    afterEach(function() {
      var child, _i, _len, _ref, _results;
      ContentEdit.PREFER_LINE_BREAKS = false;
      _ref = region.children.slice();
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        child = _ref[_i];
        _results.push(region.detach(child));
      }
      return _results;
    });
    it('should support return inserting a line break', function() {
      var text;
      text = region.children[0];
      text.focus();
      new ContentSelect.Range(2, 2).select(text.domElement());
      text._keyReturn(ev);
      return expect(region.children[0].content.html()).toBe('fo<br>o');
    });
    return it('should support shift+return splitting the element into 2', function() {
      var text;
      text = region.children[0];
      text.focus();
      new ContentSelect.Range(2, 2).select(text.domElement());
      ev.shiftKey = true;
      text._keyReturn(ev);
      expect(region.children[0].content.text()).toBe('fo');
      return expect(region.children[1].content.text()).toBe('o');
    });
  });

  describe('`Text` drop interactions`', function() {
    var region, text;
    region = null;
    text = null;
    beforeEach(function() {
      region = new factory.Region(document.createElement('div'));
      text = new factory.Text('p', {}, 'foo');
      return region.attach(text);
    });
    it('should support dropping on Text', function() {
      var otherText;
      otherText = new factory.Text('p', {}, 'bar');
      region.attach(otherText);
      expect(text.nextSibling()).toBe(otherText);
      text.drop(otherText, ['below', 'center']);
      expect(otherText.nextSibling()).toBe(text);
      text.drop(otherText, ['above', 'center']);
      return expect(text.nextSibling()).toBe(otherText);
    });
    it('should support dropping on Static', function() {
      var staticElm;
      staticElm = factory.Static.fromDOMElement(document.createElement('div'));
      region.attach(staticElm);
      expect(text.nextSibling()).toBe(staticElm);
      text.drop(staticElm, ['below', 'center']);
      expect(staticElm.nextSibling()).toBe(text);
      text.drop(staticElm, ['above', 'center']);
      return expect(text.nextSibling()).toBe(staticElm);
    });
    return it('should support being dropped on by `moveable` Static', function() {
      var staticElm;
      staticElm = new factory.Static('div', {
        'data-ce-moveable': 'data-ce-moveable'
      }, 'foo');
      region.attach(staticElm, 0);
      expect(staticElm.nextSibling()).toBe(text);
      staticElm.drop(text, ['below', 'center']);
      expect(text.nextSibling()).toBe(staticElm);
      staticElm.drop(text, ['above', 'center']);
      return expect(staticElm.nextSibling()).toBe(text);
    });
  });

  describe('`Text` merge interactions`', function() {
    var region, text;
    text = null;
    region = null;
    beforeEach(function() {
      region = new factory.Region(document.getElementById('test'));
      text = new factory.Text('p', {}, 'foo');
      return region.attach(text);
    });
    afterEach(function() {
      var child, _i, _len, _ref, _results;
      _ref = region.children.slice();
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        child = _ref[_i];
        _results.push(region.detach(child));
      }
      return _results;
    });
    return it('should support merging with Text', function() {
      var otherText;
      otherText = new factory.Text('p', {}, 'bar');
      region.attach(otherText);
      text.merge(otherText);
      expect(text.html()).toBe("<p>\n" + ContentEdit.INDENT + "foobar\n</p>");
      return expect(otherText.parent()).toBe(null);
    });
  });

  describe('`PreText()`', function() {
    return it('should return an instance of PreText`', function() {
      var preText;
      preText = new factory.PreText('pre', {}, 'foo <b>bar</b>');
      return expect(preText instanceof factory.PreText).toBe(true);
    });
  });

  describe('`PreText.cssTypeName()`', function() {
    return it('should return \'pre-text\'', function() {
      var preText;
      preText = new factory.PreText('pre', {}, 'foo <b>bar</b>');
      return expect(preText.cssTypeName()).toBe('pre-text');
    });
  });

  describe('`PreText.type()`', function() {
    return it('should return \'PreText\'', function() {
      var preText;
      preText = new factory.PreText('pre', {}, 'foo <b>bar</b>');
      return expect(preText.type()).toBe('PreText');
    });
  });

  describe('`PreText.typeName()`', function() {
    return it('should return \'Preformatted\'', function() {
      var preText;
      preText = new factory.PreText('pre', {}, 'foo <b>bar</b>');
      return expect(preText.typeName()).toBe('Preformatted');
    });
  });

  describe('PreText.html()', function() {
    return it('should return a HTML string for the pre-text element', function() {
      var I, preText;
      I = ContentEdit.INDENT;
      preText = new factory.PreText('pre', {
        'class': 'foo'
      }, "&lt;div&gt;\n    test &amp; test\n&lt;/div&gt;");
      return expect(preText.html()).toBe("<pre class=\"foo\">&lt;div&gt;\n" + ContentEdit.INDENT + "test &amp; test\n&lt;/div&gt;</pre>");
    });
  });

  describe('`PreText.fromDOMElement()`', function() {
    return it('should convert a <pre> DOM element into a preserved text element', function() {
      var I, domDiv, preText;
      I = ContentEdit.INDENT;
      domDiv = document.createElement('div');
      domDiv.innerHTML = "<pre>&lt;div&gt;\n" + ContentEdit.INDENT + "test &amp; test\n&lt;/div&gt;</pre>";
      preText = factory.PreText.fromDOMElement(domDiv.childNodes[0]);
      return expect(preText.html()).toBe("<pre>&lt;div&gt;\n" + ContentEdit.INDENT + "test &amp; test\n&lt;/div&gt;</pre>");
    });
  });

  describe('`PreText` key events`', function() {
    var I, ev, preText, region;
    I = ContentEdit.INDENT;
    ev = {
      preventDefault: function() {}
    };
    region = null;
    preText = null;
    beforeEach(function() {
      region = new factory.Region(document.getElementById('test'));
      preText = new factory.PreText('pre', {
        'class': 'foo'
      }, "&lt;div&gt;\n" + ContentEdit.INDENT + "test &amp; test\n&lt;/div&gt;");
      return region.attach(preText);
    });
    afterEach(function() {
      var child, _i, _len, _ref, _results;
      _ref = region.children.slice();
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        child = _ref[_i];
        _results.push(region.detach(child));
      }
      return _results;
    });
    return it('should support return adding a newline', function() {
      preText.focus();
      new ContentSelect.Range(13, 13).select(preText.domElement());
      preText._keyReturn(ev);
      return expect(preText.html()).toBe("<pre class=\"foo\">&lt;div&gt;\n" + ContentEdit.INDENT + "tes\nt &amp; test\n&lt;/div&gt;</pre>");
    });
  });

  describe('`ContentEdit.PreText` drop interactions`', function() {
    var preText, region;
    region = null;
    preText = null;
    beforeEach(function() {
      region = new factory.Region(document.createElement('div'));
      preText = new factory.PreText('p', {}, 'foo');
      return region.attach(preText);
    });
    it('should support dropping on PreText', function() {
      var otherPreText;
      otherPreText = new factory.PreText('pre', {}, '');
      region.attach(otherPreText);
      expect(preText.nextSibling()).toBe(otherPreText);
      preText.drop(otherPreText, ['below', 'center']);
      expect(otherPreText.nextSibling()).toBe(preText);
      preText.drop(otherPreText, ['above', 'center']);
      return expect(preText.nextSibling()).toBe(otherPreText);
    });
    it('should support dropping on Static', function() {
      var staticElm;
      staticElm = factory.Static.fromDOMElement(document.createElement('div'));
      region.attach(staticElm);
      expect(preText.nextSibling()).toBe(staticElm);
      preText.drop(staticElm, ['below', 'center']);
      expect(staticElm.nextSibling()).toBe(preText);
      preText.drop(staticElm, ['above', 'center']);
      return expect(preText.nextSibling()).toBe(staticElm);
    });
    it('should support being dropped on by `moveable` Static', function() {
      var staticElm;
      staticElm = new factory.Static('div', {
        'data-ce-moveable': 'data-ce-moveable'
      }, 'foo');
      region.attach(staticElm, 0);
      expect(staticElm.nextSibling()).toBe(preText);
      staticElm.drop(preText, ['below', 'center']);
      expect(preText.nextSibling()).toBe(staticElm);
      staticElm.drop(preText, ['above', 'center']);
      return expect(staticElm.nextSibling()).toBe(preText);
    });
    it('should support dropping on Text', function() {
      var text;
      text = new factory.Text('p');
      region.attach(text);
      expect(preText.nextSibling()).toBe(text);
      preText.drop(text, ['below', 'center']);
      expect(text.nextSibling()).toBe(preText);
      preText.drop(text, ['above', 'center']);
      return expect(preText.nextSibling()).toBe(text);
    });
    return it('should support being dropped on by Text', function() {
      var text;
      text = new factory.Text('p');
      region.attach(text, 0);
      expect(text.nextSibling()).toBe(preText);
      text.drop(preText, ['below', 'center']);
      expect(preText.nextSibling()).toBe(text);
      text.drop(preText, ['above', 'center']);
      return expect(text.nextSibling()).toBe(preText);
    });
  });

  factory = new ContentEdit.Factory();

  describe('`Image()`', function() {
    return it('should return an instance of Image`', function() {
      var image;
      image = new factory.Image({
        'src': '/foo.jpg'
      });
      expect(image instanceof factory.Image).toBe(true);
      image = new factory.Image({
        'src': '/foo.jpg'
      }, {
        'href': 'bar'
      });
      return expect(image instanceof factory.Image).toBe(true);
    });
  });

  describe('`Image.cssTypeName()`', function() {
    return it('should return \'image\'', function() {
      var image;
      image = new factory.Image({
        'src': '/foo.jpg'
      });
      return expect(image.cssTypeName()).toBe('image');
    });
  });

  describe('`Image.type()`', function() {
    return it('should return \'Image\'', function() {
      var image;
      image = new factory.Image({
        'src': '/foo.jpg'
      });
      return expect(image.type()).toBe('Image');
    });
  });

  describe('`Image.typeName()`', function() {
    return it('should return \'Image\'', function() {
      var image;
      image = new factory.Image({
        'src': '/foo.jpg'
      });
      return expect(image.typeName()).toBe('Image');
    });
  });

  describe('`Image.createDraggingDOMElement()`', function() {
    return it('should create a helper DOM element', function() {
      var helper, image, region;
      image = new factory.Image({
        'src': 'http://getme.co.uk/foo.jpg'
      });
      region = new factory.Region(document.createElement('div'));
      region.attach(image);
      helper = image.createDraggingDOMElement();
      expect(helper).not.toBe(null);
      expect(helper.tagName.toLowerCase()).toBe('div');
      return expect(helper.style.backgroundImage.replace(/"/g, '')).toBe('url(http://getme.co.uk/foo.jpg)');
    });
  });

  describe('`Image.html()`', function() {
    return it('should return a HTML string for the image', function() {
      var image;
      image = new factory.Image({
        'src': '/foo.jpg'
      });
      expect(image.html()).toBe('<img src="/foo.jpg">');
      image = new factory.Image({
        'src': '/foo.jpg'
      }, {
        'href': 'bar'
      });
      return expect(image.html()).toBe('<a href="bar" data-ce-tag="img">\n' + ("" + ContentEdit.INDENT + "<img src=\"/foo.jpg\">\n") + '</a>');
    });
  });

  describe('`Image.mount()`', function() {
    var imageA, imageB, region;
    imageA = null;
    imageB = null;
    region = null;
    beforeEach(function() {
      imageA = new factory.Image({
        'src': '/foo.jpg'
      });
      imageB = new factory.Image({
        'src': '/foo.jpg'
      }, {
        'href': 'bar'
      });
      region = new factory.Region(document.createElement('div'));
      region.attach(imageA);
      region.attach(imageB);
      imageA.unmount();
      return imageB.unmount();
    });
    it('should mount the image to the DOM', function() {
      imageA.mount();
      imageB.mount();
      expect(imageA.isMounted()).toBe(true);
      return expect(imageB.isMounted()).toBe(true);
    });
    return it('should trigger the `mount` event against the root', function() {
      var foo;
      foo = {
        handleFoo: function() {}
      };
      spyOn(foo, 'handleFoo');
      factory.root.bind('mount', foo.handleFoo);
      imageA.mount();
      return expect(foo.handleFoo).toHaveBeenCalledWith(imageA);
    });
  });

  describe('`Image.fromDOMElement()`', function() {
    it('should convert a <img> DOM element into an image element', function() {
      var domImg, img;
      domImg = document.createElement('img');
      domImg.setAttribute('src', '/foo.jpg');
      domImg.setAttribute('width', '400');
      domImg.setAttribute('height', '300');
      img = factory.Image.fromDOMElement(domImg);
      return expect(img.html()).toBe('<img height="300" src="/foo.jpg" width="400">');
    });
    it('should read the natural width of the image if not supplied as an attribute', function() {
      var domImg, img;
      domImg = document.createElement('img');
      domImg.setAttribute('src', 'data:image/gif;' + 'base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==');
      img = factory.Image.fromDOMElement(domImg);
      return expect(img.size()).toEqual([1, 1]);
    });
    return it('should convert a wrapped <a><img></a> DOM element into an image element', function() {
      var domA, domImg, img;
      domA = document.createElement('a');
      domA.setAttribute('href', 'test');
      domImg = document.createElement('img');
      domImg.setAttribute('src', '/foo.jpg');
      domImg.setAttribute('width', '400');
      domImg.setAttribute('height', '300');
      domA.appendChild(domImg);
      img = factory.Image.fromDOMElement(domA);
      return expect(img.html()).toBe('<a href="test" data-ce-tag="img">\n' + ("" + ContentEdit.INDENT) + '<img height="300" src="/foo.jpg" width="400">\n' + '</a>');
    });
  });

  describe('`Image` drop interactions', function() {
    var image, region;
    image = null;
    region = null;
    beforeEach(function() {
      region = new factory.Region(document.createElement('div'));
      image = new factory.Image({
        'src': '/foo.jpg'
      });
      return region.attach(image);
    });
    it('should support dropping on Image', function() {
      var otherImage;
      otherImage = new factory.Image({
        'src': '/bar.jpg'
      });
      region.attach(otherImage);
      expect(image.nextSibling()).toBe(otherImage);
      image.drop(otherImage, ['above', 'left']);
      expect(image.hasCSSClass('align-left')).toBe(true);
      expect(image.nextSibling()).toBe(otherImage);
      image.drop(otherImage, ['above', 'right']);
      expect(image.hasCSSClass('align-left')).toBe(false);
      expect(image.hasCSSClass('align-right')).toBe(true);
      expect(image.nextSibling()).toBe(otherImage);
      image.drop(otherImage, ['below', 'center']);
      expect(image.hasCSSClass('align-left')).toBe(false);
      expect(image.hasCSSClass('align-right')).toBe(false);
      expect(otherImage.nextSibling()).toBe(image);
      image.drop(otherImage, ['above', 'center']);
      return expect(image.nextSibling()).toBe(otherImage);
    });
    it('should support dropping on PreText', function() {
      var preText;
      preText = new factory.PreText('pre', {}, '');
      region.attach(preText);
      expect(image.nextSibling()).toBe(preText);
      image.drop(preText, ['above', 'left']);
      expect(image.hasCSSClass('align-left')).toBe(true);
      expect(image.nextSibling()).toBe(preText);
      image.drop(preText, ['above', 'right']);
      expect(image.hasCSSClass('align-left')).toBe(false);
      expect(image.hasCSSClass('align-right')).toBe(true);
      expect(image.nextSibling()).toBe(preText);
      image.drop(preText, ['below', 'center']);
      expect(image.hasCSSClass('align-left')).toBe(false);
      expect(image.hasCSSClass('align-right')).toBe(false);
      expect(preText.nextSibling()).toBe(image);
      image.drop(preText, ['above', 'center']);
      return expect(image.nextSibling()).toBe(preText);
    });
    it('should support being dropped on by PreText', function() {
      var preText;
      preText = new factory.PreText('pre', {}, '');
      region.attach(preText, 0);
      expect(preText.nextSibling()).toBe(image);
      preText.drop(image, ['below', 'center']);
      expect(image.nextSibling()).toBe(preText);
      preText.drop(image, ['above', 'center']);
      return expect(preText.nextSibling()).toBe(image);
    });
    it('should support dropping on Static', function() {
      var staticElm;
      staticElm = factory.Static.fromDOMElement(document.createElement('div'));
      region.attach(staticElm);
      expect(image.nextSibling()).toBe(staticElm);
      image.drop(staticElm, ['above', 'left']);
      expect(image.hasCSSClass('align-left')).toBe(true);
      expect(image.nextSibling()).toBe(staticElm);
      image.drop(staticElm, ['above', 'right']);
      expect(image.hasCSSClass('align-left')).toBe(false);
      expect(image.hasCSSClass('align-right')).toBe(true);
      expect(image.nextSibling()).toBe(staticElm);
      image.drop(staticElm, ['below', 'center']);
      expect(image.hasCSSClass('align-left')).toBe(false);
      expect(image.hasCSSClass('align-right')).toBe(false);
      expect(staticElm.nextSibling()).toBe(image);
      image.drop(staticElm, ['above', 'center']);
      return expect(image.nextSibling()).toBe(staticElm);
    });
    it('should support being dropped on by `moveable` Static', function() {
      var staticElm;
      staticElm = new factory.Static('div', {
        'data-ce-moveable': 'data-ce-moveable'
      }, 'foo');
      region.attach(staticElm, 0);
      expect(staticElm.nextSibling()).toBe(image);
      staticElm.drop(image, ['below', 'center']);
      expect(image.nextSibling()).toBe(staticElm);
      staticElm.drop(image, ['above', 'center']);
      return expect(staticElm.nextSibling()).toBe(image);
    });
    it('should support dropping on Text', function() {
      var text;
      text = new factory.Text('p');
      region.attach(text);
      expect(image.nextSibling()).toBe(text);
      image.drop(text, ['above', 'left']);
      expect(image.hasCSSClass('align-left')).toBe(true);
      expect(image.nextSibling()).toBe(text);
      image.drop(text, ['above', 'right']);
      expect(image.hasCSSClass('align-left')).toBe(false);
      expect(image.hasCSSClass('align-right')).toBe(true);
      expect(image.nextSibling()).toBe(text);
      image.drop(text, ['below', 'center']);
      expect(image.hasCSSClass('align-left')).toBe(false);
      expect(image.hasCSSClass('align-right')).toBe(false);
      expect(text.nextSibling()).toBe(image);
      image.drop(text, ['above', 'center']);
      return expect(image.nextSibling()).toBe(text);
    });
    return it('should support being dropped on by Text', function() {
      var text;
      text = new factory.Text('p');
      region.attach(text, 0);
      expect(text.nextSibling()).toBe(image);
      text.drop(image, ['below', 'center']);
      expect(image.nextSibling()).toBe(text);
      text.drop(image, ['above', 'center']);
      return expect(text.nextSibling()).toBe(image);
    });
  });

  factory = new ContentEdit.Factory();

  describe('`Video()`', function() {
    return it('should return an instance of Video`', function() {
      var video;
      video = new factory.Video('video', {}, []);
      return expect(video instanceof factory.Video).toBe(true);
    });
  });

  describe('`Video.cssTypeName()`', function() {
    return it('should return \'video\'', function() {
      var video;
      video = new factory.Video('video', {}, []);
      return expect(video.cssTypeName()).toBe('video');
    });
  });

  describe('`Video.type()`', function() {
    return it('should return \'video\'', function() {
      var video;
      video = new factory.Video('video', {}, []);
      return expect(video.type()).toBe('Video');
    });
  });

  describe('`Video.typeName()`', function() {
    return it('should return \'video\'', function() {
      var video;
      video = new factory.Video('video', {}, []);
      return expect(video.typeName()).toBe('Video');
    });
  });

  describe('`Video.createDraggingDOMElement()`', function() {
    var region;
    region = null;
    beforeEach(function() {
      return region = new factory.Region(document.createElement('div'));
    });
    it('should create a helper DOM element using the sources list for <video> elements', function() {
      var helper, video;
      video = new factory.Video('video', {}, [
        {
          'src': 'foo.mp4'
        }
      ]);
      region.attach(video);
      helper = video.createDraggingDOMElement();
      expect(helper).not.toBe(null);
      expect(helper.tagName.toLowerCase()).toBe('div');
      return expect(helper.innerHTML).toBe('foo.mp4');
    });
    return it('should create a helper DOM element using the src attribute for other elements (e.g iframes)', function() {
      var helper, video;
      video = new factory.Video('iframe', {
        'src': 'foo.mp4'
      });
      region.attach(video);
      helper = video.createDraggingDOMElement();
      expect(helper).not.toBe(null);
      expect(helper.tagName.toLowerCase()).toBe('div');
      return expect(helper.innerHTML).toBe('foo.mp4');
    });
  });

  describe('`Video.html()`', function() {
    return it('should return a HTML string for the image', function() {
      var INDENT, video;
      INDENT = ContentEdit.INDENT;
      video = new factory.Video('video', {
        'controls': ''
      }, [
        {
          'src': 'foo.mp4',
          'type': 'video/mp4'
        }, {
          'src': 'bar.ogg',
          'type': 'video/ogg'
        }
      ]);
      expect(video.html()).toBe('<video controls>\n' + ("" + INDENT + "<source src=\"foo.mp4\" type=\"video/mp4\">\n") + ("" + INDENT + "<source src=\"bar.ogg\" type=\"video/ogg\">\n") + '</video>');
      video = new factory.Video('iframe', {
        'src': 'foo.mp4'
      });
      return expect(video.html()).toBe('<iframe src="foo.mp4"></iframe>');
    });
  });

  describe('`Video.mount()`', function() {
    var region, videoA, videoB;
    videoA = null;
    videoB = null;
    region = null;
    beforeEach(function() {
      videoA = new factory.Video('video', {
        'controls': ''
      }, [
        {
          'src': 'foo.mp4',
          'type': 'video/mp4'
        }, {
          'src': 'bar.ogg',
          'type': 'video/ogg'
        }
      ]);
      videoB = new factory.Video('iframe', {
        'src': 'foo.mp4'
      });
      region = new factory.Region(document.createElement('div'));
      region.attach(videoA);
      region.attach(videoB);
      videoA.unmount();
      return videoB.unmount();
    });
    it('should mount the image to the DOM', function() {
      videoA.mount();
      videoB.mount();
      expect(videoA.isMounted()).toBe(true);
      return expect(videoB.isMounted()).toBe(true);
    });
    return it('should trigger the `mount` event against the root', function() {
      var foo;
      foo = {
        handleFoo: function() {}
      };
      spyOn(foo, 'handleFoo');
      factory.root.bind('mount', foo.handleFoo);
      videoA.mount();
      return expect(foo.handleFoo).toHaveBeenCalledWith(videoA);
    });
  });

  describe('`Video.fromDOMElement()`', function() {
    var INDENT;
    INDENT = ContentEdit.INDENT;
    it('should convert a <video> DOM element into a video element', function() {
      var domVideo, video;
      domVideo = document.createElement('video');
      domVideo.setAttribute('controls', '');
      domVideo.innerHTML += '<source src="foo.mp4" type="video/mp4">';
      domVideo.innerHTML += '<source src="bar.ogg" type="video/ogg">';
      video = factory.Video.fromDOMElement(domVideo);
      return expect(video.html()).toBe('<video controls>\n' + ("" + INDENT + "<source src=\"foo.mp4\" type=\"video/mp4\">\n") + ("" + INDENT + "<source src=\"bar.ogg\" type=\"video/ogg\">\n") + '</video>');
    });
    return it('should convert an iframe <iframe> DOM element into a video element', function() {
      var domVideo, video;
      domVideo = document.createElement('iframe');
      domVideo.setAttribute('src', 'foo.mp4');
      video = factory.Video.fromDOMElement(domVideo);
      return expect(video.html()).toBe('<iframe src="foo.mp4"></iframe>');
    });
  });

  describe('`Video` drop interactions`', function() {
    var region, video;
    video = null;
    region = null;
    beforeEach(function() {
      region = new factory.Region(document.createElement('div'));
      video = new factory.Video('iframe', {
        'src': '/foo.jpg'
      });
      return region.attach(video);
    });
    it('should support dropping on Image', function() {
      var image;
      image = new factory.Image({
        'src': '/bar.jpg'
      });
      region.attach(image);
      expect(video.nextSibling()).toBe(image);
      video.drop(image, ['above', 'left']);
      expect(video.hasCSSClass('align-left')).toBe(true);
      expect(video.nextSibling()).toBe(image);
      video.drop(image, ['above', 'right']);
      expect(video.hasCSSClass('align-left')).toBe(false);
      expect(video.hasCSSClass('align-right')).toBe(true);
      expect(video.nextSibling()).toBe(image);
      video.drop(image, ['below', 'center']);
      expect(video.hasCSSClass('align-left')).toBe(false);
      expect(video.hasCSSClass('align-right')).toBe(false);
      expect(image.nextSibling()).toBe(video);
      video.drop(image, ['above', 'center']);
      return expect(video.nextSibling()).toBe(image);
    });
    it('should support being dropped on by Image', function() {
      var image;
      image = new factory.Image({
        'src': '/bar.jpg'
      });
      region.attach(image, 0);
      expect(image.nextSibling()).toBe(video);
      image.drop(video, ['above', 'left']);
      expect(image.hasCSSClass('align-left')).toBe(true);
      expect(image.nextSibling()).toBe(video);
      image.drop(video, ['above', 'right']);
      expect(image.hasCSSClass('align-left')).toBe(false);
      expect(image.hasCSSClass('align-right')).toBe(true);
      expect(image.nextSibling()).toBe(video);
      image.drop(video, ['below', 'center']);
      expect(image.hasCSSClass('align-left')).toBe(false);
      expect(image.hasCSSClass('align-right')).toBe(false);
      expect(video.nextSibling()).toBe(image);
      image.drop(video, ['above', 'center']);
      return expect(image.nextSibling()).toBe(video);
    });
    it('should support dropping on PreText', function() {
      var preText;
      preText = new factory.PreText('pre', {}, '');
      region.attach(preText);
      expect(video.nextSibling()).toBe(preText);
      video.drop(preText, ['above', 'left']);
      expect(video.hasCSSClass('align-left')).toBe(true);
      expect(video.nextSibling()).toBe(preText);
      video.drop(preText, ['above', 'right']);
      expect(video.hasCSSClass('align-left')).toBe(false);
      expect(video.hasCSSClass('align-right')).toBe(true);
      expect(video.nextSibling()).toBe(preText);
      video.drop(preText, ['below', 'center']);
      expect(video.hasCSSClass('align-left')).toBe(false);
      expect(video.hasCSSClass('align-right')).toBe(false);
      expect(preText.nextSibling()).toBe(video);
      video.drop(preText, ['above', 'center']);
      return expect(video.nextSibling()).toBe(preText);
    });
    it('should support being dropped on by PreText', function() {
      var preText;
      preText = new factory.PreText('pre', {}, '');
      region.attach(preText, 0);
      expect(preText.nextSibling()).toBe(video);
      preText.drop(video, ['below', 'center']);
      expect(video.nextSibling()).toBe(preText);
      preText.drop(video, ['above', 'center']);
      return expect(preText.nextSibling()).toBe(video);
    });
    it('should support dropping on Static', function() {
      var staticElm;
      staticElm = factory.Static.fromDOMElement(document.createElement('div'));
      region.attach(staticElm);
      expect(video.nextSibling()).toBe(staticElm);
      video.drop(staticElm, ['above', 'left']);
      expect(video.hasCSSClass('align-left')).toBe(true);
      expect(video.nextSibling()).toBe(staticElm);
      video.drop(staticElm, ['above', 'right']);
      expect(video.hasCSSClass('align-left')).toBe(false);
      expect(video.hasCSSClass('align-right')).toBe(true);
      expect(video.nextSibling()).toBe(staticElm);
      video.drop(staticElm, ['below', 'center']);
      expect(video.hasCSSClass('align-left')).toBe(false);
      expect(video.hasCSSClass('align-right')).toBe(false);
      expect(staticElm.nextSibling()).toBe(video);
      video.drop(staticElm, ['above', 'center']);
      return expect(video.nextSibling()).toBe(staticElm);
    });
    it('should support being dropped on by `moveable` Static', function() {
      var staticElm;
      staticElm = new factory.Static('div', {
        'data-ce-moveable': 'data-ce-moveable'
      }, 'foo');
      region.attach(staticElm, 0);
      expect(staticElm.nextSibling()).toBe(video);
      staticElm.drop(video, ['below', 'center']);
      expect(video.nextSibling()).toBe(staticElm);
      staticElm.drop(video, ['above', 'center']);
      return expect(staticElm.nextSibling()).toBe(video);
    });
    it('should support dropping on Text', function() {
      var text;
      text = new factory.Text('p');
      region.attach(text);
      expect(video.nextSibling()).toBe(text);
      video.drop(text, ['above', 'left']);
      expect(video.hasCSSClass('align-left')).toBe(true);
      expect(video.nextSibling()).toBe(text);
      video.drop(text, ['above', 'right']);
      expect(video.hasCSSClass('align-left')).toBe(false);
      expect(video.hasCSSClass('align-right')).toBe(true);
      expect(video.nextSibling()).toBe(text);
      video.drop(text, ['below', 'center']);
      expect(video.hasCSSClass('align-left')).toBe(false);
      expect(video.hasCSSClass('align-right')).toBe(false);
      expect(text.nextSibling()).toBe(video);
      video.drop(text, ['above', 'center']);
      return expect(video.nextSibling()).toBe(text);
    });
    it('should support being dropped on by Text', function() {
      var text;
      text = new factory.Text('p');
      region.attach(text, 0);
      expect(text.nextSibling()).toBe(video);
      text.drop(video, ['below', 'center']);
      expect(video.nextSibling()).toBe(text);
      text.drop(video, ['above', 'center']);
      return expect(text.nextSibling()).toBe(video);
    });
    return it('should support dropping on Video', function() {
      var otherVideo;
      otherVideo = new factory.Video('iframe', {
        'src': '/foo.jpg'
      });
      region.attach(otherVideo);
      expect(video.nextSibling()).toBe(otherVideo);
      video.drop(otherVideo, ['above', 'left']);
      expect(video.hasCSSClass('align-left')).toBe(true);
      expect(video.nextSibling()).toBe(otherVideo);
      video.drop(otherVideo, ['above', 'right']);
      expect(video.hasCSSClass('align-left')).toBe(false);
      expect(video.hasCSSClass('align-right')).toBe(true);
      expect(video.nextSibling()).toBe(otherVideo);
      video.drop(otherVideo, ['below', 'center']);
      expect(video.hasCSSClass('align-left')).toBe(false);
      expect(video.hasCSSClass('align-right')).toBe(false);
      expect(otherVideo.nextSibling()).toBe(video);
      video.drop(otherVideo, ['above', 'center']);
      return expect(video.nextSibling()).toBe(otherVideo);
    });
  });

  factory = new ContentEdit.Factory();

  describe('`List()`', function() {
    return it('should return an instance of List`', function() {
      var list;
      list = new factory.List('ul');
      return expect(list instanceof factory.List).toBe(true);
    });
  });

  describe('`List.cssTypeName()`', function() {
    return it('should return \'list\'', function() {
      var list;
      list = new factory.List('ul');
      return expect(list.cssTypeName()).toBe('list');
    });
  });

  describe('`List.typeName()`', function() {
    return it('should return \'List\'', function() {
      var list;
      list = new factory.List('ul');
      return expect(list.type()).toBe('List');
    });
  });

  describe('`List.typeName()`', function() {
    return it('should return \'List\'', function() {
      var list;
      list = new factory.List('ul');
      return expect(list.typeName()).toBe('List');
    });
  });

  describe('`List.fromDOMElement()`', function() {
    return it('should convert the following DOM elements into a list element: <ol>, <ul>', function() {
      var INDENT, domOl, domUl, ol, ul;
      INDENT = ContentEdit.INDENT;
      domOl = document.createElement('ol');
      domOl.innerHTML = '<li>foo</li>';
      ol = factory.Text.fromDOMElement(domOl);
      expect(ol.html()).toBe("<ol>\n" + INDENT + "<li>foo</li>\n</ol>");
      domUl = document.createElement('ul');
      domUl.innerHTML = '<li>foo</li>';
      ul = factory.Text.fromDOMElement(domUl);
      return expect(ul.html()).toBe("<ul>\n" + INDENT + "<li>foo</li>\n</ul>");
    });
  });

  describe('`List` drop interactions`', function() {
    var list, region;
    list = null;
    region = null;
    beforeEach(function() {
      region = new factory.Region(document.createElement('div'));
      list = new factory.List('ul');
      return region.attach(list);
    });
    it('should support dropping on Image', function() {
      var image;
      image = new factory.Image({
        'src': '/bar.jpg'
      });
      region.attach(image);
      expect(list.nextSibling()).toBe(image);
      list.drop(image, ['below', 'center']);
      expect(image.nextSibling()).toBe(list);
      list.drop(image, ['above', 'center']);
      return expect(list.nextSibling()).toBe(image);
    });
    it('should support being dropped on by Image', function() {
      var image;
      image = new factory.Image({
        'src': '/bar.jpg'
      });
      region.attach(image, 0);
      expect(image.nextSibling()).toBe(list);
      image.drop(list, ['above', 'left']);
      expect(image.hasCSSClass('align-left')).toBe(true);
      expect(image.nextSibling()).toBe(list);
      image.drop(list, ['above', 'right']);
      expect(image.hasCSSClass('align-left')).toBe(false);
      expect(image.hasCSSClass('align-right')).toBe(true);
      expect(image.nextSibling()).toBe(list);
      image.drop(list, ['below', 'center']);
      expect(image.hasCSSClass('align-left')).toBe(false);
      expect(image.hasCSSClass('align-right')).toBe(false);
      expect(list.nextSibling()).toBe(image);
      image.drop(list, ['above', 'center']);
      return expect(image.nextSibling()).toBe(list);
    });
    it('should support dropping on List', function() {
      var otherList;
      otherList = new factory.Image({
        'src': '/bar.jpg'
      });
      region.attach(otherList);
      expect(list.nextSibling()).toBe(otherList);
      list.drop(otherList, ['below', 'center']);
      expect(otherList.nextSibling()).toBe(list);
      list.drop(otherList, ['above', 'center']);
      return expect(list.nextSibling()).toBe(otherList);
    });
    it('should support dropping on PreText', function() {
      var preText;
      preText = new factory.PreText('pre', {}, '');
      region.attach(preText);
      expect(list.nextSibling()).toBe(preText);
      list.drop(preText, ['below', 'center']);
      expect(preText.nextSibling()).toBe(list);
      list.drop(preText, ['above', 'center']);
      return expect(list.nextSibling()).toBe(preText);
    });
    it('should support being dropped on by PreText', function() {
      var preText;
      preText = new factory.PreText('pre', {}, '');
      region.attach(preText, 0);
      expect(preText.nextSibling()).toBe(list);
      preText.drop(list, ['below', 'center']);
      expect(list.nextSibling()).toBe(preText);
      preText.drop(list, ['above', 'center']);
      return expect(preText.nextSibling()).toBe(list);
    });
    it('should support dropping on Static', function() {
      var staticElm;
      staticElm = factory.Static.fromDOMElement(document.createElement('div'));
      region.attach(staticElm);
      expect(list.nextSibling()).toBe(staticElm);
      list.drop(staticElm, ['below', 'center']);
      expect(staticElm.nextSibling()).toBe(list);
      list.drop(staticElm, ['above', 'center']);
      return expect(list.nextSibling()).toBe(staticElm);
    });
    it('should support being dropped on by `moveable` Static', function() {
      var staticElm;
      staticElm = new factory.Static('div', {
        'data-ce-moveable': 'data-ce-moveable'
      }, 'foo');
      region.attach(staticElm, 0);
      expect(staticElm.nextSibling()).toBe(list);
      staticElm.drop(list, ['below', 'center']);
      expect(list.nextSibling()).toBe(staticElm);
      staticElm.drop(list, ['above', 'center']);
      return expect(staticElm.nextSibling()).toBe(list);
    });
    it('should support dropping on Text', function() {
      var text;
      text = new factory.Text('p');
      region.attach(text);
      expect(list.nextSibling()).toBe(text);
      list.drop(text, ['below', 'center']);
      expect(text.nextSibling()).toBe(list);
      list.drop(text, ['above', 'center']);
      return expect(list.nextSibling()).toBe(text);
    });
    it('should support being dropped on by Text', function() {
      var text;
      text = new factory.Text('p');
      region.attach(text, 0);
      expect(text.nextSibling()).toBe(list);
      text.drop(list, ['below', 'center']);
      expect(list.nextSibling()).toBe(text);
      text.drop(list, ['above', 'center']);
      return expect(text.nextSibling()).toBe(list);
    });
    it('should support dropping on Video', function() {
      var video;
      video = new factory.Video('iframe', {
        'src': '/foo.jpg'
      });
      region.attach(video);
      expect(list.nextSibling()).toBe(video);
      list.drop(video, ['below', 'center']);
      expect(video.nextSibling()).toBe(list);
      list.drop(video, ['above', 'center']);
      return expect(list.nextSibling()).toBe(video);
    });
    return it('should support being dropped on by Video', function() {
      var video;
      video = new factory.Video('iframe', {
        'src': '/foo.jpg'
      });
      region.attach(video, 0);
      expect(video.nextSibling()).toBe(list);
      video.drop(list, ['above', 'left']);
      expect(video.hasCSSClass('align-left')).toBe(true);
      expect(video.nextSibling()).toBe(list);
      video.drop(list, ['above', 'right']);
      expect(video.hasCSSClass('align-left')).toBe(false);
      expect(video.hasCSSClass('align-right')).toBe(true);
      expect(video.nextSibling()).toBe(list);
      video.drop(list, ['below', 'center']);
      expect(video.hasCSSClass('align-left')).toBe(false);
      expect(video.hasCSSClass('align-right')).toBe(false);
      expect(list.nextSibling()).toBe(video);
      video.drop(list, ['above', 'center']);
      return expect(video.nextSibling()).toBe(list);
    });
  });

  describe('`ListItem()`', function() {
    return it('should return an instance of ListLitem`', function() {
      var listItem;
      listItem = new factory.ListItem();
      return expect(listItem instanceof factory.ListItem).toBe(true);
    });
  });

  describe('`List.cssTypeName()`', function() {
    return it('should return \'list-item\'', function() {
      var listItem;
      listItem = new factory.ListItem();
      return expect(listItem.cssTypeName()).toBe('list-item');
    });
  });

  describe('`ListItem.list()`', function() {
    return it('should return any associated List element, or null if there isn\'t one', function() {
      var list, listItem, listItemText;
      listItem = new factory.ListItem();
      expect(listItem.list()).toBe(null);
      listItemText = new factory.ListItemText('foo');
      listItem.attach(listItemText);
      expect(listItem.list()).toBe(null);
      list = new factory.List('ul');
      listItem.attach(list);
      return expect(listItem.list()).toBe(list);
    });
  });

  describe('`ListItem.listItemText()`', function() {
    return it('should return any associated ListItemText element, or null if there isn\'t one', function() {
      var listItem, listItemText;
      listItem = new factory.ListItem();
      expect(listItem.listItemText()).toBe(null);
      listItemText = new factory.ListItemText('foo');
      listItem.attach(listItemText);
      return expect(listItem.listItemText()).toBe(listItemText);
    });
  });

  describe('`ListItem.type()`', function() {
    return it('should return \'ListItem\'', function() {
      var listItem;
      listItem = new factory.ListItem();
      return expect(listItem.type()).toBe('ListItem');
    });
  });

  describe('ListItem.html()', function() {
    return it('should return a HTML string for the list element', function() {
      var listItem, listItemText;
      listItem = new factory.ListItem({
        'class': 'foo'
      });
      listItemText = new factory.ListItemText('bar');
      listItem.attach(listItemText);
      return expect(listItem.html()).toBe('<li class="foo">\n' + ("" + ContentEdit.INDENT + "bar\n") + '</li>');
    });
  });

  describe('factory.ListItem.indent()', function() {
    it('should indent an item in a list by at most one level', function() {
      var I, domElement, list;
      I = ContentEdit.INDENT;
      domElement = document.createElement('ul');
      domElement.innerHTML = '<li>One</li>\n<li>Two</li>\n<li>Three</li>';
      list = factory.List.fromDOMElement(domElement);
      list.children[0].indent();
      expect(list.html()).toBe("<ul>\n" + I + "<li>\n" + I + I + "One\n" + I + "</li>\n" + I + "<li>\n" + I + I + "Two\n" + I + "</li>\n" + I + "<li>\n" + I + I + "Three\n" + I + "</li>\n</ul>");
      list.children[2].indent();
      expect(list.html()).toBe("<ul>\n" + I + "<li>\n" + I + I + "One\n" + I + "</li>\n" + I + "<li>\n" + I + I + "Two\n" + I + I + "<ul>\n" + I + I + I + "<li>\n" + I + I + I + I + "Three\n" + I + I + I + "</li>\n" + I + I + "</ul>\n" + I + "</li>\n</ul>");
      list.children[1].indent();
      return expect(list.html()).toBe("<ul>\n" + I + "<li>\n" + I + I + "One\n" + I + I + "<ul>\n" + I + I + I + "<li>\n" + I + I + I + I + "Two\n" + I + I + I + I + "<ul>\n" + I + I + I + I + I + "<li>\n" + I + I + I + I + I + I + "Three\n" + I + I + I + I + I + "</li>\n" + I + I + I + I + "</ul>\n" + I + I + I + "</li>\n" + I + I + "</ul>\n" + I + "</li>\n</ul>");
    });
    return it('should do nothing if the `indent` behavior is not allowed', function() {
      var I, domElement, list;
      I = ContentEdit.INDENT;
      domElement = document.createElement('ul');
      domElement.innerHTML = '<li>One</li>\n<li>Two</li>\n<li>Three</li>';
      list = factory.List.fromDOMElement(domElement);
      list.children[2].can('indent', false);
      list.children[2].indent();
      return expect(list.html()).toBe("<ul>\n" + I + "<li>\n" + I + I + "One\n" + I + "</li>\n" + I + "<li>\n" + I + I + "Two\n" + I + "</li>\n" + I + "<li>\n" + I + I + "Three\n" + I + "</li>\n</ul>");
    });
  });

  describe('ListItem.remove()', function() {
    return it('should remove an item from a list keeping integrity of the lists structure', function() {
      var I, domElement, list;
      I = ContentEdit.INDENT;
      domElement = document.createElement('ul');
      domElement.innerHTML = '<li>One</li>\n<li>Two</li>\n<li>\n    Three\n    <ul>\n        <li>Alpha</li>\n        <li>Beta</li>\n    </ul>\n</li>';
      list = factory.List.fromDOMElement(domElement);
      list.children[2].list().children[1].remove();
      expect(list.html()).toBe("<ul>\n" + I + "<li>\n" + I + I + "One\n" + I + "</li>\n" + I + "<li>\n" + I + I + "Two\n" + I + "</li>\n" + I + "<li>\n" + I + I + "Three\n" + I + I + "<ul>\n" + I + I + I + "<li>\n" + I + I + I + I + "Alpha\n" + I + I + I + "</li>\n" + I + I + "</ul>\n" + I + "</li>\n</ul>");
      list.children[2].remove();
      expect(list.html()).toBe("<ul>\n" + I + "<li>\n" + I + I + "One\n" + I + "</li>\n" + I + "<li>\n" + I + I + "Two\n" + I + "</li>\n" + I + "<li>\n" + I + I + "Alpha\n" + I + "</li>\n</ul>");
      list.children[0].remove();
      return expect(list.html()).toBe("<ul>\n" + I + "<li>\n" + I + I + "Two\n" + I + "</li>\n" + I + "<li>\n" + I + I + "Alpha\n" + I + "</li>\n</ul>");
    });
  });

  describe('ContentEdit.ListItem.unindent()', function() {
    it('should indent an item in a list or remove it and convert to a text element if it can\'t be unindented any further', function() {
      var I, domElement, list, region;
      I = ContentEdit.INDENT;
      domElement = document.createElement('ul');
      domElement.innerHTML = '<li>One</li>\n<li>Two</li>\n<li>\n    Three\n    <ul>\n        <li>\n            Alpha\n            <ul>\n                <li>Beta</li>\n                <li>Gamma</li>\n            </ul>\n        </li>\n    </ul>\n</li>';
      list = factory.List.fromDOMElement(domElement);
      region = new factory.Region(document.createElement('div'));
      region.attach(list);
      list.children[2].list().children[0].list().children[0].unindent();
      expect(region.html()).toBe("<ul>\n" + I + "<li>\n" + I + I + "One\n" + I + "</li>\n" + I + "<li>\n" + I + I + "Two\n" + I + "</li>\n" + I + "<li>\n" + I + I + "Three\n" + I + I + "<ul>\n" + I + I + I + "<li>\n" + I + I + I + I + "Alpha\n" + I + I + I + "</li>\n" + I + I + I + "<li>\n" + I + I + I + I + "Beta\n" + I + I + I + I + "<ul>\n" + I + I + I + I + I + "<li>\n" + I + I + I + I + I + I + "Gamma\n" + I + I + I + I + I + "</li>\n" + I + I + I + I + "</ul>\n" + I + I + I + "</li>\n" + I + I + "</ul>\n" + I + "</li>\n</ul>");
      list.children[2].list().children[1].list().children[0].unindent();
      expect(region.html()).toBe("<ul>\n" + I + "<li>\n" + I + I + "One\n" + I + "</li>\n" + I + "<li>\n" + I + I + "Two\n" + I + "</li>\n" + I + "<li>\n" + I + I + "Three\n" + I + I + "<ul>\n" + I + I + I + "<li>\n" + I + I + I + I + "Alpha\n" + I + I + I + "</li>\n" + I + I + I + "<li>\n" + I + I + I + I + "Beta\n" + I + I + I + "</li>\n" + I + I + I + "<li>\n" + I + I + I + I + "Gamma\n" + I + I + I + "</li>\n" + I + I + "</ul>\n" + I + "</li>\n</ul>");
      list.children[0].unindent();
      expect(region.html()).toBe("<p>\n" + I + "One\n</p>\n<ul>\n" + I + "<li>\n" + I + I + "Two\n" + I + "</li>\n" + I + "<li>\n" + I + I + "Three\n" + I + I + "<ul>\n" + I + I + I + "<li>\n" + I + I + I + I + "Alpha\n" + I + I + I + "</li>\n" + I + I + I + "<li>\n" + I + I + I + I + "Beta\n" + I + I + I + "</li>\n" + I + I + I + "<li>\n" + I + I + I + I + "Gamma\n" + I + I + I + "</li>\n" + I + I + "</ul>\n" + I + "</li>\n</ul>");
      list.children[1].list().children[0].unindent();
      list.children[2].list().children[0].unindent();
      list.children[3].list().children[0].unindent();
      list.children[4].unindent();
      expect(region.html()).toBe("<p>\n" + I + "One\n</p>\n<ul>\n" + I + "<li>\n" + I + I + "Two\n" + I + "</li>\n" + I + "<li>\n" + I + I + "Three\n" + I + "</li>\n" + I + "<li>\n" + I + I + "Alpha\n" + I + "</li>\n" + I + "<li>\n" + I + I + "Beta\n" + I + "</li>\n</ul>\n<p>\n" + I + "Gamma\n</p>");
      list.children[1].unindent();
      return expect(region.html()).toBe("<p>\n" + I + "One\n</p>\n<ul>\n" + I + "<li>\n" + I + I + "Two\n" + I + "</li>\n</ul>\n<p>\n" + I + "Three\n</p>\n<ul>\n" + I + "<li>\n" + I + I + "Alpha\n" + I + "</li>\n" + I + "<li>\n" + I + I + "Beta\n" + I + "</li>\n</ul>\n<p>\n" + I + "Gamma\n</p>");
    });
    return it('should do nothing if the `indent` behavior is not allowed', function() {
      var I, domElement, list, region;
      I = ContentEdit.INDENT;
      domElement = document.createElement('ul');
      domElement.innerHTML = '<li>One</li>\n<li>Two</li>';
      list = factory.List.fromDOMElement(domElement);
      list.children[0].can('indent', false);
      region = new factory.Region(document.createElement('div'));
      region.attach(list);
      list.children[0].unindent();
      return expect(region.html()).toBe("<ul>\n" + I + "<li>\n" + I + I + "One\n" + I + "</li>\n" + I + "<li>\n" + I + I + "Two\n" + I + "</li>\n</ul>");
    });
  });

  describe('`ListItem.fromDOMElement()`', function() {
    return it('should convert a <li> DOM element into an ListItem element', function() {
      var I, domLi, li;
      I = ContentEdit.INDENT;
      domLi = document.createElement('li');
      domLi.innerHTML = 'foo';
      li = factory.ListItem.fromDOMElement(domLi);
      expect(li.html()).toBe("<li>\n" + I + "foo\n</li>");
      domLi = document.createElement('li');
      domLi.innerHTML = 'foo\n<ul>\n    <li>bar</li>\n</ul>';
      li = factory.ListItem.fromDOMElement(domLi);
      return expect(li.html()).toBe("<li>\n" + I + "foo\n" + I + "<ul>\n" + I + I + "<li>\n" + I + I + I + "bar\n" + I + I + "</li>\n" + I + "</ul>\n</li>");
    });
  });

  describe('`ListItemText()`', function() {
    return it('should return an instance of ListItemText`', function() {
      var listItemText;
      listItemText = new factory.ListItemText('foo');
      return expect(listItemText instanceof factory.ListItemText).toBe(true);
    });
  });

  describe('`ListItemText.cssTypeName()`', function() {
    return it('should return \'list-item-text\'', function() {
      var listItemText;
      listItemText = new factory.ListItemText('foo');
      return expect(listItemText.cssTypeName()).toBe('list-item-text');
    });
  });

  describe('`ListItemText.type()`', function() {
    return it('should return \'ListItemText\'', function() {
      var listItemText;
      listItemText = new factory.ListItemText();
      return expect(listItemText.type()).toBe('ListItemText');
    });
  });

  describe('`ListItemText.typeName()`', function() {
    return it('should return \'List item\'', function() {
      var listItemText;
      listItemText = new factory.ListItemText('foo');
      return expect(listItemText.typeName()).toBe('List item');
    });
  });

  describe('`ListItemText.blur()`', function() {
    var region;
    region = null;
    beforeEach(function() {
      document.getElementById('test').innerHTML = '<ul>\n    <li>foo</li>\n    <li>bar</li>\n    <li>zee</li>\n</ul>';
      region = new factory.Region(document.getElementById('test'));
      return region.children[0].children[1].listItemText().focus();
    });
    afterEach(function() {
      var child, _i, _len, _ref, _results;
      _ref = region.children.slice();
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        child = _ref[_i];
        _results.push(region.detach(child));
      }
      return _results;
    });
    it('should blur the list item text element', function() {
      var listItemText;
      listItemText = region.children[0].children[1].listItemText();
      listItemText.blur();
      return expect(listItemText.isFocused()).toBe(false);
    });
    it('should remove the list item text element if it\'s just whitespace', function() {
      var listItemText;
      listItemText = region.children[0].children[1].listItemText();
      listItemText.content = new HTMLString.String('');
      listItemText.blur();
      return expect(listItemText.parent().parent()).toBe(null);
    });
    it('should trigger the `blur` event against the root', function() {
      var foo, listItemText;
      foo = {
        handleFoo: function() {}
      };
      spyOn(foo, 'handleFoo');
      factory.root.bind('blur', foo.handleFoo);
      listItemText = region.children[0].children[1].listItemText();
      listItemText.blur();
      return expect(foo.handleFoo).toHaveBeenCalledWith(listItemText);
    });
    return it('should not remove the list element if it\'s just whitespace but remove behaviour is disallowed for the parent list item', function() {
      var listItem, listItemText;
      listItem = region.children[0].children[1];
      listItem.can('remove', false);
      listItemText = listItem.listItemText();
      listItemText.content = new HTMLString.String('');
      listItemText.blur();
      return expect(listItemText.parent().parent()).not.toBe(null);
    });
  });

  describe('ContentEdit.Text.html()', function() {
    return it('should return a HTML string for the list item text element', function() {
      var listItemText;
      listItemText = new factory.ListItemText('bar <b>zee</b>');
      return expect(listItemText.html()).toBe('bar <b>zee</b>');
    });
  });

  describe('`ContentEdit.ListItemText` key events`', function() {
    var ev, list, listItem, listItemText, region;
    ev = null;
    list = null;
    listItem = null;
    listItemText = null;
    region = null;
    beforeEach(function() {
      ev = {
        preventDefault: function() {}
      };
      document.getElementById('test').innerHTML = '<ul>\n    <li>foo</li>\n    <li>bar</li>\n    <li>zee</li>\n</ul>';
      region = new factory.Region(document.getElementById('test'));
      list = region.children[0];
      listItem = list.children[1];
      return listItemText = listItem.listItemText();
    });
    afterEach(function() {
      var child, _i, _len, _ref, _results;
      _ref = region.children.slice();
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        child = _ref[_i];
        _results.push(region.detach(child));
      }
      return _results;
    });
    it('should support return splitting the element into 2', function() {
      listItemText.focus();
      new ContentSelect.Range(2, 2).select(listItemText.domElement());
      listItemText._keyReturn(ev);
      expect(listItemText.content.text()).toBe('ba');
      return expect(listItemText.nextContent().content.text()).toBe('r');
    });
    it('should support using tab to indent', function() {
      spyOn(listItem, 'indent');
      listItemText.focus();
      listItemText._keyTab(ev);
      return expect(listItem.indent).toHaveBeenCalled();
    });
    it('should support using shift-tab to unindent', function() {
      spyOn(listItem, 'unindent');
      ev.shiftKey = true;
      listItemText.focus();
      listItemText._keyTab(ev);
      return expect(listItem.unindent).toHaveBeenCalled();
    });
    return it('should not split the element into 2 on return if spawn is disallowed', function() {
      var listItemCount;
      listItemCount = list.children.length;
      listItem.can('spawn', false);
      listItemText.focus();
      new ContentSelect.Range(2, 2).select(listItemText.domElement());
      listItemText._keyReturn(ev);
      return expect(list.children.length).toBe(listItemCount);
    });
  });

  describe('`ListItemText` drop interactions`', function() {
    var I, listItemText, region;
    I = ContentEdit.INDENT;
    listItemText = null;
    region = null;
    beforeEach(function() {
      var domElement;
      domElement = document.createElement('div');
      domElement.innerHTML = '<ul>\n    <li>foo</li>\n    <li>bar</li>\n</ul>\n<p>zee</p>';
      region = new factory.Region(domElement);
      return listItemText = region.children[0].children[0].listItemText();
    });
    it('should support dropping on ListItemText', function() {
      var otherListItemText;
      otherListItemText = region.children[0].children[1].listItemText();
      expect(listItemText.parent().nextSibling()).toBe(otherListItemText.parent());
      listItemText.drop(otherListItemText, ['below', 'center']);
      expect(otherListItemText.parent().nextSibling()).toBe(listItemText.parent());
      listItemText.drop(otherListItemText, ['above', 'center']);
      return expect(listItemText.parent().nextSibling()).toBe(otherListItemText.parent());
    });
    it('should support dropping on Text', function() {
      var text;
      text = region.children[1];
      listItemText.drop(text, ['below', 'center']);
      expect(region.html()).toBe("<ul>\n" + I + "<li>\n" + I + I + "bar\n" + I + "</li>\n</ul>\n<p>\n" + I + "zee\n</p>\n<p>\n" + I + "foo\n</p>");
      listItemText = region.children[0].children[0].listItemText();
      listItemText.drop(text, ['above', 'center']);
      return expect(region.html()).toBe("<p>\n" + I + "bar\n</p>\n<p>\n" + I + "zee\n</p>\n<p>\n" + I + "foo\n</p>");
    });
    return it('should support being dropped on by Text', function() {
      var text;
      text = region.children[1];
      text.drop(listItemText, ['below', 'center']);
      expect(region.html()).toBe("<ul>\n" + I + "<li>\n" + I + I + "foo\n" + I + "</li>\n" + I + "<li>\n" + I + I + "zee\n" + I + "</li>\n" + I + "<li>\n" + I + I + "bar\n" + I + "</li>\n</ul>");
      text = new factory.Text('p', {}, 'umm');
      region.attach(text, 0);
      text.drop(listItemText, ['above', 'center']);
      return expect(region.html()).toBe("<ul>\n" + I + "<li>\n" + I + I + "umm\n" + I + "</li>\n" + I + "<li>\n" + I + I + "foo\n" + I + "</li>\n" + I + "<li>\n" + I + I + "zee\n" + I + "</li>\n" + I + "<li>\n" + I + I + "bar\n" + I + "</li>\n</ul>");
    });
  });

  describe('`Text` merge interactions`', function() {
    var I, region;
    I = ContentEdit.INDENT;
    region = null;
    beforeEach(function() {
      var domElement;
      domElement = document.getElementById('test');
      domElement.innerHTML = '<p>foo</p>\n<ul>\n    <li>bar</li>\n    <li>zee</li>\n</ul>\n<p>umm</p>';
      return region = new factory.Region(domElement);
    });
    afterEach(function() {
      var child, _i, _len, _ref, _results;
      _ref = region.children.slice();
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        child = _ref[_i];
        _results.push(region.detach(child));
      }
      return _results;
    });
    it('should support merging with ListItemText', function() {
      var listItemTextA, listItemTextB;
      listItemTextA = region.children[1].children[0].listItemText();
      listItemTextB = region.children[1].children[1].listItemText();
      listItemTextA.merge(listItemTextB);
      return expect(listItemTextA.html()).toBe('barzee');
    });
    return it('should support merging with Text', function() {
      var listItemText, text;
      text = region.children[2];
      listItemText = region.children[1].children[1].listItemText();
      listItemText.merge(text);
      expect(region.html()).toBe("<p>\n" + I + "foo\n</p>\n<ul>\n" + I + "<li>\n" + I + I + "bar\n" + I + "</li>\n" + I + "<li>\n" + I + I + "zeeumm\n" + I + "</li>\n</ul>");
      text = region.children[0];
      listItemText = region.children[1].children[0].listItemText();
      text.merge(listItemText);
      return expect(region.html()).toBe("<p>\n" + I + "foobar\n</p>\n<ul>\n" + I + "<li>\n" + I + I + "zeeumm\n" + I + "</li>\n</ul>");
    });
  });

  factory = new ContentEdit.Factory();

  describe('`Table()`', function() {
    return it('should return an instance of Table`', function() {
      var table;
      table = new factory.Table();
      return expect(table instanceof factory.Table).toBe(true);
    });
  });

  describe('`Table.cssTypeName()`', function() {
    return it('should return \'table\'', function() {
      var table;
      table = new factory.Table();
      return expect(table.cssTypeName()).toBe('table');
    });
  });

  describe('`Table.type()`', function() {
    return it('should return \'Table\'', function() {
      var table;
      table = new factory.Table();
      return expect(table.type()).toBe('Table');
    });
  });

  describe('`Table.typeName()`', function() {
    return it('should return \'table\'', function() {
      var table;
      table = new factory.Table();
      return expect(table.typeName()).toBe('Table');
    });
  });

  describe('`Table.firstSection()`', function() {
    return it('should return the first section in the table (their position as children is irrelevant, the order is thead, tbody, tfoot in that order ', function() {
      var table, tbody, tfoot, thead;
      table = new factory.Table();
      thead = new factory.TableSection('thead');
      tbody = new factory.TableSection('tbody');
      tfoot = new factory.TableSection('tfoot');
      expect(table.firstSection()).toBe(null);
      table.attach(tfoot);
      expect(table.firstSection()).toBe(tfoot);
      table.attach(tbody);
      expect(table.firstSection()).toBe(tbody);
      table.attach(thead);
      return expect(table.firstSection()).toBe(thead);
    });
  });

  describe('`Table.lastSection()`', function() {
    return it('should return the last section in the table (their position as children is irrelevant, the order is thead, tbody, tfoot in that order ', function() {
      var table, tbody, tfoot, thead;
      table = new factory.Table();
      thead = new factory.TableSection('thead');
      tbody = new factory.TableSection('tbody');
      tfoot = new factory.TableSection('tfoot');
      expect(table.lastSection()).toBe(null);
      table.attach(thead);
      expect(table.lastSection()).toBe(thead);
      table.attach(tbody);
      expect(table.lastSection()).toBe(tbody);
      table.attach(tfoot);
      return expect(table.lastSection()).toBe(tfoot);
    });
  });

  describe('`Table.thead()`', function() {
    return it('should return the `TableSection` (thead) for the `Table` if there is one', function() {
      var table, tableHead;
      table = new factory.Table();
      expect(table.thead()).toBe(null);
      tableHead = new factory.TableSection('thead');
      table.attach(tableHead);
      return expect(table.thead()).toBe(tableHead);
    });
  });

  describe('`Table.tbody()`', function() {
    return it('should return the `TableSection` (tbody) for the `Table` if there is one', function() {
      var table, tableBody;
      table = new factory.Table();
      expect(table.tbody()).toBe(null);
      tableBody = new factory.TableSection('tbody');
      table.attach(tableBody);
      return expect(table.tbody()).toBe(tableBody);
    });
  });

  describe('`Table.tfoot()`', function() {
    return it('should return the `TableSection` (tfoot) for the `Table` if there is one', function() {
      var table, tableFoot;
      table = new factory.Table();
      expect(table.tfoot()).toBe(null);
      tableFoot = new factory.TableSection('tfoot');
      table.attach(tableFoot);
      return expect(table.tfoot()).toBe(tableFoot);
    });
  });

  describe('`Table.fromDOMElement()`', function() {
    return it('should convert a <table> DOM element into a table element', function() {
      var I, domTable, table;
      I = ContentEdit.INDENT;
      domTable = document.createElement('table');
      domTable.innerHTML = '<tbody>\n    <tr>\n        <td>bar</td>\n        <td>zee</td>\n    </tr>\n</tbody>';
      table = factory.Table.fromDOMElement(domTable);
      expect(table.html()).toBe("<table>\n" + I + "<tbody>\n" + I + I + "<tr>\n" + I + I + I + "<td>\n" + I + I + I + I + "bar\n" + I + I + I + "</td>\n" + I + I + I + "<td>\n" + I + I + I + I + "zee\n" + I + I + I + "</td>\n" + I + I + "</tr>\n" + I + "</tbody>\n</table>");
      domTable = document.createElement('table');
      domTable.innerHTML = '<tr>\n    <td>bar</td>\n    <td>zee</td>\n</tr>';
      table = factory.Table.fromDOMElement(domTable);
      return expect(table.html()).toBe("<table>\n" + I + "<tbody>\n" + I + I + "<tr>\n" + I + I + I + "<td>\n" + I + I + I + I + "bar\n" + I + I + I + "</td>\n" + I + I + I + "<td>\n" + I + I + I + I + "zee\n" + I + I + I + "</td>\n" + I + I + "</tr>\n" + I + "</tbody>\n</table>");
    });
  });

  describe('`Table` drop interactions`', function() {
    var region, table;
    table = null;
    region = null;
    beforeEach(function() {
      region = new factory.Region(document.createElement('div'));
      table = new factory.Table();
      return region.attach(table);
    });
    it('should support dropping on Image', function() {
      var image;
      image = new factory.Image({
        'src': '/bar.jpg'
      });
      region.attach(image);
      expect(table.nextSibling()).toBe(image);
      table.drop(image, ['below', 'center']);
      expect(image.nextSibling()).toBe(table);
      table.drop(image, ['above', 'center']);
      return expect(table.nextSibling()).toBe(image);
    });
    it('should support being dropped on by Image', function() {
      var image;
      image = new factory.Image({
        'src': '/bar.jpg'
      });
      region.attach(image, 0);
      expect(image.nextSibling()).toBe(table);
      image.drop(table, ['above', 'left']);
      expect(image.hasCSSClass('align-left')).toBe(true);
      expect(image.nextSibling()).toBe(table);
      image.drop(table, ['above', 'right']);
      expect(image.hasCSSClass('align-left')).toBe(false);
      expect(image.hasCSSClass('align-right')).toBe(true);
      expect(image.nextSibling()).toBe(table);
      image.drop(table, ['below', 'center']);
      expect(image.hasCSSClass('align-left')).toBe(false);
      expect(image.hasCSSClass('align-right')).toBe(false);
      expect(table.nextSibling()).toBe(image);
      image.drop(table, ['above', 'center']);
      return expect(image.nextSibling()).toBe(table);
    });
    it('should support dropping on List', function() {
      var list;
      list = new factory.Image({
        'src': '/bar.jpg'
      });
      region.attach(list);
      expect(table.nextSibling()).toBe(list);
      table.drop(list, ['below', 'center']);
      expect(list.nextSibling()).toBe(table);
      table.drop(list, ['above', 'center']);
      return expect(table.nextSibling()).toBe(list);
    });
    it('should support being dropped on by List', function() {
      var list;
      list = new factory.Text('p');
      region.attach(list, 0);
      expect(list.nextSibling()).toBe(table);
      list.drop(table, ['below', 'center']);
      expect(table.nextSibling()).toBe(list);
      list.drop(table, ['above', 'center']);
      return expect(list.nextSibling()).toBe(table);
    });
    it('should support dropping on PreText', function() {
      var preText;
      preText = new factory.PreText('pre', {}, '');
      region.attach(preText);
      expect(table.nextSibling()).toBe(preText);
      table.drop(preText, ['below', 'center']);
      expect(preText.nextSibling()).toBe(table);
      table.drop(preText, ['above', 'center']);
      return expect(table.nextSibling()).toBe(preText);
    });
    it('should support being dropped on by PreText', function() {
      var preText;
      preText = new factory.PreText('pre', {}, '');
      region.attach(preText, 0);
      expect(preText.nextSibling()).toBe(table);
      preText.drop(table, ['below', 'center']);
      expect(table.nextSibling()).toBe(preText);
      preText.drop(table, ['above', 'center']);
      return expect(preText.nextSibling()).toBe(table);
    });
    it('should support dropping on Static', function() {
      var staticElm;
      staticElm = factory.Static.fromDOMElement(document.createElement('div'));
      region.attach(staticElm);
      expect(table.nextSibling()).toBe(staticElm);
      table.drop(staticElm, ['below', 'center']);
      expect(staticElm.nextSibling()).toBe(table);
      table.drop(staticElm, ['above', 'center']);
      return expect(table.nextSibling()).toBe(staticElm);
    });
    it('should support being dropped on by `moveable` Static', function() {
      var staticElm;
      staticElm = new factory.Static('div', {
        'data-ce-moveable': 'data-ce-moveable'
      }, 'foo');
      region.attach(staticElm, 0);
      expect(staticElm.nextSibling()).toBe(table);
      staticElm.drop(table, ['below', 'center']);
      expect(table.nextSibling()).toBe(staticElm);
      staticElm.drop(table, ['above', 'center']);
      return expect(staticElm.nextSibling()).toBe(table);
    });
    it('should support dropping on Table', function() {
      var otherTable;
      otherTable = new factory.Table();
      region.attach(otherTable);
      expect(table.nextSibling()).toBe(otherTable);
      table.drop(otherTable, ['below', 'center']);
      expect(otherTable.nextSibling()).toBe(table);
      table.drop(otherTable, ['above', 'center']);
      return expect(table.nextSibling()).toBe(otherTable);
    });
    it('should support dropping on Text', function() {
      var text;
      text = new factory.Text('p');
      region.attach(text);
      expect(table.nextSibling()).toBe(text);
      table.drop(text, ['below', 'center']);
      expect(text.nextSibling()).toBe(table);
      table.drop(text, ['above', 'center']);
      return expect(table.nextSibling()).toBe(text);
    });
    it('should support being dropped on by Text', function() {
      var text;
      text = new factory.Text('p');
      region.attach(text, 0);
      expect(text.nextSibling()).toBe(table);
      text.drop(table, ['below', 'center']);
      expect(table.nextSibling()).toBe(text);
      text.drop(table, ['above', 'center']);
      return expect(text.nextSibling()).toBe(table);
    });
    it('should support dropping on Video', function() {
      var video;
      video = new factory.Video('iframe', {
        'src': '/foo.jpg'
      });
      region.attach(video);
      expect(table.nextSibling()).toBe(video);
      table.drop(video, ['below', 'center']);
      expect(video.nextSibling()).toBe(table);
      table.drop(video, ['above', 'center']);
      return expect(table.nextSibling()).toBe(video);
    });
    return it('should support being dropped on by Video', function() {
      var video;
      video = new factory.Video('iframe', {
        'src': '/foo.jpg'
      });
      region.attach(video, 0);
      expect(video.nextSibling()).toBe(table);
      video.drop(table, ['above', 'left']);
      expect(video.hasCSSClass('align-left')).toBe(true);
      expect(video.nextSibling()).toBe(table);
      video.drop(table, ['above', 'right']);
      expect(video.hasCSSClass('align-left')).toBe(false);
      expect(video.hasCSSClass('align-right')).toBe(true);
      expect(video.nextSibling()).toBe(table);
      video.drop(table, ['below', 'center']);
      expect(video.hasCSSClass('align-left')).toBe(false);
      expect(video.hasCSSClass('align-right')).toBe(false);
      expect(table.nextSibling()).toBe(video);
      video.drop(table, ['above', 'center']);
      return expect(video.nextSibling()).toBe(table);
    });
  });

  describe('`TableSection()`', function() {
    return it('should return an instance of TableSection`', function() {
      var tableSection;
      tableSection = new factory.TableSection('tbody', {});
      return expect(tableSection instanceof factory.TableSection).toBe(true);
    });
  });

  describe('`TableSection.cssTypeName()`', function() {
    return it('should return \'table-section\'', function() {
      var tableSection;
      tableSection = new factory.TableSection('tbody', {});
      return expect(tableSection.cssTypeName()).toBe('table-section');
    });
  });

  describe('`TableSection.type()`', function() {
    return it('should return \'TableSection\'', function() {
      var tableSection;
      tableSection = new factory.TableSection('tbody', {});
      return expect(tableSection.type()).toBe('TableSection');
    });
  });

  describe('`TableSection.fromDOMElement()`', function() {
    return it('should convert a <tbody>, <tfoot> or <thead> DOM element into a table section element', function() {
      var I, domTableSection, sectionName, tableSection, _i, _len, _ref, _results;
      I = ContentEdit.INDENT;
      _ref = ['tbody', 'tfoot', 'thead'];
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        sectionName = _ref[_i];
        domTableSection = document.createElement(sectionName);
        domTableSection.innerHTML = '<tr>\n    <td>foo</td>\n    <td>bar</td>\n</tr>';
        tableSection = factory.TableSection.fromDOMElement(domTableSection);
        _results.push(expect(tableSection.html()).toBe("<" + sectionName + ">\n" + I + "<tr>\n" + I + I + "<td>\n" + I + I + I + "foo\n" + I + I + "</td>\n" + I + I + "<td>\n" + I + I + I + "bar\n" + I + I + "</td>\n" + I + "</tr>\n</" + sectionName + ">"));
      }
      return _results;
    });
  });

  describe('`TableRow()`', function() {
    return it('should return an instance of TableRow`', function() {
      var tableRow;
      tableRow = new factory.TableRow();
      return expect(tableRow instanceof factory.TableRow).toBe(true);
    });
  });

  describe('`TableRow.cssTypeName()`', function() {
    return it('should return \'table-row\'', function() {
      var tableRow;
      tableRow = new factory.TableRow();
      return expect(tableRow.cssTypeName()).toBe('table-row');
    });
  });

  describe('`TableRow.isEmpty()`', function() {
    it('should return true if the table row is empty', function() {
      var domTableRow, tableRow;
      domTableRow = document.createElement('tr');
      domTableRow.innerHTML = '<td></td><td></td>';
      tableRow = factory.TableRow.fromDOMElement(domTableRow);
      return expect(tableRow.isEmpty()).toBe(true);
    });
    return it('should return true false the table contains content', function() {
      var domTableRow, tableRow;
      domTableRow = document.createElement('tr');
      domTableRow.innerHTML = '<td>foo</td><td></td>';
      tableRow = factory.TableRow.fromDOMElement(domTableRow);
      return expect(tableRow.isEmpty()).toBe(false);
    });
  });

  describe('`TableRow.type()`', function() {
    return it('should return \'TableRow\'', function() {
      var tableRow;
      tableRow = new factory.TableRow();
      return expect(tableRow.type()).toBe('TableRow');
    });
  });

  describe('`TableRow.typeName()`', function() {
    return it('should return \'Table row\'', function() {
      var tableRow;
      tableRow = new factory.TableRow();
      return expect(tableRow.typeName()).toBe('Table row');
    });
  });

  describe('`TableRow.fromDOMElement()`', function() {
    return it('should convert a <tr> DOM element into a table row element', function() {
      var I, domTableRow, tableRow;
      I = ContentEdit.INDENT;
      domTableRow = document.createElement('tr');
      domTableRow.innerHTML = '<td>foo</td>\n<td>bar</td>';
      tableRow = factory.TableRow.fromDOMElement(domTableRow);
      return expect(tableRow.html()).toBe("<tr>\n" + I + "<td>\n" + I + I + "foo\n" + I + "</td>\n" + I + "<td>\n" + I + I + "bar\n" + I + "</td>\n</tr>");
    });
  });

  describe('`TableRow` key events`', function() {
    var emptyTableRow, ev, region, tableRow;
    ev = {
      preventDefault: function() {}
    };
    emptyTableRow = null;
    region = null;
    tableRow = null;
    beforeEach(function() {
      var domElement, domTable, table;
      domElement = document.createElement('div');
      document.body.appendChild(domElement);
      region = new factory.Region(domElement);
      domTable = document.createElement('table');
      domTable.innerHTML = '<tbody>\n<tr><td></td><td>foo</td></tr>\n<tr><td></td><td></td></tr>\n</tbody>';
      table = factory.Table.fromDOMElement(domTable);
      tableRow = table.children[0].children[0];
      emptyTableRow = table.children[0].children[1];
      return region.attach(table);
    });
    afterEach(function() {
      var child, _i, _len, _ref;
      _ref = region.children.slice();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        child = _ref[_i];
        region.detach(child);
      }
      return document.body.removeChild(region.domElement());
    });
    it('should support delete removing empty rows', function() {
      var parent, text;
      text = emptyTableRow.children[1].tableCellText();
      text.focus();
      text._keyDelete(ev);
      expect(emptyTableRow.parent()).toBe(null);
      parent = tableRow.parent();
      text = tableRow.children[1].tableCellText();
      text.focus();
      text._keyDelete(ev);
      return expect(parent).toBe(tableRow.parent());
    });
    it('should support backspace in first cell removing empty rows', function() {
      var parent, text;
      text = emptyTableRow.children[0].tableCellText();
      text.focus();
      text._keyBack(ev);
      expect(emptyTableRow.parent()).toBe(null);
      parent = tableRow.parent();
      text = tableRow.children[0].tableCellText();
      text.focus();
      text._keyBack(ev);
      return expect(parent).toBe(tableRow.parent());
    });
    return it('should not allow a row to be deleted with backspace or delete if remove behaviour is disallowed', function() {
      var text;
      emptyTableRow.can('remove', false);
      text = emptyTableRow.children[0].tableCellText();
      text.focus();
      text._keyBack(ev);
      return expect(emptyTableRow.parent()).not.toBe(null);
    });
  });

  describe('`TableRow` drop interactions`', function() {
    var region, table;
    region = null;
    table = null;
    beforeEach(function() {
      var domTable;
      region = new factory.Region(document.createElement('div'));
      domTable = document.createElement('table');
      domTable.innerHTML = '<tbody>\n    <tr>\n        <td>foo</td>\n    </tr>\n    <tr>\n        <td>bar</td>\n    </tr>\n    <tr>\n        <td>zee</td>\n    </tr>\n    <tr>\n        <td>umm</td>\n    </tr>\n</tbody>';
      table = factory.Table.fromDOMElement(domTable);
      return region.attach(table);
    });
    return it('should support dropping on TableRow', function() {
      var tableRowA, tableRowB;
      tableRowA = table.tbody().children[1];
      tableRowB = table.tbody().children[2];
      expect(tableRowA.nextSibling()).toBe(tableRowB);
      tableRowA.drop(tableRowB, ['below', 'center']);
      expect(tableRowB.nextSibling()).toBe(tableRowA);
      tableRowA.drop(tableRowB, ['above', 'center']);
      return expect(tableRowA.nextSibling()).toBe(tableRowB);
    });
  });

  describe('`TableCell()`', function() {
    return it('should return an instance of `TableCell`', function() {
      var tableCell;
      tableCell = new factory.TableCell('td', {});
      return expect(tableCell instanceof factory.TableCell).toBe(true);
    });
  });

  describe('`TableCell.cssTypeName()`', function() {
    return it('should return \'table-cell\'', function() {
      var tableCell;
      tableCell = new factory.TableCell('td', {});
      return expect(tableCell.cssTypeName()).toBe('table-cell');
    });
  });

  describe('`TableCell.tableCellText()`', function() {
    return it('should return any associated TableCellText element, or null if there isn\'t one', function() {
      var tableCell, tableCellText;
      tableCell = new factory.TableCell('td');
      expect(tableCell.tableCellText()).toBe(null);
      tableCellText = new factory.TableCellText('foo');
      tableCell.attach(tableCellText);
      return expect(tableCell.tableCellText()).toBe(tableCellText);
    });
  });

  describe('`TableCell.type()`', function() {
    return it('should return \'table-cell\'', function() {
      var tableCell;
      tableCell = new factory.TableCell('td', {});
      return expect(tableCell.type()).toBe('TableCell');
    });
  });

  describe('`TableCell.html()`', function() {
    return it('should return a HTML string for the table cell element', function() {
      var tableCell, tableCellText;
      tableCell = new factory.TableCell('td', {
        'class': 'foo'
      });
      tableCellText = new factory.TableCellText('bar');
      tableCell.attach(tableCellText);
      return expect(tableCell.html()).toBe('<td class="foo">\n' + ("" + ContentEdit.INDENT + "bar\n") + '</td>');
    });
  });

  describe('`TableCell.fromDOMElement()`', function() {
    return it('should convert a <td> or <th> DOM element into a table cell element', function() {
      var I, domTableCell, tableCell;
      I = ContentEdit.INDENT;
      domTableCell = document.createElement('td');
      domTableCell.innerHTML = 'foo';
      tableCell = factory.TableCell.fromDOMElement(domTableCell);
      expect(tableCell.html()).toBe("<td>\n" + I + "foo\n</td>");
      domTableCell = document.createElement('th');
      domTableCell.innerHTML = 'bar';
      tableCell = factory.TableCell.fromDOMElement(domTableCell);
      return expect(tableCell.html()).toBe("<th>\n" + I + "bar\n</th>");
    });
  });

  describe('`TableCellText()`', function() {
    return it('should return an instance of TableCellText', function() {
      var tableCellText;
      tableCellText = new factory.TableCellText('foo');
      return expect(tableCellText instanceof factory.TableCellText).toBe(true);
    });
  });

  describe('`TableCellText.cssTypeName()`', function() {
    return it('should return \'table-cell-text\'', function() {
      var tableCellText;
      tableCellText = new factory.TableCellText('foo');
      return expect(tableCellText.cssTypeName()).toBe('table-cell-text');
    });
  });

  describe('`TableCellText.type()`', function() {
    return it('should return \'TableCellText\'', function() {
      var tableCellText;
      tableCellText = new factory.TableCellText('foo');
      return expect(tableCellText.type()).toBe('TableCellText');
    });
  });

  describe('TableCellText.blur()', function() {
    var region, table, tableCell, tableCellText;
    region = null;
    table = null;
    tableCell = null;
    tableCellText = null;
    beforeEach(function() {
      var domTable;
      domTable = document.createElement('table');
      domTable.innerHTML = '<tbody>\n    <tr>\n        <td>bar</td>\n        <td>zee</td>\n    </tr>\n</tbody>';
      table = factory.Table.fromDOMElement(domTable);
      region = new factory.Region(document.getElementById('test'));
      region.attach(table);
      tableCell = table.tbody().children[0].children[0];
      tableCellText = tableCell.tableCellText();
      return tableCellText.focus();
    });
    afterEach(function() {
      return region.detach(table);
    });
    it('should blur the text element', function() {
      tableCellText.blur();
      return expect(tableCellText.isFocused()).toBe(false);
    });
    it('should not remove the table cell text element if it\'s just whitespace', function() {
      var parent;
      parent = tableCellText.parent();
      tableCellText.content = new HTMLString.String('');
      tableCellText.blur();
      return expect(tableCellText.parent()).toBe(parent);
    });
    return it('should trigger the `blur` event against the root', function() {
      var foo;
      foo = {
        handleFoo: function() {}
      };
      spyOn(foo, 'handleFoo');
      factory.root.bind('blur', foo.handleFoo);
      tableCellText.blur();
      return expect(foo.handleFoo).toHaveBeenCalledWith(tableCellText);
    });
  });

  describe('ContentEdit.TableCellText.html()', function() {
    return it('should return a HTML string for the table cell text element', function() {
      var tableCellText;
      tableCellText = new factory.TableCellText('bar <b>zee</b>');
      return expect(tableCellText.html()).toBe('bar <b>zee</b>');
    });
  });

  describe('`TableCellText` key events`', function() {
    var INDENT, ev, region, table, tbody;
    INDENT = ContentEdit.INDENT;
    ev = {
      preventDefault: function() {}
    };
    region = null;
    table = null;
    tbody = null;
    beforeEach(function() {
      document.getElementById('test').innerHTML = '<p>foo</p>\n<table>\n    <tbody>\n        <tr>\n            <td>foo</td>\n            <td>bar</td>\n        </tr>\n        <tr>\n            <td>zee</td>\n            <td>umm</td>\n        </tr>\n    </tbody>\n</table>\n<p>bar</p>';
      region = new factory.Region(document.getElementById('test'));
      table = region.children[1];
      return tbody = table.tbody();
    });
    afterEach(function() {
      var child, _i, _len, _ref, _results;
      _ref = region.children.slice();
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        child = _ref[_i];
        _results.push(region.detach(child));
      }
      return _results;
    });
    it('should support down arrow nav to table cell below or next content element if we\'re in the last row', function() {
      var otherTableCellText, tableCellText;
      tableCellText = tbody.children[0].children[0].tableCellText();
      tableCellText.focus();
      new ContentSelect.Range(3, 3).select(tableCellText.domElement());
      tableCellText._keyDown(ev);
      otherTableCellText = tbody.children[1].children[0].tableCellText();
      expect(factory.root.focused()).toBe(otherTableCellText);
      new ContentSelect.Range(3, 3).select(otherTableCellText.domElement());
      factory.root.focused()._keyDown(ev);
      return expect(factory.root.focused()).toBe(region.children[2]);
    });
    it('should support up arrow nav to table cell below or previous content element if we\'re in the first row', function() {
      var otherTableCellText, tableCellText;
      tableCellText = tbody.children[1].children[0].tableCellText();
      tableCellText.focus();
      new ContentSelect.Range(0, 0).select(tableCellText.domElement());
      tableCellText._keyUp(ev);
      otherTableCellText = tbody.children[0].children[0].tableCellText();
      expect(factory.root.focused()).toBe(otherTableCellText);
      factory.root.focused()._keyUp(ev);
      return expect(factory.root.focused()).toBe(region.children[0]);
    });
    it('should support return nav to next content element', function() {
      var otherTableCellText, tableCellText;
      tableCellText = tbody.children[0].children[0].tableCellText();
      tableCellText.focus();
      new ContentSelect.Range(3, 3).select(tableCellText.domElement());
      tableCellText._keyReturn(ev);
      otherTableCellText = tbody.children[0].children[1].tableCellText();
      return expect(factory.root.focused()).toBe(otherTableCellText);
    });
    it('should support using tab to nav to next table cell', function() {
      var otherTableCellText, tableCellText;
      tableCellText = tbody.children[0].children[0].tableCellText();
      tableCellText.focus();
      new ContentSelect.Range(3, 3).select(tableCellText.domElement());
      tableCellText._keyTab(ev);
      otherTableCellText = tbody.children[0].children[1].tableCellText();
      return expect(factory.root.focused()).toBe(otherTableCellText);
    });
    it('should support tab creating a new body row if last table cell in last row of the table body focused', function() {
      var otherTableCellText, rows, tableCellText;
      rows = tbody.children.length;
      tableCellText = tbody.children[1].children[1].tableCellText();
      tableCellText.focus();
      new ContentSelect.Range(3, 3).select(tableCellText.domElement());
      tableCellText._keyTab(ev);
      expect(tbody.children.length).toBe(rows + 1);
      otherTableCellText = tbody.children[rows].children[0].tableCellText();
      return expect(factory.root.focused()).toBe(otherTableCellText);
    });
    it('should support using shift-tab to nav to previous table cell', function() {
      var otherTableCellText, tableCellText;
      tableCellText = tbody.children[1].children[0].tableCellText();
      tableCellText.focus();
      new ContentSelect.Range(3, 3).select(tableCellText.domElement());
      ev.shiftKey = true;
      tableCellText._keyTab(ev);
      otherTableCellText = tbody.children[0].children[1].tableCellText();
      return expect(factory.root.focused()).toBe(otherTableCellText);
    });
    return it('should not create an new body row on tab if spawn is disallowed', function() {
      var rows, tableCell, tableCellText;
      rows = tbody.children.length;
      tableCell = tbody.children[1].children[1];
      tableCell.can('spawn', false);
      tableCellText = tableCell.tableCellText();
      tableCellText.focus();
      new ContentSelect.Range(3, 3).select(tableCellText.domElement());
      tableCellText._keyTab(ev);
      return expect(tbody.children.length).toBe(rows);
    });
  });

}).call(this);
