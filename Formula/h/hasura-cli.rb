class HasuraCli < Formula
  desc "Command-Line Interface for Hasura GraphQL Engine"
  homepage "https://hasura.io"
  url "https://github.com/hasura/graphql-engine/archive/refs/tags/v2.43.0.tar.gz"
  sha256 "c4dd6c1184dd8165eaa2d0eb0037aa2f283d01220921bba381d4397c61c3e40e"
  license "Apache-2.0"
  head "https://github.com/hasura/graphql-engine.git", branch: "master"

  # There can be a notable gap between when a version is tagged and a
  # corresponding release is created, so we check the "latest" release instead
  # of the Git tags.
  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "b31755ecaec474866f113ccdf2db023d7b5fb6ee9795be0842d76db978f34ca1"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "b31755ecaec474866f113ccdf2db023d7b5fb6ee9795be0842d76db978f34ca1"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "b31755ecaec474866f113ccdf2db023d7b5fb6ee9795be0842d76db978f34ca1"
    sha256 cellar: :any_skip_relocation, sonoma:         "8993aa09f66e924cb88f4e65bca8804fc9d5f085ff9181c1bced62fbffbeb769"
    sha256 cellar: :any_skip_relocation, ventura:        "8993aa09f66e924cb88f4e65bca8804fc9d5f085ff9181c1bced62fbffbeb769"
    sha256 cellar: :any_skip_relocation, monterey:       "8993aa09f66e924cb88f4e65bca8804fc9d5f085ff9181c1bced62fbffbeb769"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "33956978aedd6f2a7a937d0b7ace0b94875ded24a45dc02f28018fd76873d042"
  end

  depends_on "go" => :build
  depends_on "node@18" => :build

  def install
    arch = Hardware::CPU.intel? ? "amd64" : Hardware::CPU.arch.to_s
    os = OS.kernel_name.downcase

    # Based on `make build-cli-ext`, but only build a single host-specific binary
    cd "cli-ext" do
      # TODO: Remove `npm add pkg` when https://github.com/hasura/graphql-engine/issues/9440 is resolved.
      system "npm", "add", "pkg@5.8.1"
      system "npm", "install", *std_npm_args(prefix: false)
      system "npm", "run", "prebuild"
      dest = "./cli/internal/cliext/static-bin/#{os}/#{arch}/cli-ext"
      system "npx", "pkg", "./build/command.js", "--output", dest, "-t", "host"
    end

    ldflags = %W[
      -s -w
      -X github.com/hasura/graphql-engine/cli/v2/version.BuildVersion=#{version}
      -X github.com/hasura/graphql-engine/cli/v2/plugins.IndexBranchRef=master
    ]
    cd "cli" do
      system "go", "build", *std_go_args(output: bin/"hasura", ldflags:), "./cmd/hasura/"
    end

    generate_completions_from_executable(bin/"hasura", "completion", base_name: "hasura", shells: [:bash, :zsh])
  end

  test do
    system bin/"hasura", "init", "testdir"
    assert_predicate testpath/"testdir/config.yaml", :exist?
  end
end
