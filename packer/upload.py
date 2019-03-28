#!/usr/bin/env python3

import requests
from os import environ, listdir, path

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
    headers = {'authorization': 'Bearer ' + environ['GH_TOKEN']}
    response = requests.post(
        BASE_URL + '/releases', json=payload, headers=headers)
    assert response.status_code < 300
    return response.json()


def find_minimal():
    for file_name in listdir('./output/minimal'):
        _, extension = path.splitext(file_name)
        print('extension: {}'.format(extension))
        if extension == '.vmdk':
            return open(path.join('./output/minimal', file_name), 'rb')

    raise Exception('Could not find minimal vm image to upload')


def upload_artifacts(release):
    upload_url = release['upload_url'].split('{')[0]
    headers = {
        'authorization': 'Bearer ' + environ['GH_TOKEN'],
        'content-type': 'application/octet-stream'
    }
    response = requests.post(
        upload_url + '?name=vbox-docker.vmdk',
        data=find_minimal(),
        headers=headers)
    assert response.status_code < 300
    print('upload url: {}', upload_url)
    pass


build_number = fetch_build_number()
print('New build number is {}'.format(build_number))
release = create_release(build_number)
print('Created release {}', release['tag_name'])
print('Uploading artifacts...')
upload_artifacts(release)
