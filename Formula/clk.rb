class Clk < Formula
  desc "Clock in & out of work, tracking minutes spent per day"
  homepage "https://github.com/poiurewq/scripts"
  url "https://github.com/poiurewq/scripts/archive/refs/tags/clk-v0.3.8.tar.gz"
  sha256 "169ddee3350c43f505f86ebf4baa50f9f2a0d66f533a9daee9880381909e6541"
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

      To fully uninstall, remove that directory after running `brew uninstall clk`:
        rm -rf "${XDG_DATA_HOME:-$HOME/.local/share}/clk"
    EOS
  end

  test do
    assert_match "clock in & out of work", shell_output("#{bin}/clk help")
  end
end
