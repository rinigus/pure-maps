# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information

project = 'pure-maps'
copyright = '2025, pure-maps'
author = 'magdesign'

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

extensions = [
 #   'sphinx_toolbox.shields'
]



templates_path = ['_templates']
exclude_patterns = []



# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output
import sphinx_rtd_theme

html_theme = 'sphinx_rtd_theme'
html_logo = 'logo.svg'
html_theme_options = {
    'logo_only': False,
    'display_version': False,
}
html_static_path = ['_static']
