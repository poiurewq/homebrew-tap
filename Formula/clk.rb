class Clk < Formula
  desc "Clock in & out of work, tracking minutes spent per day"
  homepage "https://github.com/poiurewq/scripts"
  url "https://github.com/poiurewq/scripts/archive/refs/tags/clk-v0.3.2.tar.gz"
  sha256 "06487fa165e91936e26b0b0f661259f86504b44b7cf7992beb8b4d68a603543a"
  license "MIT"

  depends_on "bash"

  def install
    bin.install "clk/clk"
    man1.install "clk/clk.1"
  end

  test do
    assert_match "clock in & out of work", shell_output("#{bin}/clk help")
  end
end
