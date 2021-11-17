# Copyright 2019 Autodesk, Inc.  All rights reserved.
#
# Use of this software is subject to the terms of the Autodesk license agreement
# provided at the time of installation or download, or which otherwise accompanies
# this software in either electronic or hard copy form.
#

import logging
import boto3
import os
import sys
import mimetypes
import subprocess
import yaml
import shutil

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
    logs output and raises on failure

    :param str cmd: Command to execute
    :returns: The output generated
    :raises: SubprocessError on failure
    """
    log.info("Executing command '{}'".format(cmd))
    p = subprocess.Popen(cmd, shell=True)
    stdout, stderr = p.communicate()
    output = "{}\n{}".format(stdout, stderr)
    log.info(output)
    return output


def generate_pull_request_comment(doc_url):
    """
    Generates a comment pointing at a web url in the current PR

    :param doc_url: url to link to
    """
    if "TK_GITHUB_TOKEN" not in os.environ:
        log.error("Cannot add comment to pull request with link "
                  "to docs - no TK_GITHUB_TOKEN env var defined.")
    else:
        log.info("Adding PR comment with link to generated documentation...")
        cmd = "curl -H 'Authorization: token {token}' -X POST ".format(
            token=os.environ["TK_GITHUB_TOKEN"]
        )
        cmd += "-d '{\"body\": \"[Documentation Preview](%s)\"}' " % (
            doc_url,
        )
        cmd += "'https://api.github.com/repos/{repo_slug}/issues/{pull_request}/comments'".format(  # noqa
            repo_slug=os.environ["GITHUB_REPOSITORY"],
            pull_request=os.environ["PR_NUMBER"]
        )
        execute_external_command(cmd)


def parse_jekyll_configs(config_paths):
    """
    Parse jekyll config files in order of precedence from low to high, producing
    a config dictionary containing all found key/values.

    :param list config_paths: The list of jekyll config paths to check / parse
    :returns: The resulting jekyll config dictionary.
    """
    output_config = {}
    for config_path in config_paths:
        if os.path.exists(config_path):
            with open(config_path, 'r') as config_file:
                config = yaml.safe_load(config_file)
                output_config.update(config)
    return output_config


def copy_image_tree(source_dir, target_dir, overwrite=False):
    """
    Copy an image tree from an i18n source to the language target.

    :param str source_dir: The source for translated images
    :param str target_dir: The directory to copy the images to
    :param bool overwrite: Whether existing images in the target directory
        should be overwritten.
    """
    log.debug("Copying image tree from {} to {}...".format(source_dir, target_dir))
    log.debug("(existing files will {}be overwritten.)".format("" if overwrite else "not "))
    for current_path, dirnames, filenames in os.walk(source_dir):
        relative_dir = os.path.relpath(current_path, source_dir)
        target = os.path.join(target_dir, relative_dir)
        # ensure the target dir exists
        if not os.path.exists(target):
            os.makedirs(target)
        for fn in filenames:
            source_img = os.path.join(current_path, fn)
            destination_img = os.path.join(target, fn)
            if os.path.exists(destination_img):
                if not overwrite:
                    continue
                if os.path.samefile(source_img, destination_img):
                    continue
                log.debug("{} already exists, removing and overwriting...".format(destination_img))
                os.remove(destination_img)
            log.debug("Copying {} to {}...".format(source_img, destination_img))
            shutil.copy(source_img, destination_img)


def cleanup_image_i18n(config_paths, build_dir):
    """
    Iterates overr i18n targets found in the jekyll config, and cleans up
    duplicate / miscopied images from build.  If no i18n image is found, the
    default language image is copied in its place.

    :param str config_path: The path to the jekyll config to read i18n targets
        and default language from.
    :param str build_dir: The directory that the jekyll site was built to.
    """
    # determine list of i18n targets
    config = parse_jekyll_configs(config_paths)
    try:
        languages = config['languages']
        default_lang = config['default_lang']
    except KeyError:
        log.error("Could not find `languages` / `default_lang` key in jekyll config.")
        raise
    target_languages = [l for l in languages if l is not default_lang]

    # iterate over i81n target languages
    for lang in target_languages:
        lang_base = os.path.join(build_dir, lang)
        img_src = os.path.join(lang_base, lang)
        default_image_src = os.path.join(lang_base, default_lang)

        # If the source directory for this target is missing here, log a warning.
        if not os.path.exists(img_src):
            log.warning("No image source dir found for {}, skipping...".format(lang))
        else:
            # Iterate over the images in the source directory, and copy them over
            # any images in the path that they should exist in.
            copy_image_tree(img_src, lang_base, overwrite=True)

            # Now do the same, but with the default language, and only copy missing
            # images.
            if not os.path.exists(default_image_src):
                log.warning("No default image source dir found for {}, skipping...".format(lang))
            else:
                copy_image_tree(default_image_src, lang_base, overwrite=False)

        # remove the duplicated source image directories
        for img_dir_lang in languages:
            images_dir = os.path.join(lang_base, img_dir_lang)
            if os.path.exists(images_dir):
                # Remove duplicate image subdirectories
                # ignore errors since leaving files here is not harmful.
                shutil.rmtree(images_dir, ignore_errors=True)


def main():
    """
    Execute CI operations
    """
    # expected file and build locations
    this_folder = os.path.abspath(os.path.dirname(__file__))

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
    config_paths = [
        os.path.join(root_path, "jekyll_config.yml"),
        os.path.join(root_path, "jekyll", "_config.yml"),
        os.path.join(this_folder, "jekyll", "_config.yml"),
    ]

    # first figure out if we are in a PR.
    if os.environ.get("GITHUB_EVENT_NAME") == "pull_request":
        # we are in a PR.
        log.info("Inside a pull request.")

        # see if we have access to an AWS bucket
        if "S3_BUCKET" in os.environ and "S3_WEB_URL" in os.environ:
            log.info("Detected AWS S3 bucket for preview workflow.")

            s3_bucket = os.environ["S3_BUCKET"]
            target_url = os.environ["S3_WEB_URL"]
            target_url_path = "/tk-doc-generator/{commit}".format(
                commit=os.environ["GITHUB_SHA"]
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

        # cleanup image i18n
        cleanup_image_i18n(config_paths, output_path)

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

            # Add a comment to the PR to link to the generated docs
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

    log.info("CI documentation job starting up.")

    exit_code = 1
    try:
        main()
        exit_code = 0
    except Exception:
        log.exception("An exception was raised!")

    log.info("Exiting with code {}.".format(exit_code))
    sys.exit(exit_code)