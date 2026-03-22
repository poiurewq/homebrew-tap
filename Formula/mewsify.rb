class Mewsify < Formula
  desc "Preprocess Markdown study notes and synthesize speech via KittenTTS"
  homepage "https://github.com/poiurewq/scripts"
  url "https://github.com/poiurewq/scripts/archive/refs/tags/mewsify-v0.1.0.tar.gz"
  sha256 "8885108b32f3b9cf96c4e4f4da5bf928ba11450db0b269ff28dfd79e52506b8b"
  license "MIT"

  depends_on "python@3.12"

  # Prevents Homebrew's linkage fixer from rewriting @rpath dylib IDs inside
  # the venv — compiled Python extensions (e.g. pydantic_core) ship with short
  # @rpath placeholders; the absolute replacement paths overflow the Mach-O
  # header and cause "Failed to fix install linkage" errors.
  skip_clean "libexec"

  def install
    venv = libexec/"venv"
    system Formula["python@3.12"].opt_bin/"python3.12", "-m", "venv", venv
    pip = venv/"bin/pip"
    system pip, "install", "--upgrade", "pip", "--quiet"
    # Install kittentts without its declared deps: misaki[en] transitively pulls
    # torch and NVIDIA CUDA packages (~700 MB on Mac, ~3 GB on Linux) that are
    # never used when clean_text=False. All actually-needed deps are declared in
    # mewsify's own pyproject.toml and installed by the second pip call.
    system pip, "install", "--no-deps",
      "https://github.com/KittenML/KittenTTS/releases/download/0.8.1/kittentts-0.8.1-py3-none-any.whl"
    system pip, "install", "mewsify/"
    bin.install_symlink libexec/"venv/bin/mewsify"
    man1.install "mewsify/mewsify.1"
  end

  test do
    assert_match "Convert a Markdown", shell_output("#{bin}/mewsify")
  end
end
