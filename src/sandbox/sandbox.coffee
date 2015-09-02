window.onload = () ->

    regions = document.querySelectorAll('.edit-me')
    for region in regions
        new ContentEdit.Region(region)