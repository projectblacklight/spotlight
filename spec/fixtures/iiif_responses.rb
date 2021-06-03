# frozen_string_literal: true

module IiifResponses
  def complex_collection
    {
      "@id": 'uri://for-top-level-collection',
      "@type": 'sc:Collection',
      label: 'Complex Collection',
      collections: [
        {
          "@id": 'uri://for-child-collection1',
          "@type": 'sc:Collection',
          label: 'Child Collection 1'
        },
        {
          "@id": 'uri://for-child-collection2',
          "@type": 'sc:Collection',
          label: 'Child Collection 2'
        }
      ],
      manifests: [
        {
          "@id": 'uri://for-manifest1',
          "@type": 'sc:Manifest',
          label: 'Test Manifest 1'
        }
      ]
    }.to_json
  end

  def child_collection1
    {
      "@id": 'uri://for-child-collection1',
      "@type": 'sc:Collection',
      label: 'Child Collection 1',
      collections: [
        {
          "@id": 'uri://for-child-collection3',
          "@type": 'sc:Collection',
          label: 'Child Collection 3'
        }
      ],
      manifests: [
        {
          "@id": 'uri://for-manifest2',
          "@type": 'sc:Manifest',
          label: 'Test Manifest 2'
        }
      ]
    }.to_json
  end

  def child_collection2
    {
      "@id": 'uri://for-child-collection2',
      "@type": 'sc:Collection',
      label: 'Child Collection 2',
      manifests: [
        {
          "@id": 'uri://for-manifest4',
          "@type": 'sc:Manifest',
          label: 'Test Manifest 4'
        }
      ]
    }.to_json
  end

  def child_collection3
    {
      "@id": 'uri://for-child-collection3',
      "@type": 'sc:Collection',
      label: 'Child Collection 3',
      manifests: [
        {
          "@id": 'uri://for-manifest3',
          "@type": 'sc:Manifest',
          label: 'Test Manifest 3'
        }
      ]
    }.to_json
  end

  def test_manifest1
    {
      "@id": 'uri://for-manifest1',
      "@type": 'sc:Manifest',
      label: 'Test Manifest 1',
      attribution: 'Attribution Data',
      description: 'A test IIIF manifest',
      license: 'http://www.example.org/license.html',
      metadata: [
        {
          label: 'Author',
          value: 'John Doe'
        },
        {
          label: 'Author',
          value: 'Jane Doe'
        },
        {
          label: 'Another Field',
          value: 'Some data'
        }
      ],
      thumbnail: {
        "@id": 'uri://to-thumbnail'
      },
      sequences: [
        {
          "@type": 'sc:Sequence',
          canvases: [
            {
              "@type": 'sc:Canvas',
              images: [
                {
                  "@type": 'oa:Annotation',
                  resource: {
                    "@type": 'dcterms:Image',
                    "@id": 'uri://full-image',
                    service: {
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
      label: {
        "@value": 'Test Manifest 2',
        "@language": 'en'
      },
      attribution: 'Attribution Data',
      description: 'A test IIIF manifest',
      license: 'http://www.example.org/license.html',
      metadata: [
        {
          label: 'Contributor',
          value: 'John Doe'
        },
        {
          label: 'Yet Another Field',
          value: 'Some data'
        }
      ],
      thumbnail: {
        "@id": 'uri://to-thumbnail'
      },
      sequences: [
        {
          "@type": 'sc:Sequence',
          canvases: [
            {
              "@type": 'sc:Canvas',
              images: [
                {
                  "@type": 'oa:Annotation',
                  resource: {
                    "@type": 'dcterms:Image',
                    service: {
                      "@id": 'uri://to-image-service'
                    }
                  }
                },
                {
                  "@type": 'oa:Annotation',
                  resource: {
                    "@type": 'dcterms:Image',
                    service: {
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
      label: [
        {
          "@value": 'Test Manifest 3',
          "@language": 'en'
        },
        {
          "@value": "Manifeste d'essai 3",
          "@language": 'fr'
        }
      ],
      attribution: 'Attribution Data',
      description: 'A test IIIF manifest',
      license: 'http://www.example.org/license.html',
      metadata: [
        {
          label: 'Author',
          value: 'Jane Doe'
        },
        {
          label: 'Collection',
          value: 'Some Collection'
        }
      ],
      thumbnail: {
        "@id": 'uri://to-thumbnail'
      },
      sequences: [
        {
          "@type": 'sc:Sequence',
          canvases: [
            {
              "@type": 'sc:Canvas',
              images: [
                {
                  "@type": 'oa:Annotation',
                  resource: {
                    "@type": 'dcterms:Image',
                    service: {
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
      label: 'Test Manifest 4',
      attribution: 'Attribution Data',
      description: 'A test IIIF manifest',
      license: 'http://www.example.org/license.html',
      metadata: [
        {
          label: 'Contributor',
          value: 'Jane Doe'
        },
        {
          label: 'Location',
          value: 'Some location'
        }
      ],
      thumbnail: {
        "@id": 'uri://to-thumbnail'
      },
      sequences: [
        {
          "@type": 'sc:Sequence',
          canvases: [
            {
              "@type": 'sc:Canvas',
              images: [
                {
                  "@type": 'oa:Annotation',
                  resource: {
                    "@type": 'dcterms:Image',
                    service: {
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

  # inspired by https://api.digitale-sammlungen.de/iiif/presentation/v2/bsb00017921/manifest
  def test_multilingual_manifest_like_bsb
    { '@context' => 'http://iiif.io/api/presentation/2/context.json',
      '@type' => 'sc:Manifest',
      '@id' => 'https://api.digitale-sammlungen.de/iiif/presentation/v2/bsb00017921/manifest',
      'label' => 'Murasaki Shikibu: Genji monogatari - BSB Cod.jap. 18(53',
      'metadata' => [
        { 'label' =>
         [{ '@language' => 'de', '@value' => 'Verfasser' },
          { '@language' => 'zh', '@value' => '作者' },
          { '@language' => 'en', '@value' => 'Author' }],
          'value' =>
         "<span>Murasaki Shikibu -- (GND: <a href='http://d-nb.info/gnd/118985655/'>118985655</a>)</span>" },
        { 'label' =>
         [{ '@language' => 'de', '@value' => 'Sprache' },
          { '@language' => 'zh', '@value' => '語言' },
          { '@language' => 'en', '@value' => 'Language' }],
          'value' =>
         [{ '@language' => 'de', '@value' => 'Japanisch' },
          { '@language' => 'zh', '@value' => '日语' },
          { '@language' => 'en', '@value' => 'Japanese' }] }
      ] }.to_json
  end
end
