# ContentEdit

[![Build Status](https://travis-ci.org/GetmeUK/ContentEdit.svg?branch=master)](https://travis-ci.org/GetmeUK/ContentEdit)

> A JavaScript library that provides a set of classes for building content-editable HTML elements.

## Install

**Using bower**

```
bower install --save ContentEdit
```

**Using npm**

```
npm install --save ContentEdit
```

## Building
To build the library you'll need to use Grunt. First install the required node modules ([grunt-cli](http://gruntjs.com/getting-started) must be installed):
```
git clone https://github.com/GetmeUK/ContentEdit.git
cd ContentEdit
npm install
```

Install Sass (if not already installed):
```
gem install sass
```

Then run `grunt build` to build the project.

## Testing
To test the library you'll need to use Jasmine. First install Jasmine:
```
git clone https://github.com/pivotal/jasmine.git
mkdir ContentEdit/jasmine
mv jasmine/dist/jasmine-standalone-2.0.3.zip ContentEdit/jasmine
cd ContentEdit/jasmine
unzip jasmine-standalone-2.0.3.zip
```

Then open `ContentEdit/SpecRunner.html` in a browser to run the tests.

Alternatively you can use `grunt jasmine` to run the tests from the command line.

## Documentation
Full documentation is available at http://getcontenttools.com/api/content-edit

## Browser support

- Chrome
- Firefox
- IE9+
