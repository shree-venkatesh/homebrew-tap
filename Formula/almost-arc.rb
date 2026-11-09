class AlmostArc < Formula
  desc "Make Zen Browser look and behave like Arc"
  homepage "https://github.com/shree-venkatesh/Almost-Arc"
  url "https://github.com/shree-venkatesh/Almost-Arc/archive/refs/tags/v1.1.2.tar.gz"
  sha256 "cc441f2564352c1f3aad60d87f6ae903703d43d3510f2471f2ba9eaca1db6655"
  license "MPL-2.0"

  def install
    libexec.install Dir["*"]
    (bin/"almost-arc").write <<~SH
      #!/bin/bash
      # almost-arc: installs Almost Arc into your Zen profile (Homebrew wrapper).
      set -euo pipefail
      case "${1:-}" in
        install)
          shift
          if [ -d "$HOME/.almost-arc" ]; then
            echo "Almost Arc is already installed with the curl installer (~/.almost-arc)."
            echo "Either keep using that and remove this one:"
            echo
            echo "  brew uninstall almost-arc"
            echo
            echo "or remove the curl install first (/usr/local/bin/almost-arc uninstall),"
            echo "then run 'almost-arc install' again."
            exit 1
          fi
          exec "#{libexec}/install.sh" "$@" ;;
        update|upgrade)
          shift
          "#{HOMEBREW_PREFIX}/bin/brew" update
          "#{HOMEBREW_PREFIX}/bin/brew" upgrade almost-arc
          # run the newly installed version's wrapper
          exec "#{HOMEBREW_PREFIX}/bin/almost-arc" install "$@" ;;
        uninstall) shift; exec "#{libexec}/uninstall.sh" "$@" ;;
        -v|--version|version) echo "almost-arc #{version}" ;;
        *)
          echo "Usage: almost-arc <command>"
          echo
          echo "  install     Install Almost Arc into Zen again, e.g. after a Zen update (quit Zen first)"
          echo "  update      Get the latest Almost Arc from Homebrew and install it (quit Zen first)"
          echo "  uninstall   Remove Almost Arc from your Zen profile"
          echo "  --version   Print the installed version"
          [ -z "${1:-}" ] || [ "$1" = "help" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ] || exit 1
          ;;
      esac
    SH
    chmod 0755, bin/"almost-arc"
  end

  def caveats
    <<~EOS
      Homebrew only downloads Almost Arc. To put it into Zen, quit Zen and run:
        almost-arc install

      Later, `almost-arc update` gets the newest Almost Arc and installs it.
      Run `almost-arc install` again after every Zen update
      (Zen updates remove the script loader).
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/almost-arc --version")
  end
end
