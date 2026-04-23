class Oto < Formula
  desc "Preprocess Markdown study notes and synthesize speech via Kokoro TTS"
  homepage "https://github.com/poiurewq/oto"
  url "https://github.com/poiurewq/oto/archive/refs/tags/v0.4.0.tar.gz"
  sha256 "40df60741e879cba8892a46ab483b1761832cc7e443366443329db8e3563d9b5"
  license "MIT"

  depends_on "python@3.12"

  def oto_venv
    var/"oto/venv"
  end

  def oto_python_version
    "3.12"
  end

  def install
    # Stash the Python source package into libexec/src so post_install can
    # pip-install it after the linkage fixer has already run.
    # Standalone repo: project files are at the archive root, not nested
    # under a oto/ subdirectory like in the old monorepo tarball.
    (libexec/"src/oto").install Dir["*"]
    man1.install libexec/"src/oto/oto.1"

    # Write a wrapper now so it exists when Homebrew's link pass runs
    # (link happens after install but before post_install). The venv
    # entry point it delegates to is created later by post_install.
    espeak_pkg = oto_venv/"lib/python#{oto_python_version}/site-packages/espeakng_loader"
    (bin/"oto").write <<~SH
      #!/bin/bash
      export PHONEMIZER_ESPEAK_LIBRARY="#{espeak_pkg}/libespeak-ng.dylib"
      export ESPEAK_DATA_PATH="#{espeak_pkg}"
      export DO_NOT_TRACK=1
      exec "#{oto_venv}/bin/oto" "$@"
    SH
    (bin/"oto").chmod 0755
  end

  # Build the venv in post_install so it doesn't exist when Homebrew's
  # linkage fixer runs (between install and post_install). Compiled Python
  # extensions (e.g. pydantic_core) carry short @rpath dylib IDs that
  # overflow the Mach-O header when the fixer tries to rewrite them to
  # absolute paths.
  #
  # The venv lives in var/oto/venv/ (persistent across upgrades) so that
  # patch releases only need to reinstall the oto package itself (~3s)
  # instead of recreating the entire environment (~60s).
  def post_install
    py = Formula["python@3.12"].opt_bin/"python#{oto_python_version}"
    venv = oto_venv
    pip = venv/"bin/pip"
    site_packages = venv/"lib/python#{oto_python_version}/site-packages"

    # Detect if we need a full rebuild: no venv, or Python version changed.
    venv_python = venv/"bin/python#{oto_python_version}"
    needs_full_install = !venv_python.exist? || !venv_python.executable?

    if needs_full_install
      ohai "Setting up oto's Python environment — this may take a minute..."
      # Remove stale venv if Python version changed
      venv.rmtree if venv.exist?
      system py, "-m", "venv", venv
      system pip, "install", "--upgrade", "pip", "--quiet"
    else
      ohai "Upgrading oto (reusing existing Python environment)..."
    end

    # Always (re)install the oto package — this is the only part that changes
    # between releases. kokoro-onnx and its deps are declared in pyproject.toml
    # and installed cleanly (no --no-deps hacks needed).
    system pip, "install", "--upgrade", "--force-reinstall", "--no-deps",
      libexec/"src/oto"
    # Re-install oto's own deps in case they changed (pip is fast when
    # requirements are already satisfied).
    system pip, "install", libexec/"src/oto", "--quiet"

    if needs_full_install
      # Strip packages that are not needed at runtime to cut install size.
      # - sympy/mpmath: onnxruntime dep, only used for symbolic optimization
      # - setuptools: not needed after install (keep pip for upgrades)
      ohai "Cleaning up unnecessary packages..."
      system pip, "uninstall", "-y", "--quiet",
        "sympy", "mpmath",
        "setuptools"
    end
  end

  def caveats
    <<~EOS
      oto leaves three directories that are NOT removed by `brew uninstall`:

        #{oto_venv}
          Python environment (persists across upgrades for speed)

        ~/.config/oto/
          User preferences (model, voice, playback settings)

        ~/.cache/oto/models/
          Kokoro model files (downloaded on first use)

      To fully remove oto:
        brew uninstall oto
        rm -rf #{oto_venv}
        rm -rf ~/.config/oto
        rm -rf ~/.cache/oto
    EOS
  end

  test do
    assert_match "Convert a Markdown", shell_output("#{bin}/oto")
  end
end
