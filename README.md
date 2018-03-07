# GeoBlacklight Sidecar Images

[![Build Status](https://travis-ci.org/ewlarson/geoblacklight_sidecar_images.svg?branch=master)](https://travis-ci.org/ewlarson/geoblacklight_sidecar_images)
[![Maintainability](https://api.codeclimate.com/v1/badges/88c14165af5459963011/maintainability)](https://codeclimate.com/github/ewlarson/geoblacklight_sidecar_images/maintainability)
[![Coverage Status](https://coveralls.io/repos/github/ewlarson/geoblacklight_sidecar_images/badge.svg?branch=master)](https://coveralls.io/github/ewlarson/geoblacklight_sidecar_images?branch=master)

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

bundle exec rake ci
cd .internal_test_app/
rake geoblacklight:server

### Ingest Test Documents
rake geoblacklight_sidecar_images:sample_data:ingest['<FULL_PATH_TO>/geoblacklight_sidecar_images/spec/fixtures/files']

### Cache images

#### All Thumbnails
rake geoblacklight_sidecar_images:images:precache_all

#### Individual Thumbnail
rake geoblacklight_sidecar_images:images:precache_id['minnesota-iiif-jpg-83f4648a-125c-4000-a12f-aba2b432e7cd']

## TODOs

* 0.0.1 - Initial gem
* 0.1.0 - Forgo attaching placeholder imagery
* 0.2.0 - Prioritize local thumbnail solr field
* 0.3.0 - Add Statesman (state machine library)
* Future - Rails 5.2 branch / ActionStorage
