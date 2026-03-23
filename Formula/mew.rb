class Mew < Formula
  desc "Preprocess Markdown study notes and synthesize speech via KittenTTS"
  homepage "https://github.com/poiurewq/scripts"
  url "https://github.com/poiurewq/scripts/archive/refs/tags/mew-v0.1.4.tar.gz"
  sha256 "592564d5bf6173ca394199bb0b8778f70d97172c4682175b35375c32d96ff275"
  license "MIT"

  depends_on "python@3.12"

  def mew_venv
    var/"mew/venv"
  end

  def mew_python_version
    "3.12"
  end

  def install
    # Stash the Python source package into libexec/src so post_install can
    # pip-install it after the linkage fixer has already run.
    (libexec/"src").install "mew"
    man1.install libexec/"src/mew/mew.1"

    # Write a wrapper now so it exists when Homebrew's link pass runs
    # (link happens after install but before post_install). The venv
    # entry point it delegates to is created later by post_install.
    espeak_pkg = mew_venv/"lib/python#{mew_python_version}/site-packages/espeakng_loader"
    (bin/"mew").write <<~SH
      #!/bin/bash
      export PHONEMIZER_ESPEAK_LIBRARY="#{espeak_pkg}/libespeak-ng.dylib"
      export ESPEAK_DATA_PATH="#{espeak_pkg}"
      export HF_HUB_DISABLE_TELEMETRY=1
      export DO_NOT_TRACK=1
      export PYTHONWARNINGS="ignore::UserWarning:huggingface_hub"
      exec "#{mew_venv}/bin/mew" "$@"
    SH
    (bin/"mew").chmod 0755
  end

  # Build the venv in post_install so it doesn't exist when Homebrew's
  # linkage fixer runs (between install and post_install). Compiled Python
  # extensions (e.g. pydantic_core) carry short @rpath dylib IDs that
  # overflow the Mach-O header when the fixer tries to rewrite them to
  # absolute paths.
  #
  # The venv lives in var/mew/venv/ (persistent across upgrades) so that
  # patch releases only need to reinstall the mew package itself (~3s)
  # instead of recreating the entire environment (~60s).
  def post_install
    py = Formula["python@3.12"].opt_bin/"python#{mew_python_version}"
    venv = mew_venv
    pip = venv/"bin/pip"
    site_packages = venv/"lib/python#{mew_python_version}/site-packages"

    # Detect if we need a full rebuild: no venv, or Python version changed.
    venv_python = venv/"bin/python#{mew_python_version}"
    needs_full_install = !venv_python.exist? || !venv_python.executable?

    if needs_full_install
      ohai "Setting up mew's Python environment — this may take a minute..."
      # Remove stale venv if Python version changed
      venv.rmtree if venv.exist?
      system py, "-m", "venv", venv
      system pip, "install", "--upgrade", "pip", "--quiet"
      # Install kittentts without its declared deps: misaki[en] transitively
      # pulls torch and NVIDIA CUDA packages (~700 MB on Mac, ~3 GB on Linux)
      # that are never used when clean_text=False. All actually-needed deps
      # are declared in mew's own pyproject.toml.
      system pip, "install", "--no-deps",
        "https://github.com/KittenML/KittenTTS/releases/download/0.8.1/kittentts-0.8.1-py3-none-any.whl"
      # kittentts imports misaki at the top of onnx_model.py but never uses it
      # (phonemization uses phonemizer.backend.EspeakBackend instead). Remove
      # the dead import so we don't need misaki and its heavy deps (torch, CUDA).
      inreplace site_packages/"kittentts/onnx_model.py",
                "from misaki import en, espeak\n", ""
      # Suppress kittentts's "Generating audio for text: ..." print
      inreplace site_packages/"kittentts/get_model.py",
                'print(f"Generating audio for text: {text}")', ""
    else
      ohai "Upgrading mew (reusing existing Python environment)..."
    end

    # Always (re)install the mew package — this is the only part that changes
    # between releases.
    system pip, "install", "--upgrade", "--force-reinstall", "--no-deps",
      libexec/"src/mew"
    # Re-install mew's own deps in case they changed (pip is fast when
    # requirements are already satisfied).
    system pip, "install", libexec/"src/mew", "--quiet"

    if needs_full_install
      # Strip packages that are not needed at runtime to cut install size.
      # - sympy/mpmath: onnxruntime dep, only used for symbolic optimization
      # - spacy + ecosystem: kittentts declares it but never imports it
      # - babel/rdflib/csvw: transitive via phonemizer→segments→csvw
      # - setuptools: not needed after install (keep pip for upgrades)
      # - pygments: transitive via rich→spacy chain
      ohai "Cleaning up unnecessary packages (~190MB)..."
      # Patch phonemizer to not import SegmentsBackend (which pulls in
      # segments → csvw → babel, ~40MB we don't need). We only use EspeakBackend.
      inreplace site_packages/"phonemizer/backend/__init__.py",
                "from .segments import SegmentsBackend", ""
      inreplace site_packages/"phonemizer/backend/__init__.py",
                "EspeakBackend, FestivalBackend, SegmentsBackend, EspeakMbrolaBackend",
                "EspeakBackend, FestivalBackend, EspeakMbrolaBackend"
      system pip, "uninstall", "-y", "--quiet",
        "sympy", "mpmath",
        "spacy", "thinc", "blis", "srsly", "preshed", "cymem", "murmurhash",
        "spacy-legacy", "spacy-loggers", "confection", "weasel", "smart-open",
        "cloudpathlib",
        "segments", "csvw", "babel", "rdflib", "language-tags", "isodate",
        "regex",
        "pygments",
        "setuptools"
    end
  end

  def caveats
    <<~EOS
      mew's Python environment is stored in:
        #{mew_venv}

      It persists across upgrades for speed. To remove it completely:
        rm -rf #{mew_venv}
    EOS
  end

  test do
    assert_match "Convert a Markdown", shell_output("#{bin}/mew")
  end
end
