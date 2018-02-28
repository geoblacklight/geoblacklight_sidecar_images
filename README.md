# GeoBlacklight Sidecar Images
Store local copies of remote imagery in GeoBlacklight.

## Description
This GeoBlacklight plugin helps capture remote images from geo web services and save them locally. It borrows the concept of a [SolrDocumentSidecar](https://github.com/projectblacklight/spotlight/blob/master/app/models/spotlight/solr_document_sidecar.rb) from [Spotlight](https://github.com/projectblacklight/spotlight), to have an ActiveRecord-based "sidecar" to match each non-AR SolrDocument. This allows us to use [carrierwave](https://github.com/carrierwaveuploader/carrierwave) to attach images to our documents.

## Requirements

* [Blacklight](https://github.com/projectblacklight/blacklight/)
* [GeoBlacklight](https://github.com/geoblacklight/geoblacklight)
* [ImageMagick](https://github.com/ImageMagick/ImageMagick)

## Installation

Forthcoming

## Development

rake ci
cd .internal_test_app/
rake geoblacklight:server

### Ingest Test Documents
rake geoblacklight_sidecar_images:sample_data:ingest['/Users/ewlarson/Rails/geoblacklight_sidecar_images/spec/fixtures/files']

### Cache images
rake geoblacklight_sidecar_images:images:precache_id['minnesota-iiif-jpg-83f4648a-125c-4000-a12f-aba2b432e7cd']
rake geoblacklight_sidecar_images:images:precache_all

## TODOs

* EngineCart / rake ci (complete)
* Write specs / Use VCR for HTTP interactions / Spotlight examples?
* Remove .png bias / Use U of MN IIIF server (jpeg)
* Forgo attaching Placeholder imagery?
* Rails 5.2 branch / ActionStorage
