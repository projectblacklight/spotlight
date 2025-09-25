# frozen_string_literal: true

module IiifResponses
  def complex_collection
    {
      '@id': 'uri://for-top-level-collection',
      '@type': 'sc:Collection',
      label: 'Complex Collection',
      collections: [
        {
          '@id': 'uri://for-child-collection1',
          '@type': 'sc:Collection',
          label: 'Child Collection 1'
        },
        {
          '@id': 'uri://for-child-collection2',
          '@type': 'sc:Collection',
          label: 'Child Collection 2'
        }
      ],
      manifests: [
        {
          '@id': 'uri://for-manifest1',
          '@type': 'sc:Manifest',
          label: 'Test Manifest 1'
        }
      ]
    }.to_json
  end

  def child_collection1
    {
      '@id': 'uri://for-child-collection1',
      '@type': 'sc:Collection',
      label: 'Child Collection 1',
      collections: [
        {
          '@id': 'uri://for-child-collection3',
          '@type': 'sc:Collection',
          label: 'Child Collection 3'
        }
      ],
      manifests: [
        {
          '@id': 'uri://for-manifest2',
          '@type': 'sc:Manifest',
          label: 'Test Manifest 2'
        }
      ]
    }.to_json
  end

  def child_collection2
    {
      '@id': 'uri://for-child-collection2',
      '@type': 'sc:Collection',
      label: 'Child Collection 2',
      manifests: [
        {
          '@id': 'uri://for-manifest4',
          '@type': 'sc:Manifest',
          label: 'Test Manifest 4'
        }
      ]
    }.to_json
  end

  def child_collection3
    {
      '@id': 'uri://for-child-collection3',
      '@type': 'sc:Collection',
      label: 'Child Collection 3',
      manifests: [
        {
          '@id': 'uri://for-manifest3',
          '@type': 'sc:Manifest',
          label: 'Test Manifest 3'
        }
      ]
    }.to_json
  end

  def test_manifest1
    {
      '@id': 'uri://for-manifest1',
      '@type': 'sc:Manifest',
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
        '@id': 'uri://to-thumbnail'
      },
      sequences: [
        {
          '@type': 'sc:Sequence',
          canvases: [
            {
              '@type': 'sc:Canvas',
              images: [
                {
                  '@type': 'oa:Annotation',
                  resource: {
                    '@type': 'dcterms:Image',
                    '@id': 'uri://full-image',
                    service: {
                      '@id': 'uri://to-image-service'
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
      '@id': 'uri://for-manifest2',
      '@type': 'sc:Manifest',
      label: {
        '@value': 'Test Manifest 2',
        '@language': 'en'
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
        '@id': 'uri://to-thumbnail'
      },
      sequences: [
        {
          '@type': 'sc:Sequence',
          canvases: [
            {
              '@type': 'sc:Canvas',
              images: [
                {
                  '@type': 'oa:Annotation',
                  resource: {
                    '@type': 'dcterms:Image',
                    service: {
                      '@id': 'uri://to-image-service'
                    }
                  }
                },
                {
                  '@type': 'oa:Annotation',
                  resource: {
                    '@type': 'dcterms:Image',
                    service: {
                      '@id': 'uri://to-image-service2'
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
      '@id': 'uri://for-manifest3',
      '@type': 'sc:Manifest',
      label: [
        {
          '@value': 'Test Manifest 3',
          '@language': 'en'
        },
        {
          '@value': "Manifeste d'essai 3",
          '@language': 'fr'
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
        '@id': 'uri://to-thumbnail'
      },
      sequences: [
        {
          '@type': 'sc:Sequence',
          canvases: [
            {
              '@type': 'sc:Canvas',
              images: [
                {
                  '@type': 'oa:Annotation',
                  resource: {
                    '@type': 'dcterms:Image',
                    service: {
                      '@id': 'uri://to-image-service'
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
      '@id': 'uri://for-manifest4',
      '@type': 'sc:Manifest',
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
        '@id': 'uri://to-thumbnail'
      },
      sequences: [
        {
          '@type': 'sc:Sequence',
          canvases: [
            {
              '@type': 'sc:Canvas',
              images: [
                {
                  '@type': 'oa:Annotation',
                  resource: {
                    '@type': 'dcterms:Image',
                    service: {
                      '@id': 'uri://to-image-service'
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

  def test_v3_manifest
    {
      '@context' => [
        'http://www.w3.org/ns/anno.jsonld',
        'http://iiif.io/api/presentation/3/context.json'
      ],
      'type' => 'Manifest',
      'id' => 'uri://for-v3-manifest',
      'label' => {
        'eng' => [
          'A Map of the British and French settlements in North America'
        ]
      },
      'summary' => {
        'eng' => [
          'Relief shown pictorially.',
          'From the Universal magazine of knowledge and pleasure. v. 17, Oct. 1755, p. 144-145.',
          'Inset: Fort Frederick at Crown Point built by the French, 1731.'
        ]
      },
      'behavior' => [
        'individuals'
      ],
      'metadata' => [
        {
          'label' => {
            'eng' => [
              'Title'
            ]
          },
          'value' => {
            'eng' => [
              'Map of the British and French settlements in North America',
              'A Map of the British and French settlements in North America'
            ]
          }
        },
        {
          'label' => {
            'eng' => [
              'Type'
            ]
          },
          'value' => {
            'eng' => [
              'Maps'
            ]
          }
        },
        {
          'label' => {
            'eng' => [
              'Contributor'
            ]
          },
          'value' => {
            'eng' => [
              'Hinton, John, d. 1781'
            ]
          }
        },
        {
          'label' => {
            'eng' => [
              'Cartographic Scale'
            ]
          },
          'value' => {
            'eng' => [
              'Scale [ca. 1:10,000,000].'
            ]
          }
        },
        {
          'label' => {
            'eng' => [
              'Call Number'
            ]
          },
          'value' => {
            'eng' => [
              'HMC01.1058'
            ]
          }
        },
        {
          'label' => {
            'eng' => [
              'Call Number'
            ]
          },
          'value' => {
            'eng' => [
              'Electronic Resource'
            ]
          }
        }
      ],
      'rendering' => [
        {
          'type' => 'Text',
          'label' => {
            'en' => [
              'Download as PDF'
            ]
          },
          'format' => 'application/pdf',
          'id' => 'https://example.org/concern/scanned_maps/for-v3-manifest/pdf'
        },
        {
          'id' => 'http://example.org/for-v3-manifest/permanent-link',
          'format' => 'text/html',
          'type' => 'Text',
          'label' => {
            'en' => [
              'View in catalog'
            ]
          }
        }
      ],
      'items' => [
        {
          'type' => 'Canvas',
          'id' => 'https://example.org/concern/scanned_maps/for-v3-manifest/manifest/canvas/image-1',
          'items' => [
            {
              'type' => 'AnnotationPage',
              'items' => [
                {
                  'type' => 'Annotation',
                  'motivation' => 'painting',
                  'body' => {
                    'id' => 'https://iiif-cloud.example.org/iiif/2/for-v3-manifest/image-1/intermediate_file/full/1000,/0/default.jpg',
                    'type' => 'Image',
                    'height' => 4468,
                    'width' => 5998,
                    'format' => 'image/jpeg',
                    'service' =>
                      {
                        '@id' => 'https://iiif-cloud.example.org/iiif/2/for-v3-manifest/image-1/intermediate_file',
                        'profile' => 'http://iiif.io/api/image/2/level2.json',
                        '@type' => 'ImageService2'
                      }
                  },
                  'id' => 'https://example.org/concern/scanned_maps/for-v3-manifest/manifest/canvas/image-1/annotation_page/page-1/annotation/annotation-1',
                  'target' => 'https://example.org/concern/scanned_maps/for-v3-manifest/manifest/canvas/image-1'
                }
              ],
              'id' => 'https://example.org/concern/scanned_maps/for-v3-manifest/manifest/canvas/image-1/annotation_page/page-1'
            }
          ],
          'label' => {
            'eng' => [
              'PUmap_9170'
            ]
          },
          'thumbnail' => [
            {
              'id' => 'https://iiif-cloud.example.org/iiif/2/for-v3-manifest/image-1/intermediate_file/full/!200,200/0/default.jpg',
              'type' => 'Image',
              'height' => 149,
              'width' => 200,
              'format' => 'image/jpeg',
              'service' =>
                {
                  '@id' => 'https://iiif-cloud.example.org/iiif/2/for-v3-manifest/image-1/intermediate_file',
                  'profile' => 'http://iiif.io/api/image/2/level2.json',
                  '@type' => 'ImageService2'
                }
            }
          ],
          'local_identifier' => 'p6w926v351',
          'rendering' => [
            {
              'id' => 'https://example.org/downloads/for-v3-manifest/file/image-1',
              'format' => 'image/tiff',
              'type' => 'Dataset',
              'label' => {
                'en' => [
                  'Download the original file'
                ]
              }
            }
          ],
          'width' => 5998,
          'height' => 4468
        }
      ],
      'thumbnail' => [
        {
          'id' => 'uri://to-thumbnail',
          'type' => 'Image',
          'format' => 'image/jpeg',
          'height' => 150
        }
      ],
      'rights' => 'http://rightsstatements.org/vocab/NKC/1.0/',
      'requiredStatement' => {
        'label' => {
          'en' => [
            'Attribution'
          ]
        },
        'value' => {
          'en' => [
            '<span>Glen Robson, IIIF Technical Coordinator. <a href="https://creativecommons.org/licenses/by-sa/3.0">CC BY-SA 3.0</a>'
          ]
        }
      },
      'provider' => [
        {
          'id' => 'https://library.princeton.edu',
          'type' => 'Agent',
          'label' => {
            'en' => [
              'Princeton University Library'
            ]
          },
          'logo' => [
            {
              'id' => 'https://example.org/pul_logo_icon.png',
              'type' => 'Image',
              'format' => 'image/png',
              'height' => 100,
              'width' => 120
            }
          ]
        }
      ]
    }.to_json
  end

  def test_multilingual_v3_manifest
    {
      '@context' => 'http://iiif.io/api/presentation/3/context.json',
      'id' => 'https://iiif.io/api/cookbook/recipe/0006-text-language/manifest.json',
      'type' => 'Manifest',
      'label' => {
        'en' => [
          "Whistler's Mother"
        ],
        'fr' => [
          'La Mère de Whistler'
        ]
      },
      'metadata' => [
        {
          'label' => {
            'en' => [
              'Creator'
            ],
            'fr' => [
              'Auteur'
            ]
          },
          'value' => {
            'none' => [
              'Whistler, James Abbott McNeill'
            ]
          }
        },
        {
          'label' => {
            'en' => [
              'Subject'
            ],
            'fr' => [
              'Sujet'
            ]
          },
          'value' => {
            'en' => [
              'McNeill Anna Matilda, mother of Whistler (1804-1881)'
            ],
            'fr' => [
              'McNeill Anna Matilda, mère de Whistler (1804-1881)'
            ]
          }
        }
      ],
      'summary' => {
        'en' => [
          "Arrangement in Grey and Black No. 1, also called Portrait of the Artist's Mother."
        ],
        'fr' => [
          "Arrangement en gris et noir n°1, also called Portrait de la mère de l'artiste."
        ]
      },
      'requiredStatement' => {
        'label' => {
          'en' => [
            'Held By'
          ],
          'fr' => [
            'Détenu par'
          ]
        },
        'value' => {
          'none' => [
            "Musée d'Orsay, Paris, France"
          ]
        }
      },
      'items' => [
        {
          'id' => 'https://iiif.io/api/cookbook/recipe/0006-text-language/canvas/p1',
          'type' => 'Canvas',
          'width' => 1114,
          'height' => 991,
          'items' => [
            {
              'id' => 'https://iiif.io/api/cookbook/recipe/0006-text-language/page/p1/1',
              'type' => 'AnnotationPage',
              'items' => [
                {
                  'id' => 'https://iiif.io/api/cookbook/recipe/0006-text-language/annotation/p0001-image',
                  'type' => 'Annotation',
                  'motivation' => 'painting',
                  'body' => {
                    'id' => 'https://iiif.io/api/image/3.0/example/reference/329817fc8a251a01c393f517d8a17d87-Whistlers_Mother/full/max/0/default.jpg',
                    'type' => 'Image',
                    'format' => 'image/jpeg',
                    'width' => 1114,
                    'height' => 991,
                    'service' =>
                      {
                        'id' => 'https://iiif.io/api/image/3.0/example/reference/329817fc8a251a01c393f517d8a17d87-Whistlers_Mother',
                        'profile' => 'level1',
                        'type' => 'ImageService3'
                      }
                  },
                  'target' => 'https://iiif.io/api/cookbook/recipe/0006-text-language/canvas/p1'
                }
              ]
            }
          ]
        }
      ]
    }.to_json
  end
end
