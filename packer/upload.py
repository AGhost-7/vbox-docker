#!/usr/bin/env python3

from os import environ
import requests
from datetime import datetime

BASE_URL = 'https://api.github.com/repos/AGhost-7/vbox-docker'


def fetch_build_number():
    request = requests.get(BASE_URL + '/releases/latest')
    body = request.json()
    tag_name = body['tag_name']
    return tag_name.split('+')[1]


def create_release(build_number):
    version = 'v{:%d.%m.%y}+{}'.format(datetime.now(), build_number)
    payload = {
        'tag_name': version,
        'name': 'Release {}'.format(version)
    }

    request = requests.post(BASE_URL + '/releases', data=payload)
    assert request.status_code < 300
    return request.json()


def upload_artifacts(release):
    pass


build_number = fetch_build_number()
release = create_release(build_number)
upload_artifacts(release)
