class Tanghulu < Formula
  desc "Run a string of timed focus/rest sessions with pop-up reminders"
  homepage "https://github.com/poiurewq/scripts"
  url "https://github.com/poiurewq/scripts/archive/refs/tags/tanghulu-v0.1.1.tar.gz"
  sha256 "4584696be07726ca5a85b2da1ba3492ef634f91ffb8c298e584ca380bbdcd448"
  license "MIT"

  depends_on "bash"
  depends_on :macos

  def install
    bin.install "tanghulu/tanghulu"
    man1.install "tanghulu/tanghulu.1"
  end

  def caveats
    <<~EOS
      tanghulu stores named blocks and config in:
        ${XDG_CONFIG_HOME:-~/.config}/tanghulu/

      To fully uninstall, remove that directory after running `brew uninstall tanghulu`:
        rm -rf "${XDG_CONFIG_HOME:-$HOME/.config}/tanghulu"
    EOS
  end

  test do
    assert_match "run a string of timed", shell_output("#{bin}/tanghulu --version; #{bin}/tanghulu 2>&1 || true")
    assert_match "tanghulu", shell_output("#{bin}/tanghulu --version")
  end
end
