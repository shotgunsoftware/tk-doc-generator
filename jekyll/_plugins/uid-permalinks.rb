# Copyright 2019 Autodesk, Inc.  All rights reserved.
#
# Use of this software is subject to the terms of the Autodesk license agreement
# provided at the time of installation or download, or which otherwise accompanies
# this software in either electronic or hard copy form.
#

# Error raised when two page UIDs collide, meaning two different pages will
# have the same URL.  This can happen when two pages have the same pagename, or
# (in a very unlikely case) when two hashes generator for different pagenames
# are the same.
class PageUIDCollisionException < StandardError
  def initialize(msg="Page UID hashes collided.  This can be caused by "\
    "duplicate pagenames, or (very very rarely) by two pagenames hashing "\
    "to the same value.")
    super(msg)
  end
end

module Jekyll

    # Modify Jekyll's Page class to expose URL for PermalinkRewriter.
    class Page
        # Assignment method to expose URL so that we can modify page URLs from
        # our Generator.
        def url=(name)
            @url = name
        end
    end

    # Generator plugin that rewrites page permalinks and URLs at build to use
    # static UIDs for pages, based on the pagename field in the page slug.
    # This way page UIDs can be trusted to remain unchanged, even if page title
    # or location in the TOC changes.
    class PermalinkRewriter < Jekyll::Generator
        safe true
        # Set priority to highest, since we're rewriting page URLs and other
        # plugins depend on these URLs during generation.
        priority :highest

        def generate(site)
            # We'll keep track of the consumed hashes so we can detect a
            # collision.
            consumed_hashes = []
            site.pages.each do |item|
                if item.data["pagename"]
                    # We'll generate UID urls for all pages with a pagename
                    # field in their slug.
                    pagename = item.data["pagename"].to_s
                    if pagename == "index"
                        # Special case for root index -- we want it to sit at /,
                        # not under a hash.
                        item.data["permalink"] = "/"
                        item.url = "/"
                    else
                        # Generate a hash from the pagename and truncate to 8
                        # characters for better usability.
                        uid = Digest::SHA1.hexdigest(pagename)[0..7]
                        # If hashes collide, raise an exception.
                        # The likelyhood of a collision with SHA1 truncated to
                        # 8 chars is very small (around 1 in 1 million,
                        # see https://stackoverflow.com/questions/51622061).
                        # If it becomes a problem we could do something here
                        # to deal with it, however it wouldn't be as simple as
                        # say shifting the window on the hash, since existing
                        # URIs can't change when a new page is added that
                        # collides.
                        p "[PermalinkRewriter#generate] DEBUG ITEM #{item.data}"
                        p "[PermalinkRewriter#generate] DEBUG PAGENAME #{pagename}"
                        p "[PermalinkRewriter#generate] DEBUG UID #{uid}"
                        p "[PermalinkRewriter#generate] DEBUG CONSUMED HASHES #{consumed_hashes}"
                        if consumed_hashes.include? uid
                            raise PageUIDCollisionException.new "PAGENAME: #{pagename}"
                        end
                        consumed_hashes << uid
                        # Copy the site config permalink to use on this page,
                        # and replace the UID key with the generated UID.
                        url = site.config["permalink"].dup
                        url = url.gsub! ":uid", uid
                        item.data["permalink"] = url
                        item.url = url
                    end
                end
            end
        end
    end
end
