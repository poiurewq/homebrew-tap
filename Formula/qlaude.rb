class Qlaude < Formula
  desc "Claude session utilities: conversation viewer, account manager, resource lister"
  homepage "https://github.com/poiurewq/scripts"
  url "https://github.com/poiurewq/scripts/archive/refs/tags/qlaude-v0.1.1.tar.gz"
  sha256 "9f45bc875a1bc99398885e23f18eef6fab4eb5187150cfdd1538f3641760c210"
  license "MIT"

  depends_on "jq"
  depends_on "zsh" => :optional

  def install
    bin.install "qlaude/qlaude"
    man1.install "qlaude/qlaude.1"
  end

  def caveats
    <<~EOS
      qlaude stores its configuration in:
        ${XDG_CONFIG_HOME:-~/.config}/qlaude/config.zsh

      By default only the 'default' account (~/.claude) is configured.
      Add additional Claude Code accounts with:
        qlaude config add-dir <name> <basedir>

      To fully uninstall, remove the config directory after `brew uninstall qlaude`:
        rm -rf "${XDG_CONFIG_HOME:-$HOME/.config}/qlaude"
    EOS
  end

  test do
    assert_match "Claude session utilities", shell_output("#{bin}/qlaude")
  end
end
