#
# The MIT License (MIT)
#
# Copyright (c) 2022 Kristian Kutin
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

class XmlHelper {

	static [void] checkDocument([xml] $document) {

		if ($document.ChildNodes.Count -ne 2) {

			throw 'The document is malformed (root mismatch)!';
		}
	}

	static [void] checkElement([System.Xml.XmlLinkedNode] $node, [String] $expectedName) {

		if ($node.LocalName -ne $expectedName) {

			throw 'The specified xml element is invalid (expected=' + $expectedName + '; actual=' + $node.LocalName + ')!';
		}
	}

	static [void] checkAttribute([System.Xml.XmlLinkedNode] $node, [String] $expectedName) {

		if (!($node.hasAttribute($expectedName))) {

			throw 'The specified xml element is invalid (element=' + $node.Name + '; missing attribute=' + $expectedName + ')!';
		}
	}

	static [void] checkChildNodes([System.Xml.XmlLinkedNode] $node, [int] $expectedCount) {

		if ($node.ChildNodes.Count -ne $expectedCount) {

			throw 'The specified xml element (' + $node.Name + ') doesn''t have the expected child elements (expected=' + $expectedCount + '; actual=' + (node.ChildNodes.Count) + ')!';
		}
	}

}
