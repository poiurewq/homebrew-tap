class Clk < Formula
  desc "Clock in & out of work, tracking minutes spent per day"
  homepage "https://github.com/poiurewq/scripts"
  url "https://github.com/poiurewq/scripts/archive/refs/tags/clk-v0.4.11.tar.gz"
  sha256 "f5491f6ba4ca3afacfd0c8db0094e59ba5fee391c56a3a9e796bd3fa0eafbe83"
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
