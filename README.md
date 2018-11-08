# GeoBlacklight Sidecar Images

[![Build Status](https://travis-ci.org/ewlarson/geoblacklight_sidecar_images.svg?branch=master)](https://travis-ci.org/ewlarson/geoblacklight_sidecar_images)
[![Maintainability](https://api.codeclimate.com/v1/badges/88c14165af5459963011/maintainability)](https://codeclimate.com/github/ewlarson/geoblacklight_sidecar_images/maintainability)
[![Coverage Status](https://coveralls.io/repos/github/ewlarson/geoblacklight_sidecar_images/badge.svg?branch=master)](https://coveralls.io/github/ewlarson/geoblacklight_sidecar_images?branch=master)
[![Gem Version](https://badge.fury.io/rb/geoblacklight_sidecar_images.svg)](https://badge.fury.io/rb/geoblacklight_sidecar_images)

Store local copies of remote imagery in GeoBlacklight.

## Description
This GeoBlacklight plugin captures remote images from geographic web services and saves them locally. It borrows the concept of a [SolrDocumentSidecar](https://github.com/projectblacklight/spotlight/blob/master/app/models/spotlight/solr_document_sidecar.rb) from [Spotlight](https://github.com/projectblacklight/spotlight), to have an ActiveRecord-based "sidecar" to match each non-AR SolrDocument. This allows us to use [ActiveStorage](https://github.com/rails/rails/tree/master/activestorage) to attach images to our solr documents.

### Example Screenshot
![Screenshot](screenshot.png)

## Requirements

* [Ruby on Rails 5.2](https://weblog.rubyonrails.org/releases/)
* [GeoBlacklight](https://github.com/geoblacklight/geoblacklight)
* [ImageMagick](https://github.com/ImageMagick/ImageMagick)

## Suggested

* Background Job Processor

[Sidekiq](https://github.com/mperham/sidekiq) is an excellent choice if you need an opinion.

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
  # Run your GBL instance
  rake geoblacklight:server
```

```bash
rake gblsci:sample_data:ingest['<FULL_LOCAL_PATH_TO>/geoblacklight_sidecar_images/spec/fixtures/files']
```

## Rake tasks

### Harvest images

#### Harvest all images

Spawns background jobs to harvest images for all documents in your Solr index.

```bash
rake gblsci:images:harvest_all
```

#### Harvest an individual image

Allows you to add images one document id at a time.

```bash
rake gblsci:images:harvest_doc_id['stanford-cz128vq0535']
```

#### Harvest all incomplete states

Reattempt image harvesting for all non-successful state objects.

```bash
rake gblsci:images:harvest_retry
```

### Check image states

```bash
rake gblsci:images:harvest_states
```

We use a state machine library to track success/failure of our harvest tasks. The states we track are:

* initialized - SolrDocumentSidecar created, no harvest attempt run
* queued - Harvest attempt queued as background job
* processing - Harvest attempt at work
* succeeded - Harvest was successful, image attached
* failed - Harvest failed, no image attached, error logged
* placeheld - Harvest was not successful, placeholder imagery will be used

```ruby
SolrDocumentSidecar.image.attached? => false
SolrDocumentSidecar.image_state.current_state => "placeheld"
SolrDocumentSidecar.image_state.last_transition => #<SidecarImageTransition id: 207, to_state: "placeheld", metadata: {"solr_doc_id"=>"stanford-cg357zz0321", "solr_version"=>1616509329754554368, "placeheld"=>true, "viewer_protocol"=>"wms", "image_url"=>"http://geowebservices-restricted.stanford.edu/geoserver/wms/reflect?&FORMAT=image%2Fpng&TRANSPARENT=TRUE&LAYERS=druid:cg357zz0321&WIDTH=300&HEIGHT=300", "service_url"=>"http://geowebservices-restricted.stanford.edu/geoserver/wms/reflect?&FORMAT=image%2Fpng&TRANSPARENT=TRUE&LAYERS=druid:cg357zz0321&WIDTH=300&HEIGHT=300", "gblsi_thumbnail_uri"=>false, "error"=>"Faraday::Error::ConnectionFailed"},...>
```

### Destroy images

#### Remove everything

Remove all sidecar objects and attached images

```bash
rake gblsci:images:harvest_purge_all
```

#### Remove orphaned AR objects

Remove all sidecar objects and attached images for AR objects without a corresponding Solr document

```bash
rake gblsci:images:harvest_purge_orphans
```

#### Remove a batch

Remove sidecar objects and attached images via a CSV file of document ids

```bash
rake gblsci:images:harvest_purge_orphans
```

### Troubleshooting

#### Harvest report

Generate a CSV file of sidecar objects and associated image state. Useful for debugging problem items.

```bash
rake gblsci:images:harvest_report
```

#### Failed state inspect

Prints details for failed state harvest objects to stdout

```bash
rake gblsci:images:harvest_failed_state_inspect
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

## View customization

This GBL plugin includes a custom catalog/_index_split_default.html.erb file. Look there for examples on calling the image method.

```ruby
# Is there an image?
document.sidecar.image.attached?

# Can the image size be manipulated?
document.sidecar.image.variable?

# Example image_tag with resize
<%= image_tag document.sidecar.image.variant(resize: "100x100"), {class: 'media-object'} %>

```

You'll definitely want to update this file to fit your own design's needs.

## Development

```bash

# Run test suite
bundle exec rake ci

# Launch test app server
cd .internal_test_app/
rake geoblacklight:server

# Load test fixtures
bundle exec rake gblsci:sample_data:ingest['<FULL_LOCAL_PATH_TO>/geoblacklight_sidecar_images/spec/fixtures/files']

# Run harvest
bundle exec rake gblsci:images:harvest_all

# Tail log
tail -f log/image_service_development.log

```

[See Results](http://localhost:3000/?per_page=50&q=&search_field=all_fields)

## TODOs

* ~~0.0.1 - Initial gem~~
* ~~0.1.0 - Prioritize local thumbnail solr field~~
* ~~0.2.0 - Forgo attaching placeholder imagery~~
* ~~0.3.0 - Add Statesman (state machine library)~~
* ~~0.4.0 - Rails 5.2 branch / Switch to ActionStorage~~
* 0.5.0 to 0.9.0 - Feedback; Improve test coverage; Collect additional real-world issues
* 1.0.0 - Final 5.2 release
