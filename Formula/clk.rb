class Clk < Formula
  desc "Clock in & out of work, tracking minutes spent per day"
  homepage "https://github.com/poiurewq/scripts"
  url "https://github.com/poiurewq/scripts/archive/refs/tags/clk-v0.3.6.tar.gz"
  sha256 "a0535a903b22ba45245696f0066e54e7a00b427e98f17605c7aba12a8a6ae3ff"
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
