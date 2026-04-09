class Clk < Formula
  desc "Clock in & out of work, tracking minutes spent per day"
  homepage "https://github.com/poiurewq/scripts"
  url "https://github.com/poiurewq/scripts/archive/refs/tags/clk-v0.4.8.tar.gz"
  sha256 "f5ef4b331a14fbd4bf5eb438fb814f5580193d2ba32f002841abf63be526da4e"
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
