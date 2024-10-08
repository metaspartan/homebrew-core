class AnycableGo < Formula
  desc "WebSocket server with action cable protocol"
  homepage "https://github.com/anycable/anycable-go"
  url "https://github.com/anycable/anycable-go/archive/refs/tags/v1.5.3.tar.gz"
  sha256 "f4d0ab2301199d50eb45b5123f673138cddc19a8369fbb5485b1ad8b7ec4a4f2"
  license "MIT"
  head "https://github.com/anycable/anycable-go.git", branch: "master"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "61017e120a29bc9e7302f3015962a80c700b5e4aa455ea649e94d9b90f119121"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "61017e120a29bc9e7302f3015962a80c700b5e4aa455ea649e94d9b90f119121"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "61017e120a29bc9e7302f3015962a80c700b5e4aa455ea649e94d9b90f119121"
    sha256 cellar: :any_skip_relocation, sonoma:         "65199ee86f12896df5018a0c09f46616de2cb7977791bdf0f0a19e65a549f423"
    sha256 cellar: :any_skip_relocation, ventura:        "65199ee86f12896df5018a0c09f46616de2cb7977791bdf0f0a19e65a549f423"
    sha256 cellar: :any_skip_relocation, monterey:       "65199ee86f12896df5018a0c09f46616de2cb7977791bdf0f0a19e65a549f423"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "bd9bd5fa9361b286c373fe49982eee6fe9f5ed6681ead67190bac4c517448036"
  end

  depends_on "go" => :build

  def install
    ldflags = %w[
      -s -w
    ]
    ldflags << if build.head?
      "-X github.com/anycable/anycable-go/utils.sha=#{version.commit}"
    else
      "-X github.com/anycable/anycable-go/utils.version=#{version}"
    end

    system "go", "build", *std_go_args(ldflags:), "./cmd/anycable-go"
  end

  test do
    port = free_port
    pid = fork do
      exec "#{bin}/anycable-go --port=#{port}"
    end
    sleep 1
    output = shell_output("curl -sI http://localhost:#{port}/health")
    assert_match(/200 OK/m, output)
  ensure
    Process.kill("HUP", pid)
  end
end
