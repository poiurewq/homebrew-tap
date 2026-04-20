class Nt < Formula
  desc "Simple indexed notes maintainer for the command line"
  homepage "https://github.com/poiurewq/scripts"
  url "https://github.com/poiurewq/scripts/archive/refs/tags/nt-v0.4.1.tar.gz"
  sha256 "e71ef9e12b95d9b5e7cd6c78389b30bf4001a7c3e009d6c68bdbe3855f9c806c"
  license "MIT"

  depends_on "zsh" => :optional

  def install
    bin.install "nt/nt"
    man1.install "nt/nt.1"
  end

  test do
    assert_match "simple notes maintainer", shell_output("#{bin}/nt -h")
  end
end
