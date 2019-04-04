# frozen_string_literal: true

module IiifResponses
  def complex_collection
    {
      "@id": 'uri://for-top-level-collection',
      "@type": 'sc:Collection',
      "label": 'Complex Collection',
      "collections": [
        {
          "@id": 'uri://for-child-collection1',
          "@type": 'sc:Collection',
          "label": 'Child Collection 1'
        },
        {
          "@id": 'uri://for-child-collection2',
          "@type": 'sc:Collection',
          "label": 'Child Collection 2'
        }
      ],
      "manifests": [
        {
          "@id": 'uri://for-manifest1',
          "@type": 'sc:Manifest',
          "label": 'Test Manifest 1'
        }
      ]
    }.to_json
  end

  def child_collection1
    {
      "@id": 'uri://for-child-collection1',
      "@type": 'sc:Collection',
      "label": 'Child Collection 1',
      "collections": [
        {
          "@id": 'uri://for-child-collection3',
          "@type": 'sc:Collection',
          "label": 'Child Collection 3'
        }
      ],
      "manifests": [
        {
          "@id": 'uri://for-manifest2',
          "@type": 'sc:Manifest',
          "label": 'Test Manifest 2'
        }
      ]
    }.to_json
  end

  def child_collection2
    {
      "@id": 'uri://for-child-collection2',
      "@type": 'sc:Collection',
      "label": 'Child Collection 2',
      "manifests": [
        {
          "@id": 'uri://for-manifest4',
          "@type": 'sc:Manifest',
          "label": 'Test Manifest 4'
        }
      ]
    }.to_json
  end

  def child_collection3
    {
      "@id": 'uri://for-child-collection3',
      "@type": 'sc:Collection',
      "label": 'Child Collection 3',
      "manifests": [
        {
          "@id": 'uri://for-manifest3',
          "@type": 'sc:Manifest',
          "label": 'Test Manifest 3'
        }
      ]
    }.to_json
  end

  def test_manifest1
    {
      "@id": 'uri://for-manifest1',
      "@type": 'sc:Manifest',
      "label": 'Test Manifest 1',
      "attribution": 'Attribution Data',
      "description": 'A test IIIF manifest',
      "license": 'http://www.example.org/license.html',
      "metadata": [
        {
          "label": 'Author',
          "value": 'John Doe'
        },
        {
          "label": 'Author',
          "value": 'Jane Doe'
        },
        {
          "label": 'Another Field',
          "value": 'Some data'
        }
      ],
      "thumbnail": {
        "@id": 'uri://to-thumbnail'
      },
      "sequences": [
        {
          "@type": 'sc:Sequence',
          "canvases": [
            {
              "@type": 'sc:Canvas',
              "images": [
                {
                  "@type": 'oa:Annotation',
                  "resource": {
                    "@type": 'dcterms:Image',
                    "@id": 'uri://full-image',
                    "service": {
                      "@id": 'uri://to-image-service'
                    }
                  }
                }
              ]
            }
          ]
        }
      ]
    }.to_json
  end

  def test_manifest2
    {
      "@id": 'uri://for-manifest2',
      "@type": 'sc:Manifest',
      "label": {
        "@value": 'Test Manifest 2',
        "@language": 'en'
      },
      "attribution": 'Attribution Data',
      "description": 'A test IIIF manifest',
      "license": 'http://www.example.org/license.html',
      "metadata": [
        {
          "label": 'Contributor',
          "value": 'John Doe'
        },
        {
          "label": 'Yet Another Field',
          "value": 'Some data'
        }
      ],
      "thumbnail": {
        "@id": 'uri://to-thumbnail'
      },
      "sequences": [
        {
          "@type": 'sc:Sequence',
          "canvases": [
            {
              "@type": 'sc:Canvas',
              "images": [
                {
                  "@type": 'oa:Annotation',
                  "resource": {
                    "@type": 'dcterms:Image',
                    "service": {
                      "@id": 'uri://to-image-service'
                    }
                  }
                },
                {
                  "@type": 'oa:Annotation',
                  "resource": {
                    "@type": 'dcterms:Image',
                    "service": {
                      "@id": 'uri://to-image-service2'
                    }
                  }
                }
              ]
            }
          ]
        }
      ]
    }.to_json
  end

  def test_manifest3
    {
      "@id": 'uri://for-manifest3',
      "@type": 'sc:Manifest',
      "label": [
        {
          "@value": 'Test Manifest 3',
          "@language": 'en'
        },
        {
          "@value": "Manifeste d'essai 3",
          "@language": 'fr'
        }
      ],
      "attribution": 'Attribution Data',
      "description": 'A test IIIF manifest',
      "license": 'http://www.example.org/license.html',
      "metadata": [
        {
          "label": 'Author',
          "value": 'Jane Doe'
        },
        {
          "label": 'Collection',
          "value": 'Some Collection'
        }
      ],
      "thumbnail": {
        "@id": 'uri://to-thumbnail'
      },
      "sequences": [
        {
          "@type": 'sc:Sequence',
          "canvases": [
            {
              "@type": 'sc:Canvas',
              "images": [
                {
                  "@type": 'oa:Annotation',
                  "resource": {
                    "@type": 'dcterms:Image',
                    "service": {
                      "@id": 'uri://to-image-service'
                    }
                  }
                }
              ]
            }
          ]
        }
      ]
    }.to_json
  end

  def test_manifest4
    {
      "@id": 'uri://for-manifest4',
      "@type": 'sc:Manifest',
      "label": 'Test Manifest 4',
      "attribution": 'Attribution Data',
      "description": 'A test IIIF manifest',
      "license": 'http://www.example.org/license.html',
      "metadata": [
        {
          "label": 'Contributor',
          "value": 'Jane Doe'
        },
        {
          "label": 'Location',
          "value": 'Some location'
        }
      ],
      "thumbnail": {
        "@id": 'uri://to-thumbnail'
      },
      "sequences": [
        {
          "@type": 'sc:Sequence',
          "canvases": [
            {
              "@type": 'sc:Canvas',
              "images": [
                {
                  "@type": 'oa:Annotation',
                  "resource": {
                    "@type": 'dcterms:Image',
                    "service": {
                      "@id": 'uri://to-image-service'
                    }
                  }
                }
              ]
            }
          ]
        }
      ]
    }.to_json
  end
end
