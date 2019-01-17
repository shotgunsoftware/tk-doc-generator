# Copyright 2019 Autodesk, Inc.  All rights reserved.
#
# Use of this software is subject to the terms of the Autodesk license agreement
# provided at the time of installation or download, or which otherwise accompanies
# this software in either electronic or hard copy form.
#

import sys
import uuid
import logging
import shutil
import tempfile
import commands
from ruamel.yaml import YAML
import os

# set up logging channel for this script
log = logging.getLogger(__name__)


def add_to_pythonpath(path):
    """
    Prepends to PYTHONPATH and sys.path

    :param path: The path to add
    """
    pythonpath = os.environ.get("PYTHONPATH", "").split(":")
    path = os.path.expanduser(os.path.expandvars(path))
    pythonpath.insert(0, path)
    sys.path.insert(0, path)
    os.environ["PYTHONPATH"] = ":".join(pythonpath)


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


def sphinx_to_markdown(sphinx_config_path, input_folder, output_folder, custom_parents):
    """
    Executes a sphinx rst-to-markdown conversion process.

    The custom_parents paramesters holds information around
    how child-parenting should be expressed in the generated
    jekyll headers and is passed on to the custom sphinx
    jekyll/markdown plugin.

    :param str sphinx_config_path: Path to sphinx config file.
    :param str input_folder: Input to read sphinx rst from.
    :param str output_folder: Folder to write markdown to.
    :param custom_parents: dictionary with custom parent page data.
    """
    custom_parents = "&".join(["{}={}".format(page, parent) for (page, parent) in custom_parents.iteritems()])

    cmd = "sphinx-build -b markdown -c {config_path} -D md_parents=\"{cp}\" {input} {output}".format(
        config_path=sphinx_config_path,
        input=input_folder,
        output=output_folder,
        cp=custom_parents
    )
    execute_external_command(cmd)


def main(folder, sphinx_config_path):
    """
    Main payload of the script.

    The folder that is being processed will be transformed as part of the process.

    :param str folder: Folder to convert to markdown.
    :param str sphinx_config_path: Sphinx config file to use
    """

    # check for different documentation setups and key files
    if os.path.exists(os.path.join(input_folder, "index.rst")):

        # there is an index.rst - in this case we
        # are looking at a straight-forward sphinx repo, for example
        # a toolkit app.
        log.info("Detected sphinx setup...")

        # move the folder to be named _rst
        source_folder = "{}_rst".format(folder)
        shutil.move(folder, source_folder)
        # generate markdown documentation in the folder
        # where previously the rst document was, effectively
        # replace the content with md instead of rst
        sphinx_to_markdown(
            sphinx_config_path,
            source_folder,
            folder,
            custom_parents={}
        )

    elif os.path.exists(os.path.join(input_folder, "sphinx.yml")):
        # detected a sphinx.yml file - this file indicates that
        # we should include sphinx documentation from external sources.

        # read, parse the config and bring in and convert the necessary
        # content in the following way:
        #
        # - A single sphinx folder is created
        # - All external repos are cloned into a temp folder and their '/docs'
        #   folder is copied into the sphinx folders, but named with the name of
        #   the repo. We end up with a hierarchy of rst files from multiple
        #   repositories.
        # - An index.rst is generated in the sphinx folder to include all repos
        #   so that the doc generation can recurse properly.
        # - Sphinx is converted into jekyll/markdown for all repos in a single pass.
        #

        # Example file format:
        #
        # repositories:
        #   Publisher:
        #       git_url: https://github.com/shotgunsoftware/tk-multi-publish2.git
        #       parent: Toolkit App Reference
        #   Core API:
        #       git_url: https://github.com/shotgunsoftware/tk-core.git
        #       parent: /

        log.info("Detected sphinx.yml configuration file.")

        yaml_file = os.path.join(input_folder, "sphinx.yml")
        yaml = YAML(typ='safe')
        with open(yaml_file, "rt") as fh:
            yaml_data = yaml.load(fh)

        repo_data = yaml_data.get("repositories")

        temp_folder = os.path.join(tempfile.gettempdir(), uuid.uuid4().hex)
        sphinx_folder = os.path.join(input_folder, "sphinx")

        os.makedirs(temp_folder)
        os.makedirs(sphinx_folder)

        index_files = []

        # track which repos have a custom parent page
        custom_parents = {}

        # iterate over repos, clone and move docs into our sphinx folder
        for (name, params) in repo_data.iteritems():

            (repo_name, _) = os.path.splitext(os.path.basename(params["git_url"]))

            git_folder = os.path.join(temp_folder, repo_name)
            target_folder = os.path.join(sphinx_folder, repo_name)

            index_files.append("{}/index".format(repo_name))

            execute_external_command(
                "git clone --depth=1 {repo} {folder}".format(repo=params["git_url"], folder=git_folder)
            )

            # check out latest tag
            execute_external_command(
                "cd {}; git checkout $(git describe --tags $(git rev-list --tags --max-count=1))".format(git_folder)
            )

            # get latest tag
            # TODO: Handle injection of version numbers into sphinx structure.
            # output = execute_external_command("cd {}; git describe --tags".format(git_folder))

            # add python source to pythonpath
            # so that the sphinx build can auto-document methods etc.
            add_to_pythonpath(os.path.join(git_folder, "python"))

            # add hooks to pythonpath
            add_to_pythonpath(os.path.join(git_folder, "hooks"))

            # copy docs folder into target structure
            shutil.move(os.path.join(git_folder, "docs"), target_folder)

            # track custom parents
            if "parent" in params:
                custom_parents[repo_name] = params["parent"]

        # finally bind it all together:
        # construct an index.rst to link up all the repositories
        with open(os.path.join(sphinx_folder, "index.rst"), "wt") as fh:
            fh.write("Toolkit API Reference\n")
            fh.write("=====================\n\n")
            fh.write(".. toctree::\n")
            for index_file in index_files:
                fh.write("\t{}\n".format(index_file))

        # move the folder to be named .rst and replace with md build
        source_folder = "{}_rst".format(sphinx_folder)
        shutil.move(sphinx_folder, source_folder)

        # execute docgen
        sphinx_to_markdown(
            sphinx_config_path=sphinx_config_path,
            input_folder=source_folder,
            output_folder=sphinx_folder,
            custom_parents=custom_parents)


if __name__ == "__main__":
    log.setLevel(logging.INFO)
    ch = logging.StreamHandler()
    formatter = logging.Formatter("%(levelname)s %(message)s")
    ch.setFormatter(formatter)
    log.addHandler(ch)

    exit_code = 1
    try:
        input_folder = os.path.abspath(sys.argv[1])
        log.info("Sphinx doc generation")
        log.info("Processing sphinx structure in {}".format(input_folder))

        root_path = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
        sphinx_config_path = os.path.join(root_path, "sphinx")
        log.info("Using config path {}".format(sphinx_config_path))

        main(input_folder, sphinx_config_path)

        exit_code = 0
    except Exception:
        log.exception("An exception was raised!")

    log.info("Exiting with code {}.".format(exit_code))
    sys.exit(exit_code)
