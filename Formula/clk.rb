class Clk < Formula
  desc "Clock in & out of work, tracking minutes spent per day"
  homepage "https://github.com/poiurewq/scripts"
  url "https://github.com/poiurewq/scripts/archive/refs/tags/clk-v0.3.3.tar.gz"
  sha256 "7e58f43280abfce708be0a8bb7d53fc947533db89568ad4e9aa8d360e856fd0f"
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
