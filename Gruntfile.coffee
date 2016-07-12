module.exports = (grunt) ->

    # Project configuration
    grunt.initConfig({

        pkg: grunt.file.readJSON('package.json')

        coffee:
            options:
                join: true

            build:
                files:
                    'src/tmp/content-edit.js': [
                        'src/scripts/namespace.coffee'
                        'src/scripts/tag-names.coffee'
                        'src/scripts/bases.coffee'
                        'src/scripts/regions.coffee'
                        'src/scripts/fixtures.coffee'
                        'src/scripts/root.coffee'
                        'src/scripts/static.coffee'
                        'src/scripts/text.coffee'
                        'src/scripts/images.coffee'
                        'src/scripts/videos.coffee'
                        'src/scripts/lists.coffee'
                        'src/scripts/tables.coffee'
                    ]

            sandbox:
                files:
                    'sandbox/sandbox.js': 'src/sandbox/sandbox.coffee'

            spec:
                files:
                    'spec/spec-helper.js': 'src/spec/spec-helper.coffee'
                    'spec/content-edit-spec.js': [
                        'src/spec/namespace.coffee'
                        'src/spec/bases.coffee'
                        'src/spec/tag-names.coffee'
                        'src/spec/bases.coffee'
                        'src/spec/regions.coffee'
                        'src/spec/fixtures.coffee'
                        'src/spec/root.coffee'
                        'src/spec/static.coffee'
                        'src/spec/text.coffee'
                        'src/spec/images.coffee'
                        'src/spec/videos.coffee'
                        'src/spec/lists.coffee'
                        'src/spec/tables.coffee'
                        ]

        sass:
            options:
                banner: '/*! <%= pkg.name %> v<%= pkg.version %> by <%= pkg.author.name %> <<%= pkg.author.email %>> (<%= pkg.author.url %>) */'
                sourcemap: 'none'
                style: 'compressed'

            build:
                files:
                    'build/content-edit.min.css': 'src/styles/content-edit.scss'

            sandbox:
                files:
                    'sandbox/sandbox.css': 'src/sandbox/sandbox.scss'

        uglify:
            options:
                banner: '/*! <%= pkg.name %> v<%= pkg.version %> by <%= pkg.author.name %> <<%= pkg.author.email %>> (<%= pkg.author.url %>) */\n'
                mangle: true

            build:
                src: 'build/content-edit.js'
                dest: 'build/content-edit.min.js'

        concat:
            build:
                src: [
                    'external/html-string.js'
                    'external/content-select.js'
                    'src/tmp/content-edit.js'
                ]
                dest: 'build/content-edit.js'

        clean:
            build: ['src/tmp']

        jasmine:
            build:
                src: ['build/content-edit.js']
                options:
                    specs: 'spec/content-edit-spec.js'
                    helpers: 'spec/spec-helper.js'

        watch:
            build:
                files: ['src/scripts/*.coffee', 'src/styles/*.scss']
                tasks: ['build']

            sandbox:
                files: [
                    'src/sandbox/*.coffee',
                    'src/sandbox/*.scss'
                    ]
                tasks: ['sandbox']

            spec:
                files: ['src/spec/*.coffee']
                tasks: ['spec']
    })

    # Plug-ins
    grunt.loadNpmTasks 'grunt-contrib-clean'
    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-contrib-concat'
    grunt.loadNpmTasks 'grunt-contrib-jasmine'
    grunt.loadNpmTasks 'grunt-contrib-sass'
    grunt.loadNpmTasks 'grunt-contrib-uglify'
    grunt.loadNpmTasks 'grunt-contrib-watch'

    # Tasks
    grunt.registerTask 'build', [
        'coffee:build'
        'sass:build'
        'concat:build'
        'uglify:build'
        'clean:build'
    ]

    grunt.registerTask 'sandbox', [
        'coffee:sandbox'
        'sass:sandbox'
    ]

    grunt.registerTask 'spec', [
        'coffee:spec'
    ]

    grunt.registerTask 'watch-build', ['watch:build']
    grunt.registerTask 'watch-sandbox', ['watch:sandbox']
    grunt.registerTask 'watch-spec', ['watch:spec']