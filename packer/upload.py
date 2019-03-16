#!/usr/bin/env python3

import requests
from datetime import datetime

BASE_URL = 'https://api.github.com/repos/AGhost-7/vbox-docker'


def fetch_build_number():
    request = requests.get(BASE_URL + '/releases/latest')
    body = request.json()
    tag_name = body['tag_name']
    return int(tag_name.split('+')[1]) + 1


def create_release(build_number):
    version = 'v{:%y.%m.%d}+{}'.format(datetime.now(), build_number)
    payload = {
        'tag_name': version,
        'name': 'Release {}'.format(version)
    }

    request = requests.post(BASE_URL + '/releases', data=payload)
    assert request.status_code < 300
    return request.json()


def upload_artifacts(release):
    upload_url = release['upload_url'].split('{')[0]
    print('upload url: {}', upload_url)
    pass


build_number = fetch_build_number()
print('New build number is {}'.format(build_number))
release = create_release(build_number)
print('Created release {}', release['tag_name'])
print('Uploading artifacts...')
upload_artifacts(release)
