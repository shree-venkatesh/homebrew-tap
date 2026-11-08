class AlmostArc < Formula
  desc "Make Zen Browser look and behave like Arc"
  homepage "https://github.com/shree-venkatesh/Almost-Arc"
  url "https://github.com/shree-venkatesh/Almost-Arc/archive/refs/tags/v1.0.1.tar.gz"
  sha256 "48d8478ed4e5711344fe84e7a16991a41854c0e3654a80fb74fffc8adc5d05e8"
  license "MPL-2.0"

  def install
    libexec.install Dir["*"]
    (bin/"almost-arc").write <<~SH
      #!/bin/bash
      # almost-arc: installs Almost Arc into your Zen profile (Homebrew wrapper).
      set -euo pipefail
      case "${1:-}" in
        install)   shift; exec "#{libexec}/install.sh" "$@" ;;
        uninstall) shift; exec "#{libexec}/uninstall.sh" "$@" ;;
        -v|--version|version) echo "almost-arc #{version}" ;;
        *)
          echo "Usage: almost-arc <command>"
          echo
          echo "  install     Install or update Almost Arc in Zen (quit Zen first)"
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

      Run it again after `brew upgrade almost-arc` and after every Zen update
      (Zen updates remove the script loader).
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/almost-arc --version")
  end
end
