class Dynamo < Formula
  desc "Battery charge limiter and power monitor for Apple Silicon Macs"
  homepage "https://github.com/arshdwani/Dynamo"
  url "https://github.com/arshdwani/Dynamo/archive/refs/tags/v1.7.tar.gz"
  sha256 "9100087c782ea630ea75bcd42b7cb9647aa5ca02ce333506e2915dc1654fadc5"
  license "MIT"

  depends_on arch: :arm64
  depends_on macos: :ventura

  def install
    system "./build.sh"
    # Keep the built service, app and scripts together; dynamo-setup copies them into place.
    libexec.install "build", "install.sh", "uninstall.sh", "Resources"

    (bin/"dynamo-setup").write <<~SH
      #!/bin/bash
      # Installs (or upgrades) the Dynamo service and app. Asks for your password.
      exec "#{opt_libexec}/install.sh" "$@"
    SH
    (bin/"dynamo-uninstall").write <<~SH
      #!/bin/bash
      # Removes the Dynamo service and app and hands charging back to macOS.
      exec "#{opt_libexec}/uninstall.sh" "$@"
    SH
  end

  def caveats
    <<~EOS
      To finish installing Dynamo (it asks for your password once), run:
        dynamo-setup

      This installs the charging service and puts Dynamo.app in /Applications.
      After `brew upgrade dynamo`, run dynamo-setup again (or use Update in the app).
    EOS
  end

  test do
    assert_match "Dynamo #{version}", shell_output("#{libexec}/build/dynamo version")
  end
end
