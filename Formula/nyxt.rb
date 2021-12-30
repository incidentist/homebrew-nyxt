class Nyxt < Formula
    version "2.2.3"
    desc "Nyxt - the internet on your terms."
    homepage "https://nyxt.atlas.engineer"
    # Use a git checkout because the build script checks out submodules
    url "https://github.com/atlas-engineer/nyxt.git", using: :git, tag: '2.2.3'
    license "BSD-3-Clause"
  
    depends_on "sbcl" => :build
    depends_on "libfixposix"
    depends_on "webkitgtk"
  
    patch do
      url "https://github.com/atlas-engineer/nyxt/commit/6184884b48b7cacdc51d104cb2299c26437a73d8.diff"
    end
  
    def install
      # ENV.deparallelize  # if your formula fails when building in parallel
      # Remove unrecognized options if warned by configure
      # https://rubydoc.brew.sh/Formula.html#std_configure_args-instance_method
      system "make nyxt"
      system "make app-bundle"
      bin.install "Nyxt.app"
    end
  
    test do
      # `test do` will create, run in and delete a temporary directory.
      #
      # This test will fail and we won't accept that! For Homebrew/homebrew-core
      # this will need to be a test that verifies the functionality of the
      # software. Run the test with `brew test nyxt`. Options passed
      # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
      #
      # The installed folder is not in the path, so use the entire path to any
      # executables being tested: `system "#{bin}/program", "do", "something"`.
      system "false"
    end
  end
  