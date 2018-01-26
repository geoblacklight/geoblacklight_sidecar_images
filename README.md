# Geoblacklight Sidecar Images
Store local copies of remote imagery in GeoBlacklight.

## Description
This Geoblacklight plugin helps capture remote images from Geo web services and save them locally. It borrows the concept of a [SolrDocumentSidecar](https://github.com/projectblacklight/spotlight/blob/master/app/models/spotlight/solr_document_sidecar.rb) from [Spotlight](https://github.com/projectblacklight/spotlight), to have an ActiveRecord-based "sidecar" to match each non-AR SolrDocument. This allows us to use [carrierwave](https://github.com/carrierwaveuploader/carrierwave) to attach images to our documents.

## Requirements

* [Blacklight](https://github.com/projectblacklight/blacklight/)
* [Geoblacklight](https://github.com/geoblacklight/geoblacklight)
* [ImageMagick](https://github.com/ImageMagick/ImageMagick)

## Installation

Forthcoming

## TODOs

* EngineCart / rake ci (complete)
* Write specs
* Remove .png bias
* Forgo attaching Placeholder imagery
* Maybe AASM?
* Rails 5.2 branch / ActionStorage
