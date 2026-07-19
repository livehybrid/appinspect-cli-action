# Container image that runs your code
# Bumped from python:3.7.10 -> python:3.12 so the well-formed Python check
# parses modern vendored libs (typing_extensions, opentelemetry, packaging)
# with a current interpreter. Under 3.7 these raise SyntaxError.
FROM python:3.12

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
