class Clk < Formula
  desc "Clock in & out of work, tracking minutes spent per day"
  homepage "https://github.com/poiurewq/scripts"
  url "https://github.com/poiurewq/scripts/archive/refs/tags/clk-v0.5.1.tar.gz"
  sha256 "2da55817d77c65f1dd922268bf1ae02b186cfe3dd600d5c0c0011a17c0ecc28a"
  license "MIT"

  depends_on "bash"

  def install
    bin.install "clk/clk"
    man1.install "clk/clk.1"
  end

  def caveats
    <<~EOS
      clk stores its log data in:
        ${XDG_DATA_HOME:-~/.local/share}/clk/

      clk caches upgrade-check data in:
        ${XDG_CACHE_HOME:-~/.cache}/clk/

      To fully uninstall, remove both directories after running `brew uninstall clk`:
        rm -rf "${XDG_DATA_HOME:-$HOME/.local/share}/clk"
        rm -rf "${XDG_CACHE_HOME:-$HOME/.cache}/clk"
    EOS
  end

  test do
    assert_match "clock in & out of work", shell_output("#{bin}/clk help")
  end
end
