window.onload = () ->

    regions = document.querySelectorAll('.edit-me')
    for region in regions
        new ContentEdit.Region(region)

    fixtures = document.querySelectorAll('.fixture')
    for fixture in fixtures
        new ContentEdit.Fixture(fixture)