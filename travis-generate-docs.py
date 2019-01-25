# Copyright 2019 Autodesk, Inc.  All rights reserved.
#
# Use of this software is subject to the terms of the Autodesk license agreement
# provided at the time of installation or download, or which otherwise accompanies
# this software in either electronic or hard copy form.
#

#
# Travis CI script to
#
#

import logging
import boto3
import os
import sys
import mimetypes
import commands

# set up logging channel for this script
log = logging.getLogger(__name__)


def upload_folder_to_s3(s3_bucket, s3_client, src, dst):
    """
    Upload folder to S3, recursively.

    :param str s3_bucket: Bucket to upload to
    :param s3_client: boto3 s3 client object
    :param str src: Source path
    :param str dst: S3 destination path
    """
    names = os.listdir(src)
    for name in names:

        srcname = os.path.join(src, name)
        dstname = os.path.join(dst, name)

        if os.path.isdir(srcname):
            upload_folder_to_s3(s3_bucket, s3_client, srcname, dstname)
        else:
            log.info("S3 upload: '{}' -> '{}'".format(srcname, dstname))
            # auto detect mime type
            (mime_type, _) = mimetypes.guess_type(srcname)
            if mime_type is None:
                mime_type = "application/octet-stream"
            # upload
            with open(srcname, "rb") as file_handle:
                s3_client.put_object(
                    Bucket=s3_bucket,
                    ContentType=mime_type,
                    Key=dstname,
                    Body=file_handle
                )


def execute_external_command(cmd):
    """
    Executes the given command line,
    logs output checks return code.

    :param str cmd: Command to execute
    :returns: The output generated
    :raises: RuntimeError on failure
    """
    log.info("Executing command '{}'".format(cmd))
    (exit_code, output) = commands.getstatusoutput(cmd)
    log.info(output)
    log.info("Exit code: {}".format(exit_code))
    if exit_code != 0:
        raise RuntimeError("External process returned error.")
    return output


def generate_pull_request_comment(doc_url):
    """
    Generates a comment pointing at a web url in the current PR

    :param doc_url: url to link to
    """
    if "GITHUB_TOKEN" not in os.environ:
        log.error("Cannot add comment to pull request with link "
                  "to docs - no GITHUB_TOKEN env var defined.")
    else:
        log.info("Adding PR comment with link to generated documentation...")
        cmd = "curl -H 'Authorization: token {token}' -X POST ".format(
            token=os.environ["GITHUB_TOKEN"]
        )
        cmd += "-d '{\"body\": \"[Documentation Preview](%s)\"}' " % (
            doc_url,
        )
        cmd += "'https://api.github.com/repos/{repo_slug}/issues/{pull_request}/comments'".format(  # noqa
            repo_slug=os.environ["TRAVIS_REPO_SLUG"],
            pull_request=os.environ["TRAVIS_PULL_REQUEST"]
        )
        execute_external_command(cmd)


def main():
    """
    Execute CI operations
    """
    # expected file and build locations
    this_folder = os.path.dirname(__file__)

    # note - attempt to detect if we are running this for our own
    # ./docs folder or we are a submodule
    root_path = os.path.abspath(os.path.join(this_folder, ".."))

    if os.path.exists(os.path.join(root_path, ".gitmodules")):
        # a .gitmodules folder exists in the parent location
        # this means that we are running as a git submodule
        # inside another repo
        log.info("Running as a git submodule...")
    else:
        # Looks like we are not a submodule.
        root_path = os.path.abspath(this_folder)

    doc_script = os.path.join(this_folder, "scripts", "build_docs.sh")
    output_path = os.path.join(root_path, "_build")
    source_path = os.path.join(root_path, "docs")

    # grab state from CI
    current_branch = os.environ.get("TRAVIS_BRANCH")
    inside_pr = os.environ.get("TRAVIS_PULL_REQUEST") != "false"

    # first figure out i we are on master or in a PR.
    if current_branch != "master" or inside_pr:
        # we are in a PR.
        log.info("Inside a pull request.")

        # see if we have access to an AWS bucket
        if "S3_BUCKET" in os.environ and "S3_WEB_URL" in os.environ:
            log.info("Detected AWS S3 bucket for preview workflow.")

            s3_bucket = os.environ["S3_BUCKET"]
            target_url = os.environ["S3_WEB_URL"]
            target_url_path = "/tk-doc-generator/{commit}".format(
                commit=os.environ["TRAVIS_COMMIT"]
            )

        else:
            log.warning("No S3_BUCKET and S3_WEB_URL detected in environment. "
                        "No S3 preview will be generated")
            s3_bucket = None
            # enter dummy paths so we can at least build
            # the docs to check for errors
            target_url = "https://dummy.url.com"
            target_url_path = "/"

        target_full_url = "{url}{path}/index.html".format(url=target_url, path=target_url_path)

        # build the doc
        doc_command = "{script} --url={url} --url-path={path} --source={source} --output={output}".format( # noqa
            script=doc_script,
            url=target_url,
            path=target_url_path,
            source=source_path,
            output=output_path
        )
        execute_external_command(doc_command)

        if s3_bucket:
            log.info("Uploading build result to S3...")
            s3_client = boto3.client(
                "s3",
                aws_access_key_id=os.environ["AWS_S3_ACCESS_KEY"],
                aws_secret_access_key=os.environ["AWS_S3_ACCESS_TOKEN"]
            )

            # note: skip the first slash when uploading to S3
            #       in order to generate a correct path.
            upload_folder_to_s3(
                s3_bucket,
                s3_client,
                output_path,
                target_url_path[1:]
            )

            if os.environ.get("TRAVIS_PULL_REQUEST") != "false":
                # we are inside a 'PR build' rather than just a branch build
                # and we have a PR we can access
                generate_pull_request_comment(target_full_url)

    else:
        # inside master
        log.info("Inside master. Will build docs "
                 "to prepare for a deploy to gh-pages")

        if not("DOC_URL" in os.environ and "DOC_PATH" in os.environ):
            raise RuntimeError("Need to define DOC_URL and DOC_PATH")

        # build the doc
        doc_command = "{script} --url={url} --url-path={path} --source={source} --output={output}".format( # noqa
            script=doc_script,
            url=os.environ["DOC_URL"],
            path=os.environ["DOC_PATH"],
            source=source_path,
            output=output_path
        )
        execute_external_command(doc_command)


if __name__ == "__main__":
    log.setLevel(logging.INFO)
    ch = logging.StreamHandler()
    formatter = logging.Formatter("%(levelname)s %(message)s")
    ch.setFormatter(formatter)
    log.addHandler(ch)

    log.info("Travis CI documentation job starting up.")

    exit_code = 1
    try:
        main()
        exit_code = 0
    except Exception:
        log.exception("An exception was raised!")

    log.info("Exiting with code {}.".format(exit_code))
    sys.exit(exit_code)