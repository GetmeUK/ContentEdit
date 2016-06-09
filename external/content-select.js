(function() {
  var ContentSelect, SELF_CLOSING_NODE_NAMES, exports, _containedBy, _getChildNodeAndOffset, _getNodeRange, _getOffsetOfChildNode,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  ContentSelect = {};

  ContentSelect.Range = (function() {
    function Range(from, to) {
      this.set(from, to);
    }

    Range.prototype.isCollapsed = function() {
      return this._from === this._to;
    };

    Range.prototype.span = function() {
      return this._to - this._from;
    };

    Range.prototype.collapse = function() {
      return this._to = this._from;
    };

    Range.prototype.eq = function(range) {
      return this.get()[0] === range.get()[0] && this.get()[1] === range.get()[1];
    };

    Range.prototype.get = function() {
      return [this._from, this._to];
    };

    Range.prototype.select = function(element) {
      var docRange, endNode, endNodeLen, endOffset, startNode, startNodeLen, startOffset, _ref, _ref1;
      ContentSelect.Range.unselectAll();
      docRange = document.createRange();
      _ref = _getChildNodeAndOffset(element, this._from), startNode = _ref[0], startOffset = _ref[1];
      _ref1 = _getChildNodeAndOffset(element, this._to), endNode = _ref1[0], endOffset = _ref1[1];
      startNodeLen = startNode.length || 0;
      endNodeLen = endNode.length || 0;
      docRange.setStart(startNode, Math.min(startOffset, startNodeLen));
      docRange.setEnd(endNode, Math.min(endOffset, endNodeLen));
      return window.getSelection().addRange(docRange);
    };

    Range.prototype.set = function(from, to) {
      from = Math.max(0, from);
      to = Math.max(0, to);
      this._from = Math.min(from, to);
      return this._to = Math.max(from, to);
    };

    Range.prepareElement = function(element) {
      var i, node, selfClosingNodes, _i, _len, _results;
      selfClosingNodes = element.querySelectorAll(SELF_CLOSING_NODE_NAMES.join(', '));
      _results = [];
      for (i = _i = 0, _len = selfClosingNodes.length; _i < _len; i = ++_i) {
        node = selfClosingNodes[i];
        node.parentNode.insertBefore(document.createTextNode(''), node);
        if (i < selfClosingNodes.length - 1) {
          _results.push(node.parentNode.insertBefore(document.createTextNode(''), node.nextSibling));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    Range.query = function(element) {
      var docRange, endNode, endOffset, range, startNode, startOffset, _ref;
      range = new ContentSelect.Range(0, 0);
      try {
        docRange = window.getSelection().getRangeAt(0);
      } catch (_error) {
        return range;
      }
      if (element.firstChild === null && element.lastChild === null) {
        return range;
      }
      if (!_containedBy(docRange.startContainer, element)) {
        return range;
      }
      if (!_containedBy(docRange.endContainer, element)) {
        return range;
      }
      _ref = _getNodeRange(element, docRange), startNode = _ref[0], startOffset = _ref[1], endNode = _ref[2], endOffset = _ref[3];
      range.set(_getOffsetOfChildNode(element, startNode) + startOffset, _getOffsetOfChildNode(element, endNode) + endOffset);
      return range;
    };

    Range.rect = function() {
      var docRange, marker, rect;
      try {
        docRange = window.getSelection().getRangeAt(0);
      } catch (_error) {
        return null;
      }
      if (docRange.collapsed) {
        marker = document.createElement('span');
        docRange.insertNode(marker);
        rect = marker.getBoundingClientRect();
        marker.parentNode.removeChild(marker);
        return rect;
      } else {
        return docRange.getBoundingClientRect();
      }
    };

    Range.unselectAll = function() {
      if (window.getSelection()) {
        return window.getSelection().removeAllRanges();
      }
    };

    return Range;

  })();

  SELF_CLOSING_NODE_NAMES = ['br', 'img', 'input'];

  _containedBy = function(nodeA, nodeB) {
    while (nodeA) {
      if (nodeA === nodeB) {
        return true;
      }
      nodeA = nodeA.parentNode;
    }
    return false;
  };

  _getChildNodeAndOffset = function(parentNode, parentOffset) {
    var childNode, childOffset, childStack, n, _ref;
    if (parentNode.childNodes.length === 0) {
      return [parentNode, parentOffset];
    }
    childNode = null;
    childOffset = parentOffset;
    childStack = (function() {
      var _i, _len, _ref, _results;
      _ref = parentNode.childNodes;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        n = _ref[_i];
        _results.push(n);
      }
      return _results;
    })();
    while (childStack.length > 0) {
      childNode = childStack.shift();
      switch (childNode.nodeType) {
        case Node.TEXT_NODE:
          if (childNode.textContent.length >= childOffset) {
            return [childNode, childOffset];
          }
          childOffset -= childNode.textContent.length;
          break;
        case Node.ELEMENT_NODE:
          if (_ref = childNode.nodeName.toLowerCase(), __indexOf.call(SELF_CLOSING_NODE_NAMES, _ref) >= 0) {
            if (childOffset === 0) {
              return [childNode, 0];
            } else {
              childOffset = Math.max(0, childOffset - 1);
            }
          } else {
            if (childNode.childNodes) {
              Array.prototype.unshift.apply(childStack, (function() {
                var _i, _len, _ref1, _results;
                _ref1 = childNode.childNodes;
                _results = [];
                for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
                  n = _ref1[_i];
                  _results.push(n);
                }
                return _results;
              })());
            }
          }
      }
    }
    return [childNode, childOffset];
  };

  _getOffsetOfChildNode = function(parentNode, childNode) {
    var childStack, n, offset, otherChildNode, _ref, _ref1;
    if (parentNode.childNodes.length === 0) {
      return 0;
    }
    offset = 0;
    childStack = (function() {
      var _i, _len, _ref, _results;
      _ref = parentNode.childNodes;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        n = _ref[_i];
        _results.push(n);
      }
      return _results;
    })();
    while (childStack.length > 0) {
      otherChildNode = childStack.shift();
      if (otherChildNode === childNode) {
        if (_ref = otherChildNode.nodeName.toLowerCase(), __indexOf.call(SELF_CLOSING_NODE_NAMES, _ref) >= 0) {
          return offset + 1;
        }
        return offset;
      }
      switch (otherChildNode.nodeType) {
        case Node.TEXT_NODE:
          offset += otherChildNode.textContent.length;
          break;
        case Node.ELEMENT_NODE:
          if (_ref1 = otherChildNode.nodeName.toLowerCase(), __indexOf.call(SELF_CLOSING_NODE_NAMES, _ref1) >= 0) {
            offset += 1;
          } else {
            if (otherChildNode.childNodes) {
              Array.prototype.unshift.apply(childStack, (function() {
                var _i, _len, _ref2, _results;
                _ref2 = otherChildNode.childNodes;
                _results = [];
                for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
                  n = _ref2[_i];
                  _results.push(n);
                }
                return _results;
              })());
            }
          }
      }
    }
    return offset;
  };

  _getNodeRange = function(element, docRange) {
    var childNode, childNodes, endNode, endOffset, endRange, i, startNode, startOffset, startRange, _i, _j, _len, _len1, _ref;
    childNodes = element.childNodes;
    startRange = docRange.cloneRange();
    startRange.collapse(true);
    endRange = docRange.cloneRange();
    endRange.collapse(false);
    startNode = startRange.startContainer;
    startOffset = startRange.startOffset;
    endNode = endRange.endContainer;
    endOffset = endRange.endOffset;
    if (!startRange.comparePoint) {
      return [startNode, startOffset, endNode, endOffset];
    }
    if (startNode === element) {
      startNode = childNodes[childNodes.length - 1];
      startOffset = startNode.textContent.length;
      for (i = _i = 0, _len = childNodes.length; _i < _len; i = ++_i) {
        childNode = childNodes[i];
        if (startRange.comparePoint(childNode, 0) !== 1) {
          continue;
        }
        if (i === 0) {
          startNode = childNode;
          startOffset = 0;
        } else {
          startNode = childNodes[i - 1];
          startOffset = childNode.textContent.length;
        }
        if (_ref = startNode.nodeName.toLowerCase, __indexOf.call(SELF_CLOSING_NODE_NAMES, _ref) >= 0) {
          startOffset = 1;
        }
        break;
      }
    }
    if (docRange.collapsed) {
      return [startNode, startOffset, startNode, startOffset];
    }
    if (endNode === element) {
      endNode = childNodes[childNodes.length - 1];
      endOffset = endNode.textContent.length;
      for (i = _j = 0, _len1 = childNodes.length; _j < _len1; i = ++_j) {
        childNode = childNodes[i];
        if (endRange.comparePoint(childNode, 0) !== 1) {
          continue;
        }
        if (i === 0) {
          endNode = childNode;
        } else {
          endNode = childNodes[i - 1];
        }
        endOffset = childNode.textContent.length + 1;
      }
    }
    return [startNode, startOffset, endNode, endOffset];
  };

  if (typeof window !== 'undefined') {
    window.ContentSelect = ContentSelect;
  }

  if (typeof module !== 'undefined' && module.exports) {
    exports = module.exports = ContentSelect;
  }

}).call(this);
