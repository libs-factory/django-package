TERMINATOR = "\x1b[0m"
WARNING = "\x1b[1;33m [WARNING]: "
INFO = "\x1b[1;33m [INFO]: "
HINT = "\x1b[3;33m"
SUCCESS = "\x1b[1;32m [SUCCESS]: "

# The content of this string is evaluated by Jinja, and plays an important role.
# It updates the cookiecutter context to trim leading and trailing spaces
# from email values
"""
{{ cookiecutter.update({ "email": cookiecutter.email | trim }) }}
"""

# Check for Project Slug
project_slug = "{{ cookiecutter.project_slug }}"
assert project_slug == project_slug.lower(), "'{}' project slug should be all lowercase".format(project_slug)

# Check for App Slug
app_slug = "{{ cookiecutter.app_slug }}"
if hasattr(app_slug, "isidentifier"):
    assert app_slug.isidentifier(), "'{}' app slug is not a valid Python identifier.".format(app_slug)
assert app_slug == app_slug.lower(), "'{}' app slug should be all lowercase".format(app_slug)

# Check for Author Name
assert "\\" not in "{{ cookiecutter.author_name }}", "Don't include backslashes in author name."
