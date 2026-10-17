# Container image that runs your code
FROM python:3.13

# splunk-appinspect -> python-magic needs the libmagic system library and its
# compiled magic database. The full python image lineage historically shipped
# it, but pin it explicitly so the build never depends on that.
RUN apt-get update \
    && apt-get install -y --no-install-recommends libmagic1 \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt /
RUN pip install --no-cache-dir --prefer-binary -r /requirements.txt

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY entrypoint.sh /
COPY reporter.py /
COPY compare_checks.py /
COPY export_to_markdown.py /

# Code file to execute when the docker container starts up (`entrypoint.sh`)
WORKDIR /github/workspace
ENTRYPOINT ["bash", "/entrypoint.sh"]
