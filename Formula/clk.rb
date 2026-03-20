class Clk < Formula
  desc "Clock in & out of work, tracking minutes spent per day"
  homepage "https://github.com/poiurewq/scripts"
  url "https://github.com/poiurewq/scripts/archive/refs/tags/clk-v0.3.1.tar.gz"
  sha256 "4940a90cc2227fde502553399a24302e1d9b70bfdeec06f799c9fe33688d2cdd"
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
