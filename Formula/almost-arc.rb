class AlmostArc < Formula
  desc "Make Zen Browser look and behave like Arc"
  homepage "https://github.com/shree-venkatesh/Almost-Arc"
  url "https://github.com/shree-venkatesh/Almost-Arc/archive/refs/tags/v1.1.4.tar.gz"
  sha256 "be783d33f069c1d0487bd0845ed272e39bc951e16370c6aad7e8332cb7a9aa2d"
  license "MPL-2.0"

  def install
    libexec.install Dir["*"]
    (bin/"almost-arc").write <<~SH
      #!/bin/bash
      # almost-arc: installs Almost Arc into your Zen profile (Homebrew wrapper).
      set -euo pipefail

      # --beta: install the newest vX.Y.Z tag straight from GitHub. Tags that never
      # became a Release (and so never reached Homebrew) are the beta channel.
      beta_install() {
        local repo="shree-venkatesh/Almost-Arc" tag tmp
        # (no backslashes: this text goes through a Ruby heredoc)
        tag="$(curl -fsSL "https://api.github.com/repos/$repo/tags?per_page=100" |
          grep -o '"name": *"v[0-9]*[.][0-9]*[.][0-9]*"' | grep -o 'v[0-9.]*' |
          sed 's/^v//' | sort -t. -k1,1n -k2,2n -k3,3n | tail -n 1)" || true
        [ -n "$tag" ] || { echo "Couldn't find the latest tag on GitHub." >&2; exit 1; }
        tmp="$(mktemp -d)"
        trap "rm -rf '$tmp'" EXIT
        echo "Downloading Almost Arc $tag (beta)..."
        # the release file (counted downloads), else GitHub's source archive
        curl -fsSL "https://github.com/$repo/releases/download/v$tag/almost-arc-$tag.tar.gz" -o "$tmp/a.tar.gz" 2>/dev/null ||
          curl -fsSL "https://github.com/$repo/archive/refs/tags/v$tag.tar.gz" -o "$tmp/a.tar.gz"
        mkdir "$tmp/app"
        tar -xzf "$tmp/a.tar.gz" -C "$tmp/app" --strip-components 1
        "$tmp/app/install.sh"
        echo
        echo "You're on the beta ($tag). 'almost-arc install' (without --beta) goes back"
        echo "to the Homebrew version, #{version}."
      }

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
          if [ "${1:-}" = --beta ]; then beta_install; exit; fi
          exec "#{libexec}/install.sh" "$@" ;;
        update|upgrade)
          shift
          "#{HOMEBREW_PREFIX}/bin/brew" update
          "#{HOMEBREW_PREFIX}/bin/brew" upgrade almost-arc
          # run the newly installed version's wrapper (passes --beta through)
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
          echo
          echo "  --beta      With install or update: use the newest tagged version, which may"
          echo "              not be in Homebrew yet. A plain 'install' goes back to Homebrew's."
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
