# Configuration file for the Sphinx documentation builder.
import os
import sys
sys.path.insert(0, os.path.abspath('../..'))

# -- Project information

project = 'EpigeneNemaPipe'
copyright = '2025, Joseph Kirangwa'
author = 'Joseph Kirangwa'

release = '0.1'
version = '0.1.0'

# -- General configuration

extensions = [
    'myst_parser',
    'sphinx.ext.duration',
    'sphinx.ext.doctest',
    'sphinx.ext.autodoc',
    'sphinx.ext.autosummary',
    'sphinx.ext.intersphinx',
]


source_suffix = {
    '.rst': 'restructuredtext',
    '.md': 'markdown',
}

intersphinx_mapping = {
    'python': ('https://docs.python.org/3/', None),
    'sphinx': ('https://www.sphinx-doc.org/en/master/', None),
}
intersphinx_disabled_domains = ['std']

templates_path = ['_templates']

# -- Options for HTML output

html_theme = 'sphinx_rtd_theme'

# -- Options for EPUB output
epub_show_urls = 'footnote'

master_doc = "index"

html_context = {
    "display_github": True,             # Enable the link
    "github_user": "jkirangw",  # replace with your GitHub username
    "github_repo": "EpigeneNemaPipe",     # your repository name
    "github_version": "main",             # or the branch you use (e.g., master)
    "conf_py_path": "/docs/source/",      # path to your docs folder in the repo
}
