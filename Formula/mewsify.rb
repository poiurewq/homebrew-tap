class Mewsify < Formula
  desc "Preprocess Markdown study notes and synthesize speech via KittenTTS"
  homepage "https://github.com/poiurewq/scripts"
  url "https://github.com/poiurewq/scripts/archive/refs/tags/mewsify-v0.1.0.tar.gz"
  sha256 "8885108b32f3b9cf96c4e4f4da5bf928ba11450db0b269ff28dfd79e52506b8b"
  license "MIT"

  depends_on "python@3.12"

  def install
    # Stash the Python source package into libexec/src so post_install can
    # pip-install it after the linkage fixer has already run.
    (libexec/"src").install "mewsify"
    man1.install libexec/"src/mewsify/mewsify.1"
  end

  # Build the venv in post_install so it doesn't exist when Homebrew's
  # linkage fixer runs (between install and post_install). Compiled Python
  # extensions (e.g. pydantic_core) carry short @rpath dylib IDs that
  # overflow the Mach-O header when the fixer tries to rewrite them to
  # absolute paths.
  def post_install
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
    # kittentts imports misaki at the top of onnx_model.py but never uses it
    # (phonemization uses phonemizer.backend.EspeakBackend instead). Remove the
    # dead import so we don't need misaki and its heavy deps (torch, CUDA).
    inreplace venv/"lib/python3.12/site-packages/kittentts/onnx_model.py",
              "from misaki import en, espeak\n", ""
    system pip, "install", libexec/"src/mewsify"
    bin.install_symlink libexec/"venv/bin/mewsify"
  end

  test do
    assert_match "Convert a Markdown", shell_output("#{bin}/mewsify")
  end
end
