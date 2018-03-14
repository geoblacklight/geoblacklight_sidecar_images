# GeoBlacklight Sidecar Images

[![Build Status](https://travis-ci.org/ewlarson/geoblacklight_sidecar_images.svg?branch=master)](https://travis-ci.org/ewlarson/geoblacklight_sidecar_images)
[![Maintainability](https://api.codeclimate.com/v1/badges/88c14165af5459963011/maintainability)](https://codeclimate.com/github/ewlarson/geoblacklight_sidecar_images/maintainability)
[![Coverage Status](https://coveralls.io/repos/github/ewlarson/geoblacklight_sidecar_images/badge.svg?branch=master)](https://coveralls.io/github/ewlarson/geoblacklight_sidecar_images?branch=master)
[![Gem Version](https://badge.fury.io/rb/geoblacklight_sidecar_images.svg)](https://badge.fury.io/rb/geoblacklight_sidecar_images)

Store local copies of remote imagery in GeoBlacklight.

## Description
This GeoBlacklight plugin helps capture remote images from geo web services and save them locally. It borrows the concept of a [SolrDocumentSidecar](https://github.com/projectblacklight/spotlight/blob/master/app/models/spotlight/solr_document_sidecar.rb) from [Spotlight](https://github.com/projectblacklight/spotlight), to have an ActiveRecord-based "sidecar" to match each non-AR SolrDocument. This allows us to use [carrierwave](https://github.com/carrierwaveuploader/carrierwave) to attach images to our documents.

![Screenshot](https://raw.githubusercontent.com/ewlarson/geoblacklight_sidecar_images/master/screenshot.png)

## Requirements

* [GeoBlacklight](https://github.com/geoblacklight/geoblacklight)
* [ImageMagick](https://github.com/ImageMagick/ImageMagick)

## Installation

### Existing GeoBlacklight Instance

Add the gem to your Gemfile.

```ruby
gem 'geoblacklight_sidecar_images'
```

Run the generator.

```bash
$ bin/rails generate geoblacklight_sidecar_images:install
```

Run the database migration.

```bash
$ bin/rails db:migrate
```

### New GeoBlacklight Instance

Create a new GeoBlacklight instance with the GBLSI code

```bash
$ rails new app-name -m https://raw.githubusercontent.com/ewlarson/geoblacklight_sidecar_images/master/template.rb

```

### Ingest Test Documents

```bash
rake geoblacklight_sidecar_images:sample_data:ingest['<FULL_PATH_TO>/geoblacklight_sidecar_images/spec/fixtures/files']
```

### Cache images

#### All Thumbnails

```bash
rake geoblacklight_sidecar_images:images:precache_all
```

#### Individual Thumbnail

```bash
rake geoblacklight_sidecar_images:images:precache_id['minnesota-iiif-jpg-83f4648a-125c-4000-a12f-aba2b432e7cd']
```

## Prioritize Solr Thumbnail Field URIs

If you add a thumbnail uri to your geoblacklight solr documents...

### Example Doc

```json
{
  ...
  "dc_format_s":"TIFF",
  "dc_creator_sm":["Minnesota. Department of Highways."],
  "thumbnail_path_ss":"https://umedia.lib.umn.edu/sites/default/files/imagecache/square300/reference/562/image/jpeg/1089695.jpg",
  "dc_type_s":"Still image",
  ...
}
```

Then you can edit your GeoBlacklight settings.yml file to point at that solr field (Settings.GBLSI_THUMBNAIL_FIELD). Any docs in your index that have a value for that field will harvest the image at that URI instead of trying to retrieve an image via IIIF or the other web services.

## Development

```bash
bundle exec rake ci
cd .internal_test_app/
rake geoblacklight:server
```

Now you'll have an instance of GBLSI running. Follow the rake tasks above to ingest some data and harvest thumbnails.

## TODOs

* 0.0.1 - Initial gem
* 0.1.0 - Prioritize local thumbnail solr field
* 0.2.0 - Forgo attaching placeholder imagery
* 0.3.0 - Add Statesman (state machine library)
* Future - Rails 5.2 branch / ActionStorage
