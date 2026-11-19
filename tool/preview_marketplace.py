#!/usr/bin/env python3
"""Serve the compiled Flutter web preview and the real Django API on one localhost origin."""
import argparse
import os
import sys
import types
from pathlib import Path


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('backend', type=Path, help='Path to the patched urFunFarming Django checkout')
    parser.add_argument('--port', type=int, default=8000)
    parser.add_argument('--web-dir', type=Path, help='Optional prebuilt Flutter web directory')
    args = parser.parse_args()
    backend = args.backend.expanduser().resolve()
    build = (args.web_dir or (Path(__file__).resolve().parents[1] / 'build' / 'web')).expanduser().resolve()
    if not (backend / 'marketplace' / 'api_urls.py').is_file():
        parser.error('Point to a Django checkout with the marketplace API patch applied.')
    if not (build / 'index.html').is_file():
        parser.error('First build the web preview with --base-href /app/ (see docs).')
    sys.path.insert(0, str(backend))
    os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'uff.settings')
    import django
    django.setup()
    from django.conf import settings
    from django.core.management import call_command
    from django.urls import path, re_path
    from django.views.static import serve
    from uff.urls import urlpatterns
    if not settings.DEBUG or settings.PRODUCTION or settings.DATABASES['default']['ENGINE'] != 'django.db.backends.sqlite3':
        parser.error('This preview only runs with local Django DEBUG and SQLite.')
    routes = types.ModuleType('marketplace_local_preview_urls')
    routes.urlpatterns = [
        path('app/', serve, {'document_root': str(build), 'path': 'index.html'}),
        re_path(r'^app/(?P<path>.+)$', serve, {'document_root': str(build)}),
        *urlpatterns,
    ]
    sys.modules[routes.__name__] = routes
    settings.ROOT_URLCONF = routes.__name__
    print(f'Harvest Marketplace: http://127.0.0.1:{args.port}/app/', flush=True)
    call_command('runserver', f'127.0.0.1:{args.port}', use_reloader=False)


if __name__ == '__main__':
    main()
