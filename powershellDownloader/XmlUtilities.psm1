
# ================================================================================
# ===
# ===   Constant Declarations
# ===


# ================================================================================
# ===
# ===   Variable Declarations
# ===


# ================================================================================
# ===
# ===   Type Declarations
# ===


# ================================================================================
# ===
# ===   Class Declarations
# ===

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

		if (!($node.ChildNodes.Count -eq $expectedCount)) {

			throw 'The specified xml element (' + $node.Name + ') doesn''t have the expected child elements (expected=' + $expectedCount + '; actual=' + (node.ChildNodes.Count) + ')!';
		}
	}

}


# ================================================================================
# ===
# ===   Function Declarations
# ===
