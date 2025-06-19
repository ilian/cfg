# Copyright (c) 2021 ilian
# Copyright (c) 2019 Jimmy Zelinskie
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

import re
import sys
import requests

from contextlib import closing
from urllib.request import urlopen

domain_blacklist = [
    "",
    "localhost",
    "127.0.0.1",
    "0.0.0.0",
    "255.225.225.255",
    "::1",
]


ipv4_address = re.compile('^(?:(?:[0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}(?:[0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$')
ipv6_address = re.compile('^(?:(?:[0-9A-Fa-f]{1,4}:){6}(?:[0-9A-Fa-f]{1,4}:[0-9A-Fa-f]{1,4}|(?:(?:[0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}(?:[0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5]))|::(?:[0-9A-Fa-f]{1,4}:){5}(?:[0-9A-Fa-f]{1,4}:[0-9A-Fa-f]{1,4}|(?:(?:[0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}(?:[0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5]))|(?:[0-9A-Fa-f]{1,4})?::(?:[0-9A-Fa-f]{1,4}:){4}(?:[0-9A-Fa-f]{1,4}:[0-9A-Fa-f]{1,4}|(?:(?:[0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}(?:[0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5]))|(?:[0-9A-Fa-f]{1,4}:[0-9A-Fa-f]{1,4})?::(?:[0-9A-Fa-f]{1,4}:){3}(?:[0-9A-Fa-f]{1,4}:[0-9A-Fa-f]{1,4}|(?:(?:[0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}(?:[0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5]))|(?:(?:[0-9A-Fa-f]{1,4}:){,2}[0-9A-Fa-f]{1,4})?::(?:[0-9A-Fa-f]{1,4}:){2}(?:[0-9A-Fa-f]{1,4}:[0-9A-Fa-f]{1,4}|(?:(?:[0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}(?:[0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5]))|(?:(?:[0-9A-Fa-f]{1,4}:){,3}[0-9A-Fa-f]{1,4})?::[0-9A-Fa-f]{1,4}:(?:[0-9A-Fa-f]{1,4}:[0-9A-Fa-f]{1,4}|(?:(?:[0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}(?:[0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5]))|(?:(?:[0-9A-Fa-f]{1,4}:){,4}[0-9A-Fa-f]{1,4})?::(?:[0-9A-Fa-f]{1,4}:[0-9A-Fa-f]{1,4}|(?:(?:[0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}(?:[0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5]))|(?:(?:[0-9A-Fa-f]{1,4}:){,5}[0-9A-Fa-f]{1,4})?::[0-9A-Fa-f]{1,4}|(?:(?:[0-9A-Fa-f]{1,4}:){,6}[0-9A-Fa-f]{1,4})?::)$')

IP_REGEX = "(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])"
HOST_REGEX = "(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])"
HOSTSFILE_PREFIX = IP_REGEX + "|" + HOST_REGEX
HOSTSFILE_PREFIX_REGEX = re.compile(HOSTSFILE_PREFIX + "(\s+)")

def get_blocklists():
    host_files = []
    domain_files = []
    r = requests.get("https://v.firebog.net/hosts/lists.php?type=tick")
    for list in r.iter_lines(decode_unicode = True):
        try:
            l = requests.get(list)
            for line in l.iter_lines(decode_unicode = True):
                if not line:
                    continue
                if line[0] == "#":
                    continue
                word = line.split(" ")[0]
                if ipv4_address.match(word) or ipv6_address.match(word):
                    host_files.append(list)
                else:
                    domain_files.append(list)
                break
        except Exception as e:
            print("Failed to get blocklist " + list + " " + str(e), file=sys.stderr)
    return host_files, domain_files

def strip_comment(line):
    return line.split("#")[0].strip()


def domains_from_domain_list(fstream):
    for linebytes in fstream:
        line = linebytes.decode("utf-8").strip()
        if line.startswith("#"):
            continue

        domain = strip_comment(line)
        if domain not in domain_blacklist:
            yield domain


def domains_from_hostfile(fstream):
    for linebytes in fstream:
        line = linebytes.decode("utf-8").strip()
        prefix = HOSTSFILE_PREFIX_REGEX.match(line)
        if prefix is None:
            continue

        domain = strip_comment(line[prefix.end():])
        if domain in domain_blacklist:
            continue

        yield domain


def main():
    host_files, domain_files = get_blocklists()
    domains = set()
    for url in host_files:
        try:
            with closing(urlopen(url)) as f:
                domains = domains.union(set([domain for domain in domains_from_hostfile(f)]))
        except Exception as e:
            print(f"Failed to import host file {url}: {e}", file=sys.stderr)


    for url in domain_files:
        try:
            with closing(urlopen(url)) as f:
                domains = domains.union(set([domain for domain in domains_from_domain_list(f)]))
        except Exception as e:
            print(f"Failed to import domain file {url}: {e}", file=sys.stderr)

    for domain in sorted(domains):
        print(domain + "\tCNAME\t.")
        print("*." + domain + "\tCNAME\t.")


if __name__ == '__main__':
    main()
